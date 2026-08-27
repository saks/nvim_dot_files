-- Parsers for languages this config actually edits. Highlighting is the cheap
-- win over regex syntax plugins (rust.vim / vim-javascript were the slow ones).
local langs = {
  'bash',
  'c',
  'css',
  'dockerfile',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'ruby',
  'rust',
  'scss',
  'toml',
  'vim',
  'vimdoc',
  'yaml',
}

require('nvim-treesitter').install(langs)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('saksmlz_treesitter', { clear = true }),
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if ok then
      -- Avoid running regex syntax in parallel with treesitter.
      vim.bo[args.buf].syntax = 'off'
    end
  end,
})
