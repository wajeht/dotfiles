#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

apply_dock_settings() {
    echo "Applying dock settings..."

    set_default "com.apple.dock" "autohide" "bool" "true" "dock autohide"
    set_default "com.apple.dock" "orientation" "string" "right" "dock orientation"
    set_default "com.apple.dock" "tilesize" "int" "32" "dock tilesize"
    set_default "com.apple.dock" "magnification" "bool" "true" "dock magnification"
    set_default "com.apple.dock" "largesize" "int" "64" "dock largesize"
    set_default "com.apple.dock" "show-recents" "bool" "false" "disable recent apps"

    success "Dock settings applied"
}

apply_finder_settings() {
    echo "Applying Finder settings..."

    set_default "com.apple.finder" "ShowPathbar" "bool" "true" "show path bar"
    set_default "com.apple.finder" "ShowStatusBar" "bool" "true" "show status bar"
    set_default "com.apple.finder" "_FXShowPosixPathInTitle" "bool" "true" "show POSIX path"
    set_default "com.apple.finder" "FXDefaultSearchScope" "string" "SCcf" "search scope"

    success "Finder settings applied"
}

apply_screenshot_settings() {
    echo "Applying screenshot settings..."

    set_default "com.apple.screencapture" "location" "string" "~/Desktop" "screenshot location"
    set_default "com.apple.screencapture" "type" "string" "png" "screenshot type"
    set_default "com.apple.screencapture" "disable-shadow" "bool" "true" "disable screenshot shadows"

    success "Screenshot settings applied"
}

apply_input_settings() {
    echo "Applying input settings..."

    # Trackpad
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "bool" "true" "tap to click"

    # Keyboard (vim-optimized)
    set_default "NSGlobalDomain" "KeyRepeat" "int" "1" "key repeat"
    set_default "NSGlobalDomain" "InitialKeyRepeat" "int" "10" "initial key repeat"
    set_default "NSGlobalDomain" "ApplePressAndHoldEnabled" "bool" "false" "disable press and hold"

    success "Input settings applied"
}

apply_menu_bar_settings() {
    echo "Applying menu bar settings..."

    set_default "com.apple.menuextra.battery" "ShowPercent" "string" "YES" "show battery percentage"

    success "Menu bar settings applied"
}

restart_applications() {
    echo "Restarting affected applications..."

    safe_killall "Dock"
    safe_killall "Finder"
    safe_killall "SystemUIServer"

    success "Applications restarted"
}

main() {
    echo "🍎 Setting macOS system preferences..."

    check_macos
    check_macos_version

    apply_dock_settings
    apply_finder_settings
    apply_screenshot_settings
    apply_input_settings
    apply_menu_bar_settings

    restart_applications

    success "macOS preferences configured!"
    echo "Some changes may require logout/login to take full effect"
}

main "$@"
