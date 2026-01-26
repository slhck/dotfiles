# Module: shell
# Installs Oh-My-Zsh, themes, plugins, and shell tools

install_shell() {
    log "Installing shell environment..."

    _install_ohmyzsh
    _install_spaceship_theme
    _install_zsh_plugins

    if [[ "$OS" == "linux" ]]; then
        _install_fzf
        _install_zoxide
    fi
}

_install_ohmyzsh() {
    local zsh_dir="$HOME/.oh-my-zsh"

    if [[ -d "$zsh_dir" ]]; then
        log_success "Oh-My-Zsh already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Oh-My-Zsh"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
        log_success "Oh-My-Zsh installed"
    fi
}

_install_spaceship_theme() {
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local spaceship_dir="$custom_dir/themes/spaceship-prompt"

    if [[ -d "$spaceship_dir" ]]; then
        log_success "Spaceship theme already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Spaceship theme"
    else
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_dir" --depth=1
        ln -sf "$spaceship_dir/spaceship.zsh-theme" "$custom_dir/themes/spaceship.zsh-theme"
        log_success "Spaceship theme installed"
    fi

    # Update theme in zshrc
    _update_zsh_theme
}

_update_zsh_theme() {
    [[ "$DRY_RUN" == "true" ]] && return
    [[ ! -f "$HOME/.zshrc" ]] && return

    if grep -qE 'ZSH_THEME="(blinks|robbyrussell)"' "$HOME/.zshrc"; then
        sed -i.bak -E 's/ZSH_THEME="(blinks|robbyrussell)"/ZSH_THEME="spaceship"/' "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.bak"
        log_success "Updated theme to spaceship"
    fi
}

_install_zsh_plugins() {
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    local autosuggestions_dir="$custom_dir/plugins/zsh-autosuggestions"
    if [[ -d "$autosuggestions_dir" ]]; then
        log_success "zsh-autosuggestions already installed"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install zsh-autosuggestions"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
        log_success "zsh-autosuggestions installed"
    fi

    # zsh-syntax-highlighting (optional, can be slow)
    # local highlighting_dir="$custom_dir/plugins/zsh-syntax-highlighting"
    # if [[ ! -d "$highlighting_dir" ]]; then
    #     git clone https://github.com/zsh-users/zsh-syntax-highlighting "$highlighting_dir"
    # fi
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
