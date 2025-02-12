return {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    dependencies = {
        "echasnovski/mini.icons",
        "catppuccin/nvim",
    },
    opts = function()
        local colors = require("catppuccin.palettes").get_palette("mocha")

        local function lsp_name()
            local msg = "No Active Lsp"
            local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
                return msg
            end
            for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                end
            end
            return msg
        end

        vim.g.code_action_available = false
        local function code_action_indicator()
            if vim.g.code_action_available then
                return "💡"
            end
            return ""
        end

        return {
            options = {
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
            },
            always_show_tabline = false,
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    'branch',
                    {
                        'diff',
                        source = function()
                            if vim.b.minidiff_summary then
                                local s = vim.b.minidiff_summary
                                return {
                                    added = s.add,
                                    modified = s.change,
                                    removed = s.delete
                                }
                            end
                            return nil
                        end
                    },
                    'diagnostics'
                },
                lualine_c = {
                    {
                        lsp_name,
                        icon = " LSP:",
                        color = { fg = colors.lavender, gui = "bold" }
                    },
                    {
                        code_action_indicator,
                    }
                },
                lualine_x = {
                    {
                        'filename',
                        color = { fg = colors.lavender }
                    },
                    {
                        'fileformat',
                        color = { fg = colors.lavender }

                    },
                    {
                        'encoding',
                        color = { fg = colors.lavender }
                    }
                },
                lualine_y = { 'searchcount', 'progress' },
                lualine_z = { 'location' }
            },
            tabline = {
                lualine_x = {
                    {
                        'buffers',
                        show_filename_only = false,
                        buffers_color = {
                            active = { fg = colors.pink },
                            inactive = { fg = colors.overlay2 },
                        },
                        symbols = {
                            modified = ' ●', -- text to show when the buffer is modified
                            alternate_file = '# ', -- text to show to identify the alternate file
                            directory = ' ', -- text to show when the buffer is a directory
                        },
                    },
                    -- {
                    --     minimap_offset,
                    -- },
                }
            },
        }
    end
}
