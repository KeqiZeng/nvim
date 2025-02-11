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
    require("plugins.tokyonight"),
    require("plugins.dracula"),
    require("plugins.icons"),
    require("plugins.statusline"),
    require("plugins.tabline"),
    require("plugins.notify"),
    require("plugins.treesitter"),
    require("plugins.treesitter-context"),
    require("plugins.lsp"),
    require("plugins.cmp"),
    require("plugins.neocodeium"),
    require("plugins.mason"),
    require("plugins.files"),
    require("plugins.cursorword"),
    require("plugins.indent"),
    require("plugins.autopairs"),
    require("plugins.rainbow"),
    require("plugins.hipatters"),
    require("plugins.diff"),
    require("plugins.map"),
    require("plugins.clue"),
    require("plugins.jump"),
    require("plugins.jump2d"),
    require("plugins.surround"),
    require("plugins.splitjoin"),
    require("plugins.pick"),
    require("plugins.multicursor"),
    -- local plugins
    {
        dir = vim.fn.stdpath("config") .. "/lua/plugins/terminal",
        keys = {
            {
                "<C-t>",
                function()
                    require("plugins.terminal").toggle()
                end,
                mode = { "n", "t" },
                desc = "Toggle terminal"
            },
        },
        config = function()
            require("plugins.terminal").setup()
        end
    },
    {
        dir = vim.fn.stdpath("config") .. "/lua/plugins/smartcolumn",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("plugins.smartcolumn").setup()
        end
    },
    {
        dir = vim.fn.stdpath("config") .. "/lua/plugins/gitblame",
        dependencies = {
            "echasnovski/mini.diff",
        },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("plugins.gitblame").setup()
        end
    },
    {
        dir = vim.fn.stdpath("config") .. "/lua/plugins/cdroot",
        event = { "BufEnter" },
        config = function()
            require("plugins.cdroot").setup()
        end
    },
})
