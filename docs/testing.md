# Testing the dotfiles

How to try changes safely before shipping — mainly in a **throwaway macOS VM** (via
Tart) so you never touch your real machine, plus notes for the Linux/server path.
Everything here runs in a disposable guest; nothing mutates your host.

## Why a VM

`make install` does system-level things — `defaults write`, `chsh`, Homebrew casks,
config overwrites. A disposable macOS VM lets you run the *whole* install on a clean
OS, verify it, and throw it away. Apple's license permits up to two macOS VMs per
Apple Silicon host (see the [Tart FAQ](https://tart.run/faq/) for the licensing note).

Requirements: an Apple Silicon Mac (the guest is arm64) and ~40+ GB free — the base
image is ~30 GB, and a full Brewfile install adds ~30–40 GB on top.

## Install Tart

[Tart](https://tart.run) runs macOS guests on Apple Silicon via Apple's
Virtualization.framework and pulls prebuilt images. It's CLI + SSH, so the whole test
can be scripted (that's why it beats a GUI tool like UTM for this).

```sh
brew install cirruslabs/cli/tart
# Homebrew gates third-party taps now — trust the official Cirrus Labs tap first,
# or the install errors with "Refusing to load formula ... from untrusted tap":
brew trust cirruslabs/cli
```

## Pull a macOS image

Images live at `ghcr.io/cirruslabs/macos-<version>-<variant>` — browse the
[image templates repo](https://github.com/cirruslabs/macos-image-templates). Match the
image to your real OS:

```sh
# ~30 GB download; cached after the first pull
tart clone ghcr.io/cirruslabs/macos-tahoe-base:latest dotfiles-test
```

- Versions: `sonoma` (14), `sequoia` (15), `tahoe` (26), …
- Variants: `vanilla` (minimal), `base` (adds Homebrew + Command Line Tools — use this
  so `make install`'s Xcode-CLT check passes), `xcode` (adds full Xcode).

## Boot the VM and SSH in

```sh
tart run dotfiles-test --no-graphics &   # must stay running — leave this shell open
ip=$(tart ip dotfiles-test)              # first boot can take ~30 s to get an IP
ssh admin@"$ip"                          # password: admin (Cirrus Labs default, passwordless sudo)
```

Drop `--no-graphics` (or just `tart run dotfiles-test`) if you want a screen to eyeball
GUI changes.

## Install the dotfiles in the VM

```sh
git clone https://github.com/wajeht/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Scoped + fast — system defaults, then each config component (one make call each):
make macos
for c in git zsh nvim ghostty bat lsd tmux; do make "$c" install; done

# Or the full install — slow: pulls the entire Brewfile incl. GUI casks (~30–40 GB).
# Wrap in caffeinate so host sleep can't suspend the VM mid-run:
caffeinate -s make install
```

## Verify

```sh
# Did the macOS defaults actually take?
defaults read com.apple.dock tilesize                 # 16
defaults read com.apple.finder FXPreferredViewStyle   # Nlsv
defaults read com.apple.Terminal SecureKeyboardEntry  # 1

# Configs landed, no stale wiring?
ls ~/.config
git config --file ~/.config/git/config --get diff.external   # (unset — built-in diff)

# Shell loads clean, features present?
zsh -ic 'echo ok; alias three >/dev/null && echo alias-ok; typeset -f chpwd >/dev/null && echo chpwd-ok'
```

## Tear down

```sh
tart delete dotfiles-test                                  # frees the VM disk
tart delete ghcr.io/cirruslabs/macos-tahoe-base:latest     # optional: reclaim the ~30 GB base image
```

## Gotchas

Things learned the hard way:

- Homebrew tap trust — `brew install cirruslabs/cli/tart` fails until you run
  `brew trust cirruslabs/cli`.
- Disk size — the default guest disk (50 GB) fills to ~39 GB on a full Brewfile
  install. Resize before booting if needed: `tart set dotfiles-test --disk-size 100`.
- Host sleep suspends the VM — a long `make install` gets interrupted if the Mac
  sleeps. Run it under `caffeinate -s …` or keep the host awake.
- macOS prefs domains are case-insensitive — `com.apple.terminal` and
  `com.apple.Terminal` hit the same store on a standard (case-insensitive) APFS volume,
  so a casing "typo" in a `defaults` domain isn't necessarily broken. Prefer correct
  casing regardless (it matters on case-sensitive volumes).
- `brew` vs `cask` — CLI formulae are `brew "x"`, GUI apps are `cask "x"`. Mixing them
  up makes that Brewfile entry fail during `make brew`.

## macOS GUI automation notes

Use this pattern when a macOS preference cannot be set with `defaults write`, like some
Finder Sidebar rows:

- Prefer stable defaults first. Example: `defaults write com.apple.finder
  SidebarShowRecents -bool false`.
- If the setting only exists in a GUI, use AppleScript through `System Events`.
- Add a preflight script before clicking anything. This forces macOS to show
  Finder/System Events/Accessibility permission prompts before the real automation runs.
- Tell the user to allow the prompt, then rerun the command. Do not write a "done"
  marker until the real automation succeeds.
- Avoid screen coordinates when possible. Finder Settings exposes Sidebar rows as
  checkboxes under `scroll area 1`; match them by `description`, not by x/y position.
- Use a marker file for one-time GUI changes, for example
  `~/.config/dotfiles/finder-sidebar-settings-applied`, so normal reruns do not keep
  clicking checkboxes.
- Close preference windows with `click button 1 of win` in a `try` block. Finder
  Settings may not behave like a normal Finder window.

Useful debug scripts inside a visible Tart VM:

```applescript
tell application "System Events"
    tell process "Finder"
        return name of every window
    end tell
end tell
```

```applescript
set out to ""

tell application "System Events"
    tell process "Finder"
        tell scroll area 1 of window "Finder Settings"
            repeat with e in UI elements
                set out to out & "role=" & (role of e as text)
                try
                    set out to out & " desc=" & (description of e as text)
                end try
                try
                    set out to out & " value=" & (value of e as text)
                end try
                set out to out & linefeed
            end repeat
        end tell
    end tell
end tell

return out
```

Run those from the GUI Terminal app, not SSH, because macOS privacy permissions are
per-app. `tart exec ... osascript` may fail even when Terminal is already authorized.

## Linux / server path

The Linux install (`make server`) is tested on the actual Ubuntu box over SSH, or in a
throwaway Ubuntu VM:

- Real server — `ssh <host>`, `git pull` in the dotfiles, `make server install`.
- Throwaway Ubuntu VM on macOS — [OrbStack](https://orbstack.dev),
  [Lima](https://lima-vm.io), or [Multipass](https://multipass.run) spin up a quick
  Ubuntu guest; clone + `make server install` inside it.
- Isolated function tests — the release-download helper can be exercised without a full
  install:
  ```sh
  ( source src/_util.sh; HOME=$(mktemp -d) install_release_bin "<release-url>" <bin-name> )
  ```

## Notes

- Default credentials: `admin` / `admin` — for both SSH and the GUI login screen (e.g.
  after logout), with passwordless `sudo`.
- The base image is cached after the first pull, so re-testing is fast (no re-download)
  unless you delete it.
- Version numbers here (macOS 26 Tahoe, etc.) drift over time — the mechanism is the
  point, not the pins.
