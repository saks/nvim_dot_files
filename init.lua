-- llama.vim reads this at plugin load
vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.g.llama_config = { show_info = 0 }

-- GUI / desktop launches often miss shell PATH. rust-analyzer lives in ~/.cargo/bin.
do
  local extras = {
    vim.env.HOME .. '/.cargo/bin',
    vim.env.HOME .. '/.fzf/bin',
    vim.env.HOME .. '/.local/bin',
    '/opt/homebrew/bin',
  }
  for _, dir in ipairs(extras) do
    if vim.fn.isdirectory(dir) == 1 and not vim.env.PATH:find(dir, 1, true) then
      vim.env.PATH = dir .. ':' .. vim.env.PATH
    end
  end
end

require('config.plugins')
require('config.options')
require('config.completion')
require('config.lsp')
require('config.treesitter')
require('config.keymaps')
require('config.autocmds')
