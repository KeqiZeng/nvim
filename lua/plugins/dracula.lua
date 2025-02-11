return {
    "binhtran432k/dracula.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        styles = {
            keyword = { "italic" },
            functions = { bold = true },
        },
        on_highlights = function(highlights, colors)
            highlights.String = { fg = colors.green }
            highlights.Character = { fg = colors.green }
            highlights.Function = { fg = colors.bright_magenta }
            highlights.Special = { fg = colors.bright_magenta }
            highlights.Constant = { fg = colors.yellow }
            highlights["@lsp.type.property"] = { fg = colors.purple }
            highlights["@variable.member"] = { fg = colors.purple }

            highlights.MiniTablineCurrent = { bg = colors.bg_highlight, fg = colors.purple }
            highlights.MiniTablineVisible = { bg = colors.none, fg = colors.fg }
            highlights.MiniTablineHidden = { bg = colors.none, fg = colors.dark5 }
            highlights.MiniTablineModifiedCurrent = { bg = colors.bg_highlight, fg = colors.purple }
            highlights.MiniTablineModifiedVisible = { bg = colors.none, fg = colors.fg }
            highlights.MiniTablineModifiedHidden = { bg = colors.none, fg = colors.comment }

            highlights.MiniStatuslineBranch = { bg = colors.gutter_bg, fg = colors.purple }
            highlights.MiniStatuslineDiffAdd = { bg = colors.gutter_bg, fg = colors.gitSigns.add }
            highlights.MiniStatuslineDiffChange = { bg = colors.gutter_bg, fg = colors.gitSigns.change }
            highlights.MiniStatuslineDiffDelete = { bg = colors.gutter_bg, fg = colors.gitSigns.delete }
            highlights.MiniStatuslineDiagError = { bg = colors.gutter_bg, fg = colors.error }
            highlights.MiniStatuslineDiagWarn = { bg = colors.gutter_bg, fg = colors.warning }
            highlights.MiniStatuslineDiagInfo = { bg = colors.gutter_bg, fg = colors.info }
            highlights.MiniStatuslineDiagHint = { bg = colors.gutter_bg, fg = colors.hint }

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
