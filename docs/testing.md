# Testing the dotfiles

How to try changes safely before shipping — mainly in a **throwaway macOS VM** (via
Tart) so you never touch your real machine, plus notes for the Linux/server path.
Everything here runs in a disposable guest; nothing mutates your host.

## Why a VM

`make install` does system-level things — `defaults write`, `chsh`, Homebrew casks,
config overwrites. A disposable macOS VM lets you run the *whole* install on a clean
OS, verify it, and throw it away. Apple's license permits up to **2 macOS VMs** per
Apple Silicon host (see the [Tart FAQ](https://tart.run/faq/) for the licensing note).

Requirements: an Apple Silicon Mac (the guest is arm64) and ~40+ GB free — the base
image is ~30 GB, and a full Brewfile install adds ~30–40 GB on top.

## macOS VM with Tart

[Tart](https://tart.run) runs macOS guests on Apple Silicon via Apple's
Virtualization.framework and pulls prebuilt images. It's CLI + SSH, so the whole test
can be scripted (that's why it beats a GUI tool like UTM for this).

### 1. Install Tart

```sh
brew install cirruslabs/cli/tart
# Homebrew gates third-party taps now — trust the official Cirrus Labs tap first,
# or the install errors with "Refusing to load formula ... from untrusted tap":
brew trust cirruslabs/cli
```

### 2. Pull a macOS image

Images live at `ghcr.io/cirruslabs/macos-<version>-<variant>` — browse the
[image templates repo](https://github.com/cirruslabs/macos-image-templates). Match the
image to your real OS:

```sh
# ~30 GB download; cached after the first pull
tart clone ghcr.io/cirruslabs/macos-tahoe-base:latest dotfiles-test
```

- **Versions:** `sonoma` (14), `sequoia` (15), `tahoe` (26), …
- **Variants:** `vanilla` (minimal), `base` (adds Homebrew + Command Line Tools — use
  this so `make install`'s Xcode-CLT check passes), `xcode` (adds full Xcode).

### 3. Boot it headless and SSH in

```sh
tart run dotfiles-test --no-graphics &   # must stay running — leave this shell open
ip=$(tart ip dotfiles-test)              # first boot can take ~30 s to get an IP
ssh admin@"$ip"                          # password: admin  (Cirrus Labs default, passwordless sudo)
```

Drop `--no-graphics` (or just `tart run dotfiles-test`) if you want a screen to eyeball
GUI changes.

### 4. Install the dotfiles inside the VM

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

### 5. Verify

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

### 6. Tear down

```sh
tart delete dotfiles-test                                  # frees the VM disk
tart delete ghcr.io/cirruslabs/macos-tahoe-base:latest     # optional: reclaim the ~30 GB base image
```

## Gotchas (learned the hard way)

- **Homebrew tap trust** — `brew install cirruslabs/cli/tart` fails until you run
  `brew trust cirruslabs/cli`.
- **Disk size** — the default guest disk (50 GB) fills to ~39 GB on a full Brewfile
  install. Resize before booting if needed: `tart set dotfiles-test --disk-size 100`.
- **Host sleep suspends the VM** — a long `make install` gets interrupted if the Mac
  sleeps. Run it under `caffeinate -s …` or keep the host awake.
- **macOS prefs domains are case-insensitive** — `com.apple.terminal` and
  `com.apple.Terminal` hit the same store on a standard (case-insensitive) APFS volume,
  so a casing "typo" in a `defaults` domain isn't necessarily broken. Prefer correct
  casing regardless (it matters on case-sensitive volumes).
- **`brew` vs `cask`** — CLI formulae are `brew "x"`, GUI apps are `cask "x"`. Mixing
  them up makes that Brewfile entry fail during `make brew`.

## Linux / server path

The Linux install (`make server`) is tested on the actual Ubuntu box over SSH, or in a
throwaway Ubuntu VM:

- **Real server** — `ssh <host>`, `git pull` in the dotfiles, `make server install`.
- **Throwaway Ubuntu VM on macOS** — [OrbStack](https://orbstack.dev),
  [Lima](https://lima-vm.io), or [Multipass](https://multipass.run) spin up a quick
  Ubuntu guest; clone + `make server install` inside it.
- **Isolated function tests** — the release-download helper can be exercised without a
  full install:
  ```sh
  ( source src/_util.sh; HOME=$(mktemp -d) install_release_bin "<release-url>" <bin-name> )
  ```

## Notes
- The base image is cached after the first pull, so re-testing is fast (no re-download)
  unless you delete it.
- Version numbers here (macOS 26 Tahoe, etc.) drift over time — the mechanism is the
  point, not the pins.
