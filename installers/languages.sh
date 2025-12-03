# Module: languages
# Installs Python, Node.js, and Ruby version managers and runtimes

install_python() {
    log "Installing Python ${PYTHON_VERSION}..."

    _ensure_pyenv
    _install_python_version
}

install_node() {
    log "Installing Node.js ${NODE_VERSION}..."

    _ensure_nvm
    _install_node_version
}

install_ruby() {
    log "Installing Ruby..."

    _ensure_rbenv
    _install_ruby_version
}

# --- Python ---

_ensure_pyenv() {
    # macOS gets pyenv from Homebrew
    if [[ "$OS" == "macos" ]]; then
        _load_pyenv
        return
    fi

    # Linux: install if missing
    if [[ -d "$HOME/.pyenv" ]]; then
        _load_pyenv
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install pyenv"
    else
        curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
        _load_pyenv
        log_success "pyenv installed"
    fi
}

_load_pyenv() {
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
    [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    is_installed pyenv && eval "$(pyenv init -)" 2>/dev/null
}

_install_python_version() {
    if ! is_installed pyenv; then
        log_warning "pyenv not available - skipping Python"
        return
    fi

    # Resolve "latest" to actual version number
    if [[ "$PYTHON_VERSION" == "latest" ]]; then
        PYTHON_VERSION=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
        log "Resolved latest Python to $PYTHON_VERSION"
    fi

    if pyenv versions --bare 2>/dev/null | grep -q "^${PYTHON_VERSION}$"; then
        log_success "Python $PYTHON_VERSION already installed"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Python $PYTHON_VERSION"
    else
        pyenv install "$PYTHON_VERSION"
        log_success "Python $PYTHON_VERSION installed"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would set Python $PYTHON_VERSION as global"
    else
        pyenv global "$PYTHON_VERSION"
        pyenv rehash
        log_success "Python $PYTHON_VERSION set as global"
    fi
}

# --- Node.js ---

_ensure_nvm() {
    # macOS gets nvm from Homebrew
    if [[ "$OS" == "macos" ]]; then
        _load_nvm
        return
    fi

    # Linux: install if missing
    if [[ -d "$HOME/.nvm" ]]; then
        _load_nvm
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install NVM"
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
        _load_nvm
        log_success "NVM installed"
    fi
}

_load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    # NVM scripts can fail with set -e, so temporarily disable
    set +e
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    # Homebrew location (Intel and Apple Silicon)
    [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
    [[ -s "/usr/local/opt/nvm/nvm.sh" ]] && source "/usr/local/opt/nvm/nvm.sh"
    set -e
}

_install_node_version() {
    # Check if nvm is available (as a function, not command)
    local nvm_available=false
    declare -f nvm &>/dev/null && nvm_available=true

    if [[ "$nvm_available" != "true" ]]; then
        log_warning "NVM not available - skipping Node.js"
        log_warning "Install NVM and re-run, or use: brew install nvm"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Node.js $NODE_VERSION and yarn"
    else
        nvm install "$NODE_VERSION"
        nvm use "$NODE_VERSION"
        npm install -g yarn
        log_success "Node.js and yarn installed"
    fi
}

# --- Ruby ---

_ensure_rbenv() {
    # macOS gets rbenv from Homebrew
    if [[ "$OS" == "macos" ]]; then
        _load_rbenv
        return
    fi

    # Linux: install if missing
    if [[ -d "$HOME/.rbenv" ]]; then
        _load_rbenv
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install rbenv"
    else
        curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
        _load_rbenv
        log_success "rbenv installed"
    fi
}

_load_rbenv() {
    [[ -d "$HOME/.rbenv/bin" ]] && export PATH="$HOME/.rbenv/bin:$PATH"
    is_installed rbenv && eval "$(rbenv init -)" 2>/dev/null
}

_install_ruby_version() {
    if ! is_installed rbenv; then
        log_warning "rbenv not available - skipping Ruby"
        return
    fi

    # Resolve "latest" to actual version number
    if [[ "$RUBY_VERSION" == "latest" ]]; then
        RUBY_VERSION=$(rbenv install --list 2>/dev/null | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
        log "Resolved latest Ruby to $RUBY_VERSION"
    fi

    if rbenv versions --bare 2>/dev/null | grep -q "^${RUBY_VERSION}$"; then
        log_success "Ruby $RUBY_VERSION already installed"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Ruby $RUBY_VERSION"
    else
        rbenv install "$RUBY_VERSION"
        log_success "Ruby $RUBY_VERSION installed"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would set Ruby $RUBY_VERSION as global"
    else
        rbenv global "$RUBY_VERSION"
        rbenv rehash
        log_success "Ruby $RUBY_VERSION set as global"
    fi
}
