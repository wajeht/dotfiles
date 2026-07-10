# tmux Cheatsheet

The **prefix** is `Ctrl+a` (written `C-a` below). Press `C-a`, release, then the
key. Binds marked **⚙** are custom to this config (`src/configs/tmux/tmux.conf`);
the rest are tmux defaults.

## Windows

| Action | Keys |
|---|---|
| New window | `C-a c` |
| New window (no prefix) | `Cmd+T` ⚙ (opens in the current dir) |
| Rename window | `C-a ,` |
| Close window | `C-a &` (asks to confirm) |
| Close window (no prefix) | `Cmd+W` ⚙ (asks to confirm) |
| Next / previous window | `C-a n` / `C-a p` |
| Next / previous window (no prefix) | `Ctrl+Tab` / `Ctrl+Shift+Tab` ⚙ |
| Jump to window N | `C-a 0`…`9` |
| Pick window from a list | `C-a w` |
| Find window by name | `C-a f` |
| Move window to another index | `C-a .` |

## Panes

| Action | Keys |
|---|---|
| Split left/right (vertical bar) | `C-a \|` ⚙ |
| Split top/bottom | `C-a -` ⚙ |
| Close pane | `C-a x` (confirm) |
| Move between panes / nvim splits (no prefix) | `Ctrl+h/j/k/l` ⚙ (seamless with nvim via vim-tmux-navigator) |
| Move between panes | `C-a` + arrow keys, or `C-a o` to cycle |
| Resize pane (±5) | `C-a h/j/k/l` ⚙ (left/down/up/right) |
| Zoom pane fullscreen (toggle) | `C-a m` ⚙ (or default `C-a z`) |
| Show pane numbers | `C-a q` |
| Break pane into its own window | `C-a !` |
| Rotate / swap panes | `C-a {` / `C-a }` |

## Sessions

| Action | Keys |
|---|---|
| Sessionizer — switch / open / create, one prompt | `C-f` ⚙ (no prefix — works even inside nvim) |
| New session (named), the easy way | `C-f`, type a name that matches no folder, Enter → creates it (rooted at `$HOME`) |
| New session (named), from a plain shell | `tmux new -s <name>` (the `-s` names it; a bare word is treated as a command to run) |
| New session (named), **inside** tmux without `C-f` | `C-a :` then `new -s <name>` (don't run `tmux new` — it refuses to nest) |
| Detach (leave tmux running) | `C-a d` |
| List / switch sessions | `C-a s` |
| Rename session | `C-a $` |
| Previous / next session | `C-a (` / `C-a )` |
| Save sessions for reboot | `C-a Ctrl-s` ⚙ |
| Restore saved sessions | `C-a Ctrl-r` ⚙ |

Sessions are autosaved every 5 minutes and restored when the tmux server starts.
This uses `tmux-resurrect` and `tmux-continuum` through TPM. Layouts, panes,
working directories, and pane contents are saved. Running programs are restored
where `tmux-resurrect` supports them; otherwise the pane reopens in the saved
directory.

## Copy / scroll (vi mode)

| Action | Keys |
|---|---|
| Enter copy mode (scroll with `k`/`j`, `C-u`/`C-d`) | `C-a [` |
| Start selection | `v` ⚙ |
| Copy selection | `y` ⚙ |
| Paste | `C-a ]` |
| Search up / down (in copy mode) | `?` / `/` |
| Quit copy mode | `q` |

## Misc

| Action | Keys |
|---|---|
| Newline in Claude Code (no prefix) | `Shift+Enter` ⚙ (nvim/ssh panes get the real key; other panes get a newline byte) |
| Clear screen | `Ctrl-L` or `Cmd-K` ⚙ (in a split, moves to the right pane first if one exists) |
| Reload tmux config | `C-a r` ⚙ |
| Command prompt (type any command) | `C-a :` |
| List every keybinding | `C-a ?` |
| Send a literal `C-a` to the app | `C-a C-a` |

## Gotcha

The default "last window" bind is `C-a l`, but `l` is remapped to **resize pane
right** ⚙ — so `C-a l` resizes, it won't toggle to the last window. Use
`C-a n`/`p` or the number keys instead.

## Command prompt

For anything without a key, `C-a :` opens the command line:

```
:rename-window api
:rename-session backend
:move-window -t 3
:swap-window -t 1
:kill-window
:kill-session
:new-window
```
