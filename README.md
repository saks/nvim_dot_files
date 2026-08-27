# nvim config

Works on macOS and Linux. Neovim 0.12+, Lua entrypoint (`init.lua`). Plugins via `vim.pack`.

## Install

```sh
# Neovim 0.12+
# macOS: brew install neovim
# Linux: install from neovim.io / distro 0.12 package

# fzf binary (Mac/Linux). The vim plugin is pulled by vim.pack.
# If you already have ~/.fzf from the old installer, that still works.
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

git clone https://github.com/saks/nvim_dot_files.git ~/.config/nvim
nvim
```

First launch installs plugins (lockfile `nvim-pack-lock.json`) and treesitter parsers.

## Treesitter

Syntax highlighting comes from [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (Neovim 0.12 rewrite) plus compiled parsers. The plugin is pulled by `vim.pack`; you still need the **CLI and a C compiler** on the machine.

### 1. Install `tree-sitter` CLI (not the npm package)

nvim-treesitter needs `tree-sitter` **0.26.1+** on `PATH`. Install with a package manager, **not** `npm`.

```sh
# macOS
brew install tree-sitter

# Linux (Debian/Ubuntu, if the package is new enough)
sudo apt install tree-sitter-cli

# anywhere with Rust
cargo install tree-sitter-cli --locked
```

Check:

```sh
tree-sitter --version   # 0.26.1 or later
which tree-sitter
```

### 2. C compiler

Parsers compile on install (`cc` / `clang` / `gcc`).

```sh
# macOS
xcode-select --install

# Debian/Ubuntu
sudo apt install build-essential
```

`tar` and `curl` must also be on `PATH` (they usually already are).

### 3. Parser install

On startup, `lua/config/treesitter.lua` runs `require('nvim-treesitter').install({ ... })` for:

`bash`, `c`, `css`, `dockerfile`, `html`, `javascript`, `json`, `lua`, `markdown`, `markdown_inline`, `python`, `query`, `ruby`, `rust`, `scss`, `toml`, `vim`, `vimdoc`, `yaml`

That is a no-op if the parser is already there. First launch (or a new language) downloads and compiles; watch `:messages` for `Compiling parser` / `Language installed`.

Inside nvim:

```
:TSInstall rust          " one language (skip if present)
:TSInstall! rust         " force reinstall
:TSUpdate                " update all installed parsers (do this after vim.pack updates nvim-treesitter)
:TSUninstall rust
:TSLog                   " previous install / compile messages
:lua print(table.concat(require('nvim-treesitter').get_installed(), ', '))
```

To add a language, put its name in the `langs` list in `lua/config/treesitter.lua` and restart (or `:TSInstall <lang>`).

If highlighting is missing: `:checkhealth nvim-treesitter`, confirm `tree-sitter --version`, then `:TSInstall! <filetype>`.

## Layout

| Path | What |
|---|---|
| `init.lua` | Leader, then `require('config.*')` |
| `lua/config/` | options, plugins, keymaps, LSP, completion, treesitter, autocmds |
| `colors/railscasts3.lua` | Theme |
| `snippets/` | vsnip / leftover neosnippet files |

## Notes

- Alt/Option chords are bound twice (Mac composing chars **and** `<M-…>`) so the same physical keys work on both OSes and over SSH.
- Airline tabline shows **buffers**, not tab pages. fzf `ctrl-t` no longer opens a tab page.
- `<C-p>` and Alt-o / `ø` are fzf `:Files` (CtrlP is gone).
- `<C-s>` saves in normal, insert, and visual.
- After `vim.pack` updates `nvim-treesitter`, run `:TSUpdate` so parsers match the plugin.
