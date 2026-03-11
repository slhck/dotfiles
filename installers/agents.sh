# Module: agents
# Installs AI coding agents and shared agent skills

install_agents() {
    log "Installing AI coding agents..."

    # On Linux, Claude Code / Gemini CLI / Codex are not available as Homebrew casks
    if [[ "$OS" == "linux" ]]; then
        _install_claude_code
        _install_gemini_cli
        _install_codex
    fi

    _install_pi_agent
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

    if ! is_installed npm; then
        log_warning "npm not available — install Node.js first (run 'node' component), then re-run 'agents'"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install Codex globally via npm"
    else
        npm install -g @openai/codex
        log_success "Codex installed"
    fi
}

_install_pi_agent() {
    if is_installed pi; then
        log_success "pi-coding-agent already installed"
        return
    fi

    if ! is_installed npm; then
        log_warning "npm not available — install Node.js first (run 'node' component), then re-run 'agents'"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would install pi-coding-agent globally via npm"
    else
        npm install -g @mariozechner/pi-coding-agent
        log_success "pi-coding-agent installed"
    fi
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
