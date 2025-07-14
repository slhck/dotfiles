#!/usr/bin/env bash
# NVM and nodejs

nvm install --lts

npm install -g \
    yarn

# some other tools that are generally useful
tools=(
    @anthropic-ai/claude-code
    @google/gemini-cli
    @openai/codex
)

for tool in "${tools[@]}"; do
    echo "Installing $tool"
    npm install -g "$tool"
done

echo "Done"
