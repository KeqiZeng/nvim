---@diagnostic disable: undefined-global
--# selene: allow(undefined_variable)
--# selene: allow(unused_variable)
--# selene: allow(unscoped_variables)
--# selene: allow(mixed_table)
--# selene: allow(shadowing)
--# selene: allow(global_usage)

----------------
--- #options ---
----------------
local g = vim.g
local opt = vim.opt

g.loaded_node_provider = 0
g.loaded_python_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.markdown_recommended_style = 0

-- general
opt.mouse = ""
opt.syntax = "on"
opt.filetype = "on"
opt.number = true
opt.ruler = false
opt.relativenumber = true
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.signcolumn = "yes"
opt.conceallevel = 0
opt.cursorline = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.termguicolors = true
opt.winminwidth = 5
opt.wrap = false
opt.updatetime = 300 -- interval for writing swap file to disk, also used by gitsigns
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.autochdir = true
opt.autowrite = true
opt.completeopt = "menu,menuone,noselect"
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 3 -- global statusline
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.spelllang = { "en_us" }
opt.smoothscroll = true
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.listchars = "trail:▫"
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = "~",
}

-- search
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals
opt.hlsearch = true
opt.incsearch = true

-- indent
opt.autoindent = true
opt.smartindent = true -- Insert indents automatically
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent

-- tab
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2
opt.smarttab = true

-- split
opt.splitkeep = "screen"
opt.splitbelow = true
opt.splitright = true

-- fold
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "indent"

-- undo
opt.undofile = true
opt.undolevels = 10000

----------------
--- #autocmd ---
----------------
local autocmd = vim.api.nvim_create_autocmd

local function augroup(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

local function set_comment_string(comment_str)
	vim.api.nvim_buf_set_option(0, "commentstring", comment_str)
end

-- 在 FileType 事件上调用设置注释字符串的函数
autocmd("FileType", {
	group = augroup("commentstring"),
	callback = function()
		local ft = vim.bo.filetype
		if ft == "c" or ft == "cpp" or ft == "rust" or ft == "typ" then
			set_comment_string("// %s")
		end
	end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
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

-- wrap and check for spell in text filetypes
autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "gitcommit", "markdown", "txt", "typst", "tex" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

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

vim.cmd("autocmd InsertLeave * :silent lua InsertL()")
vim.cmd("autocmd InsertEnter * :silent lua InsertE()")

----------------
--- #keymaps ---
----------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

local function default_opts(desc)
	return { noremap = false, silent = true, desc = desc }
end

map({ "n", "x", "o" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x", "o" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x", "o" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map({ "n", "x", "o" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })

map({ "n", "x", "o" }, "gh", "^", default_opts("Go to line start"))
map({ "n", "x", "o" }, "gl", "$", default_opts("Go to line end"))

map("v", "<", "<gv", default_opts("Indent left"))
map("v", ">", ">gv", default_opts("Indent right"))

map("n", "<BACKSPACE>", "<cmd>nohl<CR>", default_opts("Clear hlsearch"))

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", default_opts("Increase window height"))
map("n", "<C-Down>", "<cmd>resize -2<cr>", default_opts("Decrease window height"))
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", default_opts("Decrease window width"))
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", default_opts("Increase window width"))

-- lazy
map("n", "<leader>p", "<cmd>Lazy<cr>", { desc = "Lazy" })

----------------
--- #plugins ---
----------------
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

	-- dressing
	{
		"stevearc/dressing.nvim",
		lazy = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},

	-- colorizer
	{
		"NvChad/nvim-colorizer.lua",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			user_default_options = {
				names = false, -- "Name" codes like Blue or blue
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				AARRGGBB = true, -- 0xAARRGGBB hex codes
				-- Available modes for `mode`: foreground, background,  virtualtext
				mode = "virtualtext", -- Set the display mode.
				virtualtext = "■",
			},
		},
	},

	-- dashboard
	{
		"glepnir/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- lualine
	{
		"nvim-lualine/lualine.nvim",
		event = "UIEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- bufferline
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "UIEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- -- dropbar
	-- {
	--   'Bekaboo/dropbar.nvim',
	--   event = 'UIEnter',
	--   dependencies = {
	--     'nvim-telescope/telescope-fzf-native.nvim'
	--   },
	--   opts = {}
	-- },

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	-- lsp
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
	},

	-- mason
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
	},

	-- cmp
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lua",
		},
	},

	-- codeium
	{
		"Exafunction/codeium.nvim",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})
		end,
	},

  -- outline
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = {
        position = 'left',
      },
      preview_window = {
        border = "rounded",
      },
      keymaps = {
        restore_location = '<C-r>',
        hover_symbol = 'K',
        toggle_preview = 'p',
      }
    },
  },

	-- lsp_signature
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach",
		opts = {},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},

	-- lightbulb
	{
		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		opts = {
			autocmd = { enabled = true },
			sign = { enabled = false },
			virtual_text = { enabled = true },
		},
	},

	-- guard
	{
		"nvimdev/guard.nvim",
		event = "LspAttach",
		dependencies = {
			"nvimdev/guard-collection",
		},
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
	},

	-- gitsigns
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPost",
	},

	{
		"lewis6991/satellite.nvim",
		event = "BufReadPost",
		opts = {
			current_only = true,
			winblend = 10,
			handlers = {
				gitsigns = {
					enable = false,
				},
				quickfix = {
					enable = false,
				},
			},
		},
	},

	-- TODO
	{
		"folke/todo-comments.nvim",
		event = "BufReadPost",
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
		},
	},

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	},

	-- terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = "ToggleTerm",
	},

	-- workspace
	{
		"natecraddock/workspaces.nvim",
		cmd = "Workspaces",
	},

	-- mini family --
	-- files
	{
		"echasnovski/mini.files",
		event = "VimEnter",
		version = "*",
	},

	-- surround
	{
		"echasnovski/mini.surround",
		event = "BufReadPost",
		version = "*",
		opts = {
			mappings = {
				add = "<leader>sa", -- Add surrounding in Normal and Visual modes
				delete = "<leader>sd", -- Delete surrounding
				find = "<leader>sf", -- Find surrounding (to the right)
				find_left = "<leader>sF", -- Find surrounding (to the left)
				highlight = "<leader>sh", -- Highlight surrounding
				replace = "<leader>sr", -- Replace surrounding
				update_n_lines = "sn", -- Update `n_lines`

				suffix_last = "l", -- Suffix to search with "prev" method
				suffix_next = "n", -- Suffix to search with "next" method
			},

			-- Number of lines within which surrounding is searched
			n_lines = 30,
		},
	},

	-- cursorword
	{
		"echasnovski/mini.cursorword",
		event = "CursorMoved",
		version = "*",
		opts = {},
	},

	-- indent
	{
		"echasnovski/mini.indentscope",
		event = "BufReadPost",
		version = "*",
		opts = {
			symbol = "│",
		},
	},

	-- autopairs
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		version = "*",
		opts = {},
	},

	-- rainbow
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost",
		version = "*",
	},

	-- matchup
	{
		"andymass/vim-matchup",
		event = "BufReadPost",
	},

	-- flash
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@diagnostic disable-next-line: undefined-doc-name
		---@type Flash.Config
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
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" }, -- example: yriw
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
	},

  -- undotree
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    event = "BufReadPost",
  },

	-- whichkey
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
}, {
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

--------------
--- #theme ---
--------------
require("catppuccin").setup({
	flavour = "mocha",
	show_end_of_buffer = true,
	term_colors = true,
	dim_inactive = {
		enable = true,
	},
	styles = {
		functions = { "bold" },
	},
	custom_highlights = function(colors)
		return {
			DiagnosticHint = { fg = colors.sapphire },
			DiagnosticInfo = { fg = colors.teal },
		}
	end,
	integrations = {
		alpha = true,
		cmp = true,
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
				warnings = { "undercurl" },
			},
			inlay_hints = {
				background = true,
			},
		},
		-- nvimtree = true,
		-- navic = { enabled = true, custom_bg = "lualine" },
		noice = true,
		notify = true,
		telescope = true,
		treesitter = true,
		treesitter_context = true,
	},
})
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "visual", { reverse = true })

local mocha = require("catppuccin.palettes").get_palette("mocha")

vim.cmd.highlight("IndentLine guifg=" .. mocha.surface1)
vim.cmd.highlight("IndentLineCurrent guifg=" .. mocha.pink)

------------------
--- #dashboard ---
------------------
require("dashboard").setup({
	theme = "hyper",
	config = {
		disable_move = true,
		week_header = {
			enable = true,
		},
		packages = { enable = true },
		shortcut = {
			{
				desc = " New file",
				group = "Special",
				action = "enew",
				key = "n",
			},
			{
				desc = " Find files",
				group = "Label",
				action = "lua Find_files_from_project_git_root()",
				key = "f",
			},
			{
				desc = " NvimConfig",
				group = "Number",
				action = "e +1 ~/.config/nvim/init.lua",
				key = "s",
			},
			{
				desc = "󰊳 Update",
				group = "Function",
				action = "Lazy sync",
				key = "u",
			},
			{
				desc = "  Health",
				group = "@property",
				action = "checkhealth",
				key = "h",
			},
			{
				desc = " Quit",
				group = "String",
				action = "quitall",
				key = "q",
			},
		},
		project = { enable = false, limit = 5 },
		footer = {
			"",
			"",
			"🚀 Don't worry, be happy!",
		},
	},
})

----------------
--- #lualine ---
----------------
local lualine_conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
}

local lualine_config = {
	options = {
		-- Disable sections and component separators
		component_separators = "",
		section_separators = "",
		theme = {
			-- We are going to use lualine_c an lualine_x as left and
			-- right section. Both are highlighted by c theme .  So we
			-- are just setting default looks o statusline
			normal = { c = { fg = mocha.text, bg = mocha.surface1 } },
			inactive = { c = { fg = mocha.text, bg = mocha.surface1 } },
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

ins_left({
	function()
		return "▊"
	end,
	color = { fg = mocha.yellow },
	padding = { left = 0, right = 1 },
})

ins_left({
	-- mode component
	function()
		-- return ' '
		local mode_component = {
			n = "󰰓 ",
			i = "󰰄 ",
			v = "󰰫 ",
			[""] = "󰰫 ",
			V = "󰰫 ",
			R = "󰰟 ",
			Rv = "󰰟 ",
			c = "󰯲 ",
			s = "󰰢 ",
			S = "󰰢 ",
			[""] = "󰰢 ",
			t = "󰰥 ",
			-- cv = "󰯸 ",
			-- ce = "󰯸 ",
			-- r = "󰰐 ",
			-- rm = "󰰐 ",
			-- ['r?'] = "󰰐 ",
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
			[""] = mocha.pink,
			V = mocha.pink,
			R = mocha.red,
			Rv = mocha.red,
			c = mocha.mauve,
			s = mocha.peach,
			S = mocha.peach,
			[""] = mocha.peach,
			t = mocha.lavender,
			-- cv = mocha.sky,
			-- ce = mocha.sky,
			-- r = mocha.lavender,
			-- rm = mocha.lavender,
			-- ['r?'] = mocha.lavender,
			-- no = mocha.red,
			-- ic = mocha.yellow,
			-- ['!'] = mocha.red,
		}
		return { fg = mode_color[vim.fn.mode()] }
	end,
	padding = { right = 1 },
})

ins_left({
	"filename",
	cond = lualine_conditions.buffer_not_empty,
	color = { fg = mocha.pink, gui = "bold" },
})

ins_left({
	-- filesize component
	"filesize",
	color = { fg = mocha.lavender },
	cond = lualine_conditions.buffer_not_empty,
})

ins_left({
	"branch",
	icon = "",
	color = { fg = mocha.peach, gui = "bold" },
})

ins_left({
	"diff",
	-- Is it me or the symbol for modified us really weird
	symbols = { added = " ", modified = " ", removed = " " },
	diff_color = {
		added = { fg = mocha.green },
		modified = { fg = mocha.yellow },
		removed = { fg = mocha.red },
	},
	cond = lualine_conditions.hide_in_width,
})

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left({
	function()
		return "%="
	end,
})

ins_left({
	"diagnostics",
	sources = { "nvim_diagnostic" },
	symbols = { error = " ", warn = " ", info = " ", hint = " " },
})

ins_left({
	-- Lsp server name .
	function()
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
	end,
	icon = " LSP:",
	color = { fg = mocha.lavender, gui = "bold" },
})

-- Add components to right sections
ins_right({
	"searchcount",
	cond = lualine_conditions.hide_in_width,
	color = { fg = mocha.mauve, gui = "bold" },
})

ins_right({
	"o:encoding", -- option component same as &encoding in viml
	fmt = string.upper, -- I'm not sure why it's upper case either ;)
	cond = lualine_conditions.hide_in_width,
	color = { fg = mocha.green, gui = "bold" },
})

ins_right({
	"fileformat",
	fmt = string.upper,
	icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
	color = { fg = mocha.green, gui = "bold" },
})

ins_right({ "location", color = { fg = mocha.lavender } })

ins_right({ "progress", color = { fg = mocha.lavender, gui = "bold" } })

ins_right({
	function()
		return "▊"
	end,
	color = { fg = mocha.yellow },
	padding = { left = 1 },
})

require("lualine").setup(lualine_config)

-------------------
--- #bufferline ---
-------------------
require("bufferline").setup({
	options = {
		buffer_close_icon = " ",
		diagnostics = "nvim_lsp", -- false | "nvim_lsp" | "coc",
		diagnostics_update_in_insert = false,
		-- The diagnostics indicator can be set to nil to keep the buffer name highlight but delete the highlighting
		diagnostics_indicator = function(count, level)
			local symbols = { error = " ", warn = " ", info = " ", hint = " " }
			return "  " .. symbols[level] .. "(" .. count .. ") "
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
		show_buffer_close_icons = false,
		show_close_icon = false,
		show_tab_indicators = true,
		show_duplicate_prefix = true,
		separator_style = "thick", -- "slant" | "thick" | "thin" | { "any", "any" },
		always_show_bufferline = false,
	},
})

map("n", "<LEADER>bb", "<cmd>BufferLinePick<CR>", default_opts("Swich to the picked buffer"))
map("n", "<LEADER>bc", "<cmd>BufferLinePickClose<CR>", default_opts("Close the picked buffer"))

map("n", "<LEADER>1", "<cmd>BufferLineGoToBuffer 1<CR>", default_opts("Go to buffer 1"))
map("n", "<LEADER>2", "<cmd>BufferLineGoToBuffer 2<CR>", default_opts("Go to buffer 2"))
map("n", "<LEADER>3", "<cmd>BufferLineGoToBuffer 3<CR>", default_opts("Go to buffer 3"))
map("n", "<LEADER>4", "<cmd>BufferLineGoToBuffer 4<CR>", default_opts("Go to buffer 4"))
map("n", "<LEADER>5", "<cmd>BufferLineGoToBuffer 5<CR>", default_opts("Go to buffer 5"))
map("n", "<LEADER>6", "<cmd>BufferLineGoToBuffer 6<CR>", default_opts("Go to buffer 6"))
map("n", "<LEADER>7", "<cmd>BufferLineGoToBuffer 7<CR>", default_opts("Go to buffer 7"))
map("n", "<LEADER>8", "<cmd>BufferLineGoToBuffer 8<CR>", default_opts("Go to buffer 8"))
map("n", "<LEADER>9", "<cmd>BufferLineGoToBuffer 9<CR>", default_opts("Go to buffer 9"))

-------------------
--- #treesitter ---
-------------------
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
				["]f"] = { mode = { "n", "v", "o" }, query = "@function.outer", desc = "Next function start" },
				["]c"] = { mode = { "n", "v", "o" }, query = "@class.outer", desc = "Next class start" },
			},
			goto_previous_start = {
				["[f"] = { mode = { "n", "v", "o" }, query = "@function.outer", desc = "Previous function start" },
				["[c"] = { mode = { "n", "v", "o" }, query = "@class.outer", desc = "Previous class start" },
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

------------------
--- #lspconfig ---
------------------
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

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line:duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or border
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

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

autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		local function buf_set_option(...)
			vim.api.nvim_buf_set_option(bufnr, ...)
		end

		buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

		require("lsp_signature").on_attach({}, bufnr)

		autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			callback = function()
				local current_mode = vim.fn.mode()
				if current_mode ~= "n" then
					return
				end
				local opts = {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					source = "always",
					prefix = " ",
					scope = "cursor",
				}
				vim.diagnostic.open_float(nil, opts)
			end,
		})

		-- Mappings.
		---@diagnostic disable-next-line: redefined-local
		local opts = { buffer = bufnr, noremap = true, silent = true }
		local function set_opts(desc)
			opts.buffer = bufnr
			opts.desc = desc
			return opts
		end
		map("n", "gD", vim.lsp.buf.declaration, set_opts("Go to declaration"))
		map("n", "gd", require("telescope.builtin").lsp_definitions, set_opts("Go to definitions"))
		map("n", "gt", require("telescope.builtin").lsp_type_definitions, set_opts("Go to type definitions"))
		map("n", "gr", require("telescope.builtin").lsp_references, set_opts("Go to references"))
		map("n", "gp", require("telescope.builtin").lsp_implementations, set_opts("Go to implementations"))
		map("n", "K", vim.lsp.buf.hover, set_opts("Hover"))
		map("n", "<C-k>", vim.lsp.buf.signature_help, set_opts("Show signature help"))
		map("n", "<leader>r", vim.lsp.buf.rename, set_opts("Rename"))
		map({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, set_opts("Code actions"))
	end,
})

local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

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
	"rust_analyzer",
	"typst_lsp",
	"vale_ls",
	-- "clangd",
	-- "texlab",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		capabilities = capabilities,
		single_file_support = true,
	})
end

--------------
--- #mason ---
--------------
require("mason").setup({
	ui = {
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
		"bash-language-server",
		"cmake-language-server",
		"css-lsp",
		"eslint-lsp",
		"golangci-lint",
		"gopls",
		"html-lsp",
		"json-lsp",
		"latexindent",
		"lua-language-server",
		"selene",
		"stylua",
		"markdownlint",
		"prettier",
		"pyright",
		"rust-analyzer",
		"ruff",
		"shellcheck",
		"shfmt",
    "taplo",
		"texlab",
		"typstfmt",
		"typst-lsp",
		"vale-ls",
		"yaml-language-server",
		"yamlfmt",
		"yamllint",
	},
})

------------
--- #cmp ---
------------
local cmp = require("cmp")
local lspkind = require("lspkind")

local has_words_before = function()
	---@diagnostic disable-next-line: deprecated
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text", -- show only symbol annotations
			maxwidth = function()
				return math.floor(vim.o.columns * 0.45)
			end, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
			-- can also be a function to dynamically calculate max width such as
			-- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
			ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
			show_labelDetails = true, -- show labelDetails in menu. Disabled by default
		}),
	},

	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},

	sources = {
		{ name = "nvim_lsp", priority = 99 },
		{ name = "luasnip", priority = 90 },
		{ name = "codeium", priority = 70 },
		{ name = "buffer", priority = 50 },
		{ name = "path", priority = 30 },
		{ name = "nvim_lua", priority = 10 },
	},

	mapping = {
		["<C-u>"] = cmp.mapping.scroll_docs(-3),
		["<C-d>"] = cmp.mapping.scroll_docs(3),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-\\>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif vim.snippet.active({ direction = 1 }) then
				vim.schedule(function()
					vim.snippet.jump(1)
				end)
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.snippet.active({ direction = -1 }) then
				vim.schedule(function()
					vim.snippet.jump(-1)
				end)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
})

-- `/` cmdline setup.
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{
			name = "path",
		},
	}, {
		{
			name = "cmdline",
		},
	}),
})

-----------------
--- #gitsigns ---
-----------------
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		---@diagnostic disable-next-line: redefined-local
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]h", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Next hunk" })

		map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[h", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Prev hunk" })

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage hunk" })
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Reset hunk" })
		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
		map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "Blame line" })
		map("n", "<leader>htb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
		map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff this hunk" })
		map("n", "<leader>hD", function()
			gitsigns.diffthis("~")
		end, { desc = "Diff this hunk with ~" })
		map("n", "<leader>htd", gitsigns.toggle_deleted, { desc = "Toggle deleted" })

		-- Text object
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
		map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
	end,
})

--------------
--- #guard ---
--------------
local ft = require("guard.filetype")

ft("c, cpp"):fmt("clang-format"):lint("clang-tidy")

ft("python"):fmt("ruff"):lint("ruff")

ft("rust"):fmt("rustfmt")

ft("lua"):fmt("stylua"):lint("selene")

ft("tex"):fmt("latexindent")

ft("toml"):fmt("taplo")

ft("sh"):fmt("shfmt"):lint("shellcheck")

ft("fish"):fmt("fish_indent")

require("guard").setup({
	fmt_on_save = true,
	lsp_as_default_formatter = false,
})

--------------
--- #noice ---
--------------
require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
		signature = {
			enabled = false,
		},
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
})

-- map("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, default_opts("Redirect Cmdline"))
map("n", "<leader>nl", "<cmd>Noice last<cr>", default_opts("Noice Last Message"))
map("n", "<leader>nh", "<cmd>Noice history<cr>", default_opts("Noice History"))
map("n", "<leader>na", "<cmd>Noice all<cr>", default_opts("Noice All"))
map("n", "<leader>nd", "<cmd>Noice dismiss<cr>", default_opts("Dismiss All"))
map("n", "<leader>fn", "<cmd>Noice telescope<cr>", default_opts("Noice Telescope"))

----------------------
--- #todo-comments ---
----------------------
map("n", "]t", function()
	require("todo-comments").jump_next()
end, default_opts("Next todo comment"))

map("n", "[t", function()
	require("todo-comments").jump_prev()
end, default_opts("Previous todo comment"))

map("n", "<leader>ft", ":TodoTelescope<CR>", default_opts("List todo_comments"))

------------------
--- #telescope ---
------------------
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
		preview = {
			filesize_limit = 2, -- MB
		},
		mappings = {
			i = {
				["<C-j>"] = require("telescope.actions").move_selection_next,
				["<C-k>"] = require("telescope.actions").move_selection_previous,
				["<C-p>"] = require("telescope.actions.layout").toggle_preview,
			},
			n = {
				["p"] = require("telescope.actions.layout").toggle_preview,
				["q"] = require("telescope.actions").close,
			},
		},
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
		},
	},
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("workspaces")
vim.cmd("autocmd User TelescopePreviewerLoaded setlocal wrap")

local function is_git_repo()
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end

local function get_git_root()
	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

function Live_grep_from_project_git_root()
	local opts = {}

	if is_git_repo() then
		opts = {
			cwd = get_git_root(),
		}
	end

	require("telescope.builtin").live_grep(opts)
end

function Find_files_from_project_git_root()
	local opts = {}
	if is_git_repo() then
		opts = {
			cwd = get_git_root(),
		}
	end
	require("telescope.builtin").find_files(opts)
end

map("n", "<leader>ff", "<cmd>lua Find_files_from_project_git_root()<cr>", default_opts("Find files"))
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", default_opts("List recent files"))
map("n", "<leader>fc", "<cmd>Telescope command_history<cr>", default_opts("List command history"))
map("n", "<leader>fC", "<cmd>Telescope commands<cr>", default_opts("List available commands"))
map("n", "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", default_opts("List diagnostics in current buffer"))
map("n", "<leader>fD", "<cmd>Telescope diagnostics bufnr=nil<cr>", default_opts("List diagnostics in current workspace"))
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", default_opts("List available help tags"))
map("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", default_opts("List jump List entries"))
map("n", "<leader>fs", "<cmd>Telescope search_history<cr>", default_opts("List search history"))
map("n", "<leader>fS", "<cmd>Telescope spell_suggest<cr>", default_opts("List spelling suggestions for the current word under the cursor"))
map("n", "<leader>fg", "<cmd>lua Live_grep_from_project_git_root()<cr>", default_opts("Live grep"))
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", default_opts("List buffers"))
map("n", "<leader>fm", "<cmd>Telescope marks<cr>", default_opts("List marks"))
map("n", "<leader>fv", "<cmd>Telescope treesitter<cr>", default_opts("List function names, variables, from Treesitter"))
map("n", "<leader>fw", "<cmd>Telescope workspaces<cr>", default_opts("List workspaces"))

-----------------
--- #terminal ---
-----------------
require("toggleterm").setup({
	persist_mode = false,
	start_in_insert = true,
	autochdir = true,
	size = function(term)
		if term.direction == "horizontal" then
			return 20
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	direction = "horizontal",
	float_opts = {
		border = "rounded",
		width = function()
			return math.floor(vim.o.columns * 0.8)
		end,
		height = function()
			return math.floor(vim.o.lines * 0.8)
		end,
	},
})

local Terminal = require("toggleterm.terminal").Terminal

local float_term = Terminal:new({
	display_name = "float_term",
	direction = "float",
	hidden = true,
})

local lazygit = Terminal:new({
	cmd = "lazygit",
	display_name = "Lazygig",
	direction = "float",
	hidden = true,
})

function Fterm_toggle()
	float_term:toggle()
end

function New_terminal(direction)
	local new_term = Terminal:new({ direction = direction })
	new_term:toggle()
end

function Lazygit_toggle()
	lazygit:toggle()
end

map("n", "<C-f>", "<cmd>lua Fterm_toggle()<cr>", default_opts("Toggle float_term"))
map("n", "<C-q>", "<cmd>ToggleTerm<cr>", default_opts("Toggle terminals"))
map("i", "<C-f>", "<cmd>lua Fterm_toggle()<cr>", default_opts("Toggle float_term"))
map("i", "<C-q>", "<cmd>ToggleTerm<cr>", default_opts("Toggle terminals"))
map("n", "<leader>g", "<cmd>lua Lazygit_toggle()<cr>", default_opts("Lazygit"))
map("n", "<leader>tt", "<cmd>TermSelect<cr>", default_opts("Select Terminal"))
map("n", "<leader>tr", "<cmd>ToggleTermSetName<cr>", default_opts("Set Terminal name"))

function _G.set_terminal_keymaps()
	local function set_opts(desc)
		return { buffer = 0, noremap = true, silent = true, desc = desc }
	end
	map("t", "<C-f>", [[<cmd>lua Fterm_toggle()<cr>]], set_opts("Toggle float_term"))
	map("t", "<C-q>", [[<cmd>ToggleTerm<cr>]], set_opts("Toggle Terminal"))
	map("t", "<C-x>", [[<cmd>lua New_terminal('horizontal')<cr>]], set_opts("New horizontal terminal"))
	map("t", "<C-h>", [[<cmd>wincmd h<cr>]], set_opts("Go to the left window"))
	map("t", "<C-j>", [[<cmd>wincmd j<cr>]], set_opts("Go to the down window"))
	map("t", "<C-k>", [[<cmd>wincmd k<cr>]], set_opts("Go to the up window"))
	map("t", "<C-l>", [[<cmd>wincmd l<cr>]], set_opts("Go to the right window"))
	map("t", "<C-w>", [[<cmd>close<cr>]], set_opts("Close current terminal"))
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

------------------
--- #workspace ---
------------------
require("workspaces").setup({
	hooks = {
		open = "Telescope find_files",
	},
})

map("n", "<leader>wa", "<cmd>WorkspacesAdd<cr>", default_opts("Add Workspace"))
map("n", "<leader>wr", "<cmd>WorkspacesRemove<cr>", default_opts("Remove Workspace"))
map("n", "<leader>wo", "<cmd>WorkspacesOpen<cr>", default_opts("Open Workspace"))
map("n", "<leader>wl", "<cmd>WorkspacesList<cr>", default_opts("List Workspace"))

--------------
--- #minifiles ---
--------------
require("mini.files").setup({
	content = {
		filter = function(fs_entry)
			return not vim.startswith(fs_entry.name, ".")
		end,
	},
	mappings = {
		go_in = "L",
		go_in_plus = "l",
		go_out = "H",
		go_out_plus = "h",
		synchronize = "<CR>",
	},
})

autocmd("User", {
	pattern = "MiniFilesWindowOpen",
	callback = function(args)
		local win_id = args.data.win_id
		vim.api.nvim_win_set_config(win_id, { border = "rounded" })
	end,
})

function Minifiles_toggle(...)
	if not MiniFiles.close() then
		MiniFiles.open(...)
	end
end

map("n", "<C-e>", "<cmd>lua Minifiles_toggle()<cr>", default_opts("Toggle MiniFiles"))

local map_split = function(buf_id, lhs, direction)
	local rhs = function()
		-- Make new window and set it as target
		local new_target_window
		vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
			vim.cmd(direction .. " split")
			new_target_window = vim.api.nvim_get_current_win()
		end)

		MiniFiles.set_target_window(new_target_window)
		MiniFiles.go_in({ close_on_file = true })
	end

	-- Adding `desc` will result into `show_help` entries
	local desc = "Split " .. direction
	map("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

local show_dotfiles = false

---@diagnostic disable-next-line: unused-local
local filter_show = function(fs_entry)
	return true
end

local filter_hide = function(fs_entry)
	return not vim.startswith(fs_entry.name, ".")
end

local toggle_dotfiles = function()
	show_dotfiles = not show_dotfiles
	local new_filter = show_dotfiles and filter_show or filter_hide
	MiniFiles.refresh({ content = { filter = new_filter } })
end

autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id
		map_split(buf_id, "gx", "belowright horizontal")
		map_split(buf_id, "gv", "belowright vertical")
		map("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dotfiles" })
		map("n", "gr", "<cmd>lua MiniFiles.refresh()<cr>", { buffer = buf_id, desc = "Refresh" })
	end,
})

--------------
--- #flash ---
--------------
vim.cmd("highlight Flashlabel guifg=" .. mocha.red)

function JumpToLine()
	require("flash").jump({
		search = { mode = "search", max_length = 0 },
		label = { after = { 0, 0 } },
		pattern = "^",
	})
end

map({ "n", "x", "o" }, "\\\\", "<cmd>lua JumpToLine()<CR>", default_opts("Jump to a line"))


-----------------
--- #undotree ---
-----------------
require("undotree").setup({
  window = {
    winblend = 20,
  },
  keymaps = {
    ['gp'] = "move2parent",
  },
})
vim.keymap.set("n", "<leader>u", require("undotree").toggle, default_opts("Toggle undotree"))

-----------------
--- #whichkey ---
-----------------
vim.keymap.del("n", "<C-w><C-D>")

local wk = require("which-key")
wk.setup({
	plugins = {
		presets = {
			operators = true,
			motions = true,
			text_objects = true,
			windows = true,
			nav = true,
			g = false,
			z = true,
		},
	},
	layout = {
		height = { min = 5, max = 35 }, -- min and max height of the columns
		width = { min = 20, max = 60 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "center", -- align columns left, center or right
	},
	key_labels = {
		["<space>"] = "SPC",
		["<cr>"] = "RET",
		["<tab>"] = "TAB",
		["<leader>"] = "LEADER",
	},
})

local presets = require("which-key.plugins.presets")
presets.motions["%"] = nil
presets.motions["f"] = nil
presets.motions["F"] = nil
presets.motions["t"] = nil
presets.motions["T"] = nil

wk.register({
	b = {
		name = "Buffer",
	},
	f = {
		name = "Telescope",
	},
	h = {
		name = "Gitsigns",
		t = {
			name = "Toggle",
		},
	},
	n = {
		name = "Noice",
	},
	s = {
		name = "Surround",
	},
	t = {
		name = "Terminal",
	},
	w = {
		name = "Workspace",
	},
}, { prefix = "<leader>" })

wk.register({
	["%"] = { "Go to next matching word" },
	f = { "Find char forward" },
	F = { "Find char backward" },
	t = { "Till char forward" },
	T = { "Till char backward" },
	[";"] = { "Repeat last f, F, t or T" },
	[","] = { "Repeat last f, F, t or T in opposite direction" },

	g = {
		f = { "Go to file under cursor" },
		i = { "Move to the last insertion and INSERT" },
		n = { "Search forwards and select" },
		N = { "Search backwards and select" },
		v = { "Switch to VISUAL using last selection" },
		["%"] = { "Go to previous matching word" },
	},

	["["] = {
		["%"] = { "Go to previous outer open word" },
	},

	["]"] = {
		["%"] = { "Go to next surrounding close word" },
	},

	z = {
		["%"] = { "Go to inside nearest inner contained block" },
	},
}, { mode = "n" })

wk.register({
	["%"] = { "Go to next matching word" },
	f = { "Find char forward" },
	F = { "Find char backward" },
	t = { "Till char forward" },
	T = { "Till char backward" },
	[";"] = { "Repeat last f, F, t or T" },
	[","] = { "Repeat last f, F, t or T in opposite direction" },

	g = {
		f = { "Go to the selected file" },
		i = { "Go to the last insertion" },
		["%"] = { "Go to previous matching word" },
	},

	["["] = {
		["%"] = { "Go to previous outer open word" },
	},

	["]"] = {
		["%"] = { "Go to next surrounding close word" },
	},

	z = {
		["%"] = { "Go to inside nearest inner contained block" },
	},

	i = {
		["%"] = { "Select the inside of a matching pair" },
	},

	a = {
		["%"] = { "Select a matching pair" },
	},
}, { mode = "v" })

wk.register({
	["%"] = { "Go to next matching word" },
	f = { "Find char forward" },
	F = { "Find char backward" },
	t = { "Till char forward" },
	T = { "Till char backward" },
	[";"] = { "Repeat last f, F, t or T" },
	[","] = { "Repeat last f, F, t or T in opposite direction" },

	g = {
		["%"] = { "Go to previous matching word" },
	},

	["["] = {
		["%"] = { "Go to previous outer open word" },
	},

	["]"] = {
		["%"] = { "Go to next surrounding close word" },
	},

	z = {
		["%"] = { "Go to inside nearest inner contained block" },
	},

	i = {
		["%"] = { "Select the inside of a matching pair" },
	},

	a = {
		["%"] = { "Select a matching pair" },
	},
}, { mode = "o" })
