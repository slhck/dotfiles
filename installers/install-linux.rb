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
    htop
    p7zip
    p7zip-full
    rar
    unrar
    wget
    zsh
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
run "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
run "git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build"

# fzf
run "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf"
run "~/.fzf/install"