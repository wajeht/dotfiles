push:
	@git add -A
	@git auto
	@git push --no-verify

link-nvim:
	ln -s ~/Dev/.dotfiles/.config/nvim ~/.config

unlink-nvim:
	unlink ~/.config/nvim
