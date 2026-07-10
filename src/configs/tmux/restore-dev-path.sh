#!/bin/sh
# Re-stamp @dev_path on sessions after a tmux-resurrect restore.
#
# The `dev` picker (zsh functions.zsh) dedupes a project's folder against its
# session by reading a custom @dev_path option that dev() stamps on each project
# session. tmux-resurrect restores sessions, windows and panes but NOT
# @-prefixed user options, so after a reboot every restored session loses its
# @dev_path. The picker then shows every folder again alongside its own session
# AND, when you pick that folder, the disambiguation loop in dev() sees the
# restored session as an unrelated same-named one and spawns a duplicate under a
# parent-prefixed name (bang -> dev_bang).
#
# This hook (wired via @resurrect-hook-post-restore-all in tmux.conf) rebuilds
# the stamp: for each still-unstamped session it inspects its panes' cwds and,
# on the first one that is exactly a known project dir, re-stamps @dev_path —
# mirroring the project set dev() enumerates (immediate, non-hidden subdirs of
# the DEV_DIRS roots). Panes list lowest-window-first, so the nvim window at the
# project root is matched before any shell window the cwd may have wandered in.

# True when $1 is an immediate, non-hidden subdirectory of a DEV_DIRS root —
# the same membership _dev_projects computes with `find -mindepth 1 -maxdepth 1
# -type d -not -path '*/.*'`. Keep the roots in sync with DEV_DIRS.
is_project() {
	_p="$1"
	_base=${_p##*/}
	[ -n "$_base" ] || return 1
	case "$_base" in .*) return 1 ;; esac
	_parent=${_p%/*}
	for _root in "$HOME/Dev" "$HOME/Work" "$HOME/dev" "$HOME/work"; do
		[ "$_parent" = "$_root" ] && [ -d "$_p" ] && return 0
	done
	return 1
}

tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
	[ -n "$session" ] || continue
	# A stamp already present means a freshly created (not restored) session.
	[ -n "$(tmux show-options -t "$session" -qv @dev_path 2>/dev/null)" ] && continue
	tmux list-panes -s -t "$session" -F '#{pane_current_path}' 2>/dev/null |
		while IFS= read -r path; do
			if is_project "$path"; then
				tmux set-option -t "$session" @dev_path "$path"
				break
			fi
		done
done
