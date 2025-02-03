return {
    'echasnovski/mini.statusline',
    event   = 'UIEnter',
    version = '*',
    opts    = function()
        local statusline = require('mini.statusline')

        local function gen_diff(args)
            local diff_status = vim.b.minidiff_summary
            local diff = ''
            if diff_status then
                if diff_status.add and diff_status.add > 0 then
                    diff = diff .. '%#MiniStatuslineDiffAdd#+' .. diff_status.add .. " "
                end
                if diff_status.change and diff_status.change > 0 then
                    diff = diff .. '%#MiniStatuslineDiffChange#~' .. diff_status.change .. " "
                end
                if diff_status.delete and diff_status.delete > 0 then
                    diff = diff .. '%#MiniStatuslineDiffDelete#-' .. diff_status.delete .. " "
                end
            end
            return statusline.is_truncated(args.trunc_width) and "" or diff
        end

        local gen_diagnostics = function(args)
            local diagnostics = ''
            local errors      = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
            local warnings    = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
            local info        = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
            local hints       = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

            if errors > 0 then
                diagnostics = diagnostics .. '%#MiniStatuslineDiagError# ' .. errors .. " "
            end
            if warnings > 0 then
                diagnostics = diagnostics .. '%#MiniStatuslineDiagWarn# ' .. warnings .. " "
            end
            if info > 0 then
                diagnostics = diagnostics .. '%#MiniStatuslineDiagInfo# ' .. info .. " "
            end
            if hints > 0 then
                diagnostics = diagnostics .. '%#MiniStatuslineDiagHint# ' .. hints .. " "
            end
            return statusline.is_truncated(args.trunc_width) and "" or diagnostics
        end

        vim.g.code_action_available = false
        local function gen_code_action_indicator()
            if vim.g.code_action_available then
                return "💡"
            end
            return ""
        end

        local branch_cached = ""
        local function update_git_branch()
            vim.schedule(function()
                local current_bufnr = vim.api.nvim_get_current_buf()

                -- Get directory of current buffer
                local bufname = vim.api.nvim_buf_get_name(current_bufnr)
                local dir = vim.fn.fnamemodify(bufname, ':h')

                if bufname == '' or dir == '' then
                    dir = vim.fn.getcwd()
                end

                local cmd = string.format(
                    "cd %s && git branch --show-current 2>/dev/null | tr -d '\n'", vim.fn.shellescape(dir)
                )
                local branch = vim.fn.system(cmd)

                if vim.v.shell_error == 0 and branch ~= "" then
                    branch_cached = " 󰘬 " .. branch .. " "
                else
                    branch_cached = ""
                end
            end)
        end

        update_git_branch()
        vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufNewFile", "FocusGained" }, {
            pattern = "*",
            callback = function()
                update_git_branch()
            end
        })

        local function gen_branch(args)
            local branch = branch_cached == "" and "" or "%#MiniStatuslineBranch#" .. branch_cached
            return statusline.is_truncated(args.trunc_width) and "" or branch
        end

        local function gen_statusline()
            local mode, mode_hl         = statusline.section_mode({ trunc_width = 120 })
            local branch                = gen_branch({ trunc_width = 60 })
            local diff                  = gen_diff({ trunc_width = 60 })
            local diagnostics           = gen_diagnostics({ trunc_width = 60 })
            local lsp                   = statusline.section_lsp({ icon = "", trunc_width = 75 })
            local code_action_indicator = gen_code_action_indicator()
            local filename              = statusline.section_filename({ trunc_width = 140 })
            local fileinfo              = statusline.section_fileinfo({ trunc_width = 120 })
            local location              = statusline.section_location({ trunc_width = 75 })
            local search                = statusline.section_searchcount({ trunc_width = 75 })

            return statusline.combine_groups({
                { hl = mode_hl,                 strings = { string.upper(mode) } },
                branch,
                diff,
                diagnostics,
                { hl = 'MiniStatuslineDevinfo', strings = { lsp } },
                { hl = 'MiniStatuslineDevinfo', strings = { code_action_indicator } },
                '%<', -- Mark general truncate point
                { hl = 'MiniStatuslineFilename', strings = { filename } },
                '%=', -- End left alignment
                { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                { hl = 'MiniStatuslineDevinfo',  strings = { search } },
                { hl = mode_hl,                  strings = { location } },
            })
        end
        return {
            content = {
                active = gen_statusline,
            }
        }
    end,
    init    = function()
        local timer = vim.loop.new_timer()
        timer:start(0, 200, vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
        end))
    end
}
