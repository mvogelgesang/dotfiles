#!/bin/bash

function brewInstall {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    brew install $2 $1
  else
    echo "Already installed: ${1}"
  fi
}

function printSection {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "----------------"
    echo ">>> ${1}"
    echo "----------------"
  else

  fi
}

# Homebrew
printSection Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update

brewInstall android-studio --cask
brewInstall arc --cask
brewInstall discord --cask
brewInstall docker --cask
brewInstall nvm
brewInstall pyenv
brewInstall raspberry-pi-imager --cask
brewInstall rectangle --caskbr
brewInstall visual-studio-code --cask
brewInstall vlc --cask
brewInstall watchman

# ohmyzsh
printSection ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

omz update
cp .zshrc ~/.zshrc
source ~/.zshrc
brew install starship

## SSH
printSection ssh
mkdir ~/.ssh
cd ~/.ssh
ssh-keygen -t ed25519 
# Confirm whether passphrase was used properly by accessing private key:
ssh-keygen -y -f id_ed25519
# in case the file is not there yet
touch ~/.ssh/config
echo "Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519" > ~/.ssh/config
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# add the public key to github via the GH cli
# copy public key and add it to https://github.com/
cat ~/.ssh/id_ed25519.pub | pbcopy

# node, nvm, npm
printSection "Node & NPM"
nvm install --lts
node -v && npm -v
npm install -g npm@latest

# global node packages
printSection "Node Packages -g"
./node.sh

# reactNative
printSection "React Native"
./reactNative.sh

# Other System Preferences
printSection "Other System Preferences"
# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Cross-environment config
printSection "Cross-environment Config"
bash ./shared.sh
