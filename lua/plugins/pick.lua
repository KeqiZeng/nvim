return {
    'echasnovski/mini.pick',
    event = 'BufEnter',
    -- version = '*',
    version = false, -- change this back to stable after next release
    dependencies = { "echasnovski/mini.extra" },
    opts = function()
        local win_config = function()
            local height = math.floor(0.618 * vim.o.lines)
            local width = math.floor(0.618 * vim.o.columns)
            return {
                border = 'rounded',
                anchor = 'NW',
                height = height,
                width = width,
                row = math.floor(0.5 * (vim.o.lines - height)),
                col = math.floor(0.5 * (vim.o.columns - width)),
            }
        end
        return {
            mappings = {
                caret_left        = '<Left>',
                caret_right       = '<Right>',

                choose            = '<CR>',
                choose_in_split   = '',
                choose_in_tabpage = '',
                choose_in_vsplit  = '',
                choose_marked     = '',

                delete_char       = '<BS>',
                delete_char_right = '<Del>',
                delete_left       = '',
                delete_word       = '<C-w>',

                mark              = '<C-Tab>',
                mark_all          = '<C-a>',

                move_down         = '<C-j>',
                move_start        = '<C-g>',
                move_up           = '<C-k>',

                paste             = '<C-p>',

                refine            = '<C-r>',
                refine_marked     = '<C-S-r>',

                scroll_down       = '<C-d>',
                scroll_left       = '<C-h>',
                scroll_right      = '<C-l>',
                scroll_up         = '<C-u>',

                stop              = '<Esc>',

                toggle_info       = '<S-Tab>',
                toggle_preview    = '',
            },
            options = {
                use_cache = true
            },
            window = {
                config = win_config
            },
        }
    end,
    init = function()
        local pick = require('mini.pick')
        local extra = require('mini.extra')
        local map = vim.keymap.set
        vim.ui.select = pick.ui_select

        -- Find files
        local files_opts = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                choose_marked     = '<C-CR>',
                toggle_preview    = '<Tab>',
            },
            source = {
                choose_marked = function(items)
                    for _, item in pairs(items) do
                        vim.cmd('edit ' .. item)
                    end
                end
            }
        }

        pick.registry.files = function(local_opts)
            return pick.builtin.files(local_opts, files_opts)
        end
        map('n', '<leader>ff', function()
            pick.builtin.files(nil, files_opts)
        end, { desc = "Find files" })

        -- Find recent files
        pick.registry.oldfiles = function(local_opts)
            return extra.pickers.oldfiles(local_opts, files_opts)
        end
        map('n', '<leader>fr', function()
            extra.pickers.oldfiles(nil, files_opts)
        end, { desc = "Find recent files" })

        -- Find buffers
        local wipeout_cur = function()
            local buf = pick.get_picker_matches().current.bufnr
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            vim.api.nvim_buf_delete(buf, {})
        end

        local buffers_opt = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                choose_marked     = '<C-CR>',
                toggle_preview    = '<Tab>',
                wipeout           = { char = '<C-x>', func = wipeout_cur },
            }
        }

        pick.registry.buffers = function(local_opts)
            return pick.builtin.buffers(local_opts, buffers_opt)
        end
        map('n', '<leader>fb', function()
            pick.builtin.buffers({ include_current = false }, buffers_opt)
        end, { desc = "Find buffers" })

        -- Grep current directory
        local grep_opts = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                choose_marked     = '<C-CR>',
                toggle_preview    = '<Tab>',
            }
        }
        pick.registry.grep = function(local_opts)
            return pick.builtin.grep(local_opts, grep_opts)
        end
        pick.registry.grep_live = function(local_opts)
            return pick.builtin.grep_live(local_opts, grep_opts)
        end
        map('n', '<leader>fG', function()
            pick.builtin.grep_live(nil, grep_opts)
        end, { desc = "Grep current directory interactively" })

        -- Grep current buffer
        local buf_lines_opts = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                toggle_preview    = '<Tab>',
            }
        }
        pick.registry.buf_lines = function(local_opts)
            return extra.pickers.buf_lines(local_opts, buf_lines_opts)
        end
        map('n', '<leader>fg', function()
            extra.pickers.buf_lines({ scope = "current" }, buf_lines_opts)
        end, { desc = "Grep current buffer interactively" })

        -- Find TODOs
        map('n', '<leader>ft', function()
            pick.builtin.grep({ pattern = "\\b(FIXME|HACK|TODO|NOTE)\\b" }, grep_opts)
        end, { desc = "Find TODOs" })

        -- Find history
        local history_opts = {}
        pick.registry.search_history = function()
            return extra.pickers.history({ scope = "/" }, history_opts)
        end
        pick.registry.commands_history = function()
            return extra.pickers.history({ scope = ":" }, history_opts)
        end
        map('n', '<leader>f/', function()
            extra.pickers.history({ scope = "/" }, history_opts)
        end, { desc = "Find search history" })

        -- Find commands
        local commands_opts = {}
        pick.registry.commands = function(local_opts)
            return extra.pickers.commands(local_opts, commands_opts)
        end
        map('n', '<leader>fc', function()
            extra.pickers.commands(nil, commands_opts)
        end, { desc = "Find commands" })

        -- Find jumplist
        local list_opt = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                choose_marked     = '<C-CR>',
                toggle_preview    = '<Tab>',
            }
        }
        pick.registry.list = function(local_opts)
            return extra.pickers.list(local_opts, list_opt)
        end
        map('n', '<leader>fj', function()
            extra.pickers.list({ scope = "jump" }, list_opt)
        end, { desc = "Find jumplist" })
        map('n', '<leader>fq', function()
            extra.pickers.list({ scope = "quickfix" }, list_opt)
        end, { desc = "Find quickfix" })

        -- Find marks
        local marks_opts = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                choose_marked     = '<C-CR>',
                toggle_preview    = '<Tab>',
            }
        }
        pick.registry.marks = function(local_opts)
            return extra.pickers.marks(local_opts, marks_opts)
        end
        map('n', '<leader>fm', function()
            extra.pickers.marks(nil, marks_opts)
        end, { desc = "Find marks" })

        -- Find registers
        local registers_opts = {}
        pick.registry.registers = function(local_opts)
            return extra.pickers.registers(local_opts, registers_opts)
        end
        map('n', '<leader>f`', function()
            extra.pickers.registers(nil, registers_opts)
        end, { desc = "Find registers" })

        -- Find help
        local help_opts = {
            mappings = {
                choose_in_split   = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit  = '<C-v>',
                toggle_preview    = '<Tab>',
            }
        }
        pick.registry.help = function(local_opts)
            return pick.builtin.help(local_opts, help_opts)
        end
        map('n', '<leader>fh', function()
            pick.builtin.help(nil, help_opts)
        end, { desc = "Find help" })

        -- Find spell suggestions
        local spellsuggest_opts = {}
        pick.registry.spellsuggest = function(local_opts)
            return extra.pickers.spellsuggest(local_opts, spellsuggest_opts)
        end
        map('n', 'z=', function()
            extra.pickers.spellsuggest(nil, spellsuggest_opts)
        end, { desc = "Find spell suggestions" })

        -- Find keymaps
        local keymaps_opts = {
            mappings = {
                toggle_preview = '<Tab>',
            }
        }
        pick.registry.keymaps = function()
            return extra.pickers.keymaps(nil, keymaps_opts)
        end
        map('n', '<leader>fk', function()
            extra.pickers.keymaps(nil, keymaps_opts)
        end, { desc = "Find keymaps" })

        pick.registry.git_hunks = function()
            local opts = {
                mappings = {
                    choose_in_split   = '<C-s>',
                    choose_in_tabpage = '<C-t>',
                    choose_in_vsplit  = '<C-v>',
                    choose_marked     = '<C-CR>',
                    toggle_preview    = '<Tab>',
                }
            }
            return extra.pickers.git_hunks(opts)
        end

        pick.registry.options = function()
            local opts = {
                mappings = {
                    toggle_preview = '<Tab>',
                }
            }
            return extra.pickers.options(nil, opts)
        end

        pick.registry.hl_groups = function()
            local opts = {
                mappings = {
                    toggle_preview = '<Tab>',
                }
            }
            return extra.pickers.hl_groups(nil, opts)
        end
    end
}
