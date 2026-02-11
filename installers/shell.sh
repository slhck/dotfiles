# Module: shell
# Installs starship prompt, zsh plugins, and shell tools

install_shell() {
    log "Installing shell environment..."

    _install_starship
    _install_zsh_plugins
    _cleanup_ohmyzsh

    if [[ "$OS" == "linux" ]]; then
        _install_fzf
        _install_zoxide
    fi
}

_install_starship() {
    if is_installed starship; then
        log_success "Starship already installed"
        return
    fi

    if [[ "$OS" == "macos" ]]; then
        # Installed via Brewfile
        log_warning "Starship not found — run 'packages' component first (brew install starship)"
        return
    fi

    # Linux: install via official installer
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Starship"
    else
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        log_success "Starship installed"
    fi
}

_install_zsh_plugins() {
    local plugins_dir="$HOME/.zsh/plugins"

    # zsh-autosuggestions
    local autosuggestions_dir="$plugins_dir/zsh-autosuggestions"
    if [[ -d "$autosuggestions_dir" ]]; then
        log_success "zsh-autosuggestions already installed"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install zsh-autosuggestions"
    else
        mkdir -p "$plugins_dir"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
        log_success "zsh-autosuggestions installed"
    fi

    # zsh-syntax-highlighting
    local highlighting_dir="$plugins_dir/zsh-syntax-highlighting"
    if [[ -d "$highlighting_dir" ]]; then
        log_success "zsh-syntax-highlighting already installed"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install zsh-syntax-highlighting"
    else
        mkdir -p "$plugins_dir"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$highlighting_dir"
        log_success "zsh-syntax-highlighting installed"
    fi
}

_cleanup_ohmyzsh() {
    local zsh_dir="$HOME/.oh-my-zsh"

    if [[ ! -d "$zsh_dir" ]]; then
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would remove $zsh_dir (no longer needed)"
    else
        rm -rf "$zsh_dir"
        log_success "Removed $zsh_dir (migrated to standalone setup)"
    fi
}

_install_fzf() {
    if [[ -d "$HOME/.fzf" ]]; then
        log_success "FZF already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install FZF"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --completion --key-bindings --no-update-rc --no-bash --no-fish
        log_success "FZF installed"
    fi
}

_install_zoxide() {
    if is_installed zoxide; then
        log_success "zoxide already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install zoxide"
    else
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        log_success "zoxide installed"
    fi
}
