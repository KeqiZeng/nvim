return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
        flavour = "macchiato",
        show_end_of_buffer = true,
        term_colors = true,
        no_underline = true,
        styles = {
            keywords = { "italic" },
            functions = { "bold" },
        },
        custom_highlights = function(colors)
            return {
                MiniJump = { bg = colors.red, fg = colors.base },
                MiniJump2dSpot = { bg = colors.base, fg = colors.red },

                MiniCursorword = { bg = colors.surface1 },
                MiniCursorwordCurrent = { bg = colors.surface1 },

                MiniTablineCurrent = { bg = colors.surface0, fg = colors.pink },
                MiniTablineVisible = { bg = colors.none, fg = colors.text },
                MiniTablineHidden = { bg = colors.none, fg = colors.overlay1 },
                MiniTablineModifiedCurrent = { bg = colors.surface0, fg = colors.pink },
                MiniTablineModifiedVisible = { bg = colors.none, fg = colors.text },
                MiniTablineModifiedHidden = { bg = colors.none, fg = colors.overlay1 },

                MiniStatuslineBranch = { bg = colors.surface1, fg = colors.pink },
                MiniStatuslineDiffAdd = { bg = colors.surface1, fg = colors.green },
                MiniStatuslineDiffChange = { bg = colors.surface1, fg = colors.yellow },
                MiniStatuslineDiffDelete = { bg = colors.surface1, fg = colors.red },
                MiniStatuslineDiagError = { bg = colors.surface1, fg = colors.red },
                MiniStatuslineDiagWarn = { bg = colors.surface1, fg = colors.yellow },
                MiniStatuslineDiagInfo = { bg = colors.surface1, fg = colors.sky },
                MiniStatuslineDiagHint = { bg = colors.surface1, fg = colors.teal },

                GitBlameText = { link = "Comment" },
            }
        end,
        integrations = {
            blink_cmp = true,
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
}
