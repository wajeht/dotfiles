.PHONY: install macos brew nvim git tmux zsh starship ghostty lsd push clean update dev format help

install:
	@./install.sh

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

format:
	@./scripts/format-code.sh

# Prevent make from trying to create files named after the actions
%:
	@true
