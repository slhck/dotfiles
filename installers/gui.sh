#/usr/bin/env bash
#
# Linux GUI stuff

# Sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text

# Themes
sudo add-apt-repository ppa:tista/adapta
sudo apt update
sudo apt install \
    gnome-tweak-tool
    numix-gtk-theme \
    numix-icon-theme \
    adapta-gtk-theme