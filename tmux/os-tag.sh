#!/bin/sh
# Print a plain-text OS tag for the machine this tmux server runs on. tmux.conf
# reads it once at startup into the @os_tag option; set-titles-string prepends
# it to the window title as "<os> · user@host · …".
#
# Plain text — not a Nerd Font glyph or logo — because the titlebar is drawn in
# the system UI font, which has no Nerd Font PUA glyphs (they'd render as tofu).
#
# This is the LOCAL machine's OS — #{user}@#h is always where the tmux server
# runs, so it does NOT change over SSH; a remote's identity rides in #{pane_title}.
case "$(uname -s)" in
Darwin)
	printf 'macos'
	;;
Linux)
	# ID from os-release is lowercase per the spec (ubuntu, fedora, arch, ...);
	# fall back to a generic tag if the file is missing or ID is unset.
	(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-linux}") || printf 'linux'
	;;
*)
	# Any other kernel (BSD, etc.): lowercase its uname.
	uname -s | tr '[:upper:]' '[:lower:]' | tr -d '\n'
	;;
esac
