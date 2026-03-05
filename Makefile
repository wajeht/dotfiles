.PHONY: install macos brew nvim git zsh ghostty lsd bat server push clean update format sync-nvim help

install:
	@if [ "$(words $(MAKECMDGOALS))" -eq 1 ]; then ./src/install.sh; fi

brew:
	@./src/brew.sh $(filter-out $@,$(MAKECMDGOALS))

nvim:
	@./src/nvim.sh $(filter-out $@,$(MAKECMDGOALS))

git:
	@./src/git.sh $(filter-out $@,$(MAKECMDGOALS))

zsh:
	@./src/zsh.sh $(filter-out $@,$(MAKECMDGOALS))

ghostty:
	@./src/ghostty.sh $(filter-out $@,$(MAKECMDGOALS))

lsd:
	@./src/lsd.sh $(filter-out $@,$(MAKECMDGOALS))

bat:
	@./src/bat.sh $(filter-out $@,$(MAKECMDGOALS))

server:
	@./src/server.sh $(filter-out $@,$(MAKECMDGOALS))

macos:
	@./src/macos-defaults.sh

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
	@./src/_format-code.sh

sync-nvim:
	@echo "🔄 Syncing Neovim plugin lock file..."
	@cp ~/.config/nvim/nvim-pack-lock.json src/configs/nvim/nvim-pack-lock.json 2>/dev/null || (echo "❌ nvim-pack-lock.json not found. Run :lua vim.pack.update() in Neovim first." && exit 1)
	@if git diff --quiet src/configs/nvim/nvim-pack-lock.json 2>/dev/null; then \
		echo "✅ Lock file already up to date"; \
	else \
		git add src/configs/nvim/nvim-pack-lock.json && \
		git commit -m "Update Neovim plugin lock file" && \
		echo "✅ Lock file synced and committed"; \
	fi

help:
	@echo ""
	@echo "🌟 Dotfiles Management Commands"
	@echo ""
	@echo "📦 Installation:"
	@echo "  make install           Install all dotfiles"
	@echo "  make macos             Configure macOS settings"
	@echo "  make brew              Install Homebrew packages"
	@echo "  make nvim              Install Neovim config"
	@echo "  make nvim install-bin  Install bob-managed Neovim binary (pinned target)"
	@echo "  make nvim update-bin   Update bob-managed Neovim binary (pinned target)"
	@echo "  make nvim status-bin   Show bob-managed Neovim binary status"
	@echo "  make git               Install Git config"
	@echo "  make zsh               Install Zsh config"
	@echo "  make ghostty           Install Ghostty config"
	@echo "  make lsd               Install LSD config"
	@echo "  make bat               Install Bat config"
	@echo "  make server            Install server dotfiles (Linux)"
	@echo ""
	@echo "🗑️  Uninstallation:"
	@echo "  make <component> uninstall    Uninstall specific component"
	@echo "  Example: make zsh uninstall"
	@echo ""
	@echo "🛠️  Utilities:"
	@echo "  make update            Update all packages"
	@echo "  make clean             Clean backup files"
	@echo "  make format            Format shell and Lua files"
	@echo "  make sync-nvim         Sync Neovim plugin lock file (run :lua vim.pack.update() first)"
	@echo "  make push              Format, commit and push changes"
	@echo "  make help              Show this help message"
	@echo ""

# Prevent make from trying to create files named after the actions
uninstall:
	@:

# Catch-all rule for any other unknown targets
%:
	@:
