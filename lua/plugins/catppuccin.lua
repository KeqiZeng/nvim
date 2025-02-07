return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = function()
        local function random_flavour()
            local flavour_tbl = {
                "frappe",
                "macchiato",
                "mocha",
            }
            math.randomseed(os.time())
            return flavour_tbl[math.random(1, #flavour_tbl)]
        end
        return {
            flavour = random_flavour(),
            show_end_of_buffer = true,
            term_colors = true,
            no_underline = true,
            styles = {
                functions = { "bold" },
            },
            custom_highlights = function(colors)
                return {
                    ["@lsp.type.variable"] = { link = "@lsp.type.property" },
                    DiagnosticInfo = { fg = colors.teal },
                    DiagnosticHint = { fg = colors.sapphire },

                    MiniJump = { bg = colors.red, fg = colors.base },
                    MiniJump2dSpot = { bg = colors.base, fg = colors.red },

                    MiniHipatternsTodo = { bg = colors.green },
                    MiniHipatternsNote = { bg = colors.mauve },

                    MiniTablineCurrent = { bg = colors.base, fg = colors.pink },
                    MiniTablineVisible = { bg = colors.none, fg = colors.text },
                    MiniTablineHidden = { bg = colors.none, fg = colors.overlay1 },
                    MiniTablineModifiedCurrent = { bg = colors.base, fg = colors.pink },
                    MiniTablineModifiedVisible = { bg = colors.none, fg = colors.text },
                    MiniTablineModifiedHidden = { bg = colors.none, fg = colors.overlay1 },

                    MiniStatuslineBranch = { bg = colors.surface1, fg = colors.mauve },
                    MiniStatuslineDiffAdd = { bg = colors.surface1, fg = colors.green },
                    MiniStatuslineDiffChange = { bg = colors.surface1, fg = colors.yellow },
                    MiniStatuslineDiffDelete = { bg = colors.surface1, fg = colors.red },
                    MiniStatuslineDiagError = { bg = colors.surface1, fg = colors.red },
                    MiniStatuslineDiagWarn = { bg = colors.surface1, fg = colors.yellow },
                    MiniStatuslineDiagInfo = { bg = colors.surface1, fg = colors.teal },
                    MiniStatuslineDiagHint = { bg = colors.surface1, fg = colors.sapphire },

                    GitBlameText = { fg = colors.surface2 },
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
        }
    end,
    init = function()
        vim.cmd.colorscheme("catppuccin")
    end
}
