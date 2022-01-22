#!/bin/bash

cd ~

npm install -g bash-language-server #bash

#clangd for c/c++ update with xcode-commandline-tool
# brew install llvm

pip install cmake-language-server #cmake

npm install -g dockerfile-language-server-nodejs #dockerls

go install golang.org/x/tools/gopls@latest #golang

npm install -g vscode-langservers-extracted #cssls(for css), eslint(for javascript), html and json

brew install lua-language-server pyright texlab #luals, pyright and texlab

npm install -g remark-language-server #remarkls for markdown
npm install remark
