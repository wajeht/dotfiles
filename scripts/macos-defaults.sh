#!/bin/bash

source "$(dirname "$0")/common.sh"

main() {
    step "🍎 Setting macOS preferences"

    info "Configuring Dock..."
    set_default "com.apple.dock" "autohide" "bool" "true"
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

    task "Restarting affected applications"
    killall Dock Finder SystemUIServer 2>/dev/null || true

    success "macOS preferences configured"
}

main "$@"
