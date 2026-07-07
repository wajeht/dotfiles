#!/bin/sh
# Renders status-right like the zsh prompt: cyan ~path, white 'on', green
# branch, then change counts [+staged !modified xdeleted ?untracked] in the
# same colors as prompt_git_status (.zshrc). ANSI colors so both match.
cd "$1" 2>/dev/null || exit 0
p=$(pwd)
case "$p" in
"$HOME"*) p="~${p#"$HOME"}" ;;
esac
b=$(git branch --show-current 2>/dev/null)
if [ -z "$b" ]; then
    printf '#[fg=cyan]%s' "$p"
    exit 0
fi

counts=$(git status --porcelain 2>/dev/null | awk '
    /^\?\?/ { u++; next }
    substr($0, 1, 1) ~ /[MADRC]/ { s++ }
    substr($0, 2, 1) == "M" { m++ }
    substr($0, 2, 1) == "D" { d++ }
    END { printf "%d %d %d %d", s, m, d, u }')
set -- $counts
g=""
[ "$1" -gt 0 ] && g="${g}#[fg=green]+$1"
[ "$2" -gt 0 ] && g="${g}#[fg=yellow]!$2"
[ "$3" -gt 0 ] && g="${g}#[fg=red]x$3"
[ "$4" -gt 0 ] && g="${g}#[fg=cyan]?$4"
[ -n "$g" ] && g=" #[fg=white][${g}#[fg=white]]"

printf '#[fg=cyan]%s #[fg=white]on #[fg=green]%s%s' "$p" "$b" "$g"
