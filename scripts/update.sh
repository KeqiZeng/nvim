#!/bin/bash

cd ~

brew upgrade nvim

# Provider
pip2 install --upgrade pynvim
pip install --upgrade neovim pynvim
npm update -g neovim
sudo gem update neovim

# Language-Server
npm update -g bash-language-server              #bash
npm update -g dockerfile-language-server-nodejs #dockerls
npm update -g vscode-langservers-extracted      #cssls(for css), eslint(for javascript), html and json
npm update -g remark-language-server            #remarkls for markdown
npm update remark

pip install --upgrade cmake-language-server #cmake

go install golang.org/x/tools/gopls@latest #golang

brew upgrade lua-language-server pyright texlab #luals, pyright and texlab

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
