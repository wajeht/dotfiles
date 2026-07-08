# SSH Keys, Hosts & GitHub Accounts

How SSH identity, host aliases, and multi-account GitHub are wired across machines.
Everything here is installed by `make git install` (`src/git.sh`); the templates live
in `src/configs/git/`.

## 1. Key naming convention

One rule: **`id_ed25519` is the personal key on every machine.** It is the default
identity and the commit-signing key.

| Key | Meaning | Where |
| --- | --- | --- |
| `~/.ssh/id_ed25519` | personal (wajeht) | every machine |
| `~/.ssh/id_ed25519_work` | work key | work laptop only |

`make git install` generates `id_ed25519` if it is missing. The work key is created
manually (see §6); its presence is what flips a machine into "work laptop" mode.

## 2. GitHub accounts (multi-account)

| Host alias | Account | Key |
| --- | --- | --- |
| `github.com` | personal | `id_ed25519` |
| `github-work` | work | `id_ed25519_work` (work laptop only) |

- Personal repos: `git clone git@github.com:...`
- Work repos: `git clone git@github-work:...` and keep them under `~/work/`

The `~/work/` directory triggers the work profile (`[includeIf "gitdir:~/work/"]` in
`configs/git/config` → `configs/git/work`), which sets the work name/email and signs
with `id_ed25519_work.pub`. `git.sh` only adds the `github-work` block when the work key
exists, so single-key machines never get a dangling alias.

## 3. Commit signing

- SSH signing (`gpg.format = ssh`), verified against `~/.ssh/allowed_signers`.
- `make git install` regenerates `allowed_signers`: a personal line always, a work line
  only if `id_ed25519_work.pub` exists.
- It also registers the personal key with GitHub (auth + signing) via `gh`, if `gh` is
  authenticated with the `admin:public_key` + `admin:ssh_signing_key` scopes.
- For the manual macOS walkthrough (keychain, first-time setup) see
  [VERIFIED_COMMIT.md](VERIFIED_COMMIT.md).

## 4. Host aliases

Machine shortcuts are defined once in `configs/git/ssh_hosts` (installed into
`~/.ssh/config`) and exposed as shell aliases in `configs/zsh/aliases.zsh`. No IPs or
passwords live in the aliases — just `ssh <name>`.

| Alias | Purpose |
| --- | --- |
| `work` | work laptop |
| `work-db` | work DB box (opens a `LocalForward` on 5432) |
| `one` / `two` / `three` | dev boxes (`three` is the Dell dev rig) |
| `pi` | Raspberry Pi |

All connections inherit ControlMaster multiplexing + keepalives from the `Host *` block,
so repeat `ssh`/`scp` to the same host reuse one connection.

## 5. Passwordless login to a host

One-time per host — copies your public key into the host's `authorized_keys`:

```sh
ssh-copy-id <alias>        # e.g. ssh-copy-id work   (enter the host password once)
ssh <alias>                # now passwordless
```

Host key changed after a reinstall? Clear the stale entry, then reconnect:

```sh
ssh-keygen -R <ip-or-host>
```

## 6. Setting up a new machine

1. `make git install` — generates `id_ed25519` (personal), installs git config, the
   `github.com` block, and the host aliases.
2. Work laptop only — create the work key, then re-run install to add `github-work` and
   the work signer:
   ```sh
   ssh-keygen -t ed25519 -C "265659615+clevyr-kyaw@users.noreply.github.com" -f ~/.ssh/id_ed25519_work
   make git install
   ```
3. `ssh-copy-id` into whichever hosts you need (§5).

## 7. Migrating an old work laptop to this scheme

The old scheme used `id_ed25519` = work and `id_ed25519_personal` = personal. Renaming a
key *file* does not change the key material, so nothing needs re-registering on GitHub:

```sh
cd ~/.ssh
mv id_ed25519 id_ed25519_work;            mv id_ed25519.pub id_ed25519_work.pub
mv id_ed25519_personal id_ed25519;        mv id_ed25519_personal.pub id_ed25519.pub
ssh-add -D 2>/dev/null; ssh-add id_ed25519 id_ed25519_work
cd ~/Dev/dotfiles && make git install
```

Then remove any leftover `github-personal` block from `~/.ssh/config`, and verify:

```sh
ssh -T git@github.com     # personal
ssh -T git@github-work    # work
```

## Notes

- Keys live on each machine and are **not** agent-forwarded (`ForwardAgent no`).
- The personal Mac talks to GitHub over **HTTPS**, so SSH-auth to `github.com` isn't used
  there — `id_ed25519` is for signing and for the host aliases above.
- `id_ed25519_work` never leaves the work laptop; it's registered with the work GitHub
  account manually (the local `gh` is authenticated as the personal account).
