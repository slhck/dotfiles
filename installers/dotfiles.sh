# Module: dotfiles
# Copies configuration files to home directory with backups

install_dotfiles() {
    log "Installing dotfiles..."

    local files=(
        "gitconfig:.gitconfig"
        "gitignore:.gitignore"
        "pdbrc:.pdbrc"
        "pypirc:.pypirc"
        "tmux.conf:.tmux.conf"
        "vimrc:.vimrc"
        "Rprofile:.Rprofile"
    )

    for mapping in "${files[@]}"; do
        local src="${mapping%%:*}"
        local dst="${mapping##*:}"
        _copy_dotfile "$src" "$dst"
    done

    _install_zshrc
}

_copy_dotfile() {
    local src="$1"
    local dst="$2"
    local src_path="$SCRIPT_DIR/$src"
    local dst_path="$HOME/$dst"

    backup_file "$dst_path"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would copy: $src -> $dst"
    else
        cp "$src_path" "$dst_path"
        log_success "Installed: $dst"
    fi
}

_install_zshrc() {
    local zshrc_dst="$HOME/.zshrc"
    local os_marker="# === OS-SPECIFIC CONFIG ==="

    backup_file "$zshrc_dst"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would create: .zshrc (with OS-specific config)"
        return
    fi

    cp "$SCRIPT_DIR/zshrc" "$zshrc_dst"

    # Append OS-specific config only if marker not present (idempotency)
    if ! grep -q "$os_marker" "$zshrc_dst" 2>/dev/null; then
        {
            echo ""
            echo "$os_marker"
            if [[ "$OS" == "macos" ]]; then
                cat "$SCRIPT_DIR/zshrc.osx"
            elif [[ "$OS" == "linux" ]]; then
                cat "$SCRIPT_DIR/zshrc.linux"
            fi
        } >> "$zshrc_dst"
    fi

    log_success "Installed: .zshrc"
}
