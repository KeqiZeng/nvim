return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "catppuccin/nvim",
        "saghen/blink.cmp",
        "ibhagwan/fzf-lua",
    },
    config = function()
        local border = {
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
        }

        vim.diagnostic.config({
            virtual_text = false,
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local bufnr = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)

                local function buf_set_option(...)
                    vim.api.nvim_buf_set_option(bufnr, ...)
                end

                buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

                -- diagnostics
                vim.api.nvim_create_autocmd({ "CursorHold" }, {
                    buffer = bufnr,
                    callback = function()
                        local current_mode = vim.fn.mode()
                        if current_mode ~= "n" then
                            return
                        end
                        local opts = {
                            focusable = false,
                            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost", "LspDetach" },
                            source = "always",
                            prefix = " ",
                            scope = "cursor",
                            border = border,
                        }
                        vim.diagnostic.open_float(nil, opts)
                    end,
                })

                -- set code action indicator for statusline
                vim.api.nvim_create_autocmd("CursorHold", {
                    buffer = bufnr,
                    callback = function()
                        local params = vim.lsp.util.make_range_params()
                        local cursor = vim.api.nvim_win_get_cursor(0)
                        local line = cursor[1] - 1 -- 0-based line number
                        local col = cursor[2]      -- 0-based column number

                        local diagnostics = vim.diagnostic.get(bufnr, {
                            lnum = line,
                            col = col,
                        })
                        params.context = { diagnostics = diagnostics }
                        vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result)
                            if err or not result or vim.tbl_isempty(result) then
                                vim.g.code_action_available = false
                            else
                                vim.g.code_action_available = true
                            end
                        end)
                    end,
                })

                -- reset code action indicator
                vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave", "FocusLost", "LspDetach" }, {
                    buffer = bufnr,
                    callback = function()
                        vim.g.code_action_available = false
                    end
                })

                -- format on save
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format()
                    end
                })

                -- mappings
                local opts = { buffer = bufnr, noremap = true, silent = false }
                local function set_opts(desc)
                    opts.buffer = bufnr
                    opts.desc = desc
                    return opts
                end
                local fzf = require("fzf-lua")
                vim.keymap.set("n", "gd", fzf.lsp_definitions, set_opts("Go to definition"))
                vim.keymap.set("n", "gD", fzf.lsp_declarations, set_opts("Go to declaration"))
                vim.keymap.set("n", "gt", fzf.lsp_typedefs, set_opts("Go to type_definition"))
                vim.keymap.set("n", "gp", fzf.lsp_implementations, set_opts("Go to implementation"))
                vim.keymap.set("n", "gr", fzf.lsp_references, set_opts("Go to references"))
                vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, set_opts("Find document symbols"))
                vim.keymap.set("n", "<leader>fS", fzf.lsp_workspace_symbols, set_opts("Find workspace symbols"))
                vim.keymap.set("n", "<leader>fd", fzf.lsp_document_diagnostics, set_opts("Find document diagnostics"))
                vim.keymap.set("n", "<leader>fD", fzf.lsp_workspace_diagnostics, set_opts("Find workspace diagnostics"))
                vim.keymap.set("n", "K", vim.lsp.buf.hover, set_opts("Hover"))
                vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, set_opts("Show signature help"))
                vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, set_opts("Rename"))
                vim.keymap.set("n", "<leader>a", function()
                    fzf.lsp_code_actions()
                    vim.g.code_action_available = false
                end, set_opts("Code actions"))
            end,
        })

        local lspconfig = require("lspconfig")
        local capabilities = require('blink.cmp').get_lsp_capabilities()

        local handlers = {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
        }

        local servers = {
            "bashls",
            "cmake",
            "clangd",
            "cssls",
            "eslint",
            "gopls",
            "html",
            "jsonls",
            "lua_ls",
            "pyright",
            "rust_analyzer",
            "tinymist",
            "vale_ls",
            "texlab",
        }

        for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup({
                capabilities = capabilities,
                single_file_support = true,
                handlers = handlers,
            })
        end
    end
}
