# Module: agents
# Installs AI coding agents and shared agent skills

install_agents() {
    log "Installing AI coding agents..."

    # Claude Code, Codex, pi, and herdr are installed via their official
    # install scripts (not Homebrew or npm) on both macOS and Linux.
    _install_claude_code
    _install_claude_md
    _install_claude_hooks
    _install_codex
    _install_pi_agent
    _install_herdr
    _install_herdr_plugins
    _install_herdr_renderers
    _install_herdr_config

    # Gemini CLI has no Homebrew cask on Linux, so install it via npm there.
    # On macOS it comes from the Brewfile (packages component).
    if [[ "$OS" == "linux" ]]; then
        _install_gemini_cli
    fi

    _install_agent_skills
}

_install_claude_code() {
    if is_installed claude; then
        log_success "Claude Code already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Claude Code via install script"
    else
        curl -fsSL https://claude.ai/install.sh | bash
        log_success "Claude Code installed"
    fi
}

# Deploys the global Claude instructions (CLAUDE.md) to ~/.claude. This file is
# user-authored — Claude doesn't write to it — so a plain copy with a backup is
# fine. Edit the repo copy (claude/CLAUDE.md) and re-run to update.
_install_claude_md() {
    local src="$SCRIPT_DIR/claude/CLAUDE.md"
    local dst="$HOME/.claude/CLAUDE.md"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install global Claude instructions: CLAUDE.md -> $dst"
        return
    fi

    mkdir -p "$HOME/.claude"
    backup_file "$dst"
    cp "$src" "$dst"
    log_success "Installed global Claude instructions: CLAUDE.md"
}

# Deploys Claude Code hooks tracked in the repo and registers them in the
# global settings. Currently just block-rg-replace.py, which stops Claude from
# misusing `rg -r` (ripgrep's replace flag) when it means recursion.
_install_claude_hooks() {
    local hooks_src="$SCRIPT_DIR/claude/hooks"
    local hooks_dst="$HOME/.claude/hooks"
    local settings="$HOME/.claude/settings.json"
    local hook_cmd="~/.claude/hooks/block-rg-replace.py"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Claude Code hook: block-rg-replace.py -> $hooks_dst"
        log_dry "Would register hook in $settings (PreToolUse / Bash)"
        return
    fi

    mkdir -p "$hooks_dst"
    cp "$hooks_src/block-rg-replace.py" "$hooks_dst/block-rg-replace.py"
    chmod +x "$hooks_dst/block-rg-replace.py"
    log_success "Installed Claude Code hook: block-rg-replace.py"

    if ! is_installed jq; then
        log_warning "jq not available — skipped registering hook in settings.json (add it manually)"
        return
    fi

    # Start from an empty object if there are no settings yet
    [[ -f "$settings" ]] || echo '{}' > "$settings"

    # Idempotently add the hook to the PreToolUse "Bash" matcher group without
    # touching any other settings (model, plugins, etc. are managed by Claude).
    local tmp
    tmp="$(mktemp)"
    if jq --arg cmd "$hook_cmd" '
        .hooks //= {}
        | .hooks.PreToolUse //= []
        | (if any(.hooks.PreToolUse[]; .matcher == "Bash") then .
           else .hooks.PreToolUse += [{matcher: "Bash", hooks: []}] end)
        | .hooks.PreToolUse |= map(
            if .matcher == "Bash" then
              .hooks = ((.hooks // [])
                        | if any(.[]; .command == $cmd) then .
                          else . + [{type: "command", command: $cmd}] end)
            else . end)
    ' "$settings" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$settings"
        log_success "Registered block-rg-replace hook in settings.json"
    else
        rm -f "$tmp"
        log_warning "Could not update settings.json automatically (left unchanged)"
    fi
}

_install_gemini_cli() {
    if is_installed gemini; then
        log_success "Gemini CLI already installed"
        return
    fi

    if ! is_installed npm; then
        log_warning "npm not available — install Node.js first (run 'node' component), then re-run 'agents'"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Gemini CLI globally via npm"
    else
        npm install -g @google/gemini-cli
        log_success "Gemini CLI installed"
    fi
}

_install_codex() {
    if is_installed codex; then
        log_success "Codex already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Codex via install script"
    else
        curl -fsSL https://chatgpt.com/codex/install.sh | sh
        log_success "Codex installed"
    fi
}

_install_pi_agent() {
    if is_installed pi; then
        log_success "pi-coding-agent already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install pi-coding-agent via install script"
    else
        curl -fsSL https://pi.dev/install.sh | sh
        log_success "pi-coding-agent installed"
    fi
}

_install_herdr() {
    if is_installed herdr; then
        log_success "herdr already installed"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install herdr via install script"
    else
        curl -fsSL https://herdr.dev/install.sh | sh
        log_success "herdr installed"
    fi
}

# Resolve the herdr binary even before ~/.local/bin is on PATH (herdr's
# installer drops it there). Prints nothing if herdr can't be found.
_herdr_bin() {
    command -v herdr 2>/dev/null && return
    [[ -x "$HOME/.local/bin/herdr" ]] && echo "$HOME/.local/bin/herdr"
}

# Installs the herdr plugins we rely on: the reviewr sidebar and the git-aware
# file viewer. `plugin install` is idempotent — it re-syncs an existing plugin.
_install_herdr_plugins() {
    local herdr_bin plugin
    herdr_bin="$(_herdr_bin)"
    if [[ -z "$herdr_bin" ]]; then
        log_warning "herdr not found — skipping herdr plugins"
        return
    fi

    for plugin in persiyanov/herdr-reviewr smarzban/herdr-file-viewer; do
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "Would install herdr plugin: $plugin"
        elif "$herdr_bin" plugin install "$plugin" --yes; then
            log_success "herdr plugin installed: $plugin"
        else
            log_warning "herdr plugin install failed: $plugin"
        fi
    done
}

# The herdr-file-viewer plugin renders diffs with delta and code with bat when
# they're on PATH, and falls back to plain text otherwise. (glow/markdown
# rendering is intentionally not set up.)
_install_herdr_renderers() {
    if [[ "$OS" == "macos" ]]; then
        # git-delta (provides `delta`) and bat come from the Brewfile.
        log_success "herdr renderers (delta/bat) come from the Brewfile on macOS"
        return
    fi

    # Linux, no sudo required. Careful: /usr/bin/git-delta on Debian belongs to
    # git-extras — a script that lists files differing from a branch, NOT the
    # delta pager. The real pager isn't packaged in Debian stable, so install
    # the static musl build from GitHub releases into ~/.local/bin.

    # Clean up the bad bridge from an earlier version of this installer, which
    # symlinked delta -> git-extras' git-delta. That made `git diff` pipe into
    # a script that never reads stdin: blank screen, hung pager.
    if [[ -L "$HOME/.local/bin/delta" ]] && [[ "$(readlink "$HOME/.local/bin/delta")" == *git-delta* ]]; then
        rm -f "$HOME/.local/bin/delta"
        log_warning "Removed bad delta symlink (pointed at git-extras' git-delta)"
    fi

    # ~/.local/bin may not be on PATH yet during bootstrap — check it directly.
    local delta_bin
    delta_bin="$(command -v delta 2>/dev/null || true)"
    [[ -z "$delta_bin" && -x "$HOME/.local/bin/delta" ]] && delta_bin="$HOME/.local/bin/delta"
    if [[ -n "$delta_bin" ]] && "$delta_bin" --version 2>/dev/null | grep -q "^delta "; then
        log_success "delta already installed"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install delta from GitHub releases"
    else
        local arch tag url tmpdir
        arch="$(uname -m)"  # x86_64 and aarch64 both have musl builds
        tag="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
        if [[ -z "$tag" ]]; then
            log_warning "Could not resolve latest delta release — skipping delta install"
        else
            url="https://github.com/dandavison/delta/releases/download/${tag}/delta-${tag}-${arch}-unknown-linux-musl.tar.gz"
            tmpdir="$(mktemp -d)"
            if curl -fsSL "$url" | tar xz -C "$tmpdir"; then
                mkdir -p "$HOME/.local/bin"
                install -m 755 "$tmpdir/delta-${tag}-${arch}-unknown-linux-musl/delta" "$HOME/.local/bin/delta"
                log_success "delta ${tag} installed to ~/.local/bin"
            else
                log_warning "delta download failed — git pager and herdr diff rendering unavailable"
            fi
            rm -rf "$tmpdir"
        fi
    fi

    # bat is expected from the distro package manager; the viewer degrades
    # gracefully if it — or any renderer — is missing.
    if ! is_installed bat && ! is_installed batcat; then
        log_warning "bat not found — 'apt install bat' for syntax highlighting in the herdr file viewer"
    fi
}

# Deploys the herdr config (a keybinding for the file viewer) to
# ~/.config/herdr/config.toml. Like CLAUDE.md this is user-editable, so it's a
# plain copy with a backup — edit the repo copy (herdr/config.toml) and re-run.
_install_herdr_config() {
    local src="$SCRIPT_DIR/herdr/config.toml"
    local dst="$HOME/.config/herdr/config.toml"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install herdr config: config.toml -> $dst"
        return
    fi

    mkdir -p "$HOME/.config/herdr"
    backup_file "$dst"
    cp "$src" "$dst"
    log_success "Installed herdr config: config.toml"

    # Apply immediately if a herdr server is already running (no-op otherwise).
    local herdr_bin
    herdr_bin="$(_herdr_bin)"
    [[ -n "$herdr_bin" ]] && "$herdr_bin" server reload-config >/dev/null 2>&1
    return 0
}

_install_agent_skills() {
    if ! is_installed npx; then
        log_warning "npx not available — install Node.js first (run 'node' component), then re-run 'agents'"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install agent-skills via npx"
    else
        npx --yes skills add https://github.com/slhck/agent-skills --global --skill '*' --agent 'claude-code' --agent 'gemini-cli' --agent 'codex' --agent 'pi' --agent 'opencode' -y
        log_success "agent-skills installed"
    fi
}
