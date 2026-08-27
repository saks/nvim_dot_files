local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
})

-- Compact airline chip: loading / ready / problem. No progress text.
local progress = {} ---@type table<integer, table<string|integer, boolean>>
local health = {} ---@type table<integer, string>
-- ASCII: Hack renders braille spinners as specks in the statusline.
local SPINNER = { '|', '/', '-', '\\' }
local spinner_idx = 1
local spinner_timer = vim.uv.new_timer()
local spinner_on = false

local function redraw_status()
  pcall(vim.cmd.redrawstatus)
end

local function client_busy(id)
  local tokens = progress[id]
  return tokens ~= nil and next(tokens) ~= nil
end

---@param bufnr integer
---@return 'loading'|'ready'|'problem'|nil
local function buf_lsp_state(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    return nil
  end
  for _, client in ipairs(clients) do
    local h = health[client.id]
    if h == 'error' or h == 'warn' then
      return 'problem'
    end
  end
  for _, client in ipairs(clients) do
    if client_busy(client.id) then
      return 'loading'
    end
  end
  return 'ready'
end

---@param bufnr integer
---@return boolean
local function buf_has_rust(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == 'rust_analyzer' then
      return true
    end
  end
  return false
end

local function stop_spinner()
  if spinner_on then
    spinner_timer:stop()
    spinner_on = false
  end
end

local function start_spinner()
  if spinner_on then
    return
  end
  spinner_on = true
  spinner_timer:start(
    0,
    120,
    vim.schedule_wrap(function()
      if buf_lsp_state(vim.api.nvim_get_current_buf()) ~= 'loading' then
        stop_spinner()
        redraw_status()
        return
      end
      spinner_idx = spinner_idx % #SPINNER + 1
      redraw_status()
    end)
  )
end

local function sync_spinner()
  if buf_lsp_state(vim.api.nvim_get_current_buf()) == 'loading' then
    start_spinner()
  else
    stop_spinner()
    vim.schedule(redraw_status)
  end
end

local function set_health(id, kind)
  local prev = health[id]
  health[id] = kind
  local bad = kind == 'error' or kind == 'warn'
  local was_bad = prev == 'error' or prev == 'warn'
  if bad and not was_bad then
    local client = vim.lsp.get_client_by_id(id)
    vim.notify((client and client.name or 'LSP') .. ' ' .. kind, vim.log.levels.ERROR)
  end
  vim.schedule(sync_spinner)
end

vim.api.nvim_set_hl(0, 'LspStatusLoading', { fg = '#CC7833', default = true })
vim.api.nvim_set_hl(0, 'LspStatusReady', { fg = '#A5C261', default = true })
vim.api.nvim_set_hl(0, 'LspStatusError', { fg = '#FFFFFF', bg = '#990000', bold = true, default = true })

vim.lsp.config('rust_analyzer', {
  capabilities = {
    experimental = {
      serverStatusNotification = true,
    },
  },
  handlers = {
    -- Must be registered on the config (not LspAttach) or we miss the
    -- quiescent notification that rust-analyzer sends during startup.
    ['experimental/serverStatus'] = function(_, result, ctx)
      if result and ctx and ctx.client_id then
        if result.health == 'error' then
          set_health(ctx.client_id, 'error')
        elseif result.health == 'warning' then
          set_health(ctx.client_id, 'warn')
        else
          set_health(ctx.client_id, 'ok')
        end
      end
    end,
  },
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
        features = 'all',
        allFeatures = true,
        buildScripts = { enable = true },
      },
      completion = {
        postfix = { enable = false },
        limit = 20,
      },
    },
  },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})

local servers = {}
local bins = {
  rust_analyzer = 'rust-analyzer',
  solargraph = 'solargraph',
  bashls = 'bash-language-server',
  lua_ls = 'lua-language-server',
}
for name, bin in pairs(bins) do
  if vim.fn.executable(bin) == 1 then
    servers[#servers + 1] = name
  end
end
if #servers > 0 then
  vim.lsp.enable(servers)
end

vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('saksmlz_lsp_progress', { clear = true }),
  callback = function(ev)
    local id = ev.data.client_id
    local params = ev.data.params
    if not id or not params then
      return
    end
    local value = params.value
    if type(value) ~= 'table' then
      return
    end
    progress[id] = progress[id] or {}
    if value.kind == 'end' then
      progress[id][params.token] = nil
    else
      progress[id][params.token] = true
    end
    vim.schedule(sync_spinner)
  end,
})

function _G.AirlineLspStatus()
  local bufnr = vim.api.nvim_get_current_buf()
  local state = buf_lsp_state(bufnr)
  if not state then
    return ''
  end
  local mark = buf_has_rust(bufnr) and ' 🦀' or ' ●'
  local text
  local hl
  if state == 'loading' then
    text = mark .. ' ' .. SPINNER[spinner_idx]
    hl = 'LspStatusLoading'
  elseif state == 'problem' then
    text = ' ⚠ ERROR '
    hl = 'LspStatusError'
  else
    text = mark .. ' ✓'
    hl = 'LspStatusReady'
  end
  return '%#' .. hl .. '#' .. text .. '%*'
end

vim.g.airline_section_warning = '%{%v:lua.AirlineLspStatus()%}'
vim.api.nvim_create_autocmd('User', {
  pattern = 'AirlineAfterInit',
  callback = function()
    vim.g.airline_section_warning = '%{%v:lua.AirlineLspStatus()%}'
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('saksmlz_lsp', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    vim.schedule(sync_spinner)

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    map('n', 'gD', vim.lsp.buf.declaration, 'LSP declaration')
    map('n', 'gd', vim.lsp.buf.definition, 'LSP definition')
    map('n', 'K', vim.lsp.buf.hover, 'LSP hover')
    map('n', 'gi', vim.lsp.buf.implementation, 'LSP implementation')
    map('n', '<C-k>', vim.lsp.buf.signature_help, 'LSP signature')
    map('n', '<space>D', vim.lsp.buf.type_definition, 'LSP type definition')
    map('n', '<space>r', vim.lsp.buf.rename, 'LSP rename')
    map('n', '<space>a', vim.lsp.buf.code_action, 'LSP code action')
    map('n', 'gr', vim.lsp.buf.references, 'LSP references')
    map('n', '<space>e', vim.diagnostic.open_float, 'Diagnostics float')
    map('n', '[d', function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, 'Prev diagnostic')
    map('n', ']d', function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, 'Next diagnostic')
    map('n', '<space>q', vim.diagnostic.setloclist, 'Diagnostics loclist')
    map('n', '<space>f', function()
      vim.lsp.buf.format({ async = true })
    end, 'LSP format')

    require('lsp_signature').on_attach({
      doc_lines = 0,
      handler_opts = { border = 'none' },
    }, bufnr)
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = vim.api.nvim_create_augroup('saksmlz_lsp_detach', { clear = true }),
  callback = function(args)
    local id = args.data.client_id
    progress[id] = nil
    health[id] = nil
    vim.schedule(sync_spinner)
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})

-- Treesitter paints immediately; rust-analyzer semantic tokens arrive later and
-- recolor `use` lists (types stay red, functions snap to yellow). Keep TS only.
vim.lsp.semantic_tokens.enable(false)
