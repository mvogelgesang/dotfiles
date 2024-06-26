#!/bin/bash

echo "📦 Installing nvm"
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

source ~/.bashrc

nvm install node
nvm install-latest-npm

npm install -g autoprefixer postcss-cli
npm install -g expo-cli
npm install -g markdown-link-check
npm install -g prettier
npm install -g standard
npm install -g yarn
npm install -g sfdx-cli
npm install -g typescript