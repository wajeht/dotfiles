#!/bin/bash

set -e

echo "Installing Zsh configuration..."

# Install zsh modules
mkdir -p ~/.config/zsh
cp -r .config/zsh/* ~/.config/zsh/
echo "Zsh modules copied to ~/.config/zsh/"

# Install .zshrc
rm -f ~/.zshrc
cp -f .zshrc ~/.zshrc
echo ".zshrc copied to ~/.zshrc"

# Copy reload command to clipboard
echo "source ~/.zshrc" | pbcopy

echo "✅ Zsh configuration installed!"
echo "Run 'source ~/.zshrc' or start a new shell to apply changes (command copied to clipboard)"
