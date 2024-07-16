push:
	git add -A
	git acp
	git push --no-verify

link-nvim:
	ln -s ~/Dev/.dotfiles/.config/nvim ~/.config
