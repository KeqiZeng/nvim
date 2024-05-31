--
-- #option
--
vim.g.loaded_python_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.python3_host_skip_check = 1
vim.g.python3_host_prog = "/opt/homebrew/Caskroom/miniforge/base/bin/python3"
vim.g.skip_ts_context_commentstring_module = true

--
-- #config
--
vim.cmd([[
  set encoding=utf-8
  set fileencoding=utf-8
  set clipboard=unnamedplus
  set history=500
  set timeout
  set ttimeout
  set ttimeoutlen=100
  set ignorecase
  set smartcase
  set hlsearch
  set incsearch
  set scrolloff=5
  set sidescrolloff=5
  " set foldenable
  " set fdm=manual
]])


--
-- #keymap
--
local map = vim.keymap.set
local function opts(desc)
  local opt = { noremap = true, silent = true, desc = desc }
  return opt
end
vim.g.mapleader = "\\"

map({"n", "x"}, "H", "^", opts("Go to the start of the current line"))
map({"n", "x"}, "L", "$", opts("Go to the end of the current line"))

map("x", "<", "<gv", opts("Indent line conveniently"))
map("x", ">", ">gv", opts("Indent line conveniently"))

map("n", "<BACKSPACE>", [[<cmd>nohl<CR>]], opts("Clear hlsearch"))

-- comment
function commentLine()
  require("vscode-neovim").action('editor.action.commentLine')
end

function returnToNormalMode()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  -- require("vscode-neovim").action('vscode-neovim.escape')
end

function commentLineVisual()
  require("vscode-neovim").call('editor.action.commentLine')
  require("vscode-neovim").call('vscode-neovim.escape')
end

map("n", "gcc", "<cmd>lua commentLine()<CR>", opts())
map("x", "gc", "<cmd>lua commentLineVisual()<CR>", opts())

-- go to ...
map("n", "]t", function()
  require("vscode-neovim").action('todo-tree.goToNext')
end, opts("Go to next in Todo Tree"))

map("n", "[t", function() require("vscode-neovim").action('todo-tree.goToPrevious')
end, opts("Go to previous in Todo Tree"))

map("n", "]b", function()
  require("vscode-neovim").action('editor.debug.action.goToNextBreakpoint')
end, opts("Go to next breakpoint"))

map("n", "[b", function()
  require("vscode-neovim").action('editor.debug.action.goToPreviousBreakpoint')
end, opts("Go to previous breakpoint"))

map("n", "]g", function()
  require("vscode-neovim").action('workbench.action.editor.nextChange')
end, opts("Go to next change"))

map("n", "[g", function()
  require("vscode-neovim").action('workbench.action.editor.previousChange')
end, opts("Go to previous change"))

map("n", "]d", function()
  require("vscode-neovim").action('editor.action.marker.nextInFiles')
end, opts("Go to next diagnostic in file"))

map("n", "[d", function()
  require("vscode-neovim").action('editor.action.marker.prevInFiles')
end, opts("Go to previous diagnostic in file"))

map("n", "gr", function()
  require("vscode-neovim").action('editor.action.referenceSearch.trigger')
end, opts("Peek References and go"))

map("x", "gr", function()
  require("vscode-neovim").action('editor.action.referenceSearch.trigger')
end, opts("Peek References and go"))

-- fold
map("x", "zf", function()
  require("vscode-neovim").action('editor.createFoldingRangeFromSelection')
end, opts(""))

map("n", "zc", function()
  require("vscode-neovim").action('editor.fold')
end, opts(""))

map("n", "zM", function()
  require("vscode-neovim").action('editor.foldAll')
end, opts(""))

map("x", "zM", function()
  require("vscode-neovim").action('editor.foldAllExcept')
end, opts(""))

map("n", "zC", function()
  require("vscode-neovim").action('editor.foldRecursively')
end, opts(""))

map("n", "za", function()
  require("vscode-neovim").action('editor.toggleFold')
end, opts(""))

map("n", "zo", function()
  require("vscode-neovim").action('editor.unfold')
end, opts(""))

map("n", "zR", function()
  require("vscode-neovim").action('editor.unfoldAll')
end, opts(""))

map("x", "zR", function()
  require("vscode-neovim").action('editor.unfoldAllExcept')
end, opts(""))

map("n", "zO", function()
  require("vscode-neovim").action('editor.unfoldRecursively')
end, opts(""))

-- marks
map("n", "<leader>ma", function()
  require("vscode-neovim").action('bookmarks.toggleLabeled')
end, opts("Set a labeled mark in current line"))

map({"n", "x"}, "<leader>]`", function()
  require("vscode-neovim").action('bookmarks.jumpToNext')
end, opts("Jump to next mark"))

map({"n", "x"}, "<leader>[`", function()
  require("vscode-neovim").action('bookmarks.jumpToPrevious')
end, opts("Jump to previous mark"))

map({"n", "x", "o"}, "<leader>`", function()
  require("vscode-neovim").action('bookmarks.listFromAllFiles')
end, opts("List all marks in current project"))

map("n", "<leader>mc", function()
  require("vscode-neovim").action('bookmarks.clear')
end, opts("Clear all marks in the current file"))

map("n", "<leader>mC", function()
  require("vscode-neovim").action('bookmarks.clearFromAllFiles')
end, opts("Clear all marks in the current project"))

--
-- #autocmd
--
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- #autoswitchim (require im-select)
vim.g.default_im = "com.apple.keylayout.ABC"
local function getIm()
  local t = io.popen("im-select")
  ---@diagnostic disable-next-line: need-check-nil
  return t:read("*all")
end

function InsertL()
  vim.b.im = getIm()
  if vim.b.im == vim.g.default_im then
    return 1
  end
  os.execute("im-select " .. vim.g.default_im)
end

function InsertE()
  if vim.b.im == vim.g.default_im then
    return 1
  elseif vim.b.im == nil then
    vim.b.im = vim.g.default_im
  end
  os.execute("im-select " .. vim.b.im)
end

vim.cmd([[autocmd InsertLeave * :silent lua InsertL()]])
vim.cmd([[autocmd InsertEnter * :silent lua InsertE()]])

-- #highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

--
-- #lazy.nvim
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- surround
  {
    "echasnovski/mini.surround",
    version = "*",
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  },

  -- flash
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
  char = {
    jump_labels = true,
  },
      },
      jump = {
  pos = "start",
      },
    },
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    },
  },
})

--
-- #surround
--
require("mini.surround").setup({
  highlight_duration = 1000,
  mappings = {
    add = "<leader>sa",            -- Add surrounding in Normal and Visual modes
    delete = "<leader>sd",         -- Delete surrounding
    find = "<leader>sf",           -- Find surrounding (to the right)
    find_left = "<leader>sF",      -- Find surrounding (to the left)
    highlight = "<leader>sh",      -- Highlight surrounding
    replace = "<leader>sr",        -- Replace surrounding
    update_n_lines = "<leader>sn", -- Update `n_lines`

    suffix_last = "l",             -- Suffix to search with "prev" method
    suffix_next = "n",             -- Suffix to search with "next" method
  },
  -- Number of lines within which surrounding is searched
  n_lines = 50,
})

--
-- #treesitter
--
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = false },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
  ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
  ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
  ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
  ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      include_surrounding_whitespace = false,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
  ["]f"] = { query = "@function.outer", desc = "next function start" },
  ["]c"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_previous_start = {
  ["[f"] = "@function.outer",
  ["[c"] = "@class.outer",
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
    "java",
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
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
  },
})


--
-- #flash
--
vim.cmd("highlight Flashlabel guifg=#f38ba8")

function JumpToLine()
  require("flash").jump({
    search = { mode = "search", max_length = 0 },
    label = { after = { 0, 0 } },
    pattern = "^"
  })
end

map({"n", "x", "o"}, "<leader><leader>", [[<cmd>lua JumpToLine()<CR>]], opts("Jump to a specific line"))
-- map("x", "<leader>", [[<cmd>lua JumpToLine()<CR>]], opts("Jump to a specific line"))
-- map("o", "|", [[<cmd>lua JumpToLine()<CR>]], opts("Jump to a specific line"))
