#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🍎 Setting macOS preferences"

    info "Configuring Dock..."
    set_default "com.apple.dock" "autohide" "bool" "true"
    set_default "com.apple.dock" "autohide-delay" "float" "0"
    set_default "com.apple.dock" "orientation" "string" "right"
    set_default "com.apple.dock" "tilesize" "int" "32"
    set_default "com.apple.dock" "magnification" "bool" "true"
    set_default "com.apple.dock" "largesize" "int" "64"
    set_default "com.apple.dock" "show-recents" "bool" "false"

    info "Configuring Finder..."
    set_default "com.apple.finder" "ShowPathbar" "bool" "true"
    set_default "com.apple.finder" "ShowStatusBar" "bool" "true"
    set_default "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true"
    set_default "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf"
    set_default "com.apple.finder" "AppleShowAllExtensions" "bool" "true"
    set_default "com.apple.finder" "FXEnableExtensionChangeWarning" "bool" "false"
    set_default "NSGlobalDomain" "AppleShowAllFiles" "bool" "true"

    info "Configuring screenshots..."
    set_default "com.apple.screencapture" "location" "string" "~/Desktop"
    set_default "com.apple.screencapture" "type" "string" "png"
    set_default "com.apple.screencapture" "disable-shadow" "bool" "true"

    info "Configuring input (vim-optimized)..."
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true"
    set_default "NSGlobalDomain" "KeyRepeat" "int" "1"
    set_default "NSGlobalDomain" "InitialKeyRepeat" "int" "10"
    set_default "NSGlobalDomain" "ApplePressAndHoldEnabled" "bool" "false"

    info "Configuring menu bar..."
    set_default "com.apple.menuextra.battery" "ShowPercent" "string" "YES"

    info "General UI/UX enhancements..."
    set_default "NSGlobalDomain" "AppleShowScrollBars" "string" "Always"                # Always show scrollbars
    set_default "NSGlobalDomain" "NSWindowResizeTime" "float" "0.001"                   # Increase window resize speed for Cocoa applications
    set_default "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode" "bool" "true"     # Expand save panel by default
    set_default "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode2" "bool" "true"    # Expand save panel by default
    set_default "NSGlobalDomain" "PMPrintingExpandedStateForPrint" "bool" "true"        # Expand print panel by default
    set_default "NSGlobalDomain" "PMPrintingExpandedStateForPrint2" "bool" "true"       # Expand print panel by default
    set_default "NSGlobalDomain" "NSDocumentSaveNewDocumentsToCloud" "bool" "false"     # Save to disk (not to iCloud) by default
    set_default "com.apple.LaunchServices" "LSQuarantine" "bool" "false"                # Disable the "Are you sure you want to open this application?" dialog
    set_default "com.apple.systempreferences" "NSQuitAlwaysKeepsWindows" "bool" "false" # Disable Resume system-wide
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
