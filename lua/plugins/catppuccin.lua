return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
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
            blink_cmp = true,
            flash = true,
            fzf = true,
            gitsigns = true,
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
            treesitter = true,
            treesitter_context = true,
        }
    },
    init = function()
        vim.cmd.colorscheme("catppuccin")
    end
}
