# Ketch's personal Nvimconf

Tired to open many files when change my config, so written all config in init.lua

Run setup.sh to install and update Language Server Protocol and Language Provider. On MacOS, I use clangd as LSP for c and cpp, which is included in Xcode-CommandLine-Tools, so need to run `xcode-select --install` to install it manually.

Autoswitchim require ['macism'](https://github.com/laishulu/macism)(on Mac for Squirrel) [`im-select`](https://github.com/daipeihust/im-select)(for Linux)

Two dictionaries(one for English, another for Deutsch) include in `dict` to support words completion.
