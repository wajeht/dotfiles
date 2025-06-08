.PHONY: install install-macos install-brew install-nvim install-git install-tmux install-zsh install-starship install-ghostty install-lsd uninstall uninstall-packages uninstall-complete uninstall-zsh uninstall-starship uninstall-lsd push

install:
	@./install.sh

install-macos:
	@./scripts/macos-defaults.sh

install-brew:
	@./scripts/install-brew.sh

install-nvim:
	@./scripts/install-nvim.sh

install-git:
	@./scripts/install-gitconfig.sh

install-tmux:
	@./scripts/install-tmux.sh

install-zsh:
	@./scripts/install-zsh.sh

install-starship:
	@./scripts/install-starship.sh

install-ghostty:
	@./scripts/install-ghostty.sh

install-lsd:
	@./scripts/install-lsd.sh

push:
	@make format
	@git add -A
	@git auto
	@git push --no-verify

uninstall:
	@echo "🗑️  Removing dotfiles..."
	@echo "📋 This will remove:"
	@echo "   • Configuration files (.zshrc, .tmux.conf, .gitconfig)"
	@echo "   • Custom config directories (~/.config/nvim, ~/.config/zsh, ~/.config/starship, ~/.config/ghostty)"
	@echo "   • Backup files"
	@echo ""
	@read -p "❓ Continue with uninstall? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo ""
	@echo "🧹 Removing configuration files..."
	@rm -f ~/.zshrc ~/.tmux.conf ~/.gitconfig
	@echo "🗂️  Removing config directories..."
	@rm -rf ~/.config/nvim ~/.config/zsh ~/.config/starship ~/.config/ghostty
	@echo "🧹 Removing backup files..."
	@rm -f ~/.zshrc.backup ~/.gitconfig.backup ~/.tmux.conf.backup ~/.config/starship.toml.backup
	@echo ""
	@echo "⚠️  Note: Homebrew packages are preserved"
	@echo "💡 To remove Homebrew packages: run 'make uninstall-packages'"
	@echo ""
	@echo "✅ Dotfiles removed successfully!"

uninstall-packages:
	@echo "🗑️  Removing Homebrew packages from Brewfile..."
	@echo "⚠️  This will uninstall ALL packages listed in Brewfile"
	@read -p "❓ Continue? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@brew bundle cleanup --file=Brewfile --force
	@echo "✅ Homebrew packages removed"

uninstall-complete:
	@echo "🗑️  Complete removal of dotfiles environment..."
	@echo "⚠️  This will remove:"
	@echo "   • All dotfiles configurations"
	@echo "   • All Homebrew packages from Brewfile"
	@echo ""
	@read -p "❓ This is destructive! Continue? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@make uninstall
	@make uninstall-packages
	@echo "✅ Complete removal finished!"

uninstall-nvim:
	@echo "🧹 Cleaning Neovim caches (preserving config)..."
	@rm -rf ~/.config/nvim
	@rm -rf ~/.cache/nvim
	@rm -rf ~/.local/share/nvim
	@rm -rf ~/.local/state/nvim
	@rm -rf ~/.cache/lazy
	@rm -rf ~/.cache/mason
	@rm -rf ~/.local/share/nvim/mason
	@rm -rf ~/.local/share/nvim/lazy
	@rm -rf ~/.local/share/nvim/site
	@echo "🔄 Clearing npm cache..."
	@npm cache clean --force 2>/dev/null || true
	@echo "✅ Neovim caches cleaned! Restart Neovim to reinstall plugins."

uninstall-zsh:
	@echo "🗑️  Removing Zsh configuration..."
	@echo "📋 This will remove:"
	@echo "   • ~/.zshrc"
	@echo "   • ~/.config/zsh/ directory"
	@echo "   • ~/.zsh_history (optional)"
	@echo ""
	@read -p "❓ Continue with Zsh uninstall? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo ""
	@echo "🧹 Creating backup of current config..."
	@if [ -f ~/.zshrc ]; then cp ~/.zshrc ~/.zshrc.backup.$(shell date +%Y%m%d_%H%M%S) && echo "✅ ~/.zshrc backed up"; fi
	@echo "🗂️  Removing Zsh config files..."
	@rm -f ~/.zshrc
	@rm -rf ~/.config/zsh
	@echo ""
	@read -p "❓ Also remove Zsh history? [y/N] " confirm && [ "$$confirm" = "y" ] && rm -f ~/.zsh_history && echo "🗑️  Zsh history removed" || echo "📝 Zsh history preserved"
	@echo ""
	@echo "✅ Zsh configuration removed successfully!"
	@echo "💡 To reinstall: make install-zsh"

uninstall-starship:
	@echo "🗑️  Removing Starship configuration..."
	@echo "📋 This will remove:"
	@echo "   • ~/.config/starship.toml"
	@echo "   • ~/.config/starship/ directory"
	@echo "   • Note: Starship binary will remain installed"
	@echo ""
	@read -p "❓ Continue with Starship uninstall? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo ""
	@echo "🧹 Creating backup of current config..."
	@if [ -f ~/.config/starship.toml ]; then cp ~/.config/starship.toml ~/.config/starship.toml.backup.$(shell date +%Y%m%d_%H%M%S) && echo "✅ starship.toml backed up"; fi
	@echo "🗂️  Removing Starship config files..."
	@rm -f ~/.config/starship.toml
	@rm -rf ~/.config/starship
	@echo ""
	@echo "✅ Starship configuration removed successfully!"
	@echo "💡 To reinstall: make install-starship"
	@echo "💡 To remove Starship binary: brew uninstall starship"

uninstall-lsd:
	@rm -f ~/.config/lsd/config.yaml ~/.config/lsd/colors.yaml
	@rm -rf ~/.config/lsd
	@echo ""
	@echo "✅ LSD configuration removed successfully!"
	@echo "💡 To reinstall: make install-lsd"
	@echo "💡 To remove LSD binary: brew uninstall lsd"
	@echo ""
	@echo "✅ LSD configuration removed successfully!"
	@echo "💡 To reinstall: make install-lsd"
	@echo "💡 To remove LSD binary: brew uninstall lsd"

clean:
	@echo "🧹 Cleaning backup files..."
	@find ~ -name "*.backup" -path "*/.*" -delete 2>/dev/null || true
	@echo "✅ Backup files cleaned"

update:
	@echo "🔄 Updating packages..."
	@brew update && brew upgrade && brew cleanup

dev:
	@echo "🚀 Quick setup for development..."
	@make install-brew install-nvim install-git

format:
	@./scripts/format-code.sh
