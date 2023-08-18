---@diagnostic disable: redefined-local
--
-- #global config
--
vim.g.loaded_python_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.python3_host_skip_check = 1
vim.g.python3_host_prog = "/opt/homebrew/Caskroom/miniforge/base/bin/python3"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--
-- #basic options
--
vim.cmd([[
	set number
	set cursorline
	set relativenumber
	set ruler
	set clipboard=unnamedplus
	set history=500
	set nrformats=
	set timeout
	set ttimeout
	set ttimeoutlen=50
	set syntax=on
	set ff=unix
]])

-- indent and fold
vim.cmd([[
	set noexpandtab
	set tabstop=2
	set shiftwidth=2
	set softtabstop=2
	set autoindent
	set expandtab
	set smarttab
	set foldenable
	set fdm=manual
]])

-- search
vim.cmd([[
	set ignorecase
	set smartcase
	set hlsearch
	set incsearch
]])

-- others
vim.cmd([[
	set encoding=utf-8
	set fileencoding=utf-8
	set wildmenu
	set signcolumn=yes
	set backspace=indent,eol,start
	set scrolloff=8
	set sidescrolloff=6
	set showmatch
	set matchtime=2
	set hidden
	set grepprg="rg --vimgrep"
	set updatetime=100
	set cmdheight=1
	set formatoptions+=m
	set formatoptions+=B
	set termguicolors
	let $NVIM_TUI_ENABLE_TRUE_COLOR=1
]])

--
-- #basic keymap
--
local map = vim.api.nvim_set_keymap
local function opts(desc)
  local opt = { noremap = true, silent = true, desc = desc }
  return opt
end
vim.g.mapleader = " "

map("n", "H", "^", opts("Go to the start of the current line"))
map("n", "L", "$", opts("Go to the end of the current line"))
map("x", "H", "^", opts("Go to the start of the current line"))
map("x", "L", "$", opts("Go to the end of the current line"))

map("x", "<", "<gv", opts("Indent line conveniently"))
map("x", ">", ">gv", opts("Indent line conveniently"))

map("n", "<BACKSPACE>", [[<cmd>nohl<CR>]], opts("Clear hlsearch"))
map("n", "<leader>u", [[<cmd>Lazy<CR>]], opts("Lazy"))
map("n", "<leader<UP>", [[<cmd>res +5<CR>]], opts("Increase window height"))
map("n", "<leader><DOWN>", [[<cmd>res -5<CR>]], opts("Decrease window height"))
map("n", "<leader><LEFT>", [[<cmd>vertical resize -5<CR>]], opts("Decrease window width"))
map("n", "<leader><RIGHT>", [[<cmd>vertical resize +5<CR>]], opts("Increase window width"))

map("n", "<leader>qq", "<cmd>qa<cr>", opts "Quit all")

--
-- #custom functions
--
-- #delete all buffers
function DeletAllBuffers()
  vim.api.nvim_exec(
    [[
		let s:curWinNr = winnr()
      if winbufnr (s:curWinNr) == 1
        ret
      endif
      let s:curBufNr = bufnr("%")
      exe "bn"
      let s:nextBufNr = bufnr("%")
      while s:nextBufNr != s:curBufNr
        exe "bn"
        exe "bd!".s:nextBufNr
        let s:nextBufNr = bufnr("%")
      endwhile
	]],
    false
  )
end

map("n", "<leader>bC", [[<cmd>lua DeletAllBuffers()<CR>]], opts("Delete all buffers"))

-- #save and reload current buffer
function SaveAndReload()
  vim.api.nvim_exec(
    [[
    w
    e
    ]],
    false
  )
end

map("n", "<leader>R", [[<cmd>lua SaveAndReload()<CR>]], opts("Save and reload the current buffer"))


--
-- #autocmd
--
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- #autoswitchim (require im-select)
vim.g.default_im = "com.apple.keylayout.ABC"
local function getIm()
  local t = io.popen("macism")
  ---@diagnostic disable-next-line: need-check-nil
  return t:read("*all")
end

function InsertL()
  vim.b.im = getIm()
  if vim.b.im == vim.g.default_im then
    return 1
  end
  os.execute("macism " .. vim.g.default_im)
end

function InsertE()
  if vim.b.im == vim.g.default_im then
    return 1
  elseif vim.b.im == nil then
    vim.b.im = vim.g.default_im
  end
  os.execute("macism " .. vim.b.im)
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

-- #go to last location when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function()
    local exclude = { "gitcommit" }
    local buf = vim.api.nvim_get_current_buf()
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- #close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
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
  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  -- dashboard
  {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  },

  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
  },

  -- bufferline
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons'
  },

  -- noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  -- notify
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      vim.notify = notify
      notify.setup({
        on_open = function(win)
          vim.api.nvim_win_set_config(win, { border = "single" })
        end,
        background_colour = "#1e1e2e",
        fps = 60,
        level = 2,
        minimum_width = 50,
        max_height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.4)
        end,
        render = "default",
        stages = "fade",
        timeout = 3000,
        top_down = true
      })
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<leader>fn", function()
        require('telescope').extensions.notify.notify({
          layout_strategy = 'vertical',
          layout_config = {
            width = 0.8,
            height = 0.9,
          },
          wrap_results = true,
          previewer = false,
        })
      end, opts);
      vim.keymap.set("n", "<leader>;", notify.dismiss, opts);
    end
  },

  -- dressing
  {
    "stevearc/dressing.nvim",
    lazy = true,
  },

  -- cursorword
  {
    "echasnovski/mini.cursorword",
    version = "*",
    opts = {},
  },

  -- indentline
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "UIEnter" },
  },

  -- numb
  {
    "nacro90/numb.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- matchup
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- surround
  {
    "echasnovski/mini.surround",
    version = "*",
  },

  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { 'nvim-telescope/telescope-fzf-native.nvim',    build = 'make' },

  -- ai
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
        mappings = {
          -- Main textobject prefixes
          around = "a",
          inside = "i",

          -- Next/last variants
          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",

          -- Move cursor to corresponding edge of `a` textobject
          goto_left = "g[",
          goto_right = "g]",
        },
      }
    end,
  },

  -- flash
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          jump_labels = true,
        },
      },
      jump = {
        pos = "end",
      },
    },
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },

  -- registers
  {
    "tversteeg/registers.nvim",
    name = "registers",
    cmd = "Registers",
    opts = {
      window = {
        max_width = 80,
        transparency = 0,     border = "rounded",
      },
    },
    keys = {
      { "\"",    mode = { "n", "v" } },
      { "<C-R>", mode = "i" }
    },
  },

  -- autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- comment
  {
    'numToStr/Comment.nvim',
    event = "VeryLazy",
  },
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        FIX = {
          icon = " ", -- icon used for the sign, and in search results
          color = "error", -- can be a hex color, or a named color (see below)
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "hint" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
        PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "info", alt = { "INFO" } },
        TEST = { icon = " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    }
  },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    lazy = false,
  },

  -- toggleterm
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
      autochdir = true,
      direction = "float",
      float_opts = {
        border = 'single',
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
    },
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- disable rtp plugin, as we only need its queries for mini.ai
          -- In case other textobject modules are enabled, we will load them
          -- once nvim-treesitter is loaded
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          load_textobjects = true
        end,
      },
      {
        "nvim-treesitter/nvim-treesitter-context",
        init = function()
          require("treesitter-context").setup({})
          vim.keymap.set("n", "[c", function()
            require("treesitter-context").go_to_context()
          end, { silent = true })
        end,
      },
    },

    ---@type TSConfig
    config = function(_, opts)
      if load_textobjects then
        -- PERF: no need to load the plugin, if we only need its queries for mini.ai
        if opts.textobjects then
          for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
            if opts.textobjects[mod] and opts.textobjects[mod].enable then
              local Loader = require("lazy.core.loader")
              Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
              local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
              require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
              break
            end
          end
        end
      end
    end,
  },

  -- mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = {
          { "╭", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╮", "FloatBorder" },
          { "│", "FloatBorder" },
          { "╯", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╰", "FloatBorder" },
          { "│", "FloatBorder" },
        },
      },
      ensure_installed = {
        "autopep8",
        "bash-language-server",
        "clang-format",
        "clangd",
        "cmake-language-server",
        "cpplint",
        "css-lsp",
        "eslint-lsp",
        "flake8",
        "golangci-lint",
        "google-java-format",
        "gopls",
        "html-lsp",
        "jdtls",
        "json-lsp",
        "latexindent",
        "lua-language-server",
        "luacheck",
        "markdownlint",
        "prettier",
        "pyright",
        "remark-language-server",
        "rust-analyzer",
        "shellcheck",
        "shfmt",
        "stylua",
        "texlab",
        "yaml-language-server",
        "yamlfmt",
        "yamllint",
      },
    },
    config = function(_, opts)
    require("mason").setup(opts)
    local mr = require("mason-registry")
    local function ensure_installed()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end
    if mr.refresh then
      mr.refresh(ensure_installed)
    else
      ensure_installed()
    end
  end,
  },

  {
    "williamboman/mason-lspconfig.nvim"
  },

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- cmp
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "uga-rosa/cmp-dictionary",
    },
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- lightbulb
  {
    "kosayoda/nvim-lightbulb",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      autocmd = { enabled = true }
    },
  },

  -- rename
  {
    "smjonas/inc-rename.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- code_action
  {
    "aznhe21/actions-preview.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      telescope = {
        layout_config = {
          prompt_position = "top",
          width = 0.9,
          height = 0.9,
        },
      },
    },
  },


  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- colorizer
  {
    'NvChad/nvim-colorizer.lua',
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
})

--
-- #theme
--
require("catppuccin").setup({
  flavour = "mocha",
  styles = {                 -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" }, -- Change the style of comments
    conditionals = { "italic" },
    loops = {},
    functions = { "bold" },
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  custom_highlights = function(colors)
    return {
      DiagnosticHint = { fg = colors.sapphire},
      DiagnosticInfo = { fg = colors.teal},
    }
  end,
  integrations = {
    alpha = true,
    cmp = true,
    dap = {
      enabled = true,
      enable_ui = true,
    },
    dashboard = true,
    flash = true,
    gitsigns = true,
    indent_blankline = { enabled = true },
    markdown = true,
    mason = true,
    mini = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
      inlay_hints = {
        background = true,
      },
    },
    nvimtree = true,
    navic = { enabled = true, custom_bg = "lualine" },
    noice = true,
    notify = true,
    telescope = true,
    treesitter = true,
    treesitter_context = true,
  },
})

vim.cmd([[colorscheme catppuccin]])

-- get palettes
local mocha = require("catppuccin.palettes").get_palette "mocha"
for k, v in pairs(mocha) do
  vim.api.nvim_set_var("mocha_" .. k, v)
end

vim.g.mocha_red = mocha.red

--
-- #dashboard
--
require('dashboard').setup({
  theme = 'hyper',
  config = {
    disable_move = true,
    week_header = {
      enable = true,
    },
    packages = { enable = true },
    project = { enable = false },
    shortcut = {
      {
        desc = '󰊳 Update',
        group = 'Function',
        action = 'Lazy sync',
        key = 'u'
      },
      {
        desc = ' Find files',
        group = 'Label',
        action = 'Telescope find_files',
        key = 'f',
      },
      {
        desc = ' NvimConfig',
        group = 'Number',
        action = 'e ~/.config/nvim/init.lua',
        key = 's',
      },
      {
        desc = '  Health',
        group = '@property',
        action = 'checkhealth',
        key = 'h',
      },
      {
        desc = ' Quit',
        group = 'String',
        action = 'quitall',
        key = 'q',
      },
    },
    footer = {
      "",
      "",
      "🚀 Don't worry, be happy!",
    },
  },
})

--
-- #lualine
--
local lualine_conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local lualine_config = {
  options = {
    -- Disable sections and component separators
    component_separators = '',
    section_separators = '',
    theme = {
      -- We are going to use lualine_c an lualine_x as left and
      -- right section. Both are highlighted by c theme .  So we
      -- are just setting default looks o statusline
      normal = { c = { fg = mocha.text, bg = mocha.surface0 } },
      inactive = { c = { fg = mocha.text, bg = mocha.surface0 } },
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(lualine_config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
  table.insert(lualine_config.sections.lualine_x, component)
end

ins_left {
  function()
    return '▊'
  end,
  color = { fg = mocha.yellow },     -- Sets highlighting of component
  padding = { left = 0, right = 1 }, -- We don't need space before this
}

ins_left {
  -- mode component
  function()
    -- return ' '
    local mode_component = {
      n = "󰰓 ",
      i = "󰰄 ",
      v = "󰰫 ",
      [''] = "󰰫 ",
      V = "󰰫 ",
      c = "󰯲 ",
      s = "󰰢 ",
      S = "󰰢 ",
      [''] = "󰰢 ",
      R = "󰰟 ",
      Rv = "󰰟 ",
      t = "󰰥 ",
      cv = "󰯸 ",
      ce = "󰯸 ",
      r = "󰰐 ",
      rm = "󰰐 ",
      ['r?'] = "󰰐 ",
      -- no = mocha.red,
      -- ic = mocha.yellow,
      -- ['!'] = mocha.red,
    }
    return mode_component[vim.fn.mode()]
  end,
  color = function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = mocha.blue,
      i = mocha.green,
      v = mocha.pink,
      [''] = mocha.pink,
      V = mocha.pink,
      c = mocha.mauve,
      s = mocha.peach,
      S = mocha.peach,
      [''] = mocha.peach,
      R = mocha.red,
      Rv = mocha.red,
      t = mocha.red,
      cv = mocha.sky,
      ce = mocha.sky,
      r = mocha.lavender,
      rm = mocha.lavender,
      ['r?'] = mocha.lavender,
      -- no = mocha.red,
      -- ic = mocha.yellow,
      -- ['!'] = mocha.red,
    }
    return { fg = mode_color[vim.fn.mode()] }
  end,
  padding = { right = 1 },
}

ins_left {
  'filename',
  cond = lualine_conditions.buffer_not_empty,
  color = { fg = mocha.pink, gui = 'bold' },
}

ins_left {
  -- filesize component
  'filesize',
  color = { fg = mocha.lavender },
  cond = lualine_conditions.buffer_not_empty,
}


ins_left {
  'branch',
  icon = '',
  color = { fg = mocha.peach, gui = 'bold' },
}

ins_left {
  'diff',
  -- Is it me or the symbol for modified us really weird
  symbols = { added = ' ', modified = ' ', removed = ' ' },
  diff_color = {
    added = { fg = mocha.green },
    modified = { fg = mocha.yellow },
    removed = { fg = mocha.red },
  },
  cond = lualine_conditions.hide_in_width,
}

ins_left {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = " ", warn = " ", info = " ", hint = " " },
}

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left {
  function()
    return '%='
  end,
}

ins_left {
  -- Lsp server name .
  function()
    local msg = 'No Active Lsp'
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
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
  end,
  icon = ' LSP:',
  color = { fg = mocha.lavender, gui = 'bold' },
}

-- Add components to right sections
ins_right {
  'o:encoding',       -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = lualine_conditions.hide_in_width,
  color = { fg = mocha.green, gui = 'bold' },
}

ins_right {
  'fileformat',
  fmt = string.upper,
  icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
  color = { fg = mocha.green, gui = 'bold' },
}

ins_right { 'location', color = { fg = mocha.lavender } }

ins_right { 'progress', color = { fg = mocha.lavender, gui = 'bold' } }

ins_right {
  function()
    return '▊'
  end,
  color = { fg = mocha.yellow },
  padding = { left = 1 },
}

require("lualine").setup(lualine_config)

--
-- #bufferline
--
require("bufferline").setup({
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = "ordinal", --"none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string
    close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
    indicator = {
      icon = "▎", -- this should be omitted if indicator style is not 'icon'
      style = "icon", -- 'icon' | 'underline' | 'none'
    },
    buffer_close_icon = "󰅖",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    truncate_names = true,  -- whether or not tab names should be truncated
    tab_size = 18,
    diagnostics = "nvim_lsp", -- false | "nvim_lsp" | "coc",
    diagnostics_update_in_insert = false,
    -- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
    diagnostics_indicator = function(count, level)
      return " (" .. level .. ") (" .. count .. ") "
    end,
    -- NOTE: this will be called a lot so don't do any heavy processing here
    custom_filter = function(buf_number)
      -- filter out by buffer name
      if vim.fn.bufname(buf_number) ~= "dashboard" then
        return true
      end
    end,
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center", -- "left" | "center" | "right"
        separator = true,
      },
    },
    color_icons = true,     -- whether or not to add the filetype icon highlights
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    separator_style = "thick",  -- "slant" | "thick" | "thin" | { "any", "any" },
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    hover = {
      enabled = true,
      delay = 200,
      reveal = { "close" },
    },
    sort_by = "extensions",
    custom_areas = {
      right = function()
        local result = {}
        local seve = vim.diagnostic.severity
        local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
        local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
        local info = #vim.diagnostic.get(0, { severity = seve.INFO })
        local hint = #vim.diagnostic.get(0, { severity = seve.HINT })
        if error ~= 0 then
          table.insert(result, { text = "  " .. error, fg = mocha.red })
        end
        if warning ~= 0 then
          table.insert(result, { text = "  " .. warning, fg = mocha.yellow })
        end
        if info ~= 0 then
          table.insert(result, { text = "  " .. info, fg = mocha.teal })
        end
        if hint ~= 0 then
          table.insert(result, { text = "  " .. hint, fg = mocha.sapphire })
        end
        return result
      end,
    },
  },
})

map("n", "<LEADER>bb", [[<cmd>BufferLinePick<CR>]], opts("Swich to the picked buffer"))
map("n", "<LEADER>bc", [[<cmd>BufferLinePickClose<CR>]], opts("Close the picked buffer"))

map("n", "<LEADER>1", [[<cmd>BufferLineGoToBuffer 1<CR>]], opts("Go to buffer 1"))
map("n", "<LEADER>2", [[<cmd>BufferLineGoToBuffer 2<CR>]], opts("Go to buffer 2"))
map("n", "<LEADER>3", [[<cmd>BufferLineGoToBuffer 3<CR>]], opts("Go to buffer 3"))
map("n", "<LEADER>4", [[<cmd>BufferLineGoToBuffer 4<CR>]], opts("Go to buffer 4"))
map("n", "<LEADER>5", [[<cmd>BufferLineGoToBuffer 5<CR>]], opts("Go to buffer 5"))
map("n", "<LEADER>6", [[<cmd>BufferLineGoToBuffer 6<CR>]], opts("Go to buffer 6"))
map("n", "<LEADER>7", [[<cmd>BufferLineGoToBuffer 7<CR>]], opts("Go to buffer 7"))
map("n", "<LEADER>8", [[<cmd>BufferLineGoToBuffer 8<CR>]], opts("Go to buffer 8"))
map("n", "<LEADER>9", [[<cmd>BufferLineGoToBuffer 9<CR>]], opts("Go to buffer 9"))

--
-- #noice
--
require("noice").setup({
  views = {
    cmdline_popup = {
      position = {
        row = 3,
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
    },
    popupmenu = {
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
  },
  -- add any options here
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = false,        -- use a classic bottom cmdline for search
    command_palette = true,       -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = true,            -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true,        -- add a border to hover docs and signature help
  },
})

vim.keymap.set({ "n", "i", "s" }, "<C-d>", function()
  if not require("noice.lsp").scroll(5) then
    return "<C-d>"
  end
end, { silent = true, expr = true })

vim.keymap.set({ "n", "i", "s" }, "<C-u>", function()
  if not require("noice.lsp").scroll(-5) then
    return "<C-u>"
  end
end, { silent = true, expr = true })

--
-- #dressing
--
require('dressing').setup({
  input = {
    -- Set to false to disable the vim.ui.input implementation
    enabled = true,

    -- Default prompt string
    default_prompt = "Input:",

    -- Can be 'left', 'right', or 'center'
    title_pos = "center",

    -- When true, <Esc> will close the modal
    insert_only = true,

    -- When true, input will start in insert mode.
    start_in_insert = true,

    -- These are passed to nvim_open_win
    border = "rounded",
    -- 'editor' and 'win' will default to being centered
    relative = "cursor",

    -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    prefer_width = 45,
    width = nil,
    -- min_width and max_width can be a list of mixed types.
    -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
    max_width = { 120, 0.8 },
    min_width = { 20, 0.2 },

    buf_options = {},
    win_options = {
      -- Window transparency (0-100)
      winblend = 10,
      -- Disable line wrapping
      wrap = false,
      -- Indicator for when text exceeds window
      list = true,
      listchars = "precedes:…,extends:…",
      -- Increase this for more context when text scrolls off the window
      sidescrolloff = 5,
    },

    -- Set to `false` to disable
    mappings = {
      n = {
        ["<Esc>"] = "Close",
        ["<CR>"] = "Confirm",
        ["j"] = "HistoryNext",
        ["k"] = "HistoryPrev",
      },
      i = {
        ["<C-c>"] = "Close",
        ["<CR>"] = "Confirm",
        ["<C-j>"] = "HistoryNext",
        ["<C-k>"] = "HistoryPrev",
        ["<Down>"] = "HistoryNext",
        ["<Up>"] = "HistoryPrev",
      },
    },

    override = function(conf)
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      return conf
    end,

    -- see :help dressing_get_config
    get_config = nil,
  },
  select = {
    -- Set to false to disable the vim.ui.select implementation
    enabled = true,

    -- Priority list of preferred vim.select implementations
    backend = { "telescope", "builtin", "nui" },

    -- Trim trailing `:` from prompt
    trim_prompt = true,

    -- Options for telescope selector
    -- These are passed into the telescope picker directly. Can be used like:
    -- telescope = require('telescope.themes').get_ivy({...})
    telescope = require("telescope.themes").get_dropdown({
      layout_config = {
        width = 0.9,
        height = 0.9,
        prompt_position = "top",
      }
    }),

    -- Options for nui Menu
    nui = {
      position = "50%",
      size = nil,
      relative = "editor",
      border = {
        style = "rounded",
      },
      buf_options = {
        swapfile = false,
        filetype = "DressingSelect",
      },
      win_options = {
        winblend = 10,
      },
      max_width = 120,
      max_height = 40,
      min_width = 40,
      min_height = 10,
    },

    -- Options for built-in selector
    builtin = {
      -- These are passed to nvim_open_win
      border = "rounded",
      -- 'editor' and 'win' will default to being centered
      relative = "editor",

      buf_options = {},
      win_options = {
        -- Window transparency (0-100)
        winblend = 10,
        cursorline = true,
        cursorlineopt = "both",
      },

      -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- the min_ and max_ options can be a list of mixed types.
      -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
      width = nil,
      max_width = { 120, 0.8 },
      min_width = { 40, 0.2 },
      height = nil,
      max_height = { 40, 0.8 },
      min_height = { 10, 0.2 },

      -- Set to `false` to disable
      mappings = {
        ["<Esc>"] = "Close",
        ["<C-c>"] = "Close",
        ["<CR>"] = "Confirm",
      },

      override = function(conf)
        -- This is the config that will be passed to nvim_open_win.
        -- Change values here to customize the layout
        return conf
      end,
    },

    -- Used to override format_item. See :help dressing-format
    format_item_override = {},

    -- see :help dressing_get_config
    get_config = nil,
  },
})

--
-- #cursorword
--
vim.cmd("highlight clear MiniCursorword")
vim.cmd("highlight clear MiniCursorwordCurrent")
vim.cmd("highlight MiniCursorword guifg=" .. mocha.peach .. " guibg=" .. mocha.surface1)
vim.cmd("highlight MiniCursorwordCurrent guifg=" .. mocha.peach .. " guibg=" .. mocha.surface1)

--
-- #indentline
--
vim.cmd("highlight IndentBlanklineIndent1 guifg=" .. mocha.surface2)
vim.cmd("highlight default link IndentBlanklineIndent2 IndentBlanklineIndent1")
vim.cmd("highlight default link IndentBlanklineIndent3 IndentBlanklineIndent1")
vim.cmd("highlight default link IndentBlanklineIndent4 IndentBlanklineIndent1")
vim.cmd("highlight IndentBlanklineContext guifg=" .. mocha.yellow)

require("indent_blankline").setup {
  char_list = { "│", "¦", "┆", "┊" },
  context_char_list = { "│" },
  char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
  },
  context_highlight_list = {
    "IndentBlanklineContext",
  },
  filetype_exclude = {
    "help",
    "alpha",
    "dashboard",
    "NvimTree",
    "Trouble",
    "lazy",
    "mason",
    "notify",
    "toggleterm",
    "lazyterm",
  },
  show_trailing_blankline_indent = false,
  show_current_context = true,
  show_current_context_start = true,
}

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
  n_lines = 30,
})

--
-- #flash
--
vim.cmd("highlight Flashlabel guifg=" .. mocha.red)

function JumpToLine()
  require("flash").jump({
    search = { mode = "search", max_length = 0 },
    label = { after = { 0, 0 } },
    pattern = "^"
  })
end

function ShowRemoteDiagnostic()
  require("flash").jump({
    matcher = function(win)
      ---@param diag Diagnostic
      return vim.tbl_map(function(diag)
        return {
          pos = { diag.lnum + 1, diag.col },
          end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
        }
      end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
    end,
    action = function(match, state)
      vim.api.nvim_win_call(match.win, function()
        vim.api.nvim_win_set_cursor(match.win, match.pos)
        vim.diagnostic.open_float()
      end)
      state:restore()
    end,
  })
end

map("n", "\\", [[<cmd>lua JumpToLine()<CR>]], opts("Jump to a specific line"))

map("x", "\\", [[<cmd>lua JumpToLine()<CR>]], opts("Jump to a specific line"))

map("o", "\\", [[<cmd>lua JumpToLine()<CR>]], opts("Jump to a specific line"))

map("n", "<leader>e", [[<cmd>lua ShowRemoteDiagnostic()<CR>]], opts("Show diagnostics at target without changing cursor position"))

--
-- #telescope
--
local previewers = require("telescope.previewers")

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then return end
    if stat.size > (1024 * 1024 * 3) then
      return
    else
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end
  end)
end

require("telescope").setup({
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    border = true,
    border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    preview_width = 0.8,
    layout_config = {
      prompt_position = "top",
      width = 0.9,
      height = 0.9,
    },
    sorting_strategy = "ascending",
    file_ignore_patterns = { ".git", ".cache", ".DS_Store" },
    buffer_previewer_maker = new_maker,
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-p>"] = require("telescope.actions.layout").toggle_preview
      },
      n = {
        ["p"] = require("telescope.actions.layout").toggle_preview
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      },
    },
  },
})

require("telescope").load_extension("fzf")

vim.cmd([[autocmd User TelescopePreviewerLoaded setlocal wrap]])

function Live_grep_fron_project_git_root()
  local function is_git_repo()
    vim.fn.system("git rev-parse --is-inside-work-tree")

    return vim.v.shell_error == 0
  end

  local function get_git_root()
    local dot_git_path = vim.fn.finddir(".git", ".;")
    return vim.fn.fnamemodify(dot_git_path, ":h")
  end

  local opts = {}

  if is_git_repo() then
    opts = {
      cwd = get_git_root(),
    }
  end
  require("telescope.builtin").live_grep(opts)
end

function Find_files_from_project_git_root()
  local function is_git_repo()
    vim.fn.system("git rev-parse --is-inside-work-tree")
    return vim.v.shell_error == 0
  end
  local function get_git_root()
    local dot_git_path = vim.fn.finddir(".git", ".;")
    return vim.fn.fnamemodify(dot_git_path, ":h")
  end
  local opts = {}
  if is_git_repo() then
    opts = {
      cwd = get_git_root(),
      hidden = true,
    }
  end
  require("telescope.builtin").find_files(opts)
end

-- map("n", "<leader>ff", [[<cmd>lua require('telescope.builtin').find_files() hidden=true<CR>]], opts("Find files"))
map("n", "<leader>ff", [[<cmd>lua Find_files_from_project_git_root()<CR>]], opts("Find files"))
map("n", "<leader>fr", [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], opts("List recent files"))
map("n", "<leader>fc", [[<cmd>lua require('telescope.builtin').command_history()<CR>]], opts("List command history"))
map("n", "<leader>fC", [[<cmd>lua require('telescope.builtin').commands()<CR>]],
  opts("List available plugin/user commands"))
map("n", "<leader>fd", [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]],
  opts("Lists LSP document symbols in the current buffer"))
map("n", "<leader>fD", [[<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]],
  opts("Lists LSP document symbols in the current workspace"))
map("n", "<leader>fe", [[<cmd>lua require('telescope.builtin').diagnostics() bufnr=0<CR>]], opts("List diagnostics"))
map("n", "<leader>fh", [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts("Lists available help tags"))
map("n", "<leader>fj", [[<cmd>lua require('telescope.builtin').jumplist()<CR>]], opts("Lists Jump List entries"))
map("n", "<leader>fs", [[<cmd>lua require('telescope.builtin').search_history()<CR>]], opts("List search history"))
map("n", "<leader>fS", [[<cmd>lua require('telescope.builtin').spell_suggest()<CR>]],
  opts("Lists spelling suggestions for the current word under the cursor"))
map("n", "<leader>fg", [[<cmd>lua Live_grep_from_project_git_root()<CR>]], opts("Live grep"))
map("n", "<leader>fb", [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts("List buffers"))
map("n", "<leader>fm", [[<cmd>lua require('telescope.builtin').marks()<CR>]], opts("List marks"))
map("n", "<C-f>", [[<cmd>lua require('telescope.builtin').treesitter()<CR>]],
  opts("Lists Function names, variables, from Treesitter"))

--
-- #comment
--
require("Comment").setup({
  ignore = "^$",
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

map("n", "<leader>ft", ":TodoTelescope<CR>", opts("List todo_comments"))

--
-- #nvim-tree
--
local function nvimTree_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
  vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
  vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
  vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
  vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
  vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
  vim.keymap.set('n', 'bd', api.marks.bulk.delete, opts('Delete Bookmarked'))
  vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
  vim.keymap.set('n', 'yy', api.fs.copy.node, opts('Copy'))
  vim.keymap.set('n', '[g', api.node.navigate.git.prev, opts('Prev Git'))
  vim.keymap.set('n', ']g', api.node.navigate.git.next, opts('Next Git'))
  vim.keymap.set('n', 'D', api.fs.remove, opts('Delete'))
  vim.keymap.set('n', 'd', api.fs.trash, opts('Trash'))
  vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
  vim.keymap.set('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
  vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
  vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
  vim.keymap.set('n', 'F', api.live_filter.clear, opts('Clean Filter'))
  vim.keymap.set('n', 'f', api.live_filter.start, opts('Filter'))
  vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'yp', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  vim.keymap.set('n', 'zh', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
  vim.keymap.set('n', 'zi', api.tree.toggle_gitignore_filter, opts('Toggle Filter: Git Ignore'))
  vim.keymap.set('n', 'zb', api.tree.toggle_no_buffer_filter, opts('Toggle Filter: No Buffer'))
  vim.keymap.set('n', 'zc', api.tree.toggle_git_clean_filter, opts('Toggle Filter: Git Clean'))
  vim.keymap.set('n', 'zu', api.tree.toggle_custom_filter, opts('Toggle Filter: Hidden'))
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
  vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
  vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
  vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
  vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
  vim.keymap.set('n', 'S', api.node.run.system, opts('Run System'))
  vim.keymap.set('n', 's', api.tree.search_node, opts('Search'))
  vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
  vim.keymap.set('n', 'yn', api.fs.copy.filename, opts('Copy Name'))
  vim.keymap.set('n', 'yP', api.fs.copy.relative_path, opts('Copy Relative Path'))
end

require("nvim-tree").setup({
  on_attach = nvimTree_on_attach,
  view = {
    width = 36,
  },
  renderer = {
    indent_width = 2,
    indent_markers = {
      enable = true,
      inline_arrows = true,
      icons = {
        corner = "└",
        edge = "│",
        item = "│",
        bottom = "─",
        none = " ",
      },
    },
    icons = {
      webdev_colors = true,
      git_placement = "before",
      modified_placement = "after",
      padding = " ",
      symlink_arrow = " ➛ ",
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
        modified = true,
      },
      glyphs = {
        default = "",
        symlink = "",
        bookmark = "󰆤",
        modified = "●",
        folder = {
          arrow_closed = "",
          arrow_open = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "?",
          deleted = "-",
          ignored = "◌",
        },
      },
    },
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  filters = {
    dotfiles = true,
    custom = {},
    exclude = { ".git", ".DS_Store" },
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
})

map("n", "<C-e>", [[<cmd>NvimTreeToggle<CR>]], opts("Toogle NvimTree"))

--
-- #toggleterm
--
require("toggleterm").setup({
  autochdir = true,
  direction = "float",
  float_opts = {
    border = 'single',
    width = function()
      return math.floor(vim.o.columns * 0.8)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.8)
    end,
  },
})

map("n", "<C-q>", [[<cmd>ToggleTerm<CR>]], opts("Toogle terminal"))
map("t", "<C-q>", [[<cmd>ToggleTerm<CR>]], opts("Toogle terminal"))

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<C-x>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')


--
-- #treesitter
--
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true, disable = { "python" } },
  context_commentstring = { enable = true, enable_autocmd = false },
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
-- #lspconfig
--
vim.cmd("autocmd! ColorScheme * highlight NormalFloat guibg=" .. mocha.base)
vim.cmd("autocmd! ColorScheme * highlight FloatBorder guifg=" .. mocha.text .. " guibg=" .. mocha.base)
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
  severity_sort = false,
})
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- vim.cmd([[autocmd! CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]])
map("n", "J", [[<cmd>lua vim.diagnostic.open_float(nil, {focus=false})<CR>]], opts("Show diagnostic informations"))
map("n", "[e", [[<cmd>lua vim.diagnostic.goto_prev()<CR>]], opts("Go to previous diagnostic"))
map("n", "]e", [[<cmd>lua vim.diagnostic.goto_next()<CR>]], opts("Go to next diagnostic"))


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    -- vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, opts)
    vim.keymap.set('n', 'gt', require('telescope.builtin').lsp_type_definitions, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>rn', ":IncRename ", opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>a', require("actions-preview").code_actions, opts)
    vim.keymap.set('n', '<leader>F', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local handlers = {
  -- ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
  -- ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = {
  "bashls",
  "cmake",
  "cssls",
  "eslint",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "pyright",
  "remark_ls",
  "rust_analyzer",
  -- "clangd",
  -- "jdtls",
  -- "texlab",
}

local util = require("lspconfig.util")
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
    handlers = handlers,
    single_file_support = true,
  })
end

require("lspconfig").clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  handlers = handlers,
  filetypes = { "c", "cpp", "cc", "h", "hpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = util.root_pattern(".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
    "xmake.lua"),
  single_file_support = true,
})

require("lspconfig").jdtls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  handlers = handlers,
  root_dir = util.root_pattern(".git", "build.xml", "pom.xml", "settings.gradle", "settings.gradle.kts"),
  single_file_support = true,
})

require("lspconfig").texlab.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  handlers = handlers,
  settings = {
    texlab = {
      auxDirectory = ".",
      bibtexFormatter = "texlab",
      build = {
        args = {
          "-pdf",
          "-xelatex",
          "-file-line-error",
          "-halt-on-error",
          "-interaction=nonstopmode",
          "-synctex=1",
          "%f",
        },
        executable = "latexmk",
        forwardSearchAfter = true,
        onSave = true,
      },
      chktex = {
        onEdit = false,
        onOpenAndSave = true,
      },
      diagnosticsDelay = 300,
      formatterLineLength = 120,
      forwardSearch = {
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
        args = { "%l", "%p", "%f" },
        -- executable = "zathura",
        -- args = { "--synctex-forward", "%l:1:%f", "%p" },
        onSave = false,
      },
      lint = { onChange = true },
      latexFormatter = "latexindent",
      latexindent = {
        modifyLineBreaks = false,
      },
    },
  },
  single_file_support = true,
})

--
-- #cmp
--
local has_words_before = function()
  ---@diagnostic disable-next-line: deprecated
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  sources = {
    {
      name = "nvim_lsp",
      priority = 99,
      entry_filter = function(entry)
        return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
      end,
    },
    { name = "luasnip",    priority = 90 },
    { name = "nvim_lua",   priority = 50 },
    { name = "buffer",     priority = 10 },
    { name = "path",       priority = 10 },
    { name = "dictionary", keyword_length = 2, priority = 1 },
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-c>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = true, -- do not show text alongside icons
      maxwidth = 50,    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        local lspkind_icons = {
          Text = " ",
          Method = " ",
          Function = "󰊕 ",
          Constructor = " ",
          Field = " ",
          Variable = "󰫧 ",
          Class = " ",
          Interface = " ",
          Module = " ",
          Property = " ",
          Unit = " ",
          Value = "󰟿 ",
          Enum = " ",
          Keyword = " ",
          Snippet = " ",
          Color = " ",
          File = " ",
          Reference = " ",
          Folder = " ",
          EnumMember = " ",
          Constant = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        }
        vim_item.kind = string.format("%s %s", lspkind_icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          buffer = "[BUF]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[LUA]",
          path = "[PATH]",
          luasnip = "[SNIP]",
          dictionary = "[DIC]",
        })[entry.source.name]

        return vim_item
      end,
    }),
  },
})

-- local snippets_path = vim.fn.stdpath("data") .. "/lazy/friendly-snippets"
-- require("luasnip.loaders.from_vscode").load({ paths = { "~/.config/nvim/snippets", snippets_path } })

-- cmp_cmdline
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})

-- Dictionary
require("cmp_dictionary").setup({
  dic = {
    ["*"] = { vim.fn.stdpath("config") .. "/dict/english.dic" },
  },
})


--
-- #gitsigns
--
require("gitsigns").setup({
  signs = {
    add          = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
    change       = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    delete       = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    topdelete    = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    untracked    = { hl = "GitSignsUntracked", text = '┆', numhl = "GitSignsUntrackedNr",
      linehl = "GitSignsUntrackedLn" },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false,    -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false,   -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 10,
  update_debounce = 100,
  status_formatter = nil,  -- Use default
  max_file_length = 50000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  yadm = {
    enable = false
  },

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']h', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[h', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Actions
    map('n', '<leader>hs', gs.stage_hunk)
    map('n', '<leader>hr', gs.reset_hunk)
    map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    -- map('n', '<leader>hb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.toggle_deleted)

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})
