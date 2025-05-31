#!/bin/bash

set -e

echo "Installing Tmux configuration..."
rm -f ~/.tmux.conf
cp -f .tmux.conf ~/.tmux.conf
echo "✅ .tmux.conf copied to ~/.tmux.conf"
