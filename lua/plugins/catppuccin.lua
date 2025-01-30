return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            show_end_of_buffer = true,
            term_colors = true,
            dim_inactive = {
                enable = true,
            },
            styles = {
                functions = { "bold" },
            },
            custom_highlights = function(colors)
                return {
                    ["@lsp.type.variable"] = { fg = colors.lavender },
                    DiagnosticHint = { fg = colors.sapphire },
                    DiagnosticInfo = { fg = colors.teal },
                }
            end,
            integrations = {
                -- alpha = true,
                -- cmp = true,
                -- dashboard = true,
                blink_cmp = true,
                flash = true,
                fzf = true,
                gitsigns = true,
                -- indent_blankline = { enabled = true },
                markdown = true,
                mason = true,
                mini = {
                    enabled = true,
                    indentscope_color = "pink",
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "undercurl" },
                        warnings = { "undercurl" },
                    },
                    inlay_hints = {
                        background = true,
                    },
                },
                -- nvimtree = true,
                -- navic = { enabled = true, custom_bg = "lualine" },
                -- noice = true,
                -- notify = true,
                -- telescope = true,
                treesitter = true,
                -- treesitter_context = true,
            }
        })
        vim.cmd.colorscheme("catppuccin")
    end,
}
