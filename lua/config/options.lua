local state = vim.fn.stdpath('state')
local undo = state .. '/undo'
local swap = state .. '/swap'
vim.fn.mkdir(undo, 'p')
vim.fn.mkdir(swap, 'p')

vim.opt.undofile = true
vim.opt.undodir = undo
vim.opt.swapfile = true
vim.opt.directory = swap .. '//'
vim.opt.backup = false
vim.opt.writebackup = true
vim.opt.history = 1000

vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.encoding = 'utf-8'
vim.opt.scrolloff = 3
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.hidden = true
vim.opt.wildmenu = true
vim.opt.wildmode = 'list:longest'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.previewheight = 5
vim.opt.clipboard:append('unnamedplus')
vim.opt.listchars = { tab = '▸ ', eol = '¬', trail = '.', extends = '>', precedes = '<' }
vim.opt.visualbell = false
vim.opt.errorbells = false
vim.opt.laststatus = 2
vim.opt.cursorline = true
vim.opt.ruler = true
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.number = true
vim.opt.numberwidth = 5
vim.opt.timeoutlen = 1000
vim.opt.signcolumn = 'yes'
vim.opt.completeopt = { 'menu', 'menuone', 'popup' }

-- Global conceal made JSON quotes (and similar) disappear even on the cursor.
vim.opt.conceallevel = 0
vim.opt.concealcursor = ''

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.textwidth = 99
vim.opt.colorcolumn = '100'
-- Keep gq / comment formatting / numbered lists. Do not auto-wrap at textwidth.
vim.opt.formatoptions = 'cqjln'

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true
vim.opt.incsearch = true
vim.opt.inccommand = 'nosplit'
vim.opt.showmatch = true
vim.opt.hlsearch = true
vim.opt.matchtime = 5
vim.opt.wildignore:append({
  '*.bak',
  '*~',
  '*.tmp',
  '*.backup',
  '*swp',
  '*.o',
  '*.obj',
  '.git',
  '*.rbc',
  '*.png',
  '*.xpi',
  '*.swf',
  '*.woff',
  '*.eot',
  '*.svg',
  '*.ttf',
  '*.otf',
  '*/tmp/*',
  '*.so',
  '*.zip',
})

-- Reuse an already-open buffer instead of a new tab page (quickfix, :sbuffer, …).
vim.opt.switchbuf = 'useopen'

vim.opt.winborder = 'rounded'
vim.opt.winblend = 0

if vim.fn.has('gui_running') == 1 then
  vim.opt.guioptions = 'aiA'
  vim.opt.mouse = 'a'
  vim.opt.mousehide = true
  vim.opt.guifont = 'Hack 13'
  vim.opt.linespace = 1
end

vim.cmd.colorscheme('railscasts3')

vim.api.nvim_set_hl(0, 'NonText', { fg = '#4a4a59' })
vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#4a4a59' })
vim.api.nvim_set_hl(0, 'TermCursorNC', { fg = '#fdf6e3', bg = '#93a1a1' })
