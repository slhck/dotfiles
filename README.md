# Dotfiles

My dotfiles and macOS / Linux setup scripts.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/slhck/dotfiles ~/dotfiles
cd ~/dotfiles

# Preview what will be installed
./bootstrap.sh -n

# Install everything
./bootstrap.sh

# Set zsh as default shell
chsh -s $(which zsh)
```

## Usage

```bash
./bootstrap.sh [OPTIONS] [COMPONENTS...]
```

### Options

| Option          | Description                                    |
| --------------- | ---------------------------------------------- |
| `-n, --dry-run` | Preview changes without applying               |
| `-v, --verbose` | Show commands being executed                   |
| `-a, --all`     | Install all components including optional ones |
| `-l, --list`    | List available components                      |
| `-h, --help`    | Show help                                      |

### Components

**Default** (installed with `./bootstrap.sh`):

| Component  | Description                             |
| ---------- | --------------------------------------- |
| `packages` | System packages (Homebrew/apt)          |
| `dotfiles` | Config files (.zshrc, .gitconfig, etc.) |
| `shell`    | Starship prompt + zsh plugins           |
| `vim`      | Vim + ctrlp plugin                      |
| `tmux`     | Tmux + TPM                              |
| `python`   | Pyenv + Python                          |
| `node`     | NVM + Node.js + yarn                    |
| `ruby`     | Rbenv + Ruby                            |
| `scripts`  | Custom scripts to ~/.bin                |
| `ssh`      | SSH key generation                      |
| `safe-chain` | Supply chain security (Aikido)        |

**Optional** (use `-a` or specify by name):

| Component | Description                      |
| --------- | -------------------------------- |
| `docker`  | Docker daemon setup (Linux only) |

### Examples

```bash
# Full setup
./bootstrap.sh

# Dry-run first
./bootstrap.sh -n

# Install only specific components
./bootstrap.sh dotfiles shell

# Install with optional components
./bootstrap.sh -a

# Custom Python version
PYTHON_VERSION=3.12.0 ./bootstrap.sh python

# Custom Ruby version
RUBY_VERSION=3.3.0 ./bootstrap.sh ruby
```

## Environment Variables

| Variable         | Default  | Description                         |
| ---------------- | -------- | ----------------------------------- |
| `PYTHON_VERSION` | `latest` | Python version to install via pyenv |
| `NODE_VERSION`   | `lts/*`  | Node.js version to install via nvm  |
| `RUBY_VERSION`   | `latest` | Ruby version to install via rbenv   |

## Structure

```
dotfiles/
├── bootstrap.sh          # Main entry point
├── Brewfile              # Homebrew packages (macOS)
├── zshrc                 # Main zsh config
├── zshrc.osx             # macOS-specific zsh config
├── zshrc.linux           # Linux-specific zsh config
├── gitconfig, vimrc, ... # Other config files
├── installers/           # Modular installer scripts
│   ├── packages.sh       # Homebrew/apt
│   ├── dotfiles.sh       # Config deployment + zsh alias files
│   ├── shell.sh          # Starship + zsh plugins
│   ├── editors.sh        # Vim, tmux
│   ├── languages.sh      # Python, Node, Ruby
│   └── extras.sh         # SSH, scripts, docker
├── scripts/              # Custom utility scripts
│   └── sync-omz-aliases.sh  # Update aliases from oh-my-zsh upstream
└── zsh/plugins/          # Standalone zsh alias files (generated)
    ├── git.zsh           # Git aliases + helper functions
    ├── docker.zsh        # Docker aliases
    ├── docker-compose.zsh # Docker Compose aliases
    └── macos.zsh         # macOS Finder/terminal utilities
```

## Features

- **Idempotent**: Safe to re-run anytime
- **Backups**: Existing configs saved to `~/.dotfiles-backup/`
- **Dry-run**: Preview all changes before applying
- **Selective**: Install only what you need
- **Cross-platform**: Works on macOS and Linux

## Shell Setup

The shell runs without oh-my-zsh. Git, Docker, Docker Compose, and macOS aliases are extracted from oh-my-zsh upstream into standalone `.zsh` files in `zsh/plugins/`. These are committed to the repo and copied to `~/.zsh/aliases/` during install.

To update the alias files from the latest oh-my-zsh:

```bash
./scripts/sync-omz-aliases.sh
```

This shallow-clones oh-my-zsh, extracts the plugin content, and writes the updated files. Review and commit the changes.

Plugins installed at runtime (not in the repo):

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — cloned to `~/.zsh/plugins/`
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) — cloned to `~/.zsh/plugins/`
- [Starship](https://starship.rs) — installed via Homebrew (macOS) or curl (Linux)

## Syncing Software

- **iTerm 2**: Export/Import settings, Colors: `OceanicNext`

## Brewfile

To update the Brewfile from currently installed packages:

```bash
brew bundle dump --force --describe
```

## License

MIT License.

Scripts by Evan Hahn from https://codeberg.org/EvanHahn/dotfiles/ under public domain.
