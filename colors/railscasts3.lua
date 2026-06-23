-- railscasts.lua - Modern Lua port of your railscasts colorscheme
-- Based on your original vim file: https://github.com/saks/nvim_dot_files/blob/nvim_lsp/colors/railscasts.vim

local colors = {
  bg          = "#2B2B2B",
  fg          = "#E6E1DC",
  cursor      = "#FFFFFF",
  cursorline  = "#333435",
  selection   = "#5A647E",
  linenr      = "#777777",
  statusline  = "#414243",
  comment     = "#BC9458",
  constant    = "#6D9CBE",
  string      = "#A5C261",
  keyword     = "#CC7833",
  func        = "#FFC66D",
  type        = "#DA4939",
  delimiter   = "#519F50",
  error       = "#990000",
  warn        = "#E0E000",
}

vim.cmd.highlight("clear")
vim.o.background = "dark"
vim.g.colors_name = "railscasts"

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Base
hl("Normal",      { fg = colors.fg, bg = colors.bg })
hl("Cursor",      { bg = colors.cursor })
hl("CursorLine",  { bg = colors.cursorline })
hl("Search",      { bg = colors.selection })
hl("Visual",      { bg = colors.selection })
hl("LineNr",      { fg = colors.linenr, bg = colors.cursorline })
hl("CursorLineNr",{ fg = colors.fg, bold = true })
hl("StatusLine",  { bg = colors.statusline })
hl("StatusLineNC",{ bg = colors.statusline })
hl("VertSplit",   { bg = colors.statusline })
hl("ColorColumn", { bg = "#2d2d2d" })

-- Folds, Misc
hl("Folded",      { fg = "#F6F3E8", bg = "#444444" })
hl("Directory",   { fg = colors.string })

-- Popup Menu
hl("Pmenu",       { fg = "#F6F3E8", bg = "#444444" })
hl("PmenuSel",    { fg = "#000000", bg = colors.string })
hl("PmenuSbar",   { bg = colors.selection })
hl("PmenuThumb",  { bg = "#AAAAAA" })

-- Syntax
hl("Comment",     { fg = colors.comment, italic = true })
hl("Constant",    { fg = colors.constant })
hl("String",      { fg = colors.string })
hl("Character",   { fg = colors.string })
hl("Number",      { fg = colors.string })
hl("Boolean",     { fg = colors.constant })
hl("Float",       { fg = colors.string })

hl("Identifier",  { fg = colors.keyword })
hl("Function",    { fg = colors.func })

hl("Statement",   { fg = colors.keyword })
hl("Keyword",     { fg = colors.keyword })
hl("Operator",    { fg = colors.delimiter })
hl("PreProc",     { fg = colors.keyword })
hl("Define",      { fg = colors.keyword })
hl("Include",     { fg = colors.keyword })
hl("Macro",       { fg = colors.keyword })
hl("PreCondit",   { fg = colors.keyword })

hl("Type",        { fg = colors.type })
hl("Structure",   { fg = colors.type })
hl("StorageClass",{ fg = colors.keyword })

hl("Delimiter",   { fg = colors.delimiter })
hl("Special",     { fg = colors.delimiter })
hl("Title",       { fg = "#FFFFFF", bold = true })
hl("Todo",        { fg = "#FF0000", bg = colors.warn, italic = true })
hl("Error",       { fg = "#FFFFFF", bg = colors.error })

-- Treesitter / Modern groups
hl("@markup.heading",         { fg = colors.keyword, bold = true })
hl("@markup.heading.1",       { fg = colors.keyword, bold = true })
hl("@markup.heading.2",       { fg = colors.func, bold = true })
hl("@markup.strong",          { fg = colors.keyword, bold = true })
hl("@markup.italic",          { fg = colors.constant, italic = true })
hl("@markup.code",            { fg = colors.string, bg = "#3A3A3A" })
hl("@markup.link",            { fg = colors.constant, underline = true })
hl("@markup.list",            { fg = colors.comment })

hl("@function",               { fg = colors.func })
hl("@keyword",                { fg = colors.keyword })
hl("@string",                 { fg = colors.string })
hl("@comment",                { fg = colors.comment, italic = true })
hl("@type",                   { fg = colors.type })
hl("@constant",               { fg = colors.constant })
hl("@variable",               { fg = colors.fg })
hl("@operator",               { fg = colors.delimiter })

-- LSP / Diagnostics
hl("DiagnosticError",         { fg = "#FF0000" })
hl("DiagnosticWarn",          { fg = "#E0E000" })
hl("DiagnosticInfo",          { fg = "#6D9CBE" })
hl("DiagnosticHint",          { fg = "#A5C261" })

-- Floating windows
hl("NormalFloat",             { fg = colors.fg, bg = colors.bg })
hl("FloatBorder",             { fg = "#777777", bg = colors.bg })

-- Diff
hl("DiffAdd",                 { fg = colors.fg, bg = "#144212" })
hl("DiffDelete",              { fg = colors.fg, bg = "#660000" })
hl("DiffChange",              { bg = "#2B2B2B" })  -- adjust if needed

print("railscasts colorscheme loaded successfully!")
