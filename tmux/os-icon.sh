#!/bin/sh
# Print a Nerd Font glyph for the OS this tmux server runs on. tmux.conf reads
# it once at startup into the @os_icon option (set-titles-string references it).
#
# This is the LOCAL machine's OS — the title's #{user}@#h is always where the
# tmux server runs, so the glyph does NOT change when you SSH out. A remote
# distro's identity rides in #{pane_title} instead (the part after the em dash).
#
# Glyphs come from the Nerd Font "fa"/"linux" sets. Bytes are written as octal
# UTF-8 escapes (POSIX printf), with the U+xxxx codepoint noted so you can swap
# any that render as tofu in your patched font.
case "$(uname -s)" in
Darwin)
	printf '\357\205\271' # U+F179  nf-fa-apple
	;;
Linux)
	# Match on ID plus ID_LIKE so derivatives (e.g. Linux Mint -> ubuntu) map to
	# their parent distro's glyph; fall back to Tux for anything unlisted.
	id=$(. /etc/os-release 2>/dev/null && echo "${ID} ${ID_LIKE}")
	case "$id" in
	*ubuntu*) printf '\357\214\233' ;;        # U+F31B  nf-linux-ubuntu
	*arch*) printf '\357\214\203' ;;          # U+F303  nf-linux-archlinux
	*debian*) printf '\357\214\206' ;;        # U+F306  nf-linux-debian
	*fedora* | *rhel*) printf '\357\214\212' ;; # U+F30A  nf-linux-fedora
	*) printf '\357\205\274' ;;               # U+F17C  nf-fa-linux (Tux)
	esac
	;;
*)
	printf '\357\205\274' # U+F17C  Tux fallback
	;;
esac
