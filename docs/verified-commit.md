# Verified Commits (SSH signing) on macOS

Manual walkthrough for generating an SSH key, loading it into the macOS Keychain, and
configuring Git to sign commits so they show as **Verified** on GitHub. The dotfiles
automate most of this via `make git install`; see [ssh.md](ssh.md) for the automated setup.

## Generate an SSH key

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

- `-t ed25519` → modern, secure key type
- `-C` → adds your email as a label/comment

When prompted:

- File path: press **Enter** to accept the default (`~/.ssh/id_ed25519`)
- Passphrase: recommended — adds encryption for your private key

## Add the key to the macOS Keychain

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add your key and store the passphrase in the Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Check the key is loaded:

```bash
ssh-add -l
# 256 SHA256:... /Users/jaw/.ssh/id_ed25519 (ED25519)
```

## Add the public key to GitHub

Copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

- Go to **GitHub → Settings → SSH and GPG keys → New SSH key**
- Title: `MacBook SSH signing key` (or similar)
- Paste the key and save

## Configure Git to use SSH signing

```bash
git config --global gpg.format ssh
git config --global user.signingKey ~/.ssh/id_ed25519.pub
git config --global commit.gpgSign true
```

Verify:

```bash
git config --global --get gpg.format        # ssh
git config --global --get user.signingKey   # /Users/jaw/.ssh/id_ed25519.pub
```

## Load the key automatically (optional)

Add to `~/.ssh/config` so macOS loads the key with its passphrase on login:

```text
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

## Verify a signed commit

```bash
git commit -S -m "Test SSH signed commit"
git log --show-signature -1
# Good SSH signature for user wajeht with ED25519 key
```

## Git config reference

Example `.gitconfig` with SSH signing integrated:

```ini
[user]
    name = wajeht
    email = 58354193+wajeht@users.noreply.github.com
    signingKey = ~/.ssh/id_ed25519.pub

[gpg]
    format = ssh

[commit]
    gpgSign = true

[core]
    editor = nvim
    fsmonitor = true
    autocrlf = input
    excludesfile = ~/.gitignore_global

[alias]
    push = push --no-verify
    discard = restore .
    undo = reset --soft HEAD^
    aicommit = "!f() { curl -s https://commit.jaw.dev/ | bash -s -- --no-verify; }; f"
    auto = "!f() { git add -A && git aicommit && git push --no-verify ; }; f"

[diff]
    tool = vimdiff
    algorithm = histogram
    colorMoved = zebra

[merge]
    tool = vimdiff
    conflictstyle = zdiff3

[color]
    ui = auto

[rerere]
    enabled = true
    autoUpdate = true

[help]
    autocorrect = 10
```

## Notes

- Use a **passphrase** for security; the Keychain stores it so you don't retype it.
- Your commits will show as **Verified** on GitHub.
- This setup works for both commit signing and SSH authentication for `git push`/`pull`.
