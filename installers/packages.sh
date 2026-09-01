# Module: packages
# Installs system packages via Homebrew (macOS) or apt (Linux)

install_packages() {
    log "Installing system packages..."

    if [[ "$OS" == "macos" ]]; then
        _install_homebrew
    elif [[ "$OS" == "linux" ]]; then
        _install_apt_packages
    fi
}

_install_homebrew() {
    if ! is_installed brew; then
        log "Installing Homebrew..."
        run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        log_success "Homebrew already installed"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would run: brew bundle install"
    else
        brew bundle install --file="$SCRIPT_DIR/Brewfile"
    fi
}

_install_apt_packages() {
    local packages=(
        autoconf
        build-essential
        curl
        git
        git-extras
        glow
        htop
        jq
        libbz2-dev
        libdb-dev
        libffi-dev
        libgdbm-dev
        libgdbm6
        libncurses-dev
        libreadline-dev
        libreadline-dev
        libsqlite3-dev
        libssl-dev
        libyaml-dev
        p7zip
        p7zip-full
        pipx
        pngquant
        ripgrep
        pv
        pwgen
        tree
        ufw
        unrar-free
        vim
        wget
        xclip
        zlib1g-dev
        zsh
    )

    run sudo apt update

    # Charm's apt repository provides glow on Debian/Ubuntu.
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install apt repository prerequisites: ca-certificates gnupg"
        log_dry "Would configure Charm's apt repository"
    else
        sudo apt install --assume-yes ca-certificates gnupg
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | \
            sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | \
            sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
    fi

    run sudo apt update

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install ${#packages[@]} apt packages"
    else
        sudo apt install --assume-yes "${packages[@]}"
    fi

    # Ghostty terminal emulator
    _install_ghostty_linux

    # Extra tools not in apt
    _install_linux_extras
}

_install_ghostty_linux() {
    # Skip on headless/server systems (no display server)
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" && -z "${XDG_SESSION_TYPE:-}" ]]; then
        log_warning "No display detected, skipping Ghostty"
        return
    fi

    if is_installed ghostty; then
        log_success "Ghostty already installed"
        return
    fi

    if ! is_installed snap; then
        log_warning "snap not installed, skipping Ghostty"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Ghostty via snap"
    else
        sudo snap install ghostty --classic
        log_success "Ghostty installed"
    fi
}

_install_linux_extras() {
    mkdir -p "$HOME/.local/bin"
    export DEBIAN_FRONTEND=noninteractive

    # Detect architecture for .deb packages
    local arch
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)       log_error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    # fd
    if ! is_installed fd; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install fd"
        else
            local url
            url=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | \
                jq -r '.assets[] | .browser_download_url' | grep "${arch}" | grep '\.deb$' | grep -v musl | head -1)
            wget -qO /tmp/fd.deb "$url"
            sudo dpkg -i /tmp/fd.deb
            rm -f /tmp/fd.deb
            [[ -f /usr/bin/fdfind ]] && ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
            log_success "fd installed"
        fi
    else
        log_success "fd already installed"
    fi

    # bat
    if ! is_installed bat && ! is_installed batcat; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install bat"
        else
            local url
            url=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | \
                jq -r '.assets[] | .browser_download_url' | grep "${arch}" | grep '\.deb$' | grep -v musl | head -1)
            wget -qO /tmp/bat.deb "$url"
            sudo dpkg -i /tmp/bat.deb
            rm -f /tmp/bat.deb
            [[ -f /usr/bin/batcat ]] && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
            log_success "bat installed"
        fi
    else
        log_success "bat already installed"
    fi

    # hyperfine
    if ! is_installed hyperfine; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install hyperfine"
        else
            local url
            url=$(curl -s "https://api.github.com/repos/sharkdp/hyperfine/releases/latest" | \
                jq -r '.assets[] | .browser_download_url' | grep "${arch}" | grep '\.deb$' | grep -v musl | head -1)
            wget -qO /tmp/hyperfine.deb "$url"
            sudo dpkg -i /tmp/hyperfine.deb
            rm -f /tmp/hyperfine.deb
            log_success "hyperfine installed"
        fi
    else
        log_success "hyperfine already installed"
    fi

    # tailcat
    if ! is_installed tailcat; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install tailcat"
        else
            local url
            url=$(curl -s "https://api.github.com/repos/tailscale/tailcat/releases/latest" | \
                jq -r '.assets[] | .browser_download_url' | grep "linux_${arch}" | grep '\.deb$' | head -1)
            wget -qO /tmp/tailcat.deb "$url"
            sudo dpkg -i /tmp/tailcat.deb
            rm -f /tmp/tailcat.deb
            log_success "tailcat installed"
        fi
    else
        log_success "tailcat already installed"
    fi

    # uv
    if ! is_installed uv; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install uv"
        else
            curl -LsSf https://astral.sh/uv/install.sh | sh
            log_success "uv installed"
        fi
    else
        log_success "uv already installed"
    fi

    # git-cliff
    if ! is_installed git-cliff; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install git-cliff from its latest Linux binary release"
        else
            local target url tmpdir binary
            case "$(uname -m)" in
                x86_64)  target="x86_64-unknown-linux-gnu" ;;
                aarch64) target="aarch64-unknown-linux-gnu" ;;
                *)       log_error "Unsupported architecture for git-cliff: $(uname -m)"; return 1 ;;
            esac

            url=$(curl -fsSL https://api.github.com/repos/orhun/git-cliff/releases/latest | \
                jq -r --arg target "$target" \
                    '.assets[] | select(.name | endswith("-" + $target + ".tar.gz")) | .browser_download_url' | \
                head -1)
            if [[ -z "$url" ]]; then
                log_error "Could not find a git-cliff binary for $target"
                return 1
            fi

            tmpdir=$(mktemp -d)
            curl -fsSL "$url" -o "$tmpdir/git-cliff.tar.gz"
            tar -xzf "$tmpdir/git-cliff.tar.gz" -C "$tmpdir"
            binary=$(find "$tmpdir" -type f -name git-cliff -print -quit)
            if [[ -z "$binary" ]]; then
                rm -rf "$tmpdir"
                log_error "git-cliff binary was not found in the release archive"
                return 1
            fi

            install -m 755 "$binary" "$HOME/.local/bin/git-cliff"
            rm -rf "$tmpdir"
            log_success "git-cliff installed"
        fi
    else
        log_success "git-cliff already installed"
    fi
}
