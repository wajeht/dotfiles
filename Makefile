# Dotfiles Management
# Usage: make <program> [action]
# Example: make zsh, make zsh install, make nvim uninstall
# Default action is 'install' if no action specified

.PHONY: install macos brew nvim git tmux zsh starship ghostty lsd push uninstall uninstall-complete clean update dev format help

# Legacy support - main install script
install:
	@./install.sh

# Individual program management with install/uninstall actions
brew:
	@./scripts/brew.sh $(filter-out $@,$(MAKECMDGOALS))

nvim:
	@./scripts/nvim.sh $(filter-out $@,$(MAKECMDGOALS))

git:
	@./scripts/git.sh $(filter-out $@,$(MAKECMDGOALS))

tmux:
	@./scripts/tmux.sh $(filter-out $@,$(MAKECMDGOALS))

zsh:
	@./scripts/zsh.sh $(filter-out $@,$(MAKECMDGOALS))

starship:
	@./scripts/starship.sh $(filter-out $@,$(MAKECMDGOALS))

ghostty:
	@./scripts/ghostty.sh $(filter-out $@,$(MAKECMDGOALS))

lsd:
	@./scripts/lsd.sh $(filter-out $@,$(MAKECMDGOALS))

# macOS defaults (install only)
macos:
	@./scripts/macos-defaults.sh

# Git workflow
push:
	@make format
	@git add -A
	@git auto
	@git push --no-verify

# Complete uninstall (all dotfiles)
uninstall:
	@echo "🗑️  Removing all dotfiles..."
	@echo "📋 This will remove:"
	@echo "   • Configuration files (.zshrc, .tmux.conf, .gitconfig)"
	@echo "   • Custom config directories (~/.config/nvim, ~/.config/zsh, ~/.config/starship, ~/.config/ghostty)"
	@echo "   • Backup files"
	@echo ""
	@read -p "❓ Continue with complete uninstall? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo ""
	@echo "🧹 Removing configuration files..."
	@rm -f ~/.zshrc ~/.tmux.conf ~/.gitconfig
	@echo "🗂️  Removing config directories..."
	@rm -rf ~/.config/nvim ~/.config/zsh ~/.config/starship ~/.config/ghostty ~/.config/lsd
	@echo "🧹 Removing backup files..."
	@rm -f ~/.zshrc.backup* ~/.gitconfig.backup* ~/.tmux.conf.backup* ~/.config/starship.toml.backup*
	@echo ""
	@echo "⚠️  Note: Homebrew packages are preserved"
	@echo "💡 To remove Homebrew packages: make brew uninstall"
	@echo ""
	@echo "✅ Dotfiles removed successfully!"

# Complete removal including packages
uninstall-complete:
	@echo "🗑️  Complete removal of dotfiles environment..."
	@echo "⚠️  This will remove:"
	@echo "   • All dotfiles configurations"
	@echo "   • All Homebrew packages from Brewfile"
	@echo ""
	@read -p "❓ This is destructive! Continue? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@make uninstall
	@make brew uninstall
	@echo "✅ Complete removal finished!"

# Utility commands
clean:
	@echo "🧹 Cleaning backup files..."
	@find ~ -name "*.backup*" -path "*/.*" -delete 2>/dev/null || true
	@echo "✅ Backup files cleaned"

update:
	@echo "🔄 Updating packages..."
	@brew update && brew upgrade && brew cleanup

dev:
	@echo "🚀 Quick setup for development..."
	@make brew
	@make nvim
	@make git

format:
	@./scripts/format-code.sh

# Help command
help:
	@echo "📋 Dotfiles Management Commands"
	@echo ""
	@echo "🔧 Program Management:"
	@echo "   make <program>            - Install program configuration (default)"
	@echo "   make <program> install    - Install program configuration"
	@echo "   make <program> uninstall  - Remove program configuration"
	@echo ""
	@echo "📦 Available Programs:"
	@echo "   brew     - Homebrew and packages"
	@echo "   nvim     - Neovim configuration"
	@echo "   git      - Git configuration"
	@echo "   tmux     - Tmux configuration"
	@echo "   zsh      - Zsh shell configuration"
	@echo "   starship - Starship prompt"
	@echo "   ghostty  - Ghostty terminal"
	@echo "   lsd      - LSD file listing"
	@echo "   macos    - macOS system defaults (install only)"
	@echo ""
	@echo "🚀 Examples:"
	@echo "   make zsh              - Install Zsh configuration"
	@echo "   make zsh install      - Install Zsh configuration"
	@echo "   make nvim uninstall   - Remove Neovim config and caches"
	@echo "   make starship         - Install Starship prompt"
	@echo ""
	@echo "🗑️  Removal Commands:"
	@echo "   make uninstall        - Remove all dotfile configurations"
	@echo "   make uninstall-complete - Remove configs AND packages"
	@echo ""
	@echo "🛠️  Utility Commands:"
	@echo "   make clean           - Remove backup files"
	@echo "   make update          - Update Homebrew packages"
	@echo "   make dev             - Quick dev setup (brew, nvim, git)"
	@echo "   make format          - Format code files"
	@echo "   make push            - Format, commit, and push changes"
	@echo "   make help            - Show this help message"

# Prevent make from trying to create files named after the actions
%:
	@true
