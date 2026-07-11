#!/usr/bin/env bash
# End-to-end test for the tmux-resurrect @dev_path restore hook
# (src/configs/tmux/restore-dev-path.sh).
#
# Run it from anywhere in the repo — no arguments:
#
#     ./tests/tmux-resurrect-restore.sh
#
# It spins up a disposable Ubuntu container, does the REAL deploy
# (`make tmux install`), then drives a REAL resurrect save -> kill-server ->
# restore cycle so it exercises the actual hook wiring
# (@resurrect-hook-post-restore-all), not a manual call. It proves both halves:
#
#   * the bug  — resurrect drops @dev_path, so a hook-less restore brings
#                sessions back unstamped; and
#   * the fix  — with the hook wired, restore re-stamps the genuine project
#                sessions (bang, dotfiles) while leaving a scratch session
#                sitting in a project dir (notes) and an ad-hoc session (misc)
#                untouched — the two guards from the code review.
#
# Requires Docker with outbound network (to apt-install tmux and let TPM clone
# the resurrect/continuum plugins). Nothing touches the host: no host tmux
# server, no host config. Override the base image with TEST_IMAGE=... if needed.
set -u

# ---------------------------------------------------------------------------
# Host side: re-exec this same script inside a throwaway container.
# ---------------------------------------------------------------------------
if [ -z "${IN_CONTAINER:-}" ]; then
	command -v docker >/dev/null 2>&1 || { echo "docker is required"; exit 1; }
	repo=$(cd "$(dirname "$0")/.." && pwd)
	exec docker run --rm \
		-e IN_CONTAINER=1 \
		-v "$repo":/repo:ro \
		-v "$0":/test.sh:ro \
		"${TEST_IMAGE:-ubuntu:24.04}" bash /test.sh
fi

# ---------------------------------------------------------------------------
# Container side: the actual test.
# ---------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive HOME=/root

# Bring a fresh headless server up as if the machine just rebooted. $1 = whether
# to wire the restore hook (yes/no), so we can show the before (bug) and after
# (fix) of the exact same restore.
hook_line() { grep -m1 'resurrect-hook-post-restore-all' ~/.config/tmux/tmux.conf; }
boot_server() {
	tmux kill-server 2>/dev/null || true
	# Wait until the old server is TRULY gone before starting a new one, else
	# new-session attaches to the dying old server and its stale sessions/stamps
	# survive — masking the very thing we're testing.
	while tmux list-sessions >/dev/null 2>&1; do sleep 0.1; done
	# -f /dev/null is essential: tmux auto-loads ~/.config/tmux/tmux.conf (the
	# XDG default) on every server start, which would set the hook option even
	# when we mean to test WITHOUT it. Start from an empty config, then set
	# resurrect's options explicitly — and the hook ONLY in the 'yes' case (also
	# skips continuum's auto-restore, so nothing races the restore we drive).
	tmux -f /dev/null new-session -d -s _boot -c ~
	tmux set-option -g @resurrect-dir '~/.local/share/tmux/resurrect'
	tmux set-option -g @resurrect-capture-pane-contents 'on'
	if [ "$1" = yes ]; then
		line=$(hook_line); line=${line#*set -g } # apply the deployed line verbatim
		eval "tmux set-option -g $line"
	fi
	echo "  (boot server up; hook = [$(tmux show-options -gqv @resurrect-hook-post-restore-all)])"
}

echo "############################################################"
echo "# 0. install deps + deploy dotfiles tmux config"
echo "############################################################"
apt-get -qq update >/dev/null
apt-get -qq install -y tmux zsh git make procps findutils ca-certificates >/dev/null
echo "tmux: $(tmux -V)"

cp -r /repo /root/dotfiles
cd /root/dotfiles
make tmux install >/tmp/install.log 2>&1 || { echo "INSTALL FAILED"; tail -30 /tmp/install.log; exit 1; }
# Install the zsh functions too, so the hook parses DEV_DIRS from its single
# source (functions.zsh) rather than the built-in fallback.
mkdir -p ~/.config/zsh
cp src/configs/zsh/functions.zsh ~/.config/zsh/functions.zsh

echo "--- deploy landed? ---"
test -f ~/.config/tmux/restore-dev-path.sh && echo "OK  restore-dev-path.sh installed" || { echo "MISSING script"; exit 1; }
grep -q 'resurrect-hook-post-restore-all' ~/.config/tmux/tmux.conf && echo "OK  hook wired in tmux.conf" || { echo "hook NOT wired"; exit 1; }
test -d ~/.config/tmux/plugins/tmux-resurrect && echo "OK  tmux-resurrect present" || { echo "resurrect missing"; exit 1; }
tmux kill-server 2>/dev/null || true

RES=~/.config/tmux/plugins/tmux-resurrect/scripts
CONF=~/.config/tmux/tmux.conf
show() { tmux list-sessions -F '  #{session_name}	[#{@dev_path}]' 2>/dev/null | sort; }

echo
echo "############################################################"
echo "# 1. build dev()-style sessions, then resurrect-SAVE them"
echo "############################################################"
mkdir -p ~/Dev/bang ~/Dev/dotfiles ~/scratchdir
tmux -f "$CONF" new-session -d -s bang -c ~/Dev/bang -n nvim
tmux new-window -t bang -c ~/Dev/bang -n shell
tmux set-option -t bang @dev_path ~/Dev/bang          # what dev() stamps
tmux new-session -d -s dotfiles -c ~/Dev/dotfiles -n nvim
tmux set-option -t dotfiles @dev_path ~/Dev/dotfiles
tmux new-session -d -s notes -c ~/Dev/bang            # scratch INSIDE a project (#1a: must stay unstamped)
tmux new-session -d -s misc  -c ~/scratchdir          # ad-hoc, outside any project
echo "sessions before save:"; show
tmux run-shell "$RES/save.sh"
SAVEFILE=$(ls -1 ~/.local/share/tmux/resurrect/tmux_resurrect_*.txt 2>/dev/null | tail -1)
echo "resurrect save file: $SAVEFILE"
echo "does the save file persist @dev_path?  ->  $(grep -c 'dev_path' "$SAVEFILE" 2>/dev/null) matches"
echo "  (0 = resurrect drops the stamp: the premise of the bug)"

echo
echo "############################################################"
echo "# 2. simulate reboot: restore WITHOUT the hook"
echo "#    (proves resurrect alone loses @dev_path -> the bug)"
echo "############################################################"
boot_server no
echo "fresh server BEFORE restore (should be only _boot):"; show
tmux run-shell "$RES/restore.sh" 2>/dev/null || echo "  (restore returned $?)"
sleep 0.5
echo "after restore, hook DISABLED:"; show
echo "  ^ every @dev_path is empty = the original bug reproduced"

echo
echo "############################################################"
echo "# 3. reboot again, restore WITH the hook (the fix)"
echo "############################################################"
boot_server yes
tmux run-shell "$RES/restore.sh" 2>/dev/null || echo "  (restore returned $?)"
sleep 0.5
echo "after restore, hook ENABLED:"; show

echo
echo "############################################################"
echo "# 4. assertions"
echo "############################################################"
fail=0
chk() { # $1 = session, $2 = expected @dev_path ("" means must be empty)
	got=$(tmux show-options -t "$1" -qv @dev_path 2>/dev/null)
	if [ "$got" = "$2" ]; then echo "PASS  $1 -> [${got}]"; else echo "FAIL  $1 -> [${got}] (expected [${2}])"; fail=1; fi
}
chk bang     "$HOME/Dev/bang"     # re-stamped: name==basename, pane at root
chk dotfiles "$HOME/Dev/dotfiles" # re-stamped
chk notes    ""                   # #1a: scratch in a project, wrong name -> NOT claimed
chk misc     ""                   # ad-hoc outside projects -> NOT claimed
echo
[ "$fail" = 0 ] && echo "########## ALL ASSERTIONS PASSED ##########" || { echo "########## SOME ASSERTIONS FAILED ##########"; exit 1; }
