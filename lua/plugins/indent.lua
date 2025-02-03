return {
    "echasnovski/mini.indentscope",
    event = "BufReadPost",
    version = "*",
    opts = {
        symbol = "│",
    },
    init = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "help",
                "man",
                "gitcommit",
                "checkhealth",
                "lazy",
                "mason",
                "lspinfo",
                "fzf",
            },
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
        })
    end
}
