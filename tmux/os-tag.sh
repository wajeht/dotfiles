#!/bin/sh
# Print a plain-text OS tag ("macos", or the distro id on Linux) for the machine
# the tmux server runs on — read once into @os_tag and prepended to the title.
# Plain text, not a Nerd Font glyph: the titlebar's system font would tofu nf-*.
case "$(uname -s)" in
Darwin)
	printf 'macos'
	;;
Linux)
	# os-release ID is lowercase (ubuntu, fedora, …); generic fallback otherwise.
	(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-linux}") || printf 'linux'
	;;
*)
	uname -s | tr '[:upper:]' '[:lower:]' | tr -d '\n'
	;;
esac
