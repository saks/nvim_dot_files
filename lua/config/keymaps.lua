-- nvim 0.11 maps insert <C-s> to signature help. Save in every mode instead.
pcall(vim.keymap.del, 'i', '<C-s>')
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<Cmd>write<CR>', { desc = 'Save' })

vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('v', 'jk', '<Esc>')
vim.keymap.set('t', 'jk', '<C-\\><C-n>')
if not vim.g.vscode then
  vim.keymap.set('i', '<Esc>', '<Nop>')
  vim.keymap.set('v', '<Esc>', '<Nop>')
end

vim.keymap.set('n', 'cp', function()
  vim.fn.setreg('+', vim.fn.expand('%'))
  vim.notify('copied!')
end, { desc = 'Copy relative path' })

vim.keymap.set('n', '<leader>l', '<Cmd>set list!<CR>', { desc = 'Toggle listchars' })
vim.keymap.set('', '<C-Space>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
vim.keymap.set('c', '<S-Insert>', '<C-R>+')
vim.keymap.set('v', '<C-c>', '"+y')
vim.keymap.set('v', '<LeftRelease>', '"*ygv')

-- Built-in gc/gcc. Bind both chords: macOS Option composing (÷) and Linux Alt (M-/).
for _, lhs in ipairs({ '÷', '<M-/>' }) do
  vim.keymap.set('n', lhs, 'gcc', { remap = true, desc = 'Toggle comment line' })
  vim.keymap.set('x', lhs, 'gc', { remap = true, desc = 'Toggle comment' })
end

-- Indent / bubble: same physical keys on Mac (Option → unicode) and Linux (Alt → Meta).
local function map_all(mode, keys, rhs, opts)
  for _, lhs in ipairs(keys) do
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map_all('n', { '˙', '<M-h>', '<M-Left>' }, '<<')
map_all('n', { '¬', '<M-l>', '<M-Right>' }, '>>')
map_all('v', { '˙', '<M-h>', '<M-Left>' }, '<gv')
map_all('v', { '¬', '<M-l>', '<M-Right>' }, '>gv')
map_all('n', { '˚', '<M-k>', '<M-Up>' }, '[e', { remap = true })
map_all('n', { '∆', '<M-j>', '<M-Down>' }, ']e', { remap = true })
map_all('v', { '˚', '<M-k>', '<M-Up>' }, '[egv', { remap = true })
map_all('v', { '∆', '<M-j>', '<M-Down>' }, ']egv', { remap = true })

-- CtrlP's default <C-p> was the only remaining CtrlP binding; send it to fzf.
vim.keymap.set('n', '<C-p>', '<Cmd>Files<CR>', { desc = 'Find files' })
vim.keymap.set('n', 'ø', '<Cmd>Files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<M-o>', '<Cmd>Files<CR>', { desc = 'Find files' })
vim.keymap.set({ 'n', 'v' }, '®', '<Cmd>RgCword<CR>', { silent = true, desc = 'Rg word' })
vim.keymap.set({ 'n', 'v' }, '<M-r>', '<Cmd>RgCword<CR>', { silent = true, desc = 'Rg word' })
vim.keymap.set({ 'n', 'v' }, '‰', '<Cmd>RgaCword<CR>', { silent = true, desc = 'Rg word all' })
vim.keymap.set({ 'n', 'v' }, '<S-M-r>', '<Cmd>RgaCword<CR>', { silent = true, desc = 'Rg word all' })

local function airline_tab(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, { remap = true })
end

airline_tab('≤', '<Plug>AirlineSelectPrevTab')
airline_tab('<M-,>', '<Plug>AirlineSelectPrevTab')
airline_tab('≥', '<Plug>AirlineSelectNextTab')
airline_tab('<M-.>', '<Plug>AirlineSelectNextTab')
vim.keymap.set('t', '≤', '<C-\\><C-N><Plug>AirlineSelectPrevTab', { remap = true })
vim.keymap.set('t', '<M-,>', '<C-\\><C-N><Plug>AirlineSelectPrevTab', { remap = true })
vim.keymap.set('t', '≥', '<C-\\><C-N><Plug>AirlineSelectNextTab', { remap = true })
vim.keymap.set('t', '<M-.>', '<C-\\><C-N><Plug>AirlineSelectNextTab', { remap = true })

local mac_tabs = { '¡', '™', '£', '¢', '∞', '§', '¶', '•', 'ª' }
for i, lhs in ipairs(mac_tabs) do
  airline_tab(lhs, '<Plug>AirlineSelectTab' .. i)
  airline_tab('<M-' .. i .. '>', '<Plug>AirlineSelectTab' .. i)
end

-- Expand snippet on Ctrl-K; otherwise keep insert-mode Ctrl-K (digraph).
vim.keymap.set('i', '<C-k>', function()
  if vim.fn['vsnip#expandable']() == 1 then
    return '<Plug>(vsnip-expand)'
  end
  return '<C-k>'
end, { expr = true, remap = true })
vim.keymap.set('s', '<C-k>', function()
  if vim.fn['vsnip#expandable']() == 1 then
    return '<Plug>(vsnip-expand)'
  end
  return '<C-k>'
end, { expr = true, remap = true })

local function rg_grep(args, extra)
  extra = extra or ''
  local preview = args.bang and vim.fn['fzf#vim#with_preview']('up:60%')
    or vim.fn['fzf#vim#with_preview']('right:50%:hidden', '?')
  vim.fn['fzf#vim#grep'](
    'rg --column --line-number --no-heading --color=always ' .. extra .. args.pattern,
    1,
    preview,
    args.bang
  )
end

vim.api.nvim_create_user_command('RgCword', function(opts)
  rg_grep({ bang = opts.bang, pattern = vim.fn.shellescape(vim.fn.expand('<cword>')) }, '--max-count=1 ')
end, { bang = true, nargs = '*' })

vim.api.nvim_create_user_command('RgaCword', function(opts)
  rg_grep({ bang = opts.bang, pattern = vim.fn.shellescape(vim.fn.expand('<cword>')) })
end, { bang = true, nargs = '*' })

vim.api.nvim_create_user_command('Rg', function(opts)
  rg_grep({
    bang = opts.bang,
    pattern = vim.fn.shellescape(opts.args),
  }, '--max-count=1 --smart-case ')
end, { bang = true, nargs = '*' })

vim.api.nvim_create_user_command('Rga', function(opts)
  rg_grep({
    bang = opts.bang,
    pattern = vim.fn.shellescape(opts.args),
  }, '--smart-case ')
end, { bang = true, nargs = '*' })
