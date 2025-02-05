return {
    'echasnovski/mini.hipatterns',
    version = '*',
    event = "UIEnter",
    opts = function()
        local hipatterns = require('mini.hipatterns')
        return {
            highlighters = {
                -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
                hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
                todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
                note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

                -- Highlight hex color strings (`#rrggbb`) using that color
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        }
    end,
    init = function()
        -- Add keybindings to jump between tags
        vim.keymap.set("n", "]t", function()
            vim.fn.search("\\v<(FIXME|HACK|TODO|NOTE)>")
        end, { noremap = true, desc = "Next TODOs" })

        vim.keymap.set("n", "[t", function()
            vim.fn.search("\\v<(FIXME|HACK|TODO|NOTE)>", "b")
        end, { noremap = true, desc = "Previous TODOs" })
    end
}
