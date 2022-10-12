#!/bin/bash

cd ~

brew upgrade nvim

# Provider
pip install --upgrade neovim pynvim
npm update -g neovim
sudo gem update neovim

# Language-Server
npm update remark
brew upgrade texlab #lua python and latex

# for installation of Markdown-preview
npm update -g yarn

# for Treesitter.nvim
brew upgrade tree-sitter

# for Telescope
brew upgrade ripgrep fd

# install formatter
pip install --upgrade autopep8
brew upgrade stylua shfmt clang-format prettier
conda update -c conda-forge latexindent.pl

# lint
brew install golangci-lint
