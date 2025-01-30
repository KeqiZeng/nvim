return {
    'echasnovski/mini.hipatterns',
    version = '*',
    event = "UIEnter",
    dependencies = { "catppuccin/nvim" },
    config = function()
        local hipatterns = require('mini.hipatterns')
        hipatterns.setup({
            highlighters = {
                -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
                hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
                todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
                note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

                -- Highlight hex color strings (`#rrggbb`) using that color
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        })
        local palette = require("catppuccin.palettes").get_palette("mocha")
        vim.cmd("highlight MiniHipatternsNote guibg=" .. palette.mauve)

        -- Add keybinding to search for FIXME/HACK/TODO/NOTE
        vim.keymap.set("n", "<leader>ft", function()
            require("fzf-lua").live_grep_native({
                search = "\\b(FIXME|HACK|TODO|NOTE)\\b",
                no_esc = true,
            })
        end, { noremap = true, silent = true, desc = "Find TODOs" })

        -- Add keybindings to jump between tags
        vim.keymap.set("n", "]t", function()
            vim.fn.search("\\v<(FIXME|HACK|TODO|NOTE)>")
        end, { noremap = true, desc = "Next TODOs" })

        vim.keymap.set("n", "[t", function()
            vim.fn.search("\\v<(FIXME|HACK|TODO|NOTE)>", "b")
        end, { noremap = true, desc = "Previous TODOs" })
    end
}
