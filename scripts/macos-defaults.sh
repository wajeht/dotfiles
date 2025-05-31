#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🍎 Setting macOS preferences"

    info "Configuring Dock..."
    set_default "com.apple.dock" "autohide" "bool" "true"       # Automatically hide and show the Dock
    set_default "com.apple.dock" "autohide-delay" "float" "0"   # Remove the auto-hiding Dock delay
    set_default "com.apple.dock" "orientation" "string" "right" # Place Dock on the right
    set_default "com.apple.dock" "tilesize" "int" "32"          # Set the icon size of Dock items to 32 pixels
    set_default "com.apple.dock" "magnification" "bool" "true"  # Enable magnification
    set_default "com.apple.dock" "largesize" "int" "64"         # Set magnification icon size to 64 pixels
    set_default "com.apple.dock" "show-recents" "bool" "false"  # Don't show recent applications in Dock

    info "Configuring Finder..."
    set_default "com.apple.finder" "ShowPathbar" "bool" "true"                     # Show path bar
    set_default "com.apple.finder" "ShowStatusBar" "bool" "true"                   # Show status bar
    set_default "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true"         # Display full POSIX path as Finder window title
    set_default "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf"          # When performing a search, search the current folder by default
    set_default "com.apple.finder" "AppleShowAllExtensions" "bool" "true"          # Show all filename extensions
    set_default "com.apple.finder" "FXEnableExtensionChangeWarning" "bool" "false" # Disable the warning when changing a file extension
    set_default "NSGlobalDomain" "AppleShowAllFiles" "bool" "true"                 # Show hidden files

    info "Configuring screenshots..."
    set_default "com.apple.screencapture" "location" "string" "~/Desktop" # Save screenshots to the desktop
    set_default "com.apple.screencapture" "type" "string" "png"           # Save screenshots in PNG format
    set_default "com.apple.screencapture" "disable-shadow" "bool" "true"  # Disable shadow in screenshots

    info "Configuring input (vim-optimized)..."
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true" # Enable tap to click
    set_default "NSGlobalDomain" "KeyRepeat" "int" "1"                                        # Set a blazingly fast keyboard repeat rate
    set_default "NSGlobalDomain" "InitialKeyRepeat" "int" "10"                                # Set a blazingly fast initial keyboard repeat rate
    set_default "NSGlobalDomain" "ApplePressAndHoldEnabled" "bool" "false"                    # Disable press-and-hold for keys in favor of key repeat

    info "Configuring menu bar..."
    set_default "com.apple.menuextra.battery" "ShowPercent" "string" "YES" # Show battery percentage

    info "General UI/UX enhancements..."
    set_default "com.apple.universalaccess" "reduceTransparency" "bool" "true"          # Disable transparency in the menu bar and elsewhere
    set_default "NSGlobalDomain" "NSTableViewDefaultSizeMode" "int" "2"                 # Set sidebar icon size to medium
    set_default "NSGlobalDomain" "AppleShowScrollBars" "string" "Always"                # Always show scrollbars
    set_default "NSGlobalDomain" "NSUseAnimatedFocusRing" "bool" "false"                # Disable the over-the-top focus ring animation
    set_default "NSGlobalDomain" "NSWindowResizeTime" "float" "0.001"                   # Increase window resize speed for Cocoa applications
    set_default "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode" "bool" "true"     # Expand save panel by default
    set_default "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode2" "bool" "true"    # Expand save panel by default
    set_default "NSGlobalDomain" "PMPrintingExpandedStateForPrint" "bool" "true"        # Expand print panel by default
    set_default "NSGlobalDomain" "PMPrintingExpandedStateForPrint2" "bool" "true"       # Expand print panel by default
    set_default "NSGlobalDomain" "NSDocumentSaveNewDocumentsToCloud" "bool" "false"     # Save to disk (not to iCloud) by default
    set_default "com.apple.print.PrintingPrefs" "Quit When Finished" "bool" "true"      # Automatically quit printer app once the print jobs complete
    set_default "com.apple.LaunchServices" "LSQuarantine" "bool" "false"                # Disable the "Are you sure you want to open this application?" dialog
    set_default "NSGlobalDomain" "NSTextShowsControlCharacters" "bool" "true"           # Display ASCII control characters using caret notation
    set_default "com.apple.systempreferences" "NSQuitAlwaysKeepsWindows" "bool" "false" # Disable Resume system-wide
    set_default "NSGlobalDomain" "NSDisableAutomaticTermination" "bool" "true"          # Disable automatic termination of inactive apps
    set_default "com.apple.helpviewer" "DevMode" "bool" "true"                          # Set Help Viewer windows to non-floating mode
    set_default "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" "bool" "false"      # Disable automatic capitalization
    set_default "NSGlobalDomain" "NSAutomaticDashSubstitutionEnabled" "bool" "false"    # Disable smart dashes
    set_default "NSGlobalDomain" "NSAutomaticPeriodSubstitutionEnabled" "bool" "false"  # Disable automatic period substitution
    set_default "NSGlobalDomain" "NSAutomaticQuoteSubstitutionEnabled" "bool" "false"   # Disable smart quotes
    set_default "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" "bool" "false"  # Disable auto-correct

    task "Restarting affected applications"
    killall Dock Finder SystemUIServer 2>/dev/null || true

    success "macOS preferences configured"
}

main "$@"
