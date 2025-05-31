# Legacy Configuration Files

This directory contains the old shell configuration files that have been refactored into the modular structure under `.config/zsh/`.

## Migration

The following files have been migrated:

- `aliases.sh` → `.config/zsh/aliases.zsh`
- `shell_funcs.sh` → `.config/zsh/functions.zsh`
- `env_vars.sh` → `.config/zsh/env.zsh`

## Removal

These files are kept for backup purposes. Once you've verified that the new modular configuration works correctly, you can safely remove this directory:

```bash
rm -rf .legacy/
```

## Rollback

If you need to rollback to the old structure:

1. Copy the files back to the root directory
2. Restore the old `.zshrc` from git history
3. Remove the `.config/zsh/` directory
