#!/bin/bash

cd ~

# Provider
pip install neovim pynvim
npm install -g neovim
sudo gem install neovim

# Language-Server
npm install remark
brew install texlab #lua, python and latex

#clangd for c/c++ update with xcode-commandline-tool
# brew install llvm

# for installation of Markdown-preview
npm install -g yarn

# for Treesitter.nvim
brew install tree-sitter

# for Telescope
brew install ripgrep fd

# install formatter
pip install autopep8
brew install stylua shfmt clang-format prettier
conda install -c conda-forge latexindent.pl
