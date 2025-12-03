# Module: editors
# Installs Vim and Tmux configurations

install_vim() {
    log "Installing Vim configuration..."

    local ctrlp_dir="$HOME/.vim/bundle/ctrlp.vim"

    if [[ -d "$ctrlp_dir" ]]; then
        log_success "ctrlp.vim already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install ctrlp.vim"
    else
        mkdir -p "$HOME/.vim/bundle"
        git clone https://github.com/kien/ctrlp.vim.git "$ctrlp_dir"
        log_success "ctrlp.vim installed"
    fi
}

install_tmux() {
    log "Installing Tmux configuration..."

    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log_success "TPM already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install TPM"
    else
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
        log_warning "Run 'tmux' then press Ctrl+b, I to install plugins"
    fi
}
