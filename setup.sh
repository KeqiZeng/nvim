#!/bin/bash

cd ~

# Provider
pip2 install pynvim
pip install neovim pynvim
npm install -g neovim
sudo gem install neovim

# Language-Server
npm install -g bash-language-server #bash
npm install -g dockerfile-language-server-nodejs #dockerls
npm install -g vscode-langservers-extracted #cssls(for css), eslint(for javascript), html and json
npm install -g remark-language-server #remarkls for markdown
npm install remark

pip install cmake-language-server #cmake

go install golang.org/x/tools/gopls@latest #golang

brew install lua-language-server pyright texlab #luals, pyright and texlab

#clangd for c/c++ update with xcode-commandline-tool
# brew install llvm

# for installation of Markdown-preview
npm install -g yarn

# for Treesitter.nvim
brew install tree-sitter

# for Telescope
brew install ripgrep fd
