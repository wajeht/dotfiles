.PHONY: push install-nvim uninstall-nvim install-gitconfig install-zshrc install uninstall

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

install-zshrc:
	@rm -f ~/.zshrc
	@cp -f $(CURDIR)/.zshrc ~/.zshrc
	@echo ".zshrc copied to ~/.zshrc"
	@echo "source ~/.zshrc" | pbcopy
	@echo "Run 'source ~/.zshrc' or start a new shell to apply changes (command copied to clipboard)"

install: install-nvim install-gitconfig install-zshrc
	@echo "Dotfiles installed!"

uninstall: uninstall-nvim
	# Note: Uninstalling .gitconfig is less common and might break Git setup.
	# To remove the copied files if desired, you would use rm:
	# @rm -f ~/.gitconfig
	# @rm -f ~/.zshrc
	@echo "Dotfiles uninstalled (excluding .gitconfig and .zshrc removal)."
