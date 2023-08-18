#!/bin/bash

cd ~ || return

# Nvim
brew install neovim

# Provider
pip install neovim pynvim
npm install -g neovim
sudo gem install neovim

# for installation of Markdown-preview
npm install -g yarn

# for Treesitter.nvim
brew install tree-sitter

# for Telescope
brew install ripgrep fd

# for autoswitchim
brew install macism
