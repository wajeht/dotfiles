.PHONY: install install-macos install-brew install-nvim install-git install-tmux install-zsh install-starship install-ghostty uninstall uninstall-packages uninstall-complete push

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
	@rm -f ~/.zshrc.backup ~/.gitconfig.backup ~/.tmux.conf.backup ~/.p10k.zsh.backup
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
