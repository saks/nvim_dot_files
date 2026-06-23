-- plugins
local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  gh('neovim/nvim-lspconfig'),
  gh('ray-x/lsp_signature.nvim'),
  gh('nvim-lua/lsp-status.nvim'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-path'),
  gh('hrsh7th/nvim-cmp'),

  -- Only because nvim-cmp _requires_ snippets
  gh('hrsh7th/cmp-vsnip'),
  gh('hrsh7th/vim-vsnip'),

  gh('rust-lang/rust.vim'),
  gh('cespare/vim-toml'),
  gh('ctrlpvim/ctrlp.vim'),
  gh('tpope/vim-rails'),
  gh('bling/vim-airline'),
  gh('ekalinin/Dockerfile.vim'),
  gh('godlygeek/tabular'),
  gh('junegunn/fzf.vim'),

  gh('nvim-lua/plenary.nvim'), -- dependency of gitsigns
  gh('lewis6991/gitsigns.nvim'),
  gh('tpope/vim-endwise'),
  gh('tpope/vim-fugitive'),
  gh('tpope/vim-repeat'),
  gh('tpope/vim-surround'),
  gh('tpope/vim-unimpaired'),
  gh('AndrewRadev/splitjoin.vim'),
  gh('editorconfig/editorconfig-vim'),
  gh('yosiat/oceanic-next-vim'),
  gh('pangloss/vim-javascript'),
  gh('mxw/vim-jsx'),
})

-- better key mappings for comments
do
  local binding
  if vim.fn.has("macunix") == 1 then
    binding = '÷'
  elseif vim.fn.has("unix") == 1 then
    binding = '<M-/>'
  end

  local operator_rhs = function()
    return require('vim._comment').operator()
  end

  vim.keymap.set({ 'n', 'x' }, binding, operator_rhs, { expr = true, desc = 'Toggle comment' })

  local line_rhs = function()
    return require('vim._comment').operator() .. '_'
  end

  vim.keymap.set('n', binding, line_rhs, { expr = true, desc = 'Toggle comment line' })
end


--  LSP configuration
--
local lsp_status = require('lsp-status')
local cmp = require('cmp')

lsp_status.register_progress()
lsp_status.config({
  current_function = false,
  diagnostics = false,
  show_filename = false,
  indicator_errors = 'E',
  indicator_warnings = 'W',
  indicator_info = 'i',
  indicator_hint = '?',
  indicator_ok = 'Ok',
  status_symbol = '',
})

cmp.setup({
  snippet = {
    -- REQUIRED by nvim-cmp. get rid of it once we can
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- XXX: didn't work
    -- ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'path' },
    { name = 'buffer' },
  }),
  experimental = {
    ghost_text = true
  },
})

-- Enable completing paths in :
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  })
})


local xfn = function() 
  local row = vim.api.nvim_win_get_height(0) - 3
  local col = vim.api.nvim_win_get_width(0) - 40
  local config = { 
    relative = 'win', 
    row = row, 
    anchor = 'SW', 
    col = col, 
    width = 30, 
    height = 1,
  }
  vim.api.nvim_open_win(0, true, config)
end

-- Setup lspconfig.
local on_attach = function(client, bufnr)
  lsp_status.on_attach(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.jump({count=-1, float=true})<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.jump({count=1, float=true})<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.format({async=true})<CR>', opts)

  -- Get signatures (and _only_ signatures) when in argument lists.
  require('lsp_signature').on_attach({
    doc_lines = 0,
    handler_opts = {
      border = 'none'
    },
  })
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local capabilities = vim.tbl_deep_extend('keep', capabilities, require('lsp-status').capabilities)

vim.lsp.config('solargraph', {
  init_options = { formatting = true },
  filetypes = { 'ruby' },
  root_dir = require('lspconfig.util').root_pattern('Gemfile', '.git'),
})

vim.lsp.config('bashls', {})

vim.lsp.config('rust_analyzer', {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = { group = 'module' },
        prefix = 'self',
      },
      procMacro = { enable = true },
      cargo = {
        features = "all",
        allFeatures = true,
        buildScripts = { enable = true },
      },
      completion = {
        postfix = { enable = false },
        limit = 20,
      },
    },
  },
  capabilities = capabilities,
})

vim.lsp.enable({ 'rust_analyzer', 'solargraph', 'bashls' })

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = true,
})

require('gitsigns').setup {
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl = 'GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl = 'GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl = 'GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl = 'GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl = 'GitSignsChangeLn'},
  },
  numhl = false,
  linehl = false,
}
