#!/bin/bash

# Copy dotfiles
./copy.sh

# Update Ubuntu and get standard repository programs
sudo apt update && sudo apt full-upgrade -y

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

# Basics - calls the function above which checks if the programs are installd or not
install awscli
install curl
install exfat-utils
install file
install git
install nmap
install tree
install vim
install wget
install libnss3-tools


# Run all scripts in programs/
for f in programs/*.sh; do bash "$f" -H; done

# Setup localhost https cert
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
sudo mv mkcert-v1.4.3-linux-amd64 /usr/bin/mkcert
sudo chmod +x /usr/bin/mkcert
mkcert -install
mkcert localhost

# Get all upgrades
sudo apt upgrade -y
sudo apt autoremove -y


# git config
git config --global init.defaultBranch main  
git config --global user.name "mvogelgesang"