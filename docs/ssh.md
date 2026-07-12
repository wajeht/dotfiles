# SSH Keys, Hosts & GitHub Accounts

How SSH identity, host aliases, and multi-account GitHub are wired across machines.
Everything here is installed by `make git install` (`git/install.sh`); the templates live
in `git/`.

## Key naming convention

One rule: **`id_ed25519` is the personal key on every machine.** It is the default
identity and the commit-signing key.

| Key | Meaning | Where |
| --- | --- | --- |
| `~/.ssh/id_ed25519` | personal (wajeht) | every machine |
| `~/.ssh/id_ed25519_work` | work key | work laptop only |

`make git install` generates `id_ed25519` if it is missing. The work key is created
manually (see "Setting up a new machine"); its presence is what flips a machine into
"work laptop" mode.

## GitHub accounts (multi-account)

| Host alias | Account | Key |
| --- | --- | --- |
| `github.com` | personal | `id_ed25519` |
| `github-work` | work | `id_ed25519_work` (work laptop only) |

- Personal repos: `git clone git@github.com:...`
- Work repos: `git clone git@github-work:...` and keep them under `~/work/`

The `~/work/` directory triggers the work profile (`[includeIf "gitdir:~/work/"]` in
`git/config` → `git/work`), which sets the work name/email and signs
with `id_ed25519_work.pub`. `git.sh` only adds the `github-work` block when the work key
exists, so single-key machines never get a dangling alias.

If a repo was cloned with the GitHub CLI and `git push` asks for
`Username for 'https://github.com'`, that repo's remote is HTTPS, so SSH keys are not
being used. Point the remote at SSH instead:

```sh
git remote set-url origin git@github.com:wajeht/<repo>.git
```

To repair every GitHub HTTPS remote under `~/Dev`:

```sh
find ~/Dev -name .git \( -type d -o -type f \) -print0 |
  while IFS= read -r -d '' gitpath; do
    repo=${gitpath%/.git}
    url=$(git -C "$repo" remote get-url origin 2>/dev/null || true)
    case "$url" in
      https://github.com/*)
        path=${url#https://github.com/}
        path=${path%.git}
        git -C "$repo" remote set-url origin "git@github.com:${path}.git"
        ;;
    esac
  done
```

## Commit signing

- SSH signing (`gpg.format = ssh`), verified against `~/.ssh/allowed_signers`.
- `make git install` regenerates `allowed_signers`: a personal line always, a work line
  only if `id_ed25519_work.pub` exists.
- It also registers the personal key with GitHub (auth + signing) via `gh`, if `gh` is
  authenticated with the `admin:public_key` + `admin:ssh_signing_key` scopes.
- For the manual macOS walkthrough (keychain, first-time setup) see
  [verified-commit.md](verified-commit.md).

## Host aliases

Machine shortcuts are defined once in `git/ssh_hosts` (installed into
`~/.ssh/config`) and exposed as shell aliases in `zsh/aliases.zsh`. No IPs or
passwords live in the aliases — just `ssh <name>`.

| Alias | Purpose |
| --- | --- |
| `work` | work laptop |
| `one` / `two` / `three` | dev boxes (`three` is the Dell dev rig) |
| `pi` | Raspberry Pi |

All connections inherit ControlMaster multiplexing + keepalives from the `Host *` block,
so repeat `ssh`/`scp` to the same host reuse one connection.

## Passwordless login to a host

One-time per host — copies your public key into the host's `authorized_keys`:

```sh
ssh-copy-id <alias>        # e.g. ssh-copy-id work   (enter the host password once)
ssh <alias>                # now passwordless
```

Host key changed after a reinstall? Clear the stale entry, then reconnect:

```sh
ssh-keygen -R <ip-or-host>
```

## Setting up a new machine

1. `make git install` — generates `id_ed25519` (personal), installs git config, the
   `github.com` block, and the host aliases.
2. Work laptop only — create the work key, then re-run install to add `github-work` and
   the work signer:
   ```sh
   ssh-keygen -t ed25519 -C "265659615+clevyr-kyaw@users.noreply.github.com" -f ~/.ssh/id_ed25519_work
   make git install
   ```
3. `ssh-copy-id` into whichever hosts you need (see "Passwordless login to a host").

## Migrating an old work laptop to this scheme

The old scheme used `id_ed25519` = work and `id_ed25519_personal` = personal. `make git
install` refuses to run while `id_ed25519_personal.pub` is present, so migrate the key
files first. Renaming a key *file* does not change the key material, so nothing needs
re-registering on GitHub:

```sh
cd ~/.ssh
mv id_ed25519 id_ed25519_work;            mv id_ed25519.pub id_ed25519_work.pub
mv id_ed25519_personal id_ed25519;        mv id_ed25519_personal.pub id_ed25519.pub
ssh-add -D 2>/dev/null; ssh-add id_ed25519 id_ed25519_work
cd ~/Dev/dotfiles && make git install
```

Existing work repos were cloned as `git@github.com:...`, which now resolves to the
personal key. Point them at the work alias so they authenticate with the work key
(the `https://` remotes are unaffected — they use gh's credential helper):

```sh
find ~/work -maxdepth 3 -name .git -type d | while read g; do
  d=$(dirname "$g"); r=$(git -C "$d" remote get-url origin 2>/dev/null || true)
  case "$r" in git@github.com:*) git -C "$d" remote set-url origin "git@github-work:${r#git@github.com:}";; esac
done
```

If the dotfiles repo's own remote used `git@github-personal:`, point it back at `github.com`:

```sh
git -C ~/dev/dotfiles remote set-url origin git@github.com:wajeht/dotfiles.git
```

Then remove any leftover `github-personal` block from `~/.ssh/config`, and verify (use
`ssh -n` so the check doesn't swallow following commands):

```sh
ssh -n -T git@github.com     # personal → "Hi wajeht"
ssh -n -T git@github-work    # work     → "Hi clevyr-kyaw"
```

## Notes

- Keys live on each machine and are **not** agent-forwarded (`ForwardAgent no`).
- Personal GitHub repos should use SSH remotes (`git@github.com:...`) so `git push`
  uses `id_ed25519` instead of prompting for HTTPS credentials.
- `id_ed25519_work` never leaves the work laptop; it's registered with the work GitHub
  account manually (the local `gh` is authenticated as the personal account).
