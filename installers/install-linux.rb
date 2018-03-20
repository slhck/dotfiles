#!/usr/bin/env ruby
#
# Linux installer
# https://github.com/cowboy/dotfiles/blob/master/init/20_ubuntu_apt.sh

require_relative 'functions.rb'

# Aptitude
apt_get_tools = %w(
    build-essential
    curl
    git
    git-flow
    git-extras
    htop
    p7zip
    p7zip-full
    rar
    unrar
    wget
    zsh
    python-dev
    python-pip
    python-numpy
    python-scipy
    python-setuptools
    python3-dev
    python3-pip
    python3-numpy
    python3-scipy
    python3-setuptools
    vim
    libreadline-dev
    libssl-dev
    zlib1g-dev
)
run "sudo apt-get update"
run "sudo apt-get install --assume-yes " + apt_get_tools.join(' ')

# Vim Ctrl-P
run "mkdir -p ~/.vim && cd ~/.vim && git clone https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim"

# SSH key
run "ssh-keygen -t rsa"

# oh-my-zsh
run "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"

# Rbenv and ruby-build
run "git clone https://github.com/rbenv/rbenv.git ~/.rbenv"
run "cd ~/.rbenv && src/configure && make -C src"
run "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build"
run "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bashrc"

# fzf
run "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf"
run "~/.fzf/install"

# autojump
run "git clone git://github.com/joelthelion/autojump.git ~/autojump"
run "~/autojump/install.py"
run "rm -rf ~/autojump"

# Node.js
run "curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -"
run "sudo apt-get install -y nodejs"

# pips
pips = %w(
    youtube_dl
    ffmpeg-normalize
    thefuck
)
run "pip3 install " + pips.join(' ')

# Spaceship theme
run 'git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"'
run 'ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"'

# Node.js
run 'npm install -g jsonlint jshint grunt reveal-md web-ext tldr'