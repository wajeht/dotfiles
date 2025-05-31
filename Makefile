.PHONY: install install-macos install-brew install-nvim install-git install-tmux install-zsh uninstall clean push

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

push:
	@git add -A
	@git auto
	@git push --no-verify

uninstall:
	@echo "🗑️  Removing dotfiles..."
	@rm -rf ~/.config/nvim ~/.config/zsh
	@rm -f ~/.zshrc.backup ~/.gitconfig.backup ~/.tmux.conf.backup
	@echo "✅ Dotfiles removed (kept original configs if they exist)"

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
