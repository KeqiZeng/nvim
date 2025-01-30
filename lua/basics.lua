local g = vim.g

-- Disable some providers
g.loaded_node_provider = 0
g.loaded_python_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable markdown recommended style
g.markdown_recommended_style = 0

local opt = vim.opt

-- Enable mouse support
opt.mouse = "a"

-- Enable syntax
opt.syntax = "on"

-- Enable filetype detection
opt.filetype = "on"

-- Show line number
opt.number = true

-- Show relative number by default
opt.relativenumber = true

-- Highlight cursorline
opt.cursorline = true

-- Disable the default ruler (which shows the cursor position in statusline)
opt.ruler = false

-- Enable scrolloff
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Show sign column
opt.signcolumn = "yes"

-- Disable conceal
opt.conceallevel = 0

-- Sync with system clipboard if not in ssh session
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

-- Enable true color support
opt.termguicolors = true

-- Don't show mode since we have a statusline
opt.showmode = false

-- Set timeout length on key trigger
opt.timeout = true
opt.timeoutlen = 500

-- Show trailing whitespace
opt.list = true
-- opt.listchars = "trail:▫"
opt.listchars = "trail:▫,tab:  "

-- Don't wrap lines
opt.wrap = false

-- Interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 500

-- Confirm to save changes before exiting modified buffer
opt.confirm = true

-- Preview incremental substitute in current window
opt.inccommand = "nosplit"

-- Global statusline
opt.laststatus = 3

-- DON'T autochange directory to the one where the file is
opt.autochdir = false

-- Autowrite file when switching buffers
opt.autowrite = true

-- Autoread file when it is changed outside
opt.autoread = true

-- Completion options
-- menu:     use popup menu to show possible completions
-- menuone:  show menu even when there is only one match
-- noselect: do not auto-select first match
-- preview:  show extra information about the completion
opt.completeopt = "menu,menuone,noselect,preview"

-- Indent
opt.autoindent = true  -- copy indent from current line when starting a new line
opt.smartindent = true -- add extra indent when it makes sense (e.g. after '{')
opt.shiftround = true  -- round indent to multiple of shiftwidth
opt.shiftwidth = 4     -- size of an indent (used for >> and << commands)

-- Tab
opt.expandtab = true -- use spaces instead of tabs
opt.tabstop = 4      -- number of spaces that a <Tab> counts for
opt.softtabstop = 4  -- number of spaces that a <Tab> counts for while performing editing operations
opt.smarttab = true  -- <Tab> in front of a line inserts blanks according to shiftwidth

-- Search
opt.ignorecase = true -- ignore case in search patterns
opt.smartcase = true  -- override ignorecase if search pattern contains uppercase
opt.hlsearch = true   -- highlight all matches on previous search pattern
opt.incsearch = true  -- show partial matches while typing search pattern

-- Split windows
opt.splitbelow = true    -- put new windows below current
opt.splitkeep = "screen" -- keep the position of the context on screen
opt.splitright = true    -- put new windows right of current
opt.winminwidth = 5      -- minimum width of a window

-- Fold
opt.foldenable = true     -- enable folding
opt.foldlevel = 99        -- set high fold level to keep folds open by default
opt.foldlevelstart = 99   -- start editing with all folds open
opt.foldmethod = "indent" -- use indentation for folding (alternatives: marker, syntax, expr)

-- Undo
opt.undofile = true    -- enable persistent undo (save undo history to a file)
opt.undolevels = 10000 -- maximum number of changes that can be undone

-- Spell
opt.spell = true
opt.spelllang = { "en_us" }
