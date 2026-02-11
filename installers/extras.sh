# Module: extras
# SSH keys, custom scripts, Docker setup

install_ssh() {
    log "Setting up SSH..."

    local ssh_key="$HOME/.ssh/id_ed25519"

    if [[ -f "$ssh_key" ]]; then
        log_success "SSH key already exists"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would generate SSH key"
    else
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ssh-keygen -t ed25519 -N "" -f "$ssh_key"
        log_success "SSH key generated"
        echo ""
        log "Your public key:"
        cat "${ssh_key}.pub"
        echo ""
    fi
}

install_scripts() {
    log "Installing custom scripts..."

    local bin_dir="$HOME/.bin"
    local scripts_dir="$SCRIPT_DIR/scripts"

    if [[ ! -d "$scripts_dir" ]]; then
        log_warning "Scripts directory not found"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        local count
        # -perm /111 is GNU find (Linux), -perm +111 is BSD find (macOS)
        if [[ "$OS" == "macos" ]]; then
            count=$(find "$scripts_dir" -maxdepth 1 -type f -perm +111 | wc -l | tr -d ' ')
        else
            count=$(find "$scripts_dir" -maxdepth 1 -type f -perm /111 | wc -l | tr -d ' ')
        fi
        log_dry "Would install $count scripts to $bin_dir"
    else
        mkdir -p "$bin_dir"
        local count=0
        for script in "$scripts_dir"/*; do
            if [[ -f "$script" && -x "$script" ]]; then
                cp "$script" "$bin_dir/"
                ((count++))
            fi
        done
        log_success "Installed $count scripts to $bin_dir"
    fi
}

install_safe_chain() {
    log "Installing safe-chain..."

    if [[ -f "$HOME/.safe-chain/bin/safe-chain" ]]; then
        log_success "safe-chain already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install safe-chain via install script"
    else
        curl -fsSL https://github.com/AikidoSec/safe-chain/releases/latest/download/install-safe-chain.sh | sh
        log_success "safe-chain installed"
    fi
}

install_docker() {
    log "Setting up Docker..."

    if [[ "$OS" != "linux" ]]; then
        log_warning "Docker setup only needed on Linux (macOS uses Docker Desktop)"
        return
    fi

    if ! is_installed docker; then
        log_warning "Docker not installed - run 'packages' component first"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would enable Docker service and add user to docker group"
    else
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker "${USER}"
        log_success "Docker configured"
        log_warning "Log out and back in for docker group to take effect"
    fi
}
