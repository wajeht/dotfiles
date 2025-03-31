#!/bin/bash

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"  # For Apple Silicon
  eval "$(/usr/local/bin/brew shellenv)"     # For macOS Intel
fi

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
  "awk"
  "jq"
  "sed"
  "lazygit"
)

casks=(
  "iina"
  "qbittorrent"
  "github"
  "ghostty"
  "alfred"
  "appcleaner"
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
  "handbrake"
  "tableplus"
  "visual-studio-code"
)

install_casks() {
  for cask in "${casks[@]}"; do
    if ! brew list --cask --versions "$cask" &>/dev/null; then
      echo "Installing $cask..."
      if ! brew install --cask "$cask"; then
        echo "Error installing $cask"
      fi
    else
      echo "$cask is already installed."
    fi
  done
  echo "Casks installation complete."
}

install_formulae() {
  for formula in "${formulae[@]}"; do
    if ! brew list --versions "$formula" &>/dev/null; then
      echo "Installing $formula..."
      if ! brew install "$formula"; then
        echo "Error installing $formula"
      fi
    else
      echo "$formula is already installed."
    fi
  done
  echo "Formulae installation complete."
}

brew update

install_casks

install_formulae

brew cleanup

echo "Installation and cleanup complete."
