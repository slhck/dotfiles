#!/usr/bin/env bash
#
# Dotfiles Bootstrap Script
# One command to set up a new machine
#
# Features:
#   - Dry-run mode (-n) to preview changes
#   - Selective component installation
#   - Idempotent - safe to re-run
#   - Automatic backups of existing configs
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

#------------------------------------------------------------------------------
# Configuration (override via environment variables)
#------------------------------------------------------------------------------

PYTHON_VERSION="${PYTHON_VERSION:-latest}"  # "latest" = auto-detect
NODE_VERSION="${NODE_VERSION:-lts/*}"
RUBY_VERSION="${RUBY_VERSION:-latest}"  # "latest" = auto-detect

#------------------------------------------------------------------------------
# Available components
#------------------------------------------------------------------------------

# Default components (installed with ./bootstrap.sh)
DEFAULT_COMPONENTS=(
    packages    # Homebrew/apt packages
    dotfiles    # Config files (.zshrc, .gitconfig, etc.)
    shell       # Starship + zsh plugins + fzf + zoxide
    vim         # Vim + ctrlp
    tmux        # Tmux + TPM
    python      # Pyenv + Python
    node        # NVM + Node.js + yarn
    ruby        # Rbenv + Ruby
    scripts     # Custom scripts to ~/.bin
    ssh         # SSH key generation
    safe-chain  # Supply chain security (Aikido)
)

# All available components (use -a or specify by name)
ALL_COMPONENTS=(
    "${DEFAULT_COMPONENTS[@]}"
    docker      # Docker daemon setup (Linux only)
)

#------------------------------------------------------------------------------
# State
#------------------------------------------------------------------------------

DRY_RUN=false
VERBOSE=false
SELECTED_COMPONENTS=()

#------------------------------------------------------------------------------
# Colors and logging
#------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log()         { echo -e "${BLUE}==>${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}!${NC} $1"; }
log_error()   { echo -e "${RED}✗${NC} $1"; }
log_dry()     { echo -e "${YELLOW}[DRY-RUN]${NC} $1"; }

run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "$*"
    else
        [[ "$VERBOSE" == "true" ]] && echo -e "${BOLD}$ $*${NC}"
        "$@"
    fi
}

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

is_installed() {
    command -v "$1" &>/dev/null
}

is_selected() {
    local component="$1"
    for c in "${SELECTED_COMPONENTS[@]}"; do
        [[ "$c" == "$component" ]] && return 0
    done
    return 1
}

backup_file() {
    local file="$1"
    [[ ! -f "$file" ]] && return
    [[ -L "$file" ]] && return  # Skip symlinks

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would backup: $file"
    else
        mkdir -p "$BACKUP_DIR"
        cp -p "$file" "$BACKUP_DIR/"
        log_success "Backed up: $(basename "$file")"
    fi
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

OS=$(detect_os)

#------------------------------------------------------------------------------
# Source modules
#------------------------------------------------------------------------------

source "$SCRIPT_DIR/installers/packages.sh"
source "$SCRIPT_DIR/installers/dotfiles.sh"
source "$SCRIPT_DIR/installers/shell.sh"
source "$SCRIPT_DIR/installers/editors.sh"
source "$SCRIPT_DIR/installers/languages.sh"
source "$SCRIPT_DIR/installers/extras.sh"

#------------------------------------------------------------------------------
# CLI
#------------------------------------------------------------------------------

show_help() {
    cat << EOF
${BOLD}Dotfiles Bootstrap${NC}

Usage: $(basename "$0") [OPTIONS] [COMPONENTS...]

${BOLD}Options:${NC}
  -n, --dry-run     Preview changes without applying
  -v, --verbose     Show commands being executed
  -a, --all         Install all components (default)
  -l, --list        List available components
  -h, --help        Show this help

${BOLD}Components (default):${NC}
  packages    System packages (Homebrew/apt)
  dotfiles    Config files (.zshrc, .gitconfig, etc.)
  shell       Starship prompt + zsh plugins
  vim         Vim + ctrlp plugin
  tmux        Tmux + TPM
  python      Pyenv + Python
  node        NVM + Node.js + yarn
  ruby        Rbenv + Ruby
  scripts     Custom scripts to ~/.bin
  ssh         SSH key generation
  safe-chain  Supply chain security (Aikido)

${BOLD}Components (optional):${NC}
  docker      Docker daemon setup (Linux only)

${BOLD}Examples:${NC}
  $(basename "$0")                    # Install everything
  $(basename "$0") -n                 # Dry-run everything
  $(basename "$0") dotfiles shell    # Install only dotfiles and shell
  $(basename "$0") -n packages       # Preview package installation

${BOLD}Environment Variables:${NC}
  PYTHON_VERSION=$PYTHON_VERSION
  NODE_VERSION=$NODE_VERSION
  RUBY_VERSION=${RUBY_VERSION:-<not set>}

EOF
}

list_components() {
    echo -e "${BOLD}Available components:${NC}"
    for c in "${ALL_COMPONENTS[@]}"; do
        echo "  $c"
    done
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--dry-run) DRY_RUN=true; shift ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -a|--all)     SELECTED_COMPONENTS=("${ALL_COMPONENTS[@]}"); shift ;;
            -l|--list)    list_components; exit 0 ;;
            -h|--help)    show_help; exit 0 ;;
            -*)           log_error "Unknown option: $1"; show_help; exit 1 ;;
            *)            SELECTED_COMPONENTS+=("$1"); shift ;;
        esac
    done

    # Default to default components if none specified
    [[ ${#SELECTED_COMPONENTS[@]} -eq 0 ]] && SELECTED_COMPONENTS=("${DEFAULT_COMPONENTS[@]}")

    # Header
    echo ""
    echo -e "${BOLD}Dotfiles Bootstrap${NC}"
    echo -e "OS: ${GREEN}$OS${NC}"
    [[ "$DRY_RUN" == "true" ]] && echo -e "Mode: ${YELLOW}DRY-RUN${NC}"
    echo -e "Components: ${BLUE}${SELECTED_COMPONENTS[*]}${NC}"
    echo ""

    # Run selected installers
    is_selected packages  && install_packages
    is_selected dotfiles  && install_dotfiles
    is_selected shell     && install_shell
    is_selected vim       && install_vim
    is_selected tmux      && install_tmux
    is_selected python    && install_python
    is_selected node      && install_node
    is_selected ruby      && install_ruby
    is_selected scripts   && install_scripts
    is_selected ssh       && install_ssh
    is_selected safe-chain && install_safe_chain
    is_selected docker    && install_docker

    # Footer
    echo ""
    if [[ "$DRY_RUN" == "true" ]]; then
        log_success "Dry-run complete. Run without -n to apply."
    else
        log_success "Bootstrap complete!"
        [[ -d "$BACKUP_DIR" ]] && echo -e "Backups: ${BLUE}$BACKUP_DIR${NC}"
        echo ""
        echo -e "${BOLD}Next steps:${NC}"
        echo "  1. Set zsh as default: chsh -s \$(which zsh)"
        echo "  2. Start a new terminal"
        echo "  3. In tmux, press Ctrl+b, I to install plugins"
    fi
}

main "$@"
