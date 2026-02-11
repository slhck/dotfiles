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
    _install_zsh_aliases
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

_install_zsh_aliases() {
    local src_dir="$SCRIPT_DIR/zsh/plugins"
    local dst_dir="$HOME/.zsh/aliases"

    if [[ ! -d "$src_dir" ]]; then
        log_warning "zsh alias files not found in repo"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would copy zsh alias files to $dst_dir"
        return
    fi

    mkdir -p "$dst_dir"
    local count=0
    for file in "$src_dir"/*.zsh; do
        [[ -f "$file" ]] || continue
        backup_file "$dst_dir/$(basename "$file")"
        cp "$file" "$dst_dir/"
        ((count++))
    done
    log_success "Installed $count zsh alias files to $dst_dir"
}
