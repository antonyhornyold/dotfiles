# Neovim config

Personal Neovim 0.12 config. `init.lua` loads the modules in `lua/config/`;
`snippets/` contains language-specific snippets. The leader key is Space.

Launching `nvim` without a file opens a mini.starter page with file search,
project text search, Oil, a new buffer, the config, and recent files. Select
an item with its highlighted prefix or the arrow keys, then press Enter.

## Editing keys

| Keys | Action |
| --- | --- |
| `jk` (Insert) | Return to Normal mode |
| `<M-l>` (Insert; left Option + L in Ghostty) | Move past adjacent closing quotes and brackets |
| `-` | Open Oil's floating file explorer (`q` closes it) |
| `<leader>go` | Toggle mini.diff's in-buffer change overlay |
| `<leader>t` | Toggle the floating terminal (`<C-q>` closes it) |
| `<leader>cf` (Normal/Visual) | Format buffer or selection |
| `<leader>ca` (Normal/Visual) | LSP code action |
| `<leader>rn` | LSP rename |
| `]d` / `[d` | Next / previous diagnostic |

| Find keys | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Search lines in the current buffer |
| `<leader>fG` | Search text across the project |
| `<leader>fb` | Switch buffers |
| `<leader>fr` | Find LSP references |
| `<leader>fd` / `<leader>fD` | Find buffer / workspace diagnostics |

In Insert mode, `<Tab>` indents before any text; otherwise it selects the next
completion item, advances an active snippet, or expands a matching snippet.
`<S-Tab>` moves backward in the menu or snippet. `<CR>` accepts a selected item
and otherwise uses mini.pairs' Enter behavior. `<C-y>` also accepts an item;
`<C-e>` cancels the menu. `<C-j>` expands a snippet trigger directly,
`<C-l>` / `<C-h>` move through its placeholders, and `<C-c>` stops the session.

mini.surround uses `sa` to add, `sd` to delete, and `cs` to change a surrounding.
For example, `saiw)` wraps a word in parentheses and `cs)(` changes `(word)`
to `( word )`. Its other default keys are `sf`, `sF`, and `sh` for finding or
highlighting a surrounding.

mini.ai extends `a`/`i` text objects for brackets, quotes, arguments, function
calls, and tags. Treesitter adds `aF`/`iF` for a function definition and its
body, `ac`/`ic` for a JS/TS class and its body, and `ao`/`io` for a conditional
or loop and its body. Use them with operators such as `d`, `c`, `y`, or `v`.
mini.ai's next-object variants use `aN`/`iN`, leaving Neovim's `an`/`in`
selections available.

mini.diff shows Git changes in the number column. `<leader>go` toggles an
overlay showing the changed and deleted text. `]h` / `[h` move between
hunks; `]H` / `[H` go to the last / first hunk. `ghgh` stages the current
hunk and `gHgh` resets it; `gh` / `gH` also work on a Visual selection. Reset
discards the affected buffer changes.

mini.clue shows key hints after Space in Normal or Visual mode and after `[`,
`]`, or `<C-w>` in Normal mode. The popup uses its default one-second delay.

## Plugins and tools

Plugins are declared in `lua/config/plugins.lua` and installed by Neovim's
`vim.pack`. They are Catppuccin, Oil, oil-git-status, mini.nvim (icons, pairs,
diff, ai, surround, completion, snippets, keymap, clue, starter),
nvim-treesitter, nvim-treesitter-textobjects, nvim-ts-autotag, Mason,
nvim-lspconfig, mason-lspconfig, Conform, nvim-lint,
tiny-cmdline, and fzf-lua.
The statusline and floating terminal are configured locally without plugins.
oil-git-status shows staged and working-tree Git status in Oil's two sign
columns. Oil hides Git-ignored files and untracked dotfiles by default, while
tracked dotfiles remain visible. Press `g.` in Oil to reveal hidden entries.

| Purpose | Tools |
| --- | --- |
| LSP via Mason | Lua, TypeScript/JavaScript, HTML, CSS, JSON, Tailwind CSS, PostgreSQL SQL |
| Format via Conform | Prettier (HTML, CSS, SCSS, JS, TS, JSON, JSONC, Markdown, MDX, YAML), StyLua (Lua), shfmt (Zsh), pg_format (SQL, manual only) |
| Lint via nvim-lint | luacheck (Lua), Zsh's built-in syntax check, HTMLHint (HTML), project-local Stylelint (CSS) and ESLint (JS/TS) |
| Treesitter | HTML, JavaScript, TypeScript, TSX, Lua, and SQL parsers |

ESLint and Stylelint run only when their config file and executable are found
in the project. Linting runs on buffer entry and after save. Mason provides the
configured language servers and can install Prettier, StyLua, shfmt, and
HTMLHint. `luacheck` must be available on `PATH`; Zsh uses `/bin/zsh`.
fzf-lua's project text search needs `rg` (ripgrep).

## PostgreSQL projects

Put `postgres-language-server.jsonc` in the root of a project containing SQL files.
The language server uses that file to identify the project. A minimal version is:

```jsonc
{
  "$schema": "https://pg-language-server.com/latest/schema.json",
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  }
}
```

Database-aware completion needs a connection to a local development database;
configure that per project and keep credentials out of Git. SQL formatting uses
`pg_format` only when requested with `<leader>cf`, so migration files are not
reformatted automatically on save. A project-level `.pg_format` file can set
the team's SQL formatting style.

## Updating

1. In Neovim, run `:lua vim.pack.update()` to review plugin updates. Write the
   confirmation buffer to apply them, or quit it to discard them. Restart
   Neovim after applying. The selected revisions are recorded in
   `nvim-pack-lock.json`.
2. Run `:Mason` to inspect managed tools. Press `u` on one package or `U` to
   update all installed packages. `:MasonUpdate` refreshes the registry only.
3. After updating nvim-treesitter, run `:TSUpdate` to update installed parsers.
4. Update project-local ESLint and Stylelint with that project's package
   manager. Update system tools such as `luacheck` separately.
5. Run `:checkhealth` if an update causes problems, and commit config and
   lockfile changes together.
