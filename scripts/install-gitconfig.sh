#!/bin/bash

set -e

echo "Installing Git configuration..."
rm -f ~/.gitconfig
cp -f .gitconfig ~/.gitconfig
echo "✅ .gitconfig copied to ~/.gitconfig"
