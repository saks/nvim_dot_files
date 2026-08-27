local group = vim.api.nvim_create_augroup('saksmlz_autocommands', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 500, on_visual = true })
  end,
})

local skip_strip = {
  markdown = true,
  text = true,
  gitcommit = true,
  gitrebase = true,
  diff = true,
}

-- Format via LSP first, then strip leftover trailing space.
vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= '' then
      return
    end
    local clients = vim.lsp.get_clients({
      bufnr = buf,
      method = 'textDocument/formatting',
    })
    if #clients > 0 then
      vim.lsp.buf.format({ bufnr = buf, async = false })
    end
    if skip_strip[vim.bo[buf].filetype] then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd('keeppatterns %s/\\s\\+$//e')
    vim.fn.winrestview(view)
  end,
})

-- mkview stores cursor position and folds so they come back when you re-enter
-- a buffer. Skip scratch/temp buffers so /tmp and fugitive don't pollute viewdir.
local function real_file()
  if vim.bo.buftype ~= '' then
    return false
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    return false
  end
  if name:find('^/private/tmp') or name:find('^/tmp/') or name:find('/nvim%.[^/]+/') then
    return false
  end
  return true
end

vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufLeave' }, {
  group = group,
  callback = function()
    if real_file() then
      vim.cmd('silent! mkview')
    end
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  group = group,
  callback = function()
    if real_file() then
      vim.cmd('silent! loadview')
    end
  end,
})

vim.filetype.add({
  filename = {
    Thorfile = 'ruby',
    Berksfile = 'ruby',
  },
  extension = {
    coffee = 'coffee',
    moon = 'moon',
  },
})

local function set_indent(ft, opts)
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = ft,
    callback = function()
      for k, v in pairs(opts) do
        vim.opt_local[k] = v
      end
    end,
  })
end

set_indent({ 'html', 'css', 'ruby' }, { tabstop = 2, softtabstop = 2, shiftwidth = 2, expandtab = true })
set_indent({ 'c', 'javascript' }, { tabstop = 4, softtabstop = 4, shiftwidth = 4, expandtab = true })
set_indent('lua', { textwidth = 79, colorcolumn = '80' })
set_indent('python', {
  tabstop = 4,
  softtabstop = 4,
  shiftwidth = 4,
  textwidth = 79,
  colorcolumn = '80',
  expandtab = true,
})
set_indent('rust', { textwidth = 99, colorcolumn = '100' })
