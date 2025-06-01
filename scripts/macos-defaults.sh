#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🍎 Setting macOS preferences"

    osascript -e 'tell application "System Preferences" to quit' # Close any open System Preferences panes, to prevent them from overriding settings we're about to change

    # Keep-alive: update existing `sudo` time stamp until script has finished
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &

    info "General UI/UX enhancements..."
    sudo nvram SystemAudioVolume=" " # Disable the sound effects on boot

    sudo defaults write com.apple.universalaccess reduceTransparency -bool true            # Disable transparency in the menu bar and elsewhere (requires sudo)
    defaults write NSGlobalDomain AppleHighlightColor -string "0.709800 0.835300 1.000000" # Set highlight color to blue
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

    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user # Remove duplicates in the "Open With" menu

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

    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true # Enable HiDPI display modes (requires restart)

    info "Configuring Finder..."
    set_default "com.apple.finder" "QuitMenuItem" "bool" "true"         # Finder: allow quitting via ⌘ + Q
    set_default "com.apple.finder" "DisableAllAnimations" "bool" "true" # Finder: disable window animations and Get Info animations

    defaults write com.apple.finder NewWindowTarget -string "PfDe"                        # Set Desktop as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/" # Set Desktop as the default location for new Finder windows

    set_default "com.apple.finder" "ShowExternalHardDrivesOnDesktop" "bool" "true" # Show icons for hard drives, servers, and removable media on the desktop
    set_default "com.apple.finder" "ShowHardDrivesOnDesktop" "bool" "false"        # Hide main volume (like Macintosh HD) from desktop
    set_default "com.apple.finder" "ShowMountedServersOnDesktop" "bool" "true"     # Show icons for hard drives, servers, and removable media on the desktop
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
    defaults write com.apple.finder FXPreferredGroupBy -string "None"

    # Clear existing folder view settings to force list view
    find ~/Library/Preferences -name "com.apple.finder.plist" -exec defaults delete {} :FK_StandardViewSettings \; 2>/dev/null || true
    find ~/Library/Preferences -name "com.apple.finder.plist" -exec defaults delete {} :StandardViewSettings \; 2>/dev/null || true

    # Set default view settings for all view types to list view
    defaults write com.apple.finder FK_DefaultViewStyle -string "Nlsv"
    defaults write com.apple.finder FK_DefaultSearchViewStyle -string "Nlsv"

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
    set_default "com.apple.dock" "tilesize" "int" "16"                                   # Set the icon size of Dock items to 36 pixels (overrides previous)
    set_default "com.apple.dock" "largesize" "int" "32"                                  # Set magnification icon size to 64 pixels
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

    info "Configuring Spotlight..."

    # Change indexing order and disable some search results
    defaults write com.apple.spotlight orderedItems -array \
        '{"enabled" = 1;"name" = "APPLICATIONS";}' \
        '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        '{"enabled" = 1;"name" = "DIRECTORIES";}' \
        '{"enabled" = 1;"name" = "PDF";}' \
        '{"enabled" = 1;"name" = "FONTS";}' \
        '{"enabled" = 0;"name" = "DOCUMENTS";}' \
        '{"enabled" = 0;"name" = "MESSAGES";}' \
        '{"enabled" = 0;"name" = "CONTACT";}' \
        '{"enabled" = 0;"name" = "EVENT_TODO";}' \
        '{"enabled" = 0;"name" = "IMAGES";}' \
        '{"enabled" = 0;"name" = "BOOKMARKS";}' \
        '{"enabled" = 0;"name" = "MUSIC";}' \
        '{"enabled" = 0;"name" = "MOVIES";}' \
        '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        '{"enabled" = 0;"name" = "SOURCE";}' \
        '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
        '{"enabled" = 0;"name" = "MENU_OTHER";}' \
        '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
        '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
        '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
        '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

    info "Rebuilding Spotlight index with optimized settings (fresh system setup)..."
    killall mds >/dev/null 2>&1 || true # Stop indexing service
    sudo mdutil -E / >/dev/null 2>&1    # Rebuild index with new settings
    info "Spotlight will rebuild index in background with optimized categories..."

    info "Configuring Terminal"
    # set_default "com.apple.terminal" "StringEncodings" -array "4"        # Only use UTF-8 in Terminal.app (can fail on some systems)
    set_default "com.apple.terminal" "SecureKeyboardEntry" "bool" "true" # Enable Secure Keyboard Entry in Terminal.app
    set_default "com.apple.Terminal" "ShowLineMarks" "int" "0"           # Disable the annoying line marks in Terminal

    info "Configuring Time Machine..."
    set_default "com.apple.TimeMachine" "DoNotOfferNewDisksForBackup" "bool" "true" # Prevent Time Machine from prompting to use new hard drives as backup volume
    hash tmutil &>/dev/null && sudo tmutil disablelocal 2>/dev/null || true         # Disable local Time Machine backups (if available)

    info "Configuring Activity Monitor..."
    set_default "com.apple.ActivityMonitor" "OpenMainWindow" "bool" "true"   # Show the main window when launching Activity Monitor
    set_default "com.apple.ActivityMonitor" "IconType" "int" "5"             # Visualize CPU usage in the Activity Monitor Dock icon
    set_default "com.apple.ActivityMonitor" "ShowCategory" "int" "0"         # Show all processes in Activity Monitor
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

    task "Restarting affected applications for changes to take effect." # Restarting affected applications
    app_list=( # Corrected list of applications for the killall loop
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
        "Terminal"
    )
    for app_name in "${app_list[@]}"; do
        if [ -d "/Applications/${app_name}.app" ] || [ "${app_name}" == "Dock" ] || [ "${app_name}" == "Finder" ] || [ "${app_name}" == "SystemUIServer" ]; then # Check if the app is installed before trying to kill it, to be more robust, though killall itself handles it.
            killall "${app_name}" &>/dev/null || true
        fi
    done

    success "macOS preferences configured. Note that some of these changes require a logout/restart to take effect."
}

main "$@"
