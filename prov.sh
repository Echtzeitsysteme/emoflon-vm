#!/bin/bash

#
# Config
#

ECLIPSE_ARCHIVE=eclipse-emoflon-linux-user

set -e
START_PWD=$PWD

#
# Utils
#

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

#
# Script
#

log "Start provisioning."

# Updates
log "Installing updates."
sudo apt-get update
sudo apt-get dist-upgrade -y

# Java/JDK21
log "Installing OpenJDK."
sudo apt-get install -y openjdk-21-jdk
#java --version

# Packages for building a new kernel
sudo apt-get install -y gcc make perl

# eMoflon Eclipse
log "Installing eMoflon Eclipse."
sudo apt-get install -y graphviz
mkdir -p ~/eclipse-apps
cd ~/eclipse-apps

# Get eclipse
if [[ ! -f "./$ECLIPSE_ARCHIVE.zip" ]]; then
	log "Downloading latest eMoflon Eclipse archive from Github."
	curl -s --header "Authorization: Bearer ${GITHUB_TOKEN}" \
        https://api.github.com/repos/eMoflon/emoflon-ibex-eclipse-build/releases/latest \
        | grep "$ECLIPSE_ARCHIVE.zip" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -q --header="Authorization: Bearer ${GITHUB_TOKEN}" -i - \
        || :
fi

if [[ ! -f "./$ECLIPSE_ARCHIVE.zip" ]]; then
        log "Download of eMoflon Eclipse archive failed."
        exit 1;
fi

unzip -qq -o $ECLIPSE_ARCHIVE.zip
rm -f $ECLIPSE_ARCHIVE.zip

# Create desktop launchers
mkdir -p /home/vagrant/Desktop
touch /home/vagrant/Desktop/emoflon-app.desktop
printf "
[Desktop Entry]
Version=1.0
Name=eMoflon::IBeX Eclipse
Comment=Use eMoflon::IBeX Eclipse
GenericName=eMoflon::IBeX Eclipse
Exec=bash -c \"cd /home/vagrant/eclipse-apps/eclipse && ./eclipse\"
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/home/vagrant/eclipse-apps/eclipse/icon.xpm
StartupNotify=true
" > /home/vagrant/Desktop/emoflon-app.desktop

touch /home/vagrant/Desktop/emoflon-website.desktop
printf "
[Desktop Entry]
Encoding=UTF-8
Name=eMoflon::IBeX Website
Type=Link
URL=https://emoflon.org/ibex
Icon=web-browser
" > /home/vagrant/Desktop/emoflon-website.desktop

touch /home/vagrant/Desktop/emoflon-tutorial.desktop
printf "
[Desktop Entry]
Encoding=UTF-8
Name=eMoflon::IBeX Tutorial
Type=Link
URL=https://github.com/eMoflon/emoflon-ibex-tutorial/releases/latest
Icon=web-browser
" > /home/vagrant/Desktop/emoflon-tutorial.desktop

touch /home/vagrant/Desktop/emoflon-tests.desktop
printf "
[Desktop Entry]
Encoding=UTF-8
Name=eMoflon::IBeX Test Suite
Type=Link
URL=https://github.com/eMoflon/emoflon-ibex-tests
Icon=web-browser
" > /home/vagrant/Desktop/emoflon-tests.desktop

chmod u+x /home/vagrant/Desktop/*.desktop

sudo mv /home/vagrant/Desktop/*.desktop /usr/share/xubuntu/applications/
sudo ln -s /usr/share/xubuntu/applications/emoflon-app.desktop /home/vagrant/Desktop/emoflon-app.desktop
sudo ln -s /usr/share/xubuntu/applications/emoflon-website.desktop /home/vagrant/Desktop/emoflon-website.desktop
sudo ln -s /usr/share/xubuntu/applications/emoflon-tutorial.desktop /home/vagrant/Desktop/emoflon-tutorial.desktop
sudo ln -s /usr/share/xubuntu/applications/emoflon-tests.desktop /home/vagrant/Desktop/emoflon-tests.desktop

# Install additional CLI tools
log "Install additional CLI tools."
sudo apt-get install -yq \
        git \
        ncdu \
        htop \
        tmux \
        rsync

# Clean up
log "Clean-up"
sudo apt-get remove -yq \
        libreoffice-* \
        thunderbird \
        pidgin \
        gimp \
        evolution
sudo apt-get autoremove -yq
sudo apt-get clean cache

log "Finished provisioning."
