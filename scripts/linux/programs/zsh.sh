#!/bin/bash

echo "📦 Installing zsh"

sudo apt install -y zsh
zsh --version

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

chsh -s `which zsh`