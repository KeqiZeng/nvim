#!/bin/bash

cd ~

npm i -g bash-language-server #bash

#clangd for c/c++ update with xcode-commandline-tool

pip install cmake-language-server #cmake

npm install -g dockerfile-language-server-nodejs #dockerls

go install golang.org/x/tools/gopls@latest #golang

npm i -g vscode-langservers-extracted #cssls, eslint, html and json

brew install lua-language-server pyright texlab #luals, pyright and texlab
