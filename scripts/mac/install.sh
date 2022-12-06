#!/bin/bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update

function brewInstall {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    brew install $2 $1
  else
    echo "Already installed: ${1}"
  fi
}

brewInstall visual-studio-code --cask
brewInstall docker --cask
brewInstall rectangle --cask
brewInstall discord --cask
brewInstall vlc --cask
brewInstall android-studio --cask
brewInstall nvm

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

omz update
cp .zshrc ~/.zshrc
source ~/.zshrc
brew install starship

## SSH
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

gh ssh-key add ~/.ssh/id_ed25519.pub -t github

source ~/.zshrc

nvm install --lts

node -v && npm -v

npm install -g npm@latest

# needs work
# npm config set --init-author-name "Mark Vogelgesang"
# npm config set --init-author-email "movogelgesang@gmail.com"
# npm config set --init-author-url "htttps://mvogelgesang.com"
# npm add user

npm install -g yarn
yarn -v
# Other System Preferences

# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Cross-environment config

bash ../shared.sh