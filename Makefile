.PHONY: push install-nvim uninstall-nvim

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
