# Module: agents
# Installs AI coding agents and shared agent skills

install_agents() {
    log "Installing AI coding agents..."

    # Claude Code is always installed via its install script (not Homebrew)
    _install_claude_code
    _install_claude_md
    _install_claude_hooks

    # On Linux, Gemini CLI / Codex are not available as Homebrew casks
    if [[ "$OS" == "linux" ]]; then
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
