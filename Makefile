.PHONY: push install-nvim uninstall-nvim install-gitconfig install-zsh install-tmux install-brew install-macos install uninstall

push:
	@git add -A
	@git auto
	@git push --no-verify

install-nvim:
	@./scripts/install-nvim.sh

uninstall-nvim:
	@rm -rf ~/.config/nvim
	@echo "Neovim configuration uninstalled."

install-gitconfig:
	@./scripts/install-gitconfig.sh

install-tmux:
	@./scripts/install-tmux.sh

install-zsh:
	@./scripts/install-zsh.sh

install-brew:
	@./scripts/install-brew.sh

install-macos:
	@./scripts/macos-defaults.sh

install: install-macos install-brew install-nvim install-gitconfig install-tmux install-zsh
	@echo "🎉 All dotfiles installed!"

uninstall: uninstall-nvim
	@rm -rf ~/.config/zsh
	@echo "Zsh configuration modules removed from ~/.config/zsh"
	# Note: Uninstalling .gitconfig and .zshrc is less common and might break setup.
	# To remove the copied files if desired, you would use rm:
	# @rm -f ~/.gitconfig
	# @rm -f ~/.zshrc
	@echo "Dotfiles uninstalled (excluding .gitconfig and .zshrc removal)."
