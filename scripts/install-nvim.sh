#!/bin/bash

set -e

echo "Installing Neovim configuration..."
mkdir -p ~/.config/nvim
cp -r .config/nvim/* ~/.config/nvim/
echo "✅ Neovim configuration installed."
