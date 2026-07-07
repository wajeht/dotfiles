# Ctrl+F Tmux Sessionizer — Design

**Date:** 2026-07-07
**Branch:** `feat/tmux-sessionizer`

## Goal

Restore tmux to the dotfiles and make Ctrl+F spin up a per-project tmux
session instead of a bare `cd + nvim`. Each project gets one persistent
session containing an nvim window and a shell window; re-invoking Ctrl+F on
the same project re-attaches to it.

## Background

- Ctrl+F (`\x06`, also sent by Ghostty for Cmd+F) is already bound to
  `dev-widget`, which runs `dev()` in `src/configs/zsh/functions.zsh`.
  Today `dev()` fzf-picks a directory from `DEV_DIRS=(~/Dev ~/Work)` and
  runs `cd + nvim .`. This chain stays; only `dev()`'s body changes.
- The old `.tmux.conf` was removed in commit `467b702` (Aug 2025); its
  installer `src/tmux.sh` was removed in `0586d4f` (Nov 2025). tmux is
  installed on this machine but absent from the Brewfile.

## Behavior

Ctrl+F → `dev-widget` → `dev()`:

1. fzf-pick a project directory from `DEV_DIRS` (unchanged).
2. Session name = directory basename with `.` replaced by `_`
   (tmux forbids dots in session names; `my.app` → `my_app`).
3. If no session with that name exists, create it detached:
   - window 1: `nvim .` in the project dir
   - window 2: plain shell in the project dir
   - focus on window 1
4. Attach: `tmux switch-client -t <name>` when already inside tmux
   (avoids the nested-session error), else `tmux attach -t <name>`.
5. If the session already exists, skip creation and just attach/switch —
   nvim and shell state persist across invocations.
6. If `tmux` is not on PATH, warn and fall back to the current
   `cd + nvim .` behavior.

## tmux.conf

New file `src/configs/tmux/tmux.conf`, deployed to
`~/.config/tmux/tmux.conf` (XDG path, matching ghostty/bat deployment).
Content restored from `git show 467b702~1:.tmux.conf` minus the plugin
block (no TPM, vim-tmux-navigator, resurrect, or continuum):

- `C-a` prefix (unbind `C-b`)
- `|` horizontal split, `-` vertical split
- `r` reloads `~/.config/tmux/tmux.conf` (path updated from `~/.tmux.conf`)
- `hjkl` pane resize (repeatable, 5 cells), `m` zoom toggle
- mouse on
- vi copy mode: `v` begin selection, `y` copy; no exit-on-mouse-drag
- `escape-time 10` (nvim Esc responsiveness)
- truecolor: `default-terminal "tmux-256color"` + RGB terminal-overrides

## Install wiring

Follows the existing per-tool installer pattern:

- `src/tmux.sh`: `install` copies `src/configs/tmux/*` to `~/.config/tmux/`
  (with `backup_if_exists`); `uninstall` prompts and removes the directory.
  Modeled on `src/ghostty.sh`.
- `Makefile`: `tmux` target invoking `./src/tmux.sh`, added to `.PHONY`
  and help text.
- Brewfile: add `brew "tmux"`.
- README: add tmux to the tool list.

Deploy model is copy-not-symlink: after implementation, run `make tmux`
and redeploy zsh config so the live shell picks up the new `dev()`.

## Testing

- `shellcheck`/`zsh -n` pass on the changed files.
- Live verification:
  - Ctrl+F outside tmux → session created with nvim + shell windows,
    attached, focused on nvim.
  - Ctrl+F inside tmux → `switch-client`, no nesting error.
  - Re-pick the same project → re-attach, existing state intact.
  - Project dir with a dot in its name → session created successfully.

## Out of scope (YAGNI)

- TPM or any tmux plugins (resurrect, continuum, vim-tmux-navigator)
- Terminal auto-attach (`tmux attach || tmux` on launch)
- Session kill/cleanup helpers
