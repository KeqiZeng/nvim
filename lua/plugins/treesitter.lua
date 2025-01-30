return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = { enable = true },
            indent = { enable = true },
            matchup = { enable = true },
            textobjects = {
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        ["af"] = {
                            query = "@function.outer",
                            desc = "Select outer part of a function region",
                        },
                        ["if"] = {
                            query = "@function.inner",
                            desc = "Select inner part of a function region",
                        },
                        ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
                        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                    },
                    include_surrounding_whitespace = false,
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["gsn"] = {
                            mode = "n",
                            query = "@parameter.inner",
                            desc = "Swap next parameter",
                        },
                    },
                    swap_previous = {
                        ["gsp"] = {
                            mode = "n",
                            query = "@parameter.inner",
                            desc = "Swap previous parameter",
                        },
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]f"] = {
                            mode = { "n", "v", "o" },
                            query = "@function.outer",
                            desc = "Next function start",
                        },
                        ["]c"] = {
                            mode = { "n", "v", "o" },
                            query = "@class.outer",
                            desc = "Next class start",
                        },
                        ["]z"] = {
                            mode = { "n", "v", "o" },
                            query = "@fold",
                            query_group = "folds",
                            desc = "Next fold",
                        },
                    },
                    goto_previous_start = {
                        ["[f"] = {
                            mode = { "n", "v", "o" },
                            query = "@function.outer",
                            desc = "Previous function start",
                        },
                        ["[c"] = {
                            mode = { "n", "v", "o" },
                            query = "@class.outer",
                            desc = "Previous class start",
                        },
                        ["[z"] = {
                            mode = { "n", "v", "o" },
                            query = "@fold",
                            query_group = "folds",
                            desc = "Previous fold"
                        },
                    },
                },
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BACKSPACE>",
                },
            },
            sync_install = true,
            auto_install = true,
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "css",
                "cmake",
                "gitignore",
                "go",
                "gomod",
                "html",
                "javascript",
                "json",
                "lua",
                "latex",
                "bibtex",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "rust",
                "sql",
                "toml",
                "typescript",
                "typst",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
            },
        })
    end
}
