#!/bin/bash

formulae=(
  "bat"
  "btop"
  "cmatrix"
  "fastfetch"
  "gh"
  "go"
  "lsd"
  "jq"
  "neovim"
  "trash"
  "wget"
)

casks=(
  "alacritty"
  "alfred"
  "appcleaner"
  "authy"
  "bitwarden"
  "discord"
  "firefox"
  "google-chrome"
  "imageoptim"
  "keyboard-maestro"
  "mos"
  "orbstack"
  "pika"
  "rectangle"
  "shottr"
  "slack"
  "tableplus"
  "visual-studio-code"
)

for cask in "${casks[@]}"; do
  echo "Installing $cask..."
  brew install --cask "$cask"
done

echo "Casks installation complete."

for formula in "${formulae[@]}"; do
  echo "Installing $formula..."
  brew install "$formula"
done

echo "Formulae installation complete."
