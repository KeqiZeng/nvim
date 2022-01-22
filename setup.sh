#!/bin/bash

cd ~

# Provider
pip2 install pynvim
pip install neovim pynvim
npm install -g neovim
sudo gem install neovim

# Language-Server
npm install -g bash-language-server #bash

pip install cmake-language-server #cmake

npm install -g dockerfile-language-server-nodejs #dockerls

go install golang.org/x/tools/gopls@latest #golang

npm install -g vscode-langservers-extracted #cssls(for css), eslint(for javascript), html and json

brew install lua-language-server pyright texlab #luals, pyright and texlab

npm install -g remark-language-server #remarkls for markdown
npm install remark

#clangd for c/c++ update with xcode-commandline-tool
# brew install llvm

# for installation of Markdown-preview
npm install -g yarn

# for Treesitter.nvim
brew install tree-sitter

# for Telescope
brew install ripgrep fd
