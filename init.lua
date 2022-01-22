--
-- #basic/options
--
vim.cmd("set number")
vim.cmd("set cursorline")
vim.cmd("set relativenumber")
vim.cmd("set ruler")
vim.cmd("set clipboard=unnamedplus")
vim.cmd("set history=500")
vim.cmd("set nrformats=")  -- 默认0##为十进制数
vim.cmd("set timeout")
vim.cmd("set ttimeout")
vim.cmd("set ttimeoutlen=50")
vim.cmd("syntax on")

-- 代码缩进
vim.cmd("set noexpandtab")
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set softtabstop=4")
vim.cmd("set autoindent")
vim.cmd("set smarttab")

-- 代码折叠
vim.cmd("set foldenable")
vim.cmd("set fdm=manual")

vim.cmd("set wildmenu")
vim.cmd("set signcolumn=yes")
vim.cmd("set backspace=indent,eol,start")
vim.cmd("set scrolloff=8")
vim.cmd("set sidescrolloff=5")
vim.cmd("set lazyredraw")

-- 搜索
vim.cmd("set ignorecase")
vim.cmd("set smartcase")
vim.cmd("set hlsearch")
vim.cmd("set incsearch")

-- 编码
vim.cmd("set encoding=utf-8")
vim.cmd("set fileencoding=utf-8")

vim.cmd("set showmatch")
vim.cmd("set matchtime=2")
vim.cmd("set formatoptions+=m")
vim.cmd("set formatoptions+=B")
vim.cmd("set hidden")
vim.cmd("set updatetime=100")

vim.cmd("let $NVIM_TUI_ENABLE_TRUE_COLOR=1")
vim.cmd("set termguicolors")

-- 打开nvim时光标停留在上次退出时的位置
vim.cmd([[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])
-- vim.cmd("")

--
-- #basic/keymap
--
local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }

map("n", "H", "0", opt)
map("n", "L", "$", opt)
map("n", "<BACKSPACE>", [[<cmd>nohl<CR>]], opt)
map("n", "<UP>", [[<cmd>res +5<CR>]], opt)
map("n", "<DOWN>", [[<cmd>res -5<CR>]], opt)
map("n", "<LEFT>", [[<cmd>vertical resize -5<CR>]], opt)
map("n", "<RIGHT>", [[<cmd>vertical resize +5<CR>]], opt)
map("n", "<LEADER>uu", [[<cmd>PackerSync<CR>]], opt)

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
	false)
end
map("n", "<LEADER>bC", [[<cmd>lua DeletAllBuffers()<CR>]], opt)

--
-- #packer
--
-- AUtoinstall packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]]

local use = require('packer').use
require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  -- Startup
  use 'goolord/alpha-nvim'
  -- Colorscheme
  use 'olimorris/onedarkpro.nvim'

  -- nvim-gps
  use {
	'SmiteshP/nvim-gps',
	requires = 'nvim-treesitter/nvim-treesitter'
}

  -- LuaLine
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
}
  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
}
  -- Bufferline
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}
  -- Nvim-tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
}
  -- Comment
  use 'numToStr/Comment.nvim'
  -- Hop
  use {
    'phaazon/hop.nvim',
    branch = 'v1', -- optional but strongly recommended
}
  -- Cursorword
  use 'yamatsum/nvim-cursorline'
  -- Tidy
  use 'McAuleyPenney/tidy.nvim'
  -- Indentline
  use 'lukas-reineke/indent-blankline.nvim'
  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
}
  -- Autopairs
  use {
    'windwp/nvim-autopairs',
    require('nvim-autopairs').setup()
}
  use 'windwp/nvim-ts-autotag'
  -- Rainbow
  use 'p00f/nvim-ts-rainbow'
  -- Surround
  use {
  "blackCauldron7/surround.nvim",
  config = function()
    require"surround".setup {
	mappings_style = "sandwich",
	map_insert_mode = false
    }
  end
}
  -- gitsigns
  use {
  'lewis6991/gitsigns.nvim',
  requires = 'nvim-lua/plenary.nvim'
}
  -- colorizer
  use {
  'norcalli/nvim-colorizer.lua',
  config = function()
	require'colorizer'.setup()
  end
}
  -- lazygit
  use 'kdheepak/lazygit.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'onsails/lspkind-nvim'
  use 'ray-x/lsp_signature.nvim'
  use 'tami5/lspsaga.nvim'
  use 'kosayoda/nvim-lightbulb'
  -- Cmp
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'rafamadriz/friendly-snippets'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'uga-rosa/cmp-dictionary'
end)


--
-- #alpha
--
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
math.randomseed(os.time())

local function pick_color()
  local colors = {"String", "Keyword", "Number"}
  return colors[math.random(#colors)]
end

-- set header
dashboard.section.header.val = {
    "                                                     ",
    "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
    "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
    "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
    "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
    "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
    "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
    "                                                     ",
}
dashboard.section.header.opts.hl = pick_color()

-- set menu
dashboard.section.buttons.val = {
    dashboard.button( "e", "   New file" , ":ene <BAR> startinsert <CR>"),
    dashboard.button( "f", "   Find file", ":cd $HOME | Telescope find_files hidden=true<CR>"),
    dashboard.button( "w", "   WorkSpace", ":cd $HOME/Workspace | Telescope find_files<CR>"),
    dashboard.button( "g", "ﳑ   GoSrc"    , ":cd $HOME/go/src | Telescope find_files<CR>"),
    dashboard.button( "r", "   Recent"   , ":Telescope oldfiles<CR>"),
    dashboard.button( "s", "   Settings" , ":cd $HOME/.config/nvim | Telescope find_files<CR>"),
    dashboard.button( "q", "   Quit NVIM", ":qa<CR>"),
}

dashboard.section.buttons.opts.hl = pick_color()

if vim.fn.has("win32") == 1 then
  plugins_count = vim.fn.len(vim.fn.globpath("~/AppData/Local/nvim-data/site/pack/packer/start", "*", 0, 1))
else
  plugins_count = vim.fn.len(vim.fn.globpath("~/.local/share/nvim/site/pack/packer/start", "*", 0, 1))
end

dashboard.section.footer.val = {
	"",
	"-- Packer loaded " .. plugins_count .. " plugins    --",
	"-- Happy Coding, Happy Life    --",
}

dashboard.section.footer.opts.hl = pick_color()

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])

--
-- #nvim-gps
--
local gps = require("nvim-gps")
gps.setup({

	disable_icons = false,           -- Setting it to true will disable all icons

	icons = {
		["class-name"] = ' ',      -- Classes and class-like objects
		["function-name"] = ' ',   -- Functions
		["method-name"] = ' ',     -- Methods (functions inside class-like objects)
		["container-name"] = '離 ',  -- Containers (example: lua tables)
		["tag-name"] = '炙'         -- Tags (example: html tags)
	},

	-- Add custom configuration per language or
	-- Disable the plugin for a language
	-- Any language not disabled here is enabled by default
	languages = {
		-- Some languages have custom icons
		["json"] = {
			icons = {
				["array-name"] = ' ',
				["object-name"] = ' ',
				["null-name"] = '[] ',
				["boolean-name"] = 'ﰰﰴ ',
				["number-name"] = '# ',
				["string-name"] = ' '
			}
		},
		["toml"] = {
			icons = {
				["table-name"] = ' ',
				["array-name"] = ' ',
				["boolean-name"] = 'ﰰﰴ ',
				["date-name"] = ' ',
				["date-time-name"] = ' ',
				["float-name"] = ' ',
				["inline-table-name"] = ' ',
				["integer-name"] = '# ',
				["string-name"] = ' ',
				["time-name"] = ' '
			}
		},
		["yaml"] = {
			icons = {
				["mapping-name"] = ' ',
				["sequence-name"] = ' ',
				["null-name"] = '[] ',
				["boolean-name"] = 'ﰰﰴ ',
				["integer-name"] = '# ',
				["float-name"] = ' ',
				["string-name"] = ' '
			}
		}
	}
})

--
-- #lualine
--
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'onedarkpro',
    component_separators = '|',
    section_separators = { ' ' },
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch','diff','diagnostics'},
    lualine_c = {'filename', {gps.get_location, cond = gps.is_available}},
    lualine_x = {'encoding','filetype','fileformat'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
        },
  inactive_sections = {
    lualine_a = {'filename'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'location'}
  },
  tabline = {},
  extensions = {}
}


--
-- #theme
--
local onedarkpro = require("onedarkpro")
onedarkpro.setup({
  -- Theme can be overwritten with 'onedark' or 'onelight' as a string!
  theme = function()
    if vim.o.background == "dark" then
      return "onedark"
    else
      return "onelight"
    end
  end,
  colors = {
      onedark = {
          red = "#F15e64",
          orange = "#e88854",
          green = "#98c378",
		  blue = "#86a6e8",
	      purple = "#bb88e5",
		  pink = "#ff9999",
      },
  }, -- Override default colors. Can specify colors for "onelight" or "onedark" themes by passing in a table
  hlgroups = {
      Operator = { fg = "${blue}" },
      Identifier = { link = "Operator" },
      Constant = { link = "Operator" },
      Todo = {fg = "${blue}", style = "bold,italic"},
	  TSVariable = {fg = "${pink}" },
  }, -- Override default highlight groups
  plugins = { -- Override which plugins highlight groups are loaded
      native_lsp = true,
      polygot = false,
      treesitter = true,
      -- Others omitted for brevity
  },
  styles = {
      strings = "NONE", -- Style that is applied to strings
      comments = "italic", -- Style that is applied to comments
      keywords = "NONE", -- Style that is applied to keywords
      functions = "bold", -- Style that is applied to functions
      variables = "NONE", -- Style that is applied to variables
  },
  options = {
      bold = true, -- Use the themes opinionated bold styles?
      italic = true, -- Use the themes opinionated italic styles?
      underline = true, -- Use the themes opinionated underline styles?
      undercurl = true, -- Use the themes opinionated undercurl styles?
      cursorline = true, -- Use cursorline highlighting?
      transparency = false, -- Use a transparent background?
      terminal_colors = true, -- Use the theme's colors for Neovim's :terminal?
      window_unfocussed_color = false, -- When the window is out of focus, change the normal background?
  }
})
onedarkpro.load()


--
-- #telescope
--
require("telescope").setup {
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    preview_width = 0.9,
    file_ignore_patterns = {".git", ".cache", ".DS_Store"},
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous
      }
    }
  }
}

vim.cmd([[autocmd User TelescopePreviewerLoaded setlocal wrap]])

map("n", "<LEADER>F", [[<cmd>Telescope<CR>]], opt)
map("n", "<LEADER>ff", [[<cmd>lua require('telescope.builtin').find_files() hidden=true<CR>]], opt)
map("n", "<LEADER>fo", [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], opt)
map("n", "<LEADER>fc", [[<cmd>lua require('telescope.builtin').command_history()<CR>]], opt)
map("n", "<LEADER>fd", [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opt)
map("n", "<LEADER>fD", [[<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]], opt)
map("n", "<LEADER>fe", [[<cmd>lua require('telescope.builtin').diagnostics() bufnr=0<CR>]], opt)
map("n", "<LEADER>fs", [[<cmd>lua require('telescope.builtin').search_history()<CR>]], opt)
map("n", "<LEADER>fg", [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], opt)
map("n", "<LEADER>fb", [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opt)
map("n", "<LEADER>fm", [[<cmd>lua require('telescope.builtin').marks()<CR>]], opt)
map("n", "<C-f>", [[<cmd>lua require('telescope.builtin').treesitter()<CR>]], opt)
map("n", "gr", [[<cmd>lua require('telescope.builtin').lsp_references()<CR>]], opt)
map("n", "gi", [[<cmd>lua require('telescope.builtin').lsp_implementations()<CR>]], opt)


--
-- #bufferline
--
require('bufferline').setup {
  options = {
		numbers = function(opts)
                	return string.format('%s|%s.)', opts.id, opts.raise(opts.ordinal))
                end,
    -- NOTE: this plugin is designedwith this icon in mind,
    -- and so changing this is NOT recommended, this is intended
    -- as an escape hatch for people who cannot bear it for whatever reason
    indicator_icon = '▎',
    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    --- name_formatter can be used to change the buffer's label in the bufferline.
    --- Please note some names can/will break the
    --- bufferline so use this at your discretion knowing that it has
    --- some limitations that will *NOT* be fixed.
    name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
      -- remove extension from markdown files for example
      if buf.name:match('%.md') then
        return vim.fn.fnamemodify(buf.name, ':t:r')
      end
    end,
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 18,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "("..count..")"
    end,
    -- NOTE: this will be called a lot so don't do any heavy processing here
    custom_filter = function(buf_number, buf_numbers)
      -- filter out by buffer name
      if vim.fn.bufname(buf_number) ~= "alpha" then
        return true
      end
    end,
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "center"}},
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "thick",
    enforce_regular_tabs = false,
    always_show_bufferline = false,
    sort_by = 'extension'
    },

  custom_areas = {
    right = function()
      local result = {}
      local seve = vim.diagnostic.severity
      local error = #vim.diagnostic.get(0, {severity = seve.ERROR})
      local warning = #vim.diagnostic.get(0, {severity = seve.WARN})
      local info = #vim.diagnostic.get(0, {severity = seve.INFO})
      local hint = #vim.diagnostic.get(0, {severity = seve.HINT})

      if error ~= 0 then
        table.insert(result, {text = "  " .. error, guifg = "#f15e64"})
      end

      if warning ~= 0 then
        table.insert(result, {text = "  " .. warning, guifg = "#e5c07b"})
      end

      if hint ~= 0 then
        table.insert(result, {text = "  " .. hint, guifg = "#98c378"})
      end

      if info ~= 0 then
        table.insert(result, {text = "  " .. info, guifg = "#e88854"})
      end
      return result
    end,
  }
}

map("n", "<LEADER>bb", [[<cmd>BufferLinePick<CR>]], opt)
map("n", "<LEADER>bc", [[<cmd>BufferLinePickClose<CR>]], opt)

map("n", "<LEADER>1", [[<cmd>BufferLineGoToBuffer 1<CR>]], opt)
map("n", "<LEADER>2", [[<cmd>BufferLineGoToBuffer 2<CR>]], opt)
map("n", "<LEADER>3", [[<cmd>BufferLineGoToBuffer 3<CR>]], opt)
map("n", "<LEADER>4", [[<cmd>BufferLineGoToBuffer 4<CR>]], opt)
map("n", "<LEADER>5", [[<cmd>BufferLineGoToBuffer 5<CR>]], opt)
map("n", "<LEADER>6", [[<cmd>BufferLineGoToBuffer 6<CR>]], opt)
map("n", "<LEADER>7", [[<cmd>BufferLineGoToBuffer 7<CR>]], opt)
map("n", "<LEADER>8", [[<cmd>BufferLineGoToBuffer 8<CR>]], opt)
map("n", "<LEADER>9", [[<cmd>BufferLineGoToBuffer 9<CR>]], opt)



--
-- #comment
--
require('Comment').setup {
    toggler = {
        ---Line-comment toggle keymap
        line = '<LEADER>C',
        -- ---Block-comment toggle keymap
        -- block = '<LEADER>bc',
    },
    opleader = {
        ---Line-comment keymap
        line = '<LEADER>cc',
        -- ---Block-comment keymap
        block = '<LEADER>cb',
    },
    extra = {
        ---Add comment on the line above
        above = '<LEADER>cO',
        ---Add comment on the line below
        below = '<LEADER>co',
        ---Add comment at the end of line
        eol = '<LEADER>cA',
    },
}


--
-- #hop
--
require'hop'.setup { keys = 'qwerasdfzxcvhjkluio' }
map("n", "<LEADER>ss", [[<cmd>lua require'hop'.hint_char2()<CR>]], opt)
map("n", "<LEADER>sl", [[<cmd>lua require'hop'.hint_lines()<CR>]], opt)
map('n', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<CR>", {})
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>", {})


--
-- #indentline
--
require("indent_blankline").setup({
    filetype_exclude = {"lspinfo", "packer", "checkhealth", "help", "alpha", "NvimTree", ""},
    buftype_exclude = { "terminal" },
})


--
-- #treesitter
--
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {"c", "cpp", "cmake", "go", "gomod", "python", "bash", "lua", "latex", "bibtex", "html", "dockerfile", "json", "toml", "yaml"},

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplcate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    max_file_lines = 10000,
    colors = {
        '#bb88e5',
        '#86a6e8',
        '#e5c07b',
        '#f15e64'
      }
  },
  autotag = {
    enable = true,
  },
  indent = {
    enable = true
  }
}


--
-- #nvim-tree
--
require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  open_on_setup       = false,
  ignore_ft_on_setup  = {},
  auto_close          = true,
  open_on_tab         = false,
  hijack_cursor       = false,
  update_cwd          = true,
  update_to_buf_dir   = {
    enable = true,
    auto_open = true,
  },
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = false,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfies = false,
    custom = {".git", ".DS_Store"}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 36,
    height = 30,
    hide_root_folder = false,
    side = 'left',
    auto_resize = false,
    mappings = {
      custom_only = true,
      list = {
	  { key = {"<CR>", "o" },                 action = "edit" },
      { key = "<C-]>",                        action = "cd" },
      { key = "<C-v>",                        action = "vsplit" },
      { key = "<C-x>",                        action = "split" },
      { key = "<C-t>",                        action = "tabnew" },
      { key = "<",                            action = "prev_sibling" },
      { key = ">",                            action = "next_sibling" },
      { key = "P",                            action = "parent_node" },
      { key = "<BS>",                         action = "close_node" },
      { key = "<Tab>",                        action = "preview" },
      { key = "K",                            action = "first_sibling" },
      { key = "J",                            action = "last_sibling" },
      { key = "I",                            action = "toggle_ignored" },
      { key = "zh",                           action = "toggle_dotfiles" },
      { key = "R",                            action = "refresh" },
      { key = "a",                            action = "create" },
      { key = "d",                            action = "remove" },
      { key = "r",                            action = "rename" },
      { key = "<C-r>",                        action = "full_rename" },
      { key = "x",                            action = "cut" },
      { key = "c",                            action = "copy" },
      { key = "p",                            action = "paste" },
      { key = "y",                            action = "copy_name" },
      { key = "gy",                           action = "copy_path" },
      { key = "Y",                            action = "copy_absolute_path" },
      { key = "[c",                           action = "prev_git_item" },
      { key = "]c",                           action = "next_git_item" },
      { key = "-",                            action = "dir_up" },
      { key = "q",                            action = "close" },
      { key = "?",                            action = "toggle_help" },
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
                }
        }
}
map("n", "<C-e>", [[<cmd>NvimTreeToggle<CR>]], opt)


--
-- #gitsigns
--
require('gitsigns').setup {
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  keymaps = {
    -- Default keymap options
    noremap = true,

    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},
    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},

    ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
    ['v <leader>hs'] = ':Gitsigns stage_hunk<CR>',
    ['n <leader>hu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
    ['n <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',
    ['v <leader>hr'] = ':Gitsigns reset_hunk<CR>',
    ['n <leader>hR'] = '<cmd>Gitsigns reset_buffer<CR>',
    ['n <leader>hp'] = '<cmd>Gitsigns preview_hunk<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
    ['n <leader>hS'] = '<cmd>Gitsigns stage_buffer<CR>',
    ['n <leader>hU'] = '<cmd>Gitsigns reset_buffer_index<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
    ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>'
  },
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter_opts = {
    relative_time = false
  },
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
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
}


--
-- #lazygit
--
vim.g.lazygit_floating_window_use_plenary = 1,
map("n", "<LEADER>gg", [[<cmd>LazyGit<CR>]], opt)


--
-- #lspconfig
--
local lspconfig = require('lspconfig')
local on_attach = function(_, bufnr)
  map("n", "gD", [[<cmd>lua vim.lsp.buf.declaration()<CR>]], opt)
  map("n", "gd", [[<cmd>lua vim.lsp.buf.definition()<CR>]], opt)
  map("n", "gt", [[<cmd>lua vim.lsp.buf.type_definition()<CR>]], opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  map("n", "<LEADER>wa", [[<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>]], opt)
  map("n", "<LEADER>wl", [[<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>]], opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<LEADER>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<LEADER>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()']]
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'bashls', 'clangd', 'cmake', 'gopls', 'html', 'jsonls', 'pyright', 'texlab' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    single_file_support = true
  }
end

-- lua
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.sumneko_lua.setup {
  cmd = { "/usr//local/lua-language-server/bin/lua-language-server" },
    on_attach = on_attach,
    capabilities = capabilities,
}


--
-- #lsp_signature
--
require "lsp_signature".setup()


--
-- #lightbulb
--
vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]


--
-- #cmp
--
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require 'luasnip'
local cmp = require 'cmp'
local lspkind = require('lspkind')


cmp.setup {
  snippet = {
    expand = function(args)
       require('luasnip').lsp_expand(args.body)
    end,
  },
  sources = {
    { name = 'nvim_lsp', priority = 99 },
    { name = 'luasnip', priority = 90 },
    { name = 'nvim_lua', priority = 50 },
    { name = 'buffer', priority = 10 },
    { name = 'path', priority = 10 },
    { name = 'dictionary', keyword_length = 2, priority = 1 },
  },

  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-c>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
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
    ['<S-Tab>'] = cmp.mapping(function(fallback)
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
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function (entry, vim_item)
        local lspkind_icons = {
                    Text = "",
                    Method = "",
                    Function = "",
                    Constructor = "",
                    Field = "",
                    Variable = "",
                    Class = "ﴯ",
                    Interface = "",
                    Module = "",
                    Property = "ﰠ",
                    Unit = "",
                    Value = "",
                    Enum = "",
                    Keyword = "",
                    Snippet = "",
                    Color = "",
                    File = "",
                    Reference = "",
                    Folder = "",
                    EnumMember = "",
                    Constant = "",
                    Struct = "",
                    Event = "",
                    Operator = "",
                    TypeParameter = ""
                }
		vim_item.kind = string.format("%s %s",
                            lspkind_icons[vim_item.kind],
                            vim_item.kind)
		vim_item.menu = ({
                    buffer = "[BUF]",
                    nvim_lsp = "[LSP]",
                    nvim_lua = "[LUA]",
                    path = "[PATH]",
                    luasnip = "[SNIP]",
					dictionary = "[DIC]"
                })[entry.source.name]

        return vim_item
      end
    })
  }
}

require("luasnip.loaders.from_vscode").load()

-- Dictionary
require("cmp_dictionary").setup({
    dic = {
        ["*"] = { vim.fn.stdpath "config" .. "/dict/english.dic", vim.fn.stdpath "config" .. "/dict/deutsch.dic"},
    },
})


--
-- #lspsaga
--
local lspsaga = require 'lspsaga'
lspsaga.setup { -- defaults ...
  debug = false,
  use_saga_diagnostic_sign = true,
  -- diagnostic sign
  error_sign = "",
  warn_sign = "",
  hint_sign = "",
  infor_sign = "",
  diagnostic_header_icon = "   ",
  -- code action title icon
  code_action_icon = " ",
  code_action_prompt = {
    enable = true,
    sign = true,
    sign_priority = 40,
    virtual_text = true,
  },
  finder_definition_icon = "  ",
  finder_reference_icon = "  ",
  max_preview_lines = 10,
  finder_action_keys = {
    open = "o",
    vsplit = "v",
    split = "x",
    quit = "q",
    scroll_down = "<C-j>",
    scroll_up = "<C-k>",
  },
  code_action_keys = {
    quit = "<C-e>",
    exec = "<CR>",
  },
  rename_action_keys = {
    quit = "<C-e>",
    exec = "<CR>",
  },
  definition_preview_icon = "  ",
  border_style = "single",
  rename_prompt_prefix = "➤",
  server_filetype_map = {},
  diagnostic_prefix_format = "%d. ",
}

--- In lsp attach function
-- map( "n", "gp", "<cmd>Lspsaga preview_definition<CR>", opt)
map( "n", "gp", "<cmd>Lspsaga lsp_finder<CR>", opt)
map( "n", "<LEADER>rn", "<cmd>Lspsaga rename<CR>", opt)
map( "n", "<LEADER>a", "<cmd>Lspsaga code_action<CR>", opt)
map( "x", "<LEADER>a", ":<c-u>Lspsaga range_code_action<CR>", opt)
map( "n", "K",  "<cmd>Lspsaga hover_doc<CR>", opt)
map( "n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opt)
map( "n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opt)
map( "n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opt)
map( "n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opt)
