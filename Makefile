.PHONY: install macos brew nvim git tmux zsh starship ghostty lsd bat push clean update format help

install:
	@if [ "$(words $(MAKECMDGOALS))" -eq 1 ]; then ./install.sh; fi

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

bat:
	@./scripts/bat.sh $(filter-out $@,$(MAKECMDGOALS))

macos:
	@./scripts/macos-defaults.sh

push:
	@make format
	@git add -A
	@curl -fsSl https://commit.jaw.dev | sh -s -- --no-verify
	@git push --no-verify

clean:
	@echo "🧹 Cleaning backup files..."
	@find ~ -name "*.backup*" -path "*/.*" -delete 2>/dev/null || true
	@echo "✅ Backup files cleaned"

update:
	@echo "🔄 Updating all packages..."
	@brew update && brew upgrade
	@echo "✅ Update complete"

format:
	@./scripts/format-code.sh

help:
	@echo ""
	@echo "🌟 Dotfiles Management Commands"
	@echo ""
	@echo "📦 Installation:"
	@echo "  make install           Install all dotfiles"
	@echo "  make macos             Configure macOS settings"
	@echo "  make brew              Install Homebrew packages"
	@echo "  make nvim              Install Neovim config"
	@echo "  make git               Install Git config"
	@echo "  make tmux              Install Tmux config"
	@echo "  make zsh               Install Zsh config"
	@echo "  make starship          Install Starship prompt"
	@echo "  make ghostty           Install Ghostty config"
	@echo "  make lsd               Install LSD config"
	@echo "  make bat               Install Bat config"
	@echo ""
	@echo "🗑️  Uninstallation:"
	@echo "  make <component> uninstall    Uninstall specific component"
	@echo "  Example: make zsh uninstall"
	@echo ""
	@echo "🛠️  Utilities:"
	@echo "  make update            Update all packages"
	@echo "  make clean             Clean backup files"
	@echo "  make format            Format shell and Lua files"
	@echo "  make push              Format, commit and push changes"
	@echo "  make help              Show this help message"
	@echo ""

# Prevent make from trying to create files named after the actions
uninstall:
	@:

# Catch-all rule for any other unknown targets
%:
	@:
