# -----------------------------------------------
# Set up the Environment
# -----------------------------------------------

EDITOR=vim
PAGER=less
DISPLAY=:0.0
COLORTERM=yes
PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/texbin:/usr/bin:/usr/sbin:/bin:/sbin

HISTFILE=~/.zshhistory
HISTSIZE=10000
SAVEHIST=10000

export TERM EDITOR PAGER DISPLAY LS_COLORS COLORTERM PATH HISTFILE HISTSIZE SAVEHIST

# set locale if needed
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# -----------------------------------------------
# oh-my-zsh
# -----------------------------------------------

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Use blinks with: http://ethanschoonover.com/solarized
ZSH_THEME="blinks"

COMPLETION_WAITING_DOTS="true"

# Plugins to load
plugins=(rails git git-extras github git-flow textmate ruby brew osx gem svn docker docker-compose vagrant virtualenv python)

source $ZSH/oh-my-zsh.sh

# -----------------------------------------------
#  Keybindings for iTerm2 in OS X, set it to xterm
#  defaults though.
# -----------------------------------------------

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word

bindkey '^W' vi-backward-kill-word
bindkey '^f' vi-forward-word
bindkey '^b' vi-backward-word

# -----------------------------------------------
# Load zsh modules
# -----------------------------------------------

# compinit initializes various advanced completions for zsh
autoload -U compinit && compinit

# zmv is a batch file rename tool; e.g. zmv '(*).text' '$1.txt'
autoload zmv

# -----------------------------------------------
# Set up zsh autocompletions
# -----------------------------------------------

# case-insensitive tab completion for filenames (useful on Mac OS X)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# General completion technique
zstyle ':completion:*' completer _complete _correct _approximate _prefix
zstyle ':completion:*' completer _complete _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete

# Completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

# Expand partial paths
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# Separate matches into groups
zstyle ':completion:*:matches' group 'yes'

# Describe each match group.
zstyle ':completion:*:descriptions' format "%B%d%b"

# Messages/warnings format
zstyle ':completion:*:messages' format '%B%U%d%u%b'
zstyle ':completion:*:warnings' format '%B%Uno match for: %d%u%b'

# Describe options in full
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# -----------------------------------------------
# Set zsh options
# -----------------------------------------------

setopt \
  auto_cd \
  no_beep \
  correct \
  auto_list \
  auto_pushd \
  complete_in_word \
  extended_glob \
  zle

unsetopt \
  correct_all \
  hist_verify

# Ununsed
# glob_complete \
# setopt complete_aliases

# -----------------------------------------------
# Shell Aliases
# -----------------------------------------------

## Command Aliases
alias x=exit
alias c=clear
alias s=screen
alias t=tmux
alias ta='tmux a'
alias tls='tmux ls'
alias vi='vim'
#alias ls='ls --color=auto -F'
#alias l='ls -lAF --color=auto'
alias zrc='vim ~/.zshrc'
alias e='smartextract'
alias pie='perl -pi -e'

## Listings
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias llha='ls -lha'

## ZMV-specific
alias zcp='zmv -C'
alias zln='zmv -L'
alias mmv='noglob zmv -W'

## Pipe Aliases (Global)
alias -g L='|less'
alias -g G='|grep'
alias -g T='|tail'
alias -g H='|head'
alias -g W='|wc -l'
alias -g S='|sort'

## Special Root Aliases
[ $UID = 0 ] && \
  alias m='make' && \
  alias mi='make install' && \
  alias rm='rm -i' && \
  alias mv='mv -i' && \
  alias cp='cp -i'

## Git
alias gcam='git add -A && git commit -m "update" && git pull --rebase && git push'
alias gups='git submodule update --rebase --remote --init --recursive'

# -----------------------------------------------
#  User-defined Functions
# -----------------------------------------------

cl() {
  cd "$@"
  ls -la
}

mc() {
  mkdir -p "$*" && cd "$*"
}

# Usage: smartextract <file>
# Description: extracts archived files / mounts disk images
# Note: .dmg/hdiutil is Mac OS X-specific.
smartextract () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)  tar -jxvf "$1"        ;;
            *.tar.gz)   tar -zxvf "$1"        ;;
            *.bz2)      bunzip2 "$1"          ;;
            *.dmg)      hdiutil mount "$1"    ;;
            *.gz)       gunzip "$1"           ;;
            *.rar)      unrar x "$1"          ;;
            *.tar)      tar -xvf "$1"         ;;
            *.tbz2)     tar -jxvf "$1"        ;;
            *.tgz)      tar -zxvf "$1"        ;;
            *.zip)      unzip "$1"            ;;
            *.Z)        uncompress "$1"       ;;
            *)          echo "'$1' cannot be extracted/mounted via smartextract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

psgrep() {
    if [ ! -z $1 ] ; then
        echo "Grepping for processes matching $1..."
        ps aux | grep $1 | grep -v grep
    else
        echo "!! Need name to grep for"
    fi
}

embed-fonts() {
  # http://stackoverflow.com/q/2670809/
  if [ "$#" -ne 2 ]; then
    echo "Usage: embed-fonts <input> <output>" && return
  fi
  gs \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/screen \
   -dCompressFonts=true \
   -dSubsetFonts=true \
   -dNOPAUSE \
   -dBATCH \
   -sDEVICE=pdfwrite \
   -sOutputFile="$2" \
   -c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams" \
   -f "$1"
}

# -----------------------------------------------
#  Color for ls
# -----------------------------------------------

export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;36:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.bz2=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.sit=01;31:*.hqx=01;31:*.jpg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mpg=01;35:*.avi=01;35:*.mov=01;35:*.app=01;33:*.c=00;33:*.php=00;33:*.pl=00;33:*.cgi=00;33:'
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# -----------------------------------------------
#  rbenv
# -----------------------------------------------

#if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init - zsh)"; fi
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# END: Global configuration file


