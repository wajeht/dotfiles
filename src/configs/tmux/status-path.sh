#!/bin/sh
# Emits the git segment for the right zone of the status line: white 'on', green branch,
# then change counts [+staged !modified xdeleted ?untracked] in the same colors
# as prompt_git_status (.zshrc) so the two match. The session name is prepended
# by tmux; this prints nothing when the pane is not inside a git repo.
# Invoke as `/bin/sh status-path.sh` (macOS re-scans unsigned scripts on
# every direct exec, ~400ms; going through the interpreter skips it).
cd "$1" 2>/dev/null || exit 0

# One git call: branch + change counts. --no-optional-locks: never write
# index locks from a background poller; fsmonitor off: the daemon roundtrip
# costs ~150ms+ and a 5s poll gains nothing from it
out=$(git -c core.fsmonitor=false --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
[ -z "$out" ] && exit 0

set -- $(printf '%s\n' "$out" | awk '
    /^# branch\.head / { bh = $3 }
    /^\? /             { u++; next }
    /^[12] / {
        if (substr($2, 1, 1) != ".") s++
        if (substr($2, 2, 1) == "M") m++
        if (substr($2, 2, 1) == "D") d++
    }
    END { printf "%s %d %d %d %d", bh, s, m, d, u }')
b=$1
g=""
[ "$2" -gt 0 ] && g="${g}#[fg=green]+$2"
[ "$3" -gt 0 ] && g="${g}#[fg=yellow]!$3"
[ "$4" -gt 0 ] && g="${g}#[fg=red]x$4"
[ "$5" -gt 0 ] && g="${g}#[fg=cyan]?$5"
[ -n "$g" ] && g=" #[fg=white][${g}#[fg=white]]"

printf ' #[fg=white]on #[fg=green]%s%s' "$b" "$g"
