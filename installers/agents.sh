# Module: agents
# Installs AI coding agents and shared agent skills

install_agents() {
    log "Installing AI coding agents..."

    _install_pi_agent
    _install_agent_skills
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
    local skills_dir="$HOME/.agents/skills"
    local claude_dir="$HOME/.claude"
    local symlink="$claude_dir/skills"

    # Clone agent-skills repo
    if [[ -d "$skills_dir" ]]; then
        log_success "agent-skills already cloned"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would clone agent-skills to $skills_dir"
    else
        mkdir -p "$HOME/.agents"
        git clone https://github.com/slhck/agent-skills.git "$skills_dir"
        log_success "agent-skills cloned to $skills_dir"
    fi

    # Create Claude skills symlink
    if [[ -L "$symlink" ]]; then
        log_success "Claude skills symlink already exists"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "Would symlink $symlink -> $skills_dir"
    else
        mkdir -p "$claude_dir"
        ln -s "$skills_dir" "$symlink"
        log_success "Symlinked $symlink -> $skills_dir"
    fi
}
