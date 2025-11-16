# Git SSH Key & Commit Signing Setup on macOS

## 1. Generate an SSH Key

Run in Terminal:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

* `-t ed25519` → modern, secure key type
* `-C` → adds your email as a label/comment

**When prompted:**

* File path: press **Enter** to accept default (`~/.ssh/id_ed25519`)
* Passphrase: recommended, adds encryption for your private key

---

## 2. Add the Key to macOS Keychain

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add your key to the agent and store passphrase in Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Check the key is loaded:

```bash
ssh-add -l
```

Expected output:

```
256 SHA256:... /Users/jaw/.ssh/id_ed25519 (ED25519)
```

---

## 3. Add Public Key to GitHub

Copy the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

1. Go to **GitHub → Settings → SSH and GPG keys → New SSH key**
2. Title: `MacBook SSH signing key` (or similar)
3. Paste the key and save

---

## 4. Configure Git to Use SSH Signing

Update your global `.gitconfig`:

```bash
git config --global gpg.format ssh
git config --global user.signingKey ~/.ssh/id_ed25519.pub
git config --global commit.gpgSign true
```

Verify:

```bash
git config --global --get gpg.format
git config --global --get user.signingKey
```

Expected output:

```
ssh
/Users/jaw/.ssh/id_ed25519.pub
```

---

## 5. Optional: Permanent SSH Key Loading

Create or edit `~/.ssh/config` and add:

```text
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

Now macOS will automatically load your key with the passphrase on login.

---

## 6. Verify Signed Commit

Make a test commit:

```bash
git commit -S -m "Test SSH signed commit"
```

Check the signature:

```bash
git log --show-signature -1
```

Expected output:

```
Good SSH signature for user wajeht with ED25519 key
```

---

## 7. Git Config Reference

Here is an example `.gitconfig` with SSH signing integrated:

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
    aicommit = "!f() { curl -s https://commit.jaw.dev/ | sh -s -- --no-verify; }; f"
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

This config includes commit signing with SSH, editor settings, useful aliases, and color/output settings.

---

## ✅ Notes

* Use a **passphrase** for security; the Keychain stores it so you don’t type it every time.
* Your commits will now show as **Verified** on GitHub.
* This setup works for both commit signing and SSH authentication for Git push/pull.

