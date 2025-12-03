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
| `shell`    | Oh-My-Zsh + Spaceship theme + plugins   |
| `vim`      | Vim + ctrlp plugin                      |
| `tmux`     | Tmux + TPM                              |
| `python`   | Pyenv + Python                          |
| `node`     | NVM + Node.js + yarn                    |
| `ruby`     | Rbenv + Ruby                            |
| `scripts`  | Custom scripts to ~/.bin                |
| `ssh`      | SSH key generation                      |

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
│   ├── dotfiles.sh       # Config deployment
│   ├── shell.sh          # Oh-my-zsh + plugins
│   ├── editors.sh        # Vim, tmux
│   ├── languages.sh      # Python, Node, Ruby
│   └── extras.sh         # SSH, scripts, docker
└── scripts/              # Custom utility scripts
```

## Features

- **Idempotent**: Safe to re-run anytime
- **Backups**: Existing configs saved to `~/.dotfiles-backup/`
- **Dry-run**: Preview all changes before applying
- **Selective**: Install only what you need
- **Cross-platform**: Works on macOS and Linux

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
