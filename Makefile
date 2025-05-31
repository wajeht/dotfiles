.PHONY: push install-nvim uninstall-nvim install-gitconfig install-zsh install-tmux install uninstall

push:
	@git add -A
	@git auto
	@git push --no-verify

install-nvim:
	@mkdir -p ~/.config/nvim
	@cp -r $(CURDIR)/.config/nvim/* ~/.config/nvim/
	@echo "Neovim configuration installed."

uninstall-nvim:
	@rm -rf ~/.config/nvim
	@echo "Neovim configuration uninstalled."

install-gitconfig:
	@rm -f ~/.gitconfig
	@cp -f $(CURDIR)/.gitconfig ~/.gitconfig
	@echo ".gitconfig copied to ~/.gitconfig"

install-tmux:
	@rm -f ~/.tmux.conf
	@cp -f $(CURDIR)/.tmux.conf ~/.tmux.conf
	@echo ".tmux.conf copied to ~/.tmux.conf"

install-zsh:
	@echo "Installing Zsh configuration..."
	@mkdir -p ~/.config/zsh
	@cp -r $(CURDIR)/.config/zsh/* ~/.config/zsh/
	@echo "Zsh modules copied to ~/.config/zsh/"
	@rm -f ~/.zshrc
	@cp -f $(CURDIR)/.zshrc ~/.zshrc
	@echo ".zshrc copied to ~/.zshrc"
	@echo "source ~/.zshrc" | pbcopy
	@echo "Zsh configuration installed! Run 'source ~/.zshrc' or start a new shell to apply changes (command copied to clipboard)"

install: install-nvim install-gitconfig install-tmux install-zsh
	@echo "All dotfiles installed!"

uninstall: uninstall-nvim
	@rm -rf ~/.config/zsh
	@echo "Zsh configuration modules removed from ~/.config/zsh"
	# Note: Uninstalling .gitconfig and .zshrc is less common and might break setup.
	# To remove the copied files if desired, you would use rm:
	# @rm -f ~/.gitconfig
	# @rm -f ~/.zshrc
	@echo "Dotfiles uninstalled (excluding .gitconfig and .zshrc removal)."
