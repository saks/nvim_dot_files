local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
})

-- Progress + readiness for airline (replaces lsp-status.nvim).
local progress = {} ---@type table<integer, table<string|integer, string>>
local health = {} ---@type table<integer, string>

local function redraw_status()
  vim.schedule(function()
    pcall(vim.cmd.redrawstatus)
  end)
end

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
          health[ctx.client_id] = 'error'
        elseif result.health == 'warning' then
          health[ctx.client_id] = 'warn'
        else
          health[ctx.client_id] = 'ok'
        end
        redraw_status()
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
      local msg = value.title or 'LSP'
      if value.percentage then
        msg = string.format('%s %d%%', msg, value.percentage)
      elseif type(value.message) == 'string' and #value.message > 0 and #value.message < 40 then
        msg = msg .. ': ' .. value.message
      end
      progress[id][params.token] = msg
    end
    redraw_status()
  end,
})

function _G.AirlineLspStatus()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ''
  end
  local bits = {}
  for _, client in ipairs(clients) do
    local msgs = progress[client.id]
    if msgs then
      for _, msg in pairs(msgs) do
        bits[#bits + 1] = msg
      end
    end
  end
  if #bits > 0 then
    return table.concat(bits, ' | ')
  end
  local names = {}
  for _, client in ipairs(clients) do
    local tag = health[client.id]
    if tag == 'error' then
      names[#names + 1] = client.name .. ' error'
    elseif tag == 'warn' then
      names[#names + 1] = client.name .. ' warn'
    else
      names[#names + 1] = client.name .. ' Ok'
    end
  end
  return table.concat(names, ',')
end

vim.cmd([[
  function! AirlineLspStatus() abort
    return v:lua.AirlineLspStatus()
  endfunction
]])
vim.fn['airline#parts#define_function']('lsp_status', 'AirlineLspStatus')
vim.g.airline_section_warning = vim.fn['airline#section#create_right']({ 'lsp_status' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('saksmlz_lsp', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    redraw_status()

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
    redraw_status()
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
})
