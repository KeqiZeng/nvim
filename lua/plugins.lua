local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    require("plugins.catppuccin"),
    require("plugins.lualine"),
    require("plugins.treesitter"),
    require("plugins.treesitter-context"),
    require("plugins.lsp"),
    require("plugins.cmp"),
    require("plugins.neocodeium"),
    require("plugins.mason"),
    require("plugins.file-explorer"),
    require("plugins.cursorword"),
    require("plugins.indent"),
    require("plugins.autopairs"),
    require("plugins.rainbow"),
    require("plugins.hipatters"),
    require("plugins.jump"),
    require("plugins.jump2d"),
    require("plugins.surround"), -- surround maybe have to after jump2d, for `ds` keymap
    require("plugins.fzf"),
    require("plugins.multicursor"),
    require("plugins.gitsigns"),
    require("plugins.clue")
})

require("terminal")
