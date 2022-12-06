#!/bin/bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update

brew install --cask \
  dropbox \
  keepassx \ 
  google-chrome  \
  tor \
  visual-studio-code \
  docker \
  rectangle \
  discord \
  vlc \
  imageoptim \
  wget \
  git \
  nvm \
  pnpm \
  commitzen \

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

omz update
cp .zshrc ~/.zshrc
source ~/.zshrc
brew install starship

## SSH
mkdir ~/.ssh

cd ~/.ssh

ssh-keygen -t ed25519 -C "github"
# Confirm whether passphrase was used properly by accessing private key:
ssh-keygen -y -f gitHub
# in case the file is not there yet
touch ~/.ssh/config
echo "Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/github" > ~/.ssh/config

ssh-add --apple-use-keychain ~/.ssh/github

# add the public key to github via the GH cli
# copy public key and add it to https://github.com/
cat ~/.ssh/id_rsa.pub | pbcopy

# or use GitHub's CLI
gh auth login
# for the first login I think the SSH key gets added
# without the next command, but if not:

gh ssh-key add ~/.ssh/id_rsa.pub -t github

# NVM
echo "source $(brew --prefix nvm)/nvm.sh" >> ~/.zshrc

source ~/.zshrc

nvm install --lts

node -v && npm -v

npm install -g npm@latest

npm set init.author.name "Mark Vogelgesang"
npm set init.author.email "movogelgesang@gmail.com"
npm set init.author.url "mvogelgesang.com"
npm add user

npm install -g yarn
yarn -v
# Other System Preferences

# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Cross-environment config

bash ../shared.sh