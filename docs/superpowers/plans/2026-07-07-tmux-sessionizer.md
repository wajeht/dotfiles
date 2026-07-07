# Ctrl+F Tmux Sessionizer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ctrl+F opens an fzf project picker that creates (or re-attaches to) a per-project tmux session with an nvim window and a shell window.

**Architecture:** The existing Ctrl+F → `dev-widget` → `dev()` chain in zsh stays untouched; only `dev()`'s body changes to create/attach tmux sessions. A restored plugin-free `tmux.conf` ships in `src/configs/tmux/` and deploys to `~/.config/tmux/` via a new `src/tmux.sh` installer following the repo's existing per-tool installer pattern.

**Tech Stack:** zsh, tmux, fzf, bash installer scripts, Make.

**Spec:** `docs/superpowers/specs/2026-07-07-tmux-sessionizer-design.md`

## Global Constraints

- Deploy model is copy-not-symlink: configs live in `src/configs/` and are copied to `$HOME` by installers. Editing `src/configs/` alone does NOT change live behavior until redeployed.
- tmux config path is `~/.config/tmux/tmux.conf` (XDG), NOT `~/.tmux.conf`.
- Session name = project directory basename with `.` replaced by `_`.
- No tmux plugins (no TPM, resurrect, continuum, vim-tmux-navigator).
- This repo has no test framework; every task verifies via syntax checks (`bash -n`, `zsh -n`) and real command runs with expected output.
- No `cat` heredocs for file creation in interactive steps (user's `cat` is aliased to `bat`); use the Write/Edit tools or the code blocks below verbatim.

---

### Task 1: tmux config + installer + wiring

**Files:**
- Create: `src/configs/tmux/tmux.conf`
- Create: `src/tmux.sh` (executable)
- Modify: `Makefile:1` (.PHONY), after `Makefile:19` (target), after `Makefile:74` (help)
- Modify: `src/install.sh:113` (add component line after ghostty)
- Modify: `src/configs/homebrew/Brewfile:28` (add tmux after fzf)
- Modify: `README.md:24` (tool list), `README.md:33` (components line)

**Interfaces:**
- Consumes: `step`, `info`, `task`, `success`, `backup_if_exists` from `src/_util.sh` (already exist).
- Produces: `~/.config/tmux/tmux.conf` on disk after `make tmux`; Task 2's sessionizer assumes tmux reads this config automatically (tmux checks `$XDG_CONFIG_HOME/tmux/tmux.conf` a.k.a. `~/.config/tmux/tmux.conf` natively since tmux 3.1).

- [ ] **Step 1: Create `src/configs/tmux/tmux.conf`**

Restored from `git show 467b702~1:.tmux.conf` with the plugin block removed and the reload path updated to the XDG location:

```conf
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

set -g prefix C-a
unbind C-b
bind-key C-a send-prefix

unbind %
bind | split-window -h

unbind '"'
bind - split-window -v

unbind r
bind r source-file ~/.config/tmux/tmux.conf

bind j resize-pane -D 5
bind k resize-pane -U 5
bind l resize-pane -R 5
bind h resize-pane -L 5

bind -r m resize-pane -Z

set -g mouse on

set-window-option -g mode-keys vi

bind-key -T copy-mode-vi 'v' send -X begin-selection # 'v' to begin selection
bind-key -T copy-mode-vi 'y' send -X copy-selection # 'y' to copy

unbind -T copy-mode-vi MouseDragEnd1Pane # Don't exit copy mode with mouse drag

set -sg escape-time 10 # Remove esc delay in Neovim
```

- [ ] **Step 2: Verify the config parses with a throwaway tmux server**

Run:
```bash
tmux -L cfgtest -f src/configs/tmux/tmux.conf new-session -d -s cfgtest && tmux -L cfgtest kill-server && echo CONFIG_OK
```
Expected: `CONFIG_OK` and no error output. (`-L cfgtest` uses an isolated socket so this never touches real sessions.)

- [ ] **Step 3: Create `src/tmux.sh`**

Modeled on `src/ghostty.sh`, plus a config backup per the spec:

```bash
#!/bin/bash

source "$(dirname "$0")/_util.sh"

install_tmux() {
    step "🖥️ Installing Tmux Configuration"

    backup_if_exists ~/.config/tmux/tmux.conf

    info "Installing Tmux configuration..."
    mkdir -p ~/.config/tmux
    cp -r "$(dirname "$0")/configs/tmux/"* ~/.config/tmux/
    task "Copied configuration to ~/.config/tmux/"

    success "Tmux configuration installed"
}

uninstall_tmux() {
    step "🗑️  Removing Tmux Configuration"

    echo "📋 This will remove:"
    echo "   • ~/.config/tmux/ directory"
    echo "   • All Tmux configuration files"
    echo ""
    read -p "❓ Continue with Tmux uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1

    info "Removing Tmux configuration..."
    rm -rf ~/.config/tmux
    task "Removed ~/.config/tmux/"

    success "Tmux configuration removed successfully!"
    info "💡 To reinstall: make tmux install"
}

main() {
    case "${1:-install}" in
    install)
        install_tmux
        ;;
    uninstall)
        uninstall_tmux
        ;;
    *)
        install_tmux
        ;;
    esac
}

main "$@"
```

- [ ] **Step 4: Make it executable and syntax-check**

Run:
```bash
chmod +x src/tmux.sh && bash -n src/tmux.sh && echo SYNTAX_OK
```
Expected: `SYNTAX_OK`

- [ ] **Step 5: Wire up the Makefile**

Three edits to `Makefile`:

Line 1 — add `tmux` to `.PHONY` (after `ghostty`):
```makefile
.PHONY: install macos brew nvim git zsh ghostty tmux lsd bat server push clean update format sync-nvim help
```

After the `ghostty:` target (line 18-19), insert:
```makefile
tmux:
	@./src/tmux.sh $(filter-out $@,$(MAKECMDGOALS))
```

In `help:`, after the `make ghostty` line (line 74), insert:
```makefile
	@echo "  make tmux              Install Tmux config"
```

- [ ] **Step 6: Wire up `src/install.sh`**

After line 113 (`run_component ... ghostty.sh ...`), insert:
```bash
    run_component "$(dirname "$0")/tmux.sh" "install" "Tmux config" || failed_components+=("Tmux config")
```

- [ ] **Step 7: Add tmux to the Brewfile**

In `src/configs/homebrew/Brewfile`, after `brew "fzf"` (line 28), insert:
```ruby
brew "tmux"         # Terminal multiplexer
```

- [ ] **Step 8: Update README.md**

In "What Gets Installed" after the Ghostty line (line 22), insert:
```markdown
- **Tmux** - Per-project terminal sessions
```

Change line 33 from:
```markdown
make macos brew nvim git zsh ghostty lsd bat
```
to:
```markdown
make macos brew nvim git zsh ghostty tmux lsd bat
```

- [ ] **Step 9: Run the installer for real**

Run:
```bash
make tmux && ls ~/.config/tmux/tmux.conf
```
Expected: installer step/success output, then the path `~/.config/tmux/tmux.conf` printed (file exists).

- [ ] **Step 10: Commit**

```bash
git add src/configs/tmux/tmux.conf src/tmux.sh Makefile src/install.sh src/configs/homebrew/Brewfile README.md
git commit -m "feat(tmux): restore plugin-free tmux config with installer"
```

---

### Task 2: Rewrite `dev()` as a tmux sessionizer

**Files:**
- Modify: `src/configs/zsh/functions.zsh:29-40` (the `dev()` function body only; `DEV_DIRS` on line 27 and `dev-widget`/bindings at lines 286-308 stay untouched)

**Interfaces:**
- Consumes: `DEV_DIRS` array (line 27), `~/.config/tmux/tmux.conf` from Task 1 (picked up automatically by tmux ≥3.1).
- Produces: `dev [dir]` — no argument: fzf picker (Ctrl+F path); with a directory argument: skips fzf and opens that project directly (also what the verification steps use). `dev-widget` continues to call plain `dev`.

- [ ] **Step 1: Replace the `dev()` function**

Replace lines 29-40 of `src/configs/zsh/functions.zsh`:

```zsh
function dev() {
  local selected_dir search_dirs=()
  for d in "${DEV_DIRS[@]}"; do [ -d "$d" ] && search_dirs+=("$d"); done
  if (( ${#search_dirs} == 0 )); then
    echo "No project directories found"
    return 1
  fi

  if [ -n "$1" ]; then
    selected_dir="$1"
  else
    selected_dir=$(find "${search_dirs[@]}" -maxdepth 1 -type d -not -path "*/\.*" | grep -v -E "^(${(j:|:)search_dirs})$" | fzf --height 40% --layout=reverse --border)
  fi
  [ -n "$selected_dir" ] || return 0
  if [ ! -d "$selected_dir" ]; then
    echo "Not a directory: $selected_dir"
    return 1
  fi

  if ! command -v tmux > /dev/null 2>&1; then
    echo "tmux not found; opening without a session"
    builtin cd "$selected_dir" && nvim .
    return
  fi

  # tmux forbids dots in session names
  local session_name="${${selected_dir:t}//./_}"

  if ! tmux has-session -t "=$session_name" 2> /dev/null; then
    tmux new-session -ds "$session_name" -c "$selected_dir" -n nvim nvim .
    tmux new-window -t "$session_name" -c "$selected_dir" -n shell
    tmux select-window -t "$session_name:nvim"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "=$session_name"
  else
    tmux attach -t "=$session_name"
  fi
}
```

Notes for the implementer:
- `${selected_dir:t}` is zsh for basename; `${...//./_}` swaps dots for underscores.
- `-t "=$session_name"` forces exact-name matching (plain `-t foo` prefix-matches `foobar`).
- `new-session ... -n nvim nvim .` makes window "nvim" run `nvim .` directly; `select-window -t "$session_name:nvim"` targets it by name so it works regardless of `base-index`.

- [ ] **Step 2: Syntax-check**

Run:
```bash
zsh -n src/configs/zsh/functions.zsh && echo SYNTAX_OK
```
Expected: `SYNTAX_OK`

- [ ] **Step 3: Functional test — session creation with two windows**

Run (non-interactive, so `tmux attach` will fail with "not a terminal" — that error is EXPECTED and harmless; session creation is what's under test):

```bash
mkdir -p /tmp/devtest.proj
zsh -c 'source src/configs/zsh/functions.zsh; dev /tmp/devtest.proj' || true
tmux list-windows -t "=devtest_proj" -F '#{window_name}'
```
Expected output (dot became underscore; two windows):
```
nvim
shell
```

- [ ] **Step 4: Functional test — re-invoke attaches instead of duplicating**

Run:
```bash
zsh -c 'source src/configs/zsh/functions.zsh; dev /tmp/devtest.proj' || true
tmux list-sessions -F '#{session_name}' | grep -c '^devtest_proj$'
```
Expected: `1` (still exactly one session).

- [ ] **Step 5: Cleanup test artifacts**

Run:
```bash
tmux kill-session -t "=devtest_proj" && rm -rf /tmp/devtest.proj && echo CLEAN
```
Expected: `CLEAN`

- [ ] **Step 6: Commit**

```bash
git add src/configs/zsh/functions.zsh
git commit -m "feat(zsh): turn ctrl+f dev picker into tmux sessionizer"
```

---

### Task 3: Deploy and live verification

**Files:**
- None created/modified in the repo; this deploys `src/configs/zsh/` to `~/.config/zsh/` so the live shell gets the new `dev()`.

**Interfaces:**
- Consumes: `make zsh` installer (existing), Task 1's installed tmux config, Task 2's `dev()`.
- Produces: working Ctrl+F behavior in the user's terminal.

- [ ] **Step 1: Redeploy zsh config**

Run:
```bash
make zsh
```
Expected: zsh installer success output.

- [ ] **Step 2: Confirm the deployed copy has the sessionizer**

Run:
```bash
grep -c "tmux new-session" ~/.config/zsh/functions.zsh
```
Expected: `1`

- [ ] **Step 3: Manual live checks (needs the user's real terminal)**

These cannot be scripted; ask the user to verify in a fresh terminal:

1. Ctrl+F outside tmux → fzf picker → picking a project lands in a tmux session, nvim open, prefix+n reveals a shell window in the project dir.
2. Ctrl+F from inside that tmux session → picking a different project switches sessions with no "sessions should be nested with care" error.
3. Ctrl+F again on the first project → re-attaches with nvim state intact.

- [ ] **Step 4: Final commit check**

Run:
```bash
git status --porcelain
```
Expected: empty (everything committed in Tasks 1-2; Task 3 changes nothing in the repo).
