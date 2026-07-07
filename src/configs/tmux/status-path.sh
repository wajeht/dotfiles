#!/bin/sh
# Renders the status-right path like the zsh prompt: cyan ~path, white 'on',
# green branch (ANSI colors so it matches PROMPT's %F{cyan}/%F{green}).
cd "$1" 2>/dev/null || exit 0
p=$(pwd)
case "$p" in
"$HOME"*) p="~${p#"$HOME"}" ;;
esac
b=$(git branch --show-current 2>/dev/null)
if [ -n "$b" ]; then
    printf '#[fg=cyan]%s #[fg=white]on #[fg=green]%s' "$p" "$b"
else
    printf '#[fg=cyan]%s' "$p"
fi
