#!/bin/bash

source "$(dirname "$0")/../scripts/utils.sh"

# Finder sidebar favorites. macOS stores these in the SharedFileList framework, which
# `defaults` can't touch — so this uses the mysides cask (installed via `make brew`).
# Rebuilds the Favorites list top-to-bottom in a fixed order.
configure_finder_sidebar() {
    if ! command -v mysides >/dev/null 2>&1; then
        warning "mysides not installed — skipping Finder sidebar favorites (run 'make brew', then re-run 'make macos')"
        return 0
    fi

    info "Setting Finder sidebar favorites..."
    mkdir -p "$HOME/Dev" "$HOME/Videos"

    # Clear existing favorites, then add ours in order.
    local name
    while IFS= read -r name; do
        [ -n "$name" ] && mysides remove "$name" >/dev/null 2>&1 || true
    done <<<"$(mysides list 2>/dev/null | sed 's/ -> .*//')"

    mysides add Applications "file:///Applications/" >/dev/null
    mysides add Downloads "file://$HOME/Downloads/" >/dev/null
    mysides add Documents "file://$HOME/Documents/" >/dev/null
    mysides add Desktop "file://$HOME/Desktop/" >/dev/null
    mysides add Dev "file://$HOME/Dev/" >/dev/null
    mysides add Pictures "file://$HOME/Pictures/" >/dev/null
    mysides add Videos "file://$HOME/Videos/" >/dev/null
    mysides add Movies "file://$HOME/Movies/" >/dev/null
    mysides add Music "file://$HOME/Music/" >/dev/null

    killall Finder >/dev/null 2>&1 || true
    task "Set Finder sidebar favorites"
}

configure_finder_sidebar_settings() {
    local marker="$HOME/.config/dotfiles/finder-sidebar-settings-applied"

    defaults write com.apple.finder SidebarShowRecents -bool false

    if [ -f "$marker" ]; then
        task "Finder sidebar sections already configured"
        return 0
    fi

    info "Hiding Finder sidebar clutter..."
    info "If prompted, allow your terminal to control Finder/System Events, then rerun 'make macos'"

    if ! osascript <<'APPLESCRIPT'; then
tell application "Finder" to activate
delay 0.2

tell application "System Events"
    tell process "Finder"
        set frontmost to true
        exists menu bar 1
    end tell
end tell
APPLESCRIPT
        warning "Finder sidebar cleanup needs Accessibility access; grant it and rerun 'make macos'"
        return 0
    fi

    if osascript <<'APPLESCRIPT'; then
on set_sidebar_checkbox(area, checkboxDescription, desiredValue)
    tell application "System Events"
        tell area
            repeat with itemCheckbox in checkboxes
                try
                    if description of itemCheckbox is checkboxDescription then
                        repeat 3 times
                            if (value of itemCheckbox as integer) is desiredValue then return true
                            click itemCheckbox
                            delay 0.1
                        end repeat

                        return ((value of itemCheckbox as integer) is desiredValue)
                    end if
                end try
            end repeat
        end tell
    end tell

    return true
end set_sidebar_checkbox

tell application "Finder" to activate
delay 0.5

tell application "System Events"
    tell process "Finder"
        set frontmost to true
        click menu item "Settings…" of menu 1 of menu bar item "Finder" of menu bar 1

        repeat 30 times
            if exists window "Finder Settings" then exit repeat
            delay 0.1
        end repeat

        set win to window "Finder Settings"
        set position of win to {20, 100}
        perform action "AXRaise" of win
        delay 0.3
        click button "Sidebar" of toolbar 1 of win
        delay 0.3

        set sidebarArea to scroll area 1 of win
        set labelsToHide to {"Recents", "Shared", "Cloud Storage", "Managed’s Virtual Machine", "Macintosh HD", "Hard disks", "External disks", "CDs, DVDs, and iOS Devices"}
        set failedLabels to {}

        repeat with sidebarLabel in labelsToHide
            if not my set_sidebar_checkbox(sidebarArea, sidebarLabel as text, 0) then
                set end of failedLabels to sidebarLabel as text
            end if
        end repeat

        if (count of failedLabels) is greater than 0 then
            error "Could not hide Finder sidebar items: " & failedLabels
        end if

        try
            click button 1 of win
        end try
    end tell
end tell
APPLESCRIPT
        mkdir -p "$(dirname "$marker")"
        touch "$marker"
        task "Hid Finder sidebar clutter"
    else
        warning "Finder sidebar cleanup needs Accessibility access; grant it and rerun 'make macos'"
    fi
}

configure_finder_view_settings() {
    local template="$(dirname "$0")/finder-view-settings.json"
    local finder_preferences
    local desktop_settings list_settings extended_list_settings

    if [ ! -f "$template" ]; then
        warning "Finder view settings template not found"
        return 1
    fi

    finder_preferences=$(mktemp)
    if ! defaults export com.apple.finder "$finder_preferences" >/dev/null 2>&1; then
        plutil -create xml1 "$finder_preferences"
    fi

    desktop_settings=$(plutil -extract DesktopViewSettings json -o - "$template")
    list_settings=$(plutil -extract ListViewSettings json -o - "$template")
    extended_list_settings=$(plutil -extract ExtendedListViewSettingsV2 json -o - "$template")

    plutil -remove DesktopViewSettings "$finder_preferences" >/dev/null 2>&1 || true
    plutil -insert DesktopViewSettings -json "$desktop_settings" "$finder_preferences"

    local settings_key
    for settings_key in StandardViewSettings FK_StandardViewSettings; do
        if ! plutil -type "$settings_key" "$finder_preferences" >/dev/null 2>&1; then
            plutil -insert "$settings_key" -dictionary "$finder_preferences"
        fi

        plutil -remove "$settings_key.ListViewSettings" "$finder_preferences" >/dev/null 2>&1 || true
        plutil -insert "$settings_key.ListViewSettings" -json "$list_settings" "$finder_preferences"
        plutil -remove "$settings_key.ExtendedListViewSettingsV2" "$finder_preferences" >/dev/null 2>&1 || true
        plutil -insert "$settings_key.ExtendedListViewSettingsV2" -json "$extended_list_settings" "$finder_preferences"
        plutil -remove "$settings_key.SettingsType" "$finder_preferences" >/dev/null 2>&1 || true
        plutil -insert "$settings_key.SettingsType" -string "$settings_key" "$finder_preferences"
    done

    defaults import com.apple.finder "$finder_preferences" >/dev/null
    rm -f "$finder_preferences"
    task "Matched Finder desktop and list view layout"
}

configure_login_items() {
    local app_paths=(
        "/Applications/Alfred 5.app"
        "/Applications/Moom.app"
        "/Applications/Mos.app"
        "/Applications/SensibleSideButtons.app"
        "/Applications/Shottr.app"
        "/Applications/Superkey.app"
    )
    local app_path configured=0

    info "Configuring Login Items..."
    for app_path in "${app_paths[@]}"; do
        [ -d "$app_path" ] || continue

        if osascript - "$app_path" <<'APPLESCRIPT'; then
on run argv
    set appPath to item 1 of argv

    tell application "System Events"
        set matchingItems to every login item whose path is appPath
        if (count of matchingItems) is 0 then
            make login item at end with properties {path:appPath, hidden:false}
        else
            set hidden of item 1 of matchingItems to false
        end if
    end tell
end run
APPLESCRIPT
            configured=$((configured + 1))
        else
            warning "Could not configure login item: ${app_path##*/}"
        fi
    done

    task "Configured $configured installed Login Items"
}

main() {
    case "${1:-install}" in
    uninstall)
        step "🍎 macOS preferences"
        warning "macOS defaults can't be cleanly reverted; there is no uninstall. Reset individual settings in System Settings, or use a fresh user account."
        return 0
        ;;
    esac

    step "🍎 Setting macOS preferences"

    osascript -e 'tell application "System Preferences" to quit' # Close any open System Preferences panes, to prevent them from overriding settings we're about to change

    # Keep-alive: update existing `sudo` time stamp until script has finished
    local sudo_keepalive_pid
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
    sudo_keepalive_pid=$!
    trap "pkill -P $sudo_keepalive_pid 2>/dev/null || true; kill $sudo_keepalive_pid 2>/dev/null || true" EXIT

    info "General UI/UX enhancements..."
    sudo nvram SystemAudioVolume=" " # Disable the sound effects on boot

    sudo defaults write com.apple.universalaccess reduceTransparency -bool true            # Disable transparency in the menu bar and elsewhere (requires sudo)
    defaults write NSGlobalDomain AppleHighlightColor -string "0.709800 0.835300 1.000000" # Set highlight color to blue
    set_default "NSGlobalDomain" "AppleInterfaceStyle" "string" "Dark"                     # Use dark mode
    set_default "NSGlobalDomain" "AppleInterfaceStyleSwitchesAutomatically" "bool" "false" # Keep dark mode on instead of switching automatically
    set_default "NSGlobalDomain" "NSTableViewDefaultSizeMode" "int" "2"                    # Set sidebar icon size to medium
    set_default "NSGlobalDomain" "AppleShowScrollBars" "string" "Always"                   # Always show scrollbars
    set_default "NSGlobalDomain" "NSUseAnimatedFocusRing" "bool" "false"                   # Disable the over-the-top focus ring animation
    set_default "NSGlobalDomain" "NSWindowResizeTime" "float" "0.001"                      # Increase window resize speed for Cocoa applications
    set_default "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode" "bool" "true"        # Expand save panel by default
    set_default "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode2" "bool" "true"       # Expand save panel by default
    set_default "NSGlobalDomain" "PMPrintingExpandedStateForPrint" "bool" "true"           # Expand print panel by default
    set_default "NSGlobalDomain" "PMPrintingExpandedStateForPrint2" "bool" "true"          # Expand print panel by default
    set_default "NSGlobalDomain" "NSDocumentSaveNewDocumentsToCloud" "bool" "false"        # Save to disk (not to iCloud) by default
    set_default "com.apple.print.PrintingPrefs" "QuitWhenFinished" "bool" "true"           # Automatically quit printer app once the print jobs complete
    set_default "com.apple.LaunchServices" "LSQuarantine" "bool" "false"                   # Disable the "Are you sure you want to open this application?" dialog

    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -r -domain local -domain system -domain user # Remove duplicates in the "Open With" menu

    set_default "NSGlobalDomain" "NSTextShowsControlCharacters" "bool" "true"           # Display ASCII control characters using caret notation
    set_default "com.apple.systempreferences" "NSQuitAlwaysKeepsWindows" "bool" "false" # Disable Resume system-wide
    set_default "NSGlobalDomain" "NSDisableAutomaticTermination" "bool" "true"          # Disable automatic termination of inactive apps
    set_default "com.apple.helpviewer" "DevMode" "bool" "true"                          # Set Help Viewer windows to non-floating mode

    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName # Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window

    launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null # Disable Notification Center and remove the menu bar icon

    set_default "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" "bool" "false"     # Disable automatic capitalization
    set_default "NSGlobalDomain" "NSAutomaticDashSubstitutionEnabled" "bool" "false"   # Disable smart dashes
    set_default "NSGlobalDomain" "NSAutomaticPeriodSubstitutionEnabled" "bool" "false" # Disable automatic period substitution
    set_default "NSGlobalDomain" "NSAutomaticQuoteSubstitutionEnabled" "bool" "false"  # Disable smart quotes
    set_default "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" "bool" "false" # Disable auto-correct

    info "Trackpad, mouse, keyboard, Bluetooth accessories, and input..."
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true" # Enable tap to click for this user and for the login screen
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1             # Enable tap to click for this user and for the login screen
    set_default "NSGlobalDomain" "com.apple.mouse.tapBehavior" "int" "1"                      # Enable tap to click for this user and for the login screen

    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadCornerSecondaryClick" "int" "2" # Trackpad: map bottom right corner to right-click
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadRightClick" "bool" "true"       # Trackpad: map bottom right corner to right-click
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1          # Trackpad: map bottom right corner to right-click
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true             # Trackpad: map bottom right corner to right-click

    set_default "NSGlobalDomain" "com.apple.swipescrolldirection" "bool" "true"         # Enable "natural" (Lion-style) scrolling
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40 # Increase sound quality for Bluetooth headphones/headsets
    set_default "NSGlobalDomain" "AppleKeyboardUIMode" "int" "3"                        # Enable full keyboard access for all controls

    sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true # Use scroll gesture with the Ctrl (^) modifier key to zoom
    sudo defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144 # Use scroll gesture with the Ctrl (^) modifier key to zoom
    sudo defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true  # Follow the keyboard focus while zoomed in

    set_default "NSGlobalDomain" "ApplePressAndHoldEnabled" "bool" "false" # Disable press-and-hold for keys in favor of key repeat
    set_default "NSGlobalDomain" "KeyRepeat" "int" "1"                     # Set a blazingly fast keyboard repeat rate
    set_default "NSGlobalDomain" "InitialKeyRepeat" "int" "15"             # Set a blazingly fast initial keyboard repeat rate

    defaults write NSGlobalDomain AppleLanguages -array "en-US" "en"       # Set language and text formats (US English example)
    defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD" # Set language and text formats (US English example)
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"   # Set language and text formats (US English example)
    defaults write NSGlobalDomain AppleMetricUnits -bool false             # Set language and text formats (US English example)

    sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true # Show language menu in the top right corner of the boot screen

    info "Energy saving settings..."
    sudo pmset -a lidwake 1          # Enable lid wakeup
    sudo pmset -a autorestart 1      # Restart automatically on power loss
    sudo pmset -a displaysleep 0     # Never sleep the display
    sudo pmset -c sleep 0            # Never sleep the machine when on charger
    sudo pmset -b sleep 0            # Never sleep the machine when on battery
    sudo pmset -a standbydelay 86400 # Set standby delay to 24 hours (default is 1 hour)
    sudo pmset -a hibernatemode 0    # Disable hibernation (speeds up entering sleep mode)
    sudo pmset -b lowpowermode 0     # Disable low power mode on battery

    info "Screen settings..."
    set_default "com.apple.screensaver" "askForPassword" "int" "1"              # Require password immediately after sleep or screen saver begins
    set_default "com.apple.screensaver" "askForPasswordDelay" "int" "0"         # Require password immediately after sleep or screen saver begins
    set_default "com.apple.screencapture" "location" "string" "${HOME}/Desktop" # Save screenshots to the desktop
    set_default "com.apple.screencapture" "type" "string" "png"                 # Save screenshots in PNG format
    set_default "com.apple.screencapture" "disable-shadow" "bool" "true"        # Disable shadow in screenshots
    set_default "NSGlobalDomain" "AppleFontSmoothing" "int" "1"                 # Enable subpixel font rendering on non-Apple LCDs
    defaults write com.apple.ncprefs dnd_prefs -dict dndDisplayLock -bool true  # Don't show notifications when screen is locked

    local black_wallpaper="/System/Library/Desktop Pictures/Solid Colors/Black.png"
    if [ -f "$black_wallpaper" ]; then
        if osascript \
            -e 'tell application "System Events"' \
            -e 'tell every desktop' \
            -e "set picture to \"$black_wallpaper\"" \
            -e 'end tell' \
            -e 'end tell' >/dev/null; then
            task "Set desktop background to solid black"
        else
            warning "Could not set desktop background; grant System Events access and rerun 'make macos'"
        fi
    else
        warning "Solid black desktop background not found"
    fi

    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true # Enable HiDPI display modes (requires restart)

    info "Configuring Finder..."
    set_default "com.apple.finder" "QuitMenuItem" "bool" "true"         # Finder: allow quitting via ⌘ + Q
    set_default "com.apple.finder" "DisableAllAnimations" "bool" "true" # Finder: disable window animations and Get Info animations

    defaults write com.apple.finder NewWindowTarget -string "PfDe"                        # Set Desktop as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/" # Set Desktop as the default location for new Finder windows

    # Create ~/Dev folder if it doesn't exist
    if [ ! -d "${HOME}/Dev" ]; then
        mkdir -p "${HOME}/Dev"
        info "Created ~/Dev folder"
    fi

    # Configure Finder sidebar visibility
    set_default "com.apple.finder" "SidebarDevicesSectionDisclosedState" "bool" "true" # Show Locations section
    set_default "com.apple.finder" "SidebarPlacesSectionDisclosedState" "bool" "true"  # Show Favorites section
    set_default "com.apple.finder" "SidebarSharedSectionDisclosedState" "bool" "true"  # Show Shared section
    set_default "com.apple.finder" "SidebarTagsSectionDisclosedState" "bool" "false"   # Hide Tags section (can be enabled if needed)

    # Show sidebar by default
    set_default "com.apple.finder" "ShowSidebar" "bool" "true"

    set_default "com.apple.finder" "ShowExternalHardDrivesOnDesktop" "bool" "true" # Show icons for hard drives, servers, and removable media on the desktop
    set_default "com.apple.finder" "ShowHardDrivesOnDesktop" "bool" "false"        # Hide main volume (like Macintosh HD) from desktop
    set_default "com.apple.finder" "ShowMountedServersOnDesktop" "bool" "false"    # Hide mounted servers from the desktop
    set_default "com.apple.finder" "ShowRemovableMediaOnDesktop" "bool" "true"     # Show icons for hard drives, servers, and removable media on the desktop

    set_default "NSGlobalDomain" "AppleShowAllFiles" "bool" "true"                 # Finder: show hidden files by default
    set_default "NSGlobalDomain" "AppleShowAllExtensions" "bool" "true"            # Finder: show all filename extensions
    set_default "com.apple.finder" "ShowStatusBar" "bool" "true"                   # Finder: show status bar
    set_default "com.apple.finder" "ShowPathbar" "bool" "true"                     # Finder: show path bar
    set_default "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true"         # Display full POSIX path as Finder window title
    set_default "com.apple.finder" "_FXSortFoldersFirst" "bool" "true"             # Keep folders on top when sorting by name
    set_default "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf"          # When performing a search, search the current folder by default
    set_default "com.apple.finder" "FXEnableExtensionChangeWarning" "bool" "false" # Disable the warning when changing a file extension
    set_default "NSGlobalDomain" "com.apple.springing.enabled" "bool" "true"       # Enable spring loading for directories
    set_default "NSGlobalDomain" "com.apple.springing.delay" "float" "0"           # Remove the spring loading delay for directories

    set_default "com.apple.desktopservices" "DSDontWriteNetworkStores" "bool" "true" # Avoid creating .DS_Store files on network or USB volumes
    set_default "com.apple.desktopservices" "DSDontWriteUSBStores" "bool" "true"     # Avoid creating .DS_Store files on network or USB volumes

    set_default "com.apple.frameworks.diskimages" "skip-verify" "bool" "true"        # Disable disk image verification
    set_default "com.apple.frameworks.diskimages" "skip-verify-locked" "bool" "true" # Disable disk image verification
    set_default "com.apple.frameworks.diskimages" "skip-verify-remote" "bool" "true" # Disable disk image verification

    set_default "com.apple.frameworks.diskimages" "auto-open-ro-root" "bool" "true" # Automatically open a new Finder window when a volume is mounted
    set_default "com.apple.frameworks.diskimages" "auto-open-rw-root" "bool" "true" # Automatically open a new Finder window when a volume is mounted
    set_default "com.apple.finder" "OpenWindowForNewRemovableDisk" "bool" "true"    # Automatically open a new Finder window when a volume is mounted

    set_default "com.apple.finder" "FXPreferredViewStyle" "string" "Nlsv" # Use list view in all Finder windows by default

    # Reset all folder view settings to list view
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    defaults write com.apple.finder FXPreferredSearchViewStyle -string "Nlsv"
    defaults write com.apple.finder FXPreferredGroupBy -string "Kind"

    # Set default view settings for all view types to list view
    defaults write com.apple.finder FK_DefaultViewStyle -string "Nlsv"
    defaults write com.apple.finder FK_DefaultSearchViewStyle -string "Nlsv"
    configure_finder_view_settings || warning "Finder view layout setup had issues (continuing)"

    configure_finder_sidebar || warning "Finder sidebar favorites setup had issues (continuing)"
    configure_finder_sidebar_settings || warning "Finder sidebar settings setup had issues (continuing)"
    configure_login_items || warning "Login Items setup had issues (continuing)"

    set_default "com.apple.finder" "WarnOnEmptyTrash" "bool" "false"           # Disable the warning before emptying the Trash
    set_default "com.apple.NetworkBrowser" "BrowseAllInterfaces" "bool" "true" # Enable AirDrop over Ethernet and on unsupported Macs

    chflags nohidden ~/Library     # Show the ~/Library folder
    sudo chflags nohidden /Volumes # Show the /Volumes folder

    # Expand the following File Info panes: "General", "Open with", and "Sharing & Permissions"
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

    info "Configuring Dock, Dashboard, and hot corners..."
    set_default "com.apple.dock" "mouse-over-hilite-stack" "bool" "true"                 # Enable highlight hover effect for the grid view of a stack (Dock)
    set_default "com.apple.dock" "tilesize" "int" "16"                                   # Set the icon size of Dock items to 16 pixels
    set_default "com.apple.dock" "magnification" "bool" "true"                           # Magnify Dock icons on hover
    set_default "com.apple.dock" "largesize" "int" "32"                                  # Set magnification icon size to 32 pixels
    set_default "com.apple.dock" "mineffect" "string" "scale"                            # Change minimize/maximize window effect
    set_default "com.apple.dock" "minimize-to-application" "bool" "true"                 # Minimize windows into their application's icon
    set_default "com.apple.dock" "enable-spring-load-actions-on-all-items" "bool" "true" # Enable spring loading for all Dock items
    set_default "com.apple.dock" "show-process-indicators" "bool" "true"                 # Show indicator lights for open applications in the Dock
    set_default "com.apple.dock" "launchanim" "bool" "false"                             # Don't animate opening applications from the Dock
    set_default "com.apple.dock" "expose-animation-duration" "float" "0.1"               # Speed up Mission Control animations
    set_default "com.apple.dock" "expose-group-by-app" "bool" "false"                    # Don't group windows by application in Mission Control
    set_default "com.apple.dashboard" "mcx-disabled" "bool" "true"                       # Disable Dashboard
    set_default "com.apple.dock" "dashboard-in-overlay" "bool" "true"                    # Don't show Dashboard as a Space
    set_default "com.apple.dock" "mru-spaces" "bool" "false"                             # Don't automatically rearrange Spaces based on most recent use
    set_default "com.apple.dock" "autohide-delay" "float" "0"                            # Remove the auto-hiding Dock delay (already set, ensuring value)
    set_default "com.apple.dock" "autohide-time-modifier" "float" "0"                    # Remove the animation when hiding/showing the Dock
    set_default "com.apple.dock" "autohide" "bool" "true"                                # Automatically hide and show the Dock (already set, ensuring value)
    set_default "com.apple.dock" "showhidden" "bool" "true"                              # Make Dock icons of hidden applications translucent
    set_default "com.apple.dock" "show-recents" "bool" "false"                           # Don't show recent applications in Dock (already set, ensuring value)
    set_default "com.apple.dock" "orientation" "string" "right"                          # Position the Dock on the right edge of the screen
    defaults write com.apple.dock persistent-apps -array                                 # Remove all pinned app icons (leaves only Finder + Trash)
    defaults write com.apple.dock persistent-others -array                               # Remove all pinned folders/stacks (e.g. Downloads)

    if [ -d "${HOME}/Library/Application Support/Dock" ]; then # Reset Launchpad, but keep the desktop wallpaper intact
        find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete
    fi

    set_default "com.apple.dock" "wvous-tl-corner" "int" "2" # Hot corners: Top left screen corner → Mission Control
    set_default "com.apple.dock" "wvous-tl-modifier" "int" "0"
    set_default "com.apple.dock" "wvous-tr-corner" "int" "2" # Hot corners: Top right screen corner → Mission Control
    set_default "com.apple.dock" "wvous-tr-modifier" "int" "0"
    set_default "com.apple.dock" "wvous-bl-corner" "int" "2" # Hot corners: Bottom left screen corner → Mission Control
    set_default "com.apple.dock" "wvous-bl-modifier" "int" "0"
    set_default "com.apple.dock" "wvous-br-corner" "int" "2" # Hot corners: Bottom right screen corner → Mission Control
    set_default "com.apple.dock" "wvous-br-modifier" "int" "0"

    info "Configuring Window Manager and menu bar clock..."
    set_default "com.apple.WindowManager" "AppWindowGroupingBehavior" "int" "1"
    set_default "com.apple.WindowManager" "AutoHide" "bool" "false"
    set_default "com.apple.WindowManager" "EnableStandardClickToShowDesktop" "bool" "false" # Don't hide windows when clicking the wallpaper
    set_default "com.apple.WindowManager" "EnableTiledWindowMargins" "bool" "false"
    set_default "com.apple.WindowManager" "EnableTilingOptionAccelerator" "bool" "false"
    set_default "com.apple.WindowManager" "GloballyEnabled" "bool" "false" # Disable Stage Manager
    set_default "com.apple.WindowManager" "HideDesktop" "bool" "true"
    set_default "com.apple.WindowManager" "StageManagerHideWidgets" "bool" "true"
    set_default "com.apple.WindowManager" "StandardHideDesktopIcons" "bool" "false"
    set_default "com.apple.WindowManager" "StandardHideWidgets" "bool" "true"

    set_default "com.apple.menuextra.clock" "FlashDateSeparators" "bool" "false"
    set_default "com.apple.menuextra.clock" "IsAnalog" "bool" "false"
    set_default "com.apple.menuextra.clock" "ShowAMPM" "bool" "false"
    set_default "com.apple.menuextra.clock" "ShowDate" "int" "1"
    set_default "com.apple.menuextra.clock" "ShowDayOfWeek" "bool" "true"
    set_default "com.apple.menuextra.clock" "ShowSeconds" "bool" "false"

    set_default "NSGlobalDomain" "AppleMenuBarVisibleInFullscreen" "bool" "false"
    set_default "NSGlobalDomain" "_HIHideMenuBar" "bool" "false"
    set_default "com.apple.controlcenter" "AutoHideMenuBarOption" "int" "2"
    set_default "com.apple.controlcenter" "NSStatusItem Visible BentoBox" "bool" "true"
    set_default "com.apple.controlcenter" "NSStatusItem VisibleCC Battery" "bool" "true"
    set_default "com.apple.controlcenter" "NSStatusItem VisibleCC BentoBox-0" "bool" "true"
    set_default "com.apple.controlcenter" "NSStatusItem VisibleCC Clock" "bool" "true"
    set_default "com.apple.controlcenter" "NSStatusItem VisibleCC NowPlaying" "bool" "true"
    set_default "com.apple.controlcenter" "NSStatusItem VisibleCC Sound" "bool" "true"
    set_default "com.apple.controlcenter" "NSStatusItem VisibleCC WiFi" "bool" "true"

    info "Configuring Safari & WebKit..."
    sudo defaults write com.apple.Safari UniversalSearchEnabled -bool false                                                                   # Privacy: don't send search queries to Apple
    sudo defaults write com.apple.Safari SuppressSearchSuggestions -bool true                                                                 # Privacy: don't send search queries to Apple
    sudo defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true                                                             # Press Tab to highlight each item on a web page
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true                            # Press Tab to highlight each item on a web page
    sudo defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true                                                             # Show the full URL in the address bar
    sudo defaults write com.apple.Safari HomePage -string "about:blank"                                                                       # Set Safari's home page to `about:blank`
    sudo defaults write com.apple.Safari AutoOpenSafeDownloads -bool false                                                                    # Prevent Safari from opening 'safe' files automatically
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true          # Allow hitting the Backspace key to go to the previous page
    sudo defaults write com.apple.Safari ShowFavoritesBar -bool false                                                                         # Hide Safari's bookmarks bar by default
    sudo defaults write com.apple.Safari ShowSidebarInTopSites -bool false                                                                    # Hide Safari's sidebar in Top Sites
    sudo defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2                                                                    # Disable Safari's thumbnail cache for History and Top Sites
    sudo defaults write com.apple.Safari IncludeInternalDebugMenu -bool true                                                                  # Enable Safari's debug menu
    sudo defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false                                                          # Make Safari's search banners default to Contains instead of Starts With
    sudo defaults write com.apple.Safari ProxiesInBookmarksBar -string "()"                                                                   # Remove useless icons from Safari's bookmarks bar
    sudo defaults write com.apple.Safari IncludeDevelopMenu -bool true                                                                        # Enable the Develop menu and the Web Inspector in Safari
    sudo defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true                                                 # Enable the Develop menu and the Web Inspector in Safari
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true                 # Enable the Develop menu and the Web Inspector in Safari
    set_default "NSGlobalDomain" "WebKitDeveloperExtras" "bool" "true"                                                                        # Add a context menu item for showing the Web Inspector in web views
    sudo defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true                                                         # Enable continuous spellchecking
    sudo defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false                                                    # Disable auto-correct
    sudo defaults write com.apple.Safari AutoFillFromAddressBook -bool false                                                                  # Disable AutoFill
    sudo defaults write com.apple.Safari AutoFillPasswords -bool false                                                                        # Disable AutoFill
    sudo defaults write com.apple.Safari AutoFillCreditCardData -bool false                                                                   # Disable AutoFill
    sudo defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false                                                               # Disable AutoFill
    sudo defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true                                                               # Warn about fraudulent websites
    sudo defaults write com.apple.Safari WebKitPluginsEnabled -bool false                                                                     # Disable plug-ins
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false                        # Disable plug-ins
    sudo defaults write com.apple.Safari WebKitJavaEnabled -bool false                                                                        # Disable Java
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false                           # Disable Java
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false              # Disable Java for local files
    sudo defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false                                              # Block pop-up windows
    sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false # Block pop-up windows
    sudo defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true                                                                  # Enable "Do Not Track"
    sudo defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true                                                      # Update extensions automatically

    info "Configuring Mail..."
    sudo defaults write com.apple.mail DisableReplyAnimations -bool true            # Disable send and reply animations in Mail.app
    sudo defaults write com.apple.mail DisableSendAnimations -bool true             # Disable send and reply animations in Mail.app
    sudo defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false # Copy email addresses as `foo@example.com`

    sudo defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\\U21a9" # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app

    sudo defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes" # Display emails in threaded mode, sorted by date (oldest at the top)
    sudo defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"      # Display emails in threaded mode, sorted by date (oldest at the top)
    sudo defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"   # Display emails in threaded mode, sorted by date (oldest at the top)

    sudo defaults write com.apple.mail DisableInlineAttachmentViewing -bool true              # Disable inline attachments (just show the icons)
    sudo defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled" # Disable automatic spell checking

    info "Configuring Terminal"
    # set_default "com.apple.terminal" "StringEncodings" -array "4"        # Only use UTF-8 in Terminal.app (can fail on some systems)
    set_default "com.apple.Terminal" "SecureKeyboardEntry" "bool" "true" # Enable Secure Keyboard Entry in Terminal.app
    set_default "com.apple.Terminal" "ShowLineMarks" "int" "0"           # Disable the annoying line marks in Terminal

    info "Configuring Time Machine..."
    set_default "com.apple.TimeMachine" "DoNotOfferNewDisksForBackup" "bool" "true" # Prevent Time Machine from prompting to use new hard drives as backup volume
    hash tmutil &>/dev/null && sudo tmutil disablelocal 2>/dev/null || true         # Disable local Time Machine backups (if available)

    info "Configuring Activity Monitor..."
    set_default "com.apple.ActivityMonitor" "OpenMainWindow" "bool" "true"   # Show the main window when launching Activity Monitor
    set_default "com.apple.ActivityMonitor" "IconType" "int" "5"             # Visualize CPU usage in the Activity Monitor Dock icon
    set_default "com.apple.ActivityMonitor" "ShowCategory" "int" "100"       # Match the Mac Studio process category
    set_default "com.apple.ActivityMonitor" "SortColumn" "string" "CPUUsage" # Sort Activity Monitor results by CPU usage
    set_default "com.apple.ActivityMonitor" "SortDirection" "int" "0"        # Sort Activity Monitor results by CPU usage (descending)

    info "Configuring TextEdit, Disk Utility, QuickTime Player..."
    set_default "com.apple.addressbook" "ABShowDebugMenu" "bool" "true"        # Enable the debug menu in Address Book
    set_default "com.apple.dashboard" "devmode" "bool" "true"                  # Enable Dashboard dev mode
    set_default "com.apple.TextEdit" "RichText" "int" "0"                      # Use plain text mode for new TextEdit documents
    set_default "com.apple.TextEdit" "PlainTextEncoding" "int" "4"             # Open and save files as UTF-8 in TextEdit
    set_default "com.apple.TextEdit" "PlainTextEncodingForWrite" "int" "4"     # Open and save files as UTF-8 in TextEdit
    set_default "com.apple.DiskUtility" "DUDebugMenuEnabled" "bool" "true"     # Enable the debug menu in Disk Utility
    set_default "com.apple.DiskUtility" "advanced-image-options" "bool" "true" # Enable advanced image options in Disk Utility
    set_default "com.apple.QuickTimePlayerX" "MGPlayMovieOnOpen" "bool" "true" # Auto-play videos when opened with QuickTime Player

    info "Configuring Mac App Store..."
    set_default "com.apple.appstore" "WebKitDeveloperExtras" "bool" "true"       # Enable the WebKit Developer Tools in the Mac App Store
    set_default "com.apple.appstore" "ShowDebugMenu" "bool" "true"               # Enable Debug Menu in the Mac App Store
    set_default "com.apple.SoftwareUpdate" "AutomaticCheckEnabled" "bool" "true" # Enable the automatic update check
    set_default "com.apple.SoftwareUpdate" "ScheduleFrequency" "int" "1"         # Check for software updates daily
    set_default "com.apple.SoftwareUpdate" "AutomaticDownload" "int" "1"         # Download newly available updates in background
    set_default "com.apple.SoftwareUpdate" "CriticalUpdateInstall" "int" "1"     # Install System data files & security updates
    set_default "com.apple.SoftwareUpdate" "ConfigDataInstall" "int" "1"         # Automatically download apps purchased on other Macs
    set_default "com.apple.commerce" "AutoUpdate" "bool" "true"                  # Turn on app auto-update
    set_default "com.apple.commerce" "AutoUpdateRestartRequired" "bool" "true"   # Allow the App Store to reboot machine on macOS updates

    info "Configuring Photos..."
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true # Prevent Photos from opening automatically when devices are plugged in

    info "Configuring Messages..."
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false # Disable automatic emoji substitution
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false         # Disable smart quotes
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false            # Disable continuous spell checking

    info "Configuring Google Chrome (if installed)..."
    if [ -d "/Applications/Google Chrome.app" ]; then
        defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false      # Disable the all too sensitive backswipe on trackpads
        defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false # Disable the all too sensitive backswipe on Magic Mouse
        defaults write com.google.Chrome DisablePrintPreview -bool true                       # Use the system-native print preview dialog
        defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true          # Expand the print dialog by default
        info "Google Chrome settings applied."
    else
        info "Google Chrome not found, skipping configuration."
    fi

    task "Restarting affected applications for changes to take effect."
    app_list=(
        "Activity Monitor"
        "Address Book"
        "Calendar"
        "Contacts"
        "Dock"
        "Finder"
        "Google Chrome"
        "Mail"
        "Messages"
        "Photos"
        "Safari"
        "SystemUIServer"
        "WindowManager"
    )
    # Do not restart terminal/editor apps; one of them may be running this script.
    for app_name in "${app_list[@]}"; do
        if [ -d "/Applications/${app_name}.app" ] || [ "${app_name}" == "Dock" ] || [ "${app_name}" == "Finder" ] || [ "${app_name}" == "SystemUIServer" ] || [ "${app_name}" == "WindowManager" ]; then # Check if the app is installed before trying to kill it, to be more robust, though killall itself handles it.
            killall "${app_name}" &>/dev/null || true
        fi
    done

    success "macOS preferences configured. Note that some of these changes require a logout/restart to take effect."
}

main "$@"
