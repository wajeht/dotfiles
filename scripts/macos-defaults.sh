#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

main() {
    echo "🍎 Setting macOS preferences..."

    # Dock settings
    set_default "com.apple.dock" "autohide" "bool" "true"
    set_default "com.apple.dock" "orientation" "string" "right"
    set_default "com.apple.dock" "tilesize" "int" "32"
    set_default "com.apple.dock" "magnification" "bool" "true"
    set_default "com.apple.dock" "largesize" "int" "64"
    set_default "com.apple.dock" "show-recents" "bool" "false"

    # Finder settings
    set_default "com.apple.finder" "ShowPathbar" "bool" "true"
    set_default "com.apple.finder" "ShowStatusBar" "bool" "true"
    set_default "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true"
    set_default "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf"

    # Screenshot settings
    set_default "com.apple.screencapture" "location" "string" "~/Desktop"
    set_default "com.apple.screencapture" "type" "string" "png"
    set_default "com.apple.screencapture" "disable-shadow" "bool" "true"

    # Input settings (vim-optimized)
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true"
    set_default "NSGlobalDomain" "KeyRepeat" "int" "1"
    set_default "NSGlobalDomain" "InitialKeyRepeat" "int" "10"
    set_default "NSGlobalDomain" "ApplePressAndHoldEnabled" "bool" "false"

    # Menu bar
    set_default "com.apple.menuextra.battery" "ShowPercent" "string" "YES"

    # Restart affected apps
    killall Dock Finder SystemUIServer 2>/dev/null || true

    success "macOS preferences configured!"
}

main "$@"
