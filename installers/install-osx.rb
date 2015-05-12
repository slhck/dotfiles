#!/usr/bin/env ruby
#
# OS X installer

require_relative 'functions.rb'

# XCode
run "sudo xcode-select -switch /usr/bin"

# Vim Ctrl-P
run "mkdir -p ~/.vim && cd ~/.vim && git clone https://github.com/kien/ctrlp.vim.git bundle/ctrlp.vim"

# Homebrew
run %( ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" )
run "brew tap caskroom/cask"
run "brew install brew-cask"

# Homebrew casks
casks = %w(
  betterzipql
  qlcolorcode
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-csv
  quicklook-json
  quicknfo
  suspicious-package
  webpquicklook
)
run "brew cask install " + casks.join(" ")

# Homebrew formulae
formulae = %w(
  bash
  coreutils
  dos2unix
  ffmpeg
  findutils
  git
  git-extras
  git-flow
  grc
  id3tool
  lesspipe
  man2html
  media-info
  mercurial
  nmap
  python
  rbenv
  ruby-build
  sl
  ssh-copy-id
  terminal-notifier
  tree
  unrar
  wget
  youtube-dl
  zsh
)
run "brew install " + formulae.join(" ")

# ffmpeg
run "brew install ffmpeg \
--with-faac \
--with-fdk-aac \
--with-ffplay \
--with-fontconfig \
--with-freetype \
--with-frei0r \
--with-libass \
--with-libbluray \
--with-libcaca \
--with-libquvi \
--with-libsoxr \
--with-libssh \
--with-libvidstab \
--with-libvorbis \
--with-libvpx \
--with-opencore-amr \
--with-openjpeg \
--with-openssl \
--with-opus \
--with-rtmpdump \
--with-schroedinger \
--with-speex \
--with-theora \
--with-tools \
--with-webp \
--with-x265"

# oh-my-zsh
run "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh"

# FZF
run "brew reinstall --HEAD fzf"
# Install shell extensions
run "/usr/local/Cellar/fzf/HEAD/install"