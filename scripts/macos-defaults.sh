#!/bin/bash

# ======================
# macOS System Preferences
# ======================

echo "Setting macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true                    # Auto-hide dock
defaults write com.apple.dock orientation -string "right"            # Position dock on right
defaults write com.apple.dock tilesize -int 16                       # Super small dock icons
defaults write com.apple.dock magnification -bool true               # Enable magnification on hover
defaults write com.apple.dock largesize -int 30                      # Magnified size when hovering
defaults write com.apple.dock show-recents -bool false               # Don't show recent apps

# Finder
defaults write com.apple.finder ShowPathbar -bool true               # Show path bar
defaults write com.apple.finder ShowStatusBar -bool true             # Show status bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true   # Show full path in title
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"  # Search current folder by default

# Screenshots
defaults write com.apple.screencapture location -string "~/Desktop"  # Screenshot location
defaults write com.apple.screencapture type -string "png"                        # PNG format
defaults write com.apple.screencapture disable-shadow -bool true                 # No shadows

# Trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true  # Tap to click

# Keyboard (optimized for vim)
defaults write NSGlobalDomain KeyRepeat -int 1                       # Fastest key repeat (vim navigation)
defaults write NSGlobalDomain InitialKeyRepeat -int 10               # Shortest delay before repeat starts
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false   # Disable press-and-hold for accent chars (vim compatibility)

# Menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES" # Show battery percentage

echo "macOS defaults set! You may need to restart some apps or logout/login for all changes to take effect."

# Restart affected applications
killall Dock
killall Finder
killall SystemUIServer
