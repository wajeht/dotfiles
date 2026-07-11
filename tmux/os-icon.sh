#!/bin/sh
# Print an OS marker for the machine this tmux server runs on. tmux.conf reads
# it once at startup into the @os_icon option; set-titles-string prepends it.
#
# The macOS titlebar (and the Linux window title) is drawn in the SYSTEM UI
# font, NOT the terminal's Nerd Font — so Nerd Font PUA glyphs (nf-*) render as
# tofu there. We therefore emit only what a system font can show:
#   - macOS: U+F8FF, the Apple logo baked into Apple's system fonts. It renders
#      natively (it's what Option-Shift-K types). Apple-only, so...
#   - Linux: a short lowercase distro tag in plain text (ubuntu, arch, ...),
#     since no titlebar font carries per-distro logos.
#
# This is the LOCAL machine's OS — #{user}@#h is always where the tmux server
# runs, so it does NOT change over SSH; a remote's identity rides in #{pane_title}.
case "$(uname -s)" in
Darwin)
	printf '\357\243\277' # U+F8FF  Apple logo (Apple system-font PUA)
	;;
Linux)
	# ID from os-release is lowercase per the spec (ubuntu, arch, debian, ...);
	# fall back to a generic tag if the file is missing or ID is unset.
	(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-linux}") || printf 'linux'
	;;
*)
	# Any other kernel (BSD, etc.): lowercase its uname.
	uname -s | tr '[:upper:]' '[:lower:]' | tr -d '\n'
	;;
esac
