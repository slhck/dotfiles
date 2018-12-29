# Dotfiles

This is a repository of my dotfiles and OS X / Linux-specific installers.

**CAVEAT:** None of this is fully automated. Take whatever you need.

# Brewfile creation

```
brew bundle dump --force --describe
```

# Installation

Prerequisites under Linux:

```
sudo apt update && sudo apt install -y git
mkdir -p ~/Documents/Projects/slhck/
git clone https://github.com/slhck/dotfiles ~/Documents/Projects/slhck/dotfiles
cd !$
```

Under macOS, download the repo manually.

Then:

1. Run the `installers/general.sh` script for general tool installation
1. Run the `installers/bootstrap.sh` script for copying the relevant files
1. Switch to ZSH
    - Through `chsh -s /usr/bin/zsh`
    - Then change the default shell for GNOME Terminal (Linux)
1. Run the `installers/zsh.sh` script for zsh-specific stuff
1. Run the `installers/node.sh` script
1. Run the `installers/python.sh` script

# Syncing Software

* Sublime Text 3: Copy the `Packages/User` folder
* iTerm 2:
  * Export/Import settings
  * Colors: `OceanicNext`