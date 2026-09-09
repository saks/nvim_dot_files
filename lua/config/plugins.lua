-- Airline reads these at init. tabline shows buffers, not tab pages.
vim.g.airline_powerline_fonts = 1
vim.g.airline_detect_modified = 1
vim.g.airline_detect_paste = 1
vim.g.airline_theme = 'dark'
vim.g.airline_extensions = { 'branch', 'whitespace', 'tabline', 'nvimlsp' }
vim.g['airline#parts#ffenc#skip_expected_string'] = 'utf-8[unix]'
vim.g['airline#extensions#tabline#buffer_idx_mode'] = 1
vim.g['airline#extensions#tabline#show_tabs'] = 0
vim.g['airline#extensions#tabline#show_buffers'] = 1
vim.g['airline#extensions#tabline#ignore_bufadd_pat'] =
  '!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

-- Stay in buffers. Default fzf ctrl-t opened a new tab page.
vim.g.fzf_action = {
  ['ctrl-s'] = 'split',
  ['ctrl-v'] = 'vsplit',
}

-- :Files lists via rg. Ctrl-G drops gitignored files; Ctrl-A includes them.
local rg_files = "rg --files --hidden --glob '!.git'"
local rg_files_all = "rg --files --hidden --no-ignore --glob '!.git'"
vim.env.FZF_DEFAULT_COMMAND = rg_files
vim.g.fzf_vim = {
  files_options = {
    '--header', 'CTRL-G: hide gitignored  CTRL-A: all files',
    '--bind', 'ctrl-g:reload(' .. rg_files .. ')',
    '--bind', 'ctrl-a:reload(' .. rg_files_all .. ')',
  },
}

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add({
  gh('nvim-treesitter/nvim-treesitter'),
  gh('neovim/nvim-lspconfig'),
  gh('ray-x/lsp_signature.nvim'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-path'),
  gh('hrsh7th/nvim-cmp'),
  -- nvim-cmp still requires a snippet expander
  gh('hrsh7th/cmp-vsnip'),
  gh('hrsh7th/vim-vsnip'),
  gh('tpope/vim-rails'),
  gh('bling/vim-airline'),
  gh('godlygeek/tabular'),
  gh('junegunn/fzf'),
  gh('junegunn/fzf.vim'),
  gh('nvim-lua/plenary.nvim'),
  gh('lewis6991/gitsigns.nvim'),
  gh('tpope/vim-endwise'),
  gh('tpope/vim-fugitive'),
  gh('tpope/vim-repeat'),
  gh('tpope/vim-surround'),
  gh('tpope/vim-unimpaired'),
  gh('AndrewRadev/splitjoin.vim'),
  gh('ggml-org/llama.vim'),
})

-- Plugins left on disk from the old pack list are inactive after this add();
-- delete them so they do not linger in nvim-pack-lock.json.
vim.schedule(function()
  local ok, names = pcall(function()
    return vim
      .iter(vim.pack.get(nil, { info = false }))
      :filter(function(p)
        return not p.active
      end)
      :map(function(p)
        return p.spec.name
      end)
      :totable()
  end)
  if ok and names and #names > 0 then
    pcall(vim.pack.del, names)
  end
end)

require('gitsigns').setup({
  signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

-- Dropped (treesitter / built-ins / unused). Listed so the old setup is
-- recoverable from git history:
--   ctrlpvim/ctrlp.vim              -- <C-p> is now :Files
--   pangloss/vim-javascript
--   mxw/vim-jsx                     -- not doing React
--   cespare/vim-toml
--   ekalinin/Dockerfile.vim
--   rust-lang/rust.vim              -- rust-analyzer formats; treesitter highlights
--   editorconfig/editorconfig-vim   -- Neovim built-in
--   nvim-lua/lsp-status.nvim        -- vim.lsp.status() / airline nvimlsp
--   yosiat/oceanic-next-vim
--   github/copilot.vim
--   prettier/vim-prettier
--   junegunn/vim-plug
