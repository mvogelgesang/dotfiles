#!/bin/bash

# https://code.visualstudio.com/docs/setup/linux
echo "⌨️  Installing VSCode"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt install -y apt-transport-https
sudo apt update
sudo apt install -y code
rm microsoft.gpg
function install {
  name="${1}"
  code --install-extension ${name} --force
}
# new extensions just require extension id
install eamodio.gitlens
install bierner.markdown-preview-github-styles
install davidanson.vscode-markdownlint
install jounqin.vscode-mdx
install dsznajder.es7-react-js-snippets
install esbenp.prettier-vscode
install rebornix.ruby
install wingrunr21.vscode-ruby
install msjsdiag.vscode-react-native
install EQuimper.react-native-react-redux
install PKief.material-icon-theme