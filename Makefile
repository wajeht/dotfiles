push:
	git add -A
	aicommits --type conventional
	git push --no-verify

link-nvim:
	ln -s ~/Dev/.dotfiles/.config/nvim ~/.config
