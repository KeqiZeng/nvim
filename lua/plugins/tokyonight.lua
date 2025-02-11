return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        style = "moon",
        styles = {
            keyword = { "italic" },
            functions = { bold = true },
        },
        on_highlights = function(highlights, colors)
            highlights.MiniIndentscopeSymbol = { fg = colors.magenta }

            highlights.MiniTablineCurrent = { bg = colors.bg_highlight, fg = colors.orange }
            highlights.MiniTablineVisible = { bg = colors.none, fg = colors.fg }
            highlights.MiniTablineHidden = { bg = colors.none, fg = colors.dark5 }
            highlights.MiniTablineModifiedCurrent = { bg = colors.bg_highlight, fg = colors.orange }
            highlights.MiniTablineModifiedVisible = { bg = colors.none, fg = colors.fg }
            highlights.MiniTablineModifiedHidden = { bg = colors.none, fg = colors.comment }

            highlights.MiniStatuslineBranch = { bg = colors.fg_gutter, fg = colors.orange }
            highlights.MiniStatuslineDiffAdd = { bg = colors.fg_gutter, fg = colors.git.add }
            highlights.MiniStatuslineDiffChange = { bg = colors.fg_gutter, fg = colors.git.change }
            highlights.MiniStatuslineDiffDelete = { bg = colors.fg_gutter, fg = colors.git.delete }
            highlights.MiniStatuslineDiagError = { bg = colors.fg_gutter, fg = colors.error }
            highlights.MiniStatuslineDiagWarn = { bg = colors.fg_gutter, fg = colors.warning }
            highlights.MiniStatuslineDiagInfo = { bg = colors.fg_gutter, fg = colors.info }
            highlights.MiniStatuslineDiagHint = { bg = colors.fg_gutter, fg = colors.hint }

            highlights.GitBlameText = { link = "Comment" }
        end,
        plugins = {
            all = false,
            auto = false,

            blink = true,
            lazy = true,
            mini_clue = true,
            mini_cursorword = true,
            mini_deps = true,
            mini_diff = true,
            mini_files = true,
            mini_hipatterns = true,
            mini_icons = true,
            mini_indentscope = true,
            mini_jump = true,
            mini_map = true,
            mini_notify = true,
            mini_pick = true,
            mini_statusline = true,
            mini_surround = true,
            mini_tabline = true,
            rainbow = true,
        },
    },
}
