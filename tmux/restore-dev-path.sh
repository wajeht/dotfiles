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
# the stamp for each still-unstamped session. To re-stamp a session we require
# BOTH signals dev() itself couples, so we never claim a folder dev() wouldn't:
#   1. one of the session's panes sits in a real project dir (resolved to its
#      physical path, matched against the same immediate/non-hidden subdirs of
#      the DEV_DIRS roots that dev() enumerates), and
#   2. the session's NAME is the one dev() derives for that dir (its sanitized
#      basename, or the parent-prefixed / underscore-suffixed disambiguation).
# So a scratch session merely cd'd into a project keeps its own name and is left
# alone, and a project session whose shell pane wandered into a *different*
# project isn't mis-stamped to it. The stamp value is the physical dir, matching
# dev()'s own ${dir:A} stamp and the picker's ${dpath:A} dedup key.

# The DEV_DIRS roots, kept as the single source of truth in functions.zsh: parse
# the array literal there (`DEV_DIRS=(~/Dev ~/Work ...)`) and expand a leading ~
# to $HOME. Falls back to the documented default if the file is absent/edited
# into a form we can't parse, so a restore is never left worse than before.
get_roots() {
    _raw=$(sed -n 's/^[[:space:]]*DEV_DIRS=(\(.*\)).*/\1/p' \
        "$HOME/.config/zsh/functions.zsh" 2>/dev/null | head -1)
    [ -n "$_raw" ] || _raw='~/Dev ~/Work ~/dev ~/work'
    for _t in $_raw; do
        case "$_t" in
        "~") printf '%s\n' "$HOME" ;;
        "~/"*) printf '%s\n' "$HOME/${_t#\~/}" ;;
        *) printf '%s\n' "$_t" ;;
        esac
    done
}

# Resolved (symlink-followed) physical path of each existing root, one per line.
# Resolving here — and resolving pane cwds below — is what lets the string
# compare match even when a root like ~/Dev is itself a symlink.
RROOTS=$(get_roots | while IFS= read -r _r; do
    [ -d "$_r" ] || continue
    (cd "$_r" 2>/dev/null && pwd -P)
done)

# tmux forbids '.'/':' in session names; dev() maps every char outside
# [A-Za-z0-9_-] to '_'. printf (no trailing newline) keeps tr from adding one.
sanitize() { printf '%s' "$1" | tr -c 'A-Za-z0-9_-' '_'; }

# True when $1 is an immediate, non-hidden subdir of a (resolved) root — the
# resolved-path equivalent of _dev_projects' `find -mindepth 1 -maxdepth 1
# -type d -not -path '*/.*'`. Caller has already confirmed $1 exists as a dir.
is_project() {
    _b=${1##*/}
    case "$_b" in .*) return 1 ;; esac
    printf '%s\n' "$RROOTS" | grep -qxF -- "${1%/*}"
}

# True when session name $1 is the name dev() would give project-name $2:
# exact, or $2 followed only by the '_' chars dev()'s clash loop appends.
name_matches() {
    [ "$1" = "$2" ] && return 0
    _rest=${1#"$2"}
    [ "$_rest" = "$1" ] && return 1 # $2 wasn't even a prefix
    case "$_rest" in
    *[!_]*) return 1 ;; # trailing chars aren't all underscores
    *) return 0 ;;
    esac
}

tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
    [ -n "$session" ] || continue
    # A stamp already present means a freshly created (not restored) session.
    [ -n "$(tmux show-options -t "$session" -qv @dev_path 2>/dev/null)" ] && continue
    tmux list-panes -s -t "$session" -F '#{pane_current_path}' 2>/dev/null |
        while IFS= read -r cwd; do
            [ -n "$cwd" ] || continue
            rp=$(cd "$cwd" 2>/dev/null && pwd -P) || continue
            is_project "$rp" || continue
            base=$(sanitize "${rp##*/}")
            parent=${rp%/*}
            pfx="$(sanitize "${parent##*/}")_${base}"
            if name_matches "$session" "$base" || name_matches "$session" "$pfx"; then
                tmux set-option -t "$session" @dev_path "$rp"
                break
            fi
        done
done
