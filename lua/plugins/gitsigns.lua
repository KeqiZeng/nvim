return {
    "lewis6991/gitsigns.nvim",
    event = "UIEnter",
    config = function()
        require('gitsigns').setup({
            current_line_blame = true,
            preview_config = {
                border = 'rounded',
            },
            on_attach = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                  opts = opts or {}
                  opts.buffer = bufnr
                  vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']h', function()
                  if vim.wo.diff then
                    vim.cmd.normal({']c', bang = true})
                  else
                    gitsigns.nav_hunk('next')
                  end
                end, { desc = "Go to next hunk" })

                map('n', '[h', function()
                  if vim.wo.diff then
                    vim.cmd.normal({'[c', bang = true})
                  else
                    gitsigns.nav_hunk('prev')
                  end
                end, { desc = "Go to previous hunk" })

                -- Actions
                map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage hunk" })
                map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset hunk" })

                map('v', '<leader>hs', function()
                  gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, { desc = "Stage hunk visual" })

                map('v', '<leader>hr', function()
                  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, { desc = "Reset hunk visual" })

                map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
                map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset buffer" })
                map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })

                map('n', '<leader>hd', gitsigns.diffthis, { desc = "Show diff" })

                map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = "Add all hunks to quickfix list" })
                map('n', '<leader>hq', gitsigns.setqflist)

                -- Toggles
                map('n', '<leader>tb', gitsigns.toggle_current_line_blame)

                -- Text object
                map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
              end
        })
    end
}
