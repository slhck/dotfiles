# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles repo with a modular bootstrap system for macOS and Linux. No build system or tests to run — changes are applied by copying files to `$HOME`.

## Applying Changes

```bash
# Full install (default components)
./bootstrap.sh

# Dry-run to preview
./bootstrap.sh -n

# Specific components only
./bootstrap.sh dotfiles shell

# All components including optional ones
./bootstrap.sh -a
```

After editing `zshrc`, deploy to the live config:
```bash
cp zshrc ~/.zshrc && echo -e "\n# === OS-SPECIFIC CONFIG ===" >> ~/.zshrc && cat zshrc.linux >> ~/.zshrc  # Linux
cp zshrc ~/.zshrc && echo -e "\n# === OS-SPECIFIC CONFIG ===" >> ~/.zshrc && cat zshrc.osx >> ~/.zshrc    # macOS
```

## Architecture

**Bootstrap system:** `bootstrap.sh` orchestrates modular installers from `installers/`. Each installer is a standalone script sourced by bootstrap. Components: `packages`, `dotfiles`, `shell`, `vim`, `tmux`, `python`, `node`, `ruby`, `scripts`, `ssh`, `safe-chain`, `agents`. Optional: `docker`.

**Zshrc is three layers:** Base `zshrc` is copied to `~/.zshrc`, then OS-specific config (`zshrc.osx` or `zshrc.linux`) is appended after a `# === OS-SPECIFIC CONFIG ===` marker. User overrides go in `~/.zshrc.local` (not tracked).

**Dotfiles are copied, not symlinked.** The `dotfiles` installer uses `cp`, with automatic backups to `~/.dotfiles-backup/YYYYMMDD-HHMMSS/`. This means edits to repo files must be re-deployed.

**Oh-my-zsh aliases are extracted, not loaded via framework.** `scripts/sync-omz-aliases.sh` extracts plugin files into `zsh/plugins/*.zsh`, which get copied to `~/.zsh/aliases/`. A GitHub Actions workflow runs this weekly and creates a PR. Don't manually edit files in `zsh/plugins/` — they're auto-generated.

**Scripts in `scripts/`** are copied to `~/.bin` by the `scripts` installer.

## Key Conventions

- All installers are idempotent — safe to re-run
- `run()` helper respects `DRY_RUN` and `VERBOSE` flags
- `is_installed()` checks command availability before installing
- OS detection: `detect_os()` returns "macos" or "linux"
- Language versions use version managers: pyenv, nvm, rbenv
- NVM is sourced directly (not lazy-loaded) to avoid conflicts with safe-chain wrappers
- `safe-chain` (Aikido) wraps npm/npx/pip etc. for supply chain security — defined in `~/.safe-chain/scripts/init-posix.sh`, sourced after NVM in zshrc
