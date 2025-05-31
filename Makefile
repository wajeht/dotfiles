.PHONY: push install-nvim uninstall-nvim install-gitconfig

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
	@cp $(CURDIR)/.gitconfig ~/.gitconfig
	@echo ".gitconfig installed to ~/.gitconfig"

install:
	@make install-nvim
	@make install-gitconfig # Add this line to your 'install' target

uninstall:
	@make uninstall-nvim
