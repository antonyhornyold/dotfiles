# macOS dotfiles

This repository lives directly at `~/.config`. Its `bootstrap.sh` installs the
tools and activates the Zsh and Neovim configuration on a new Mac.

## Before using a new Mac

Create an empty GitHub repository, then add it as the remote for this local repo
and push the current branch:

```sh
git -C ~/.config remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git -C ~/.config push -u origin HEAD
```

Replace the URL with your repository's URL. Do not initialize the GitHub
repository with a README, since this repository already has one.

## Bootstrap a new Mac

Open Terminal, sign in to GitHub if the repository is private, then run:

```sh
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git ~/.config
bash ~/.config/bootstrap.sh
```

Replace the URL with your own. The clone command expects `~/.config` not to
exist yet. If it already contains files, review and move those files before
cloning; the bootstrap script does not delete them.

The script may prompt for an administrator password while installing Homebrew,
Ghostty, or its managed block in `/private/etc/zshenv`. On a fresh Mac, Git or
Homebrew may first ask to install Apple's Command Line Tools.

## What the script does

1. Installs Homebrew if needed and installs the formulas and Ghostty cask from
   the [Brewfile](Brewfile). It does not start the PostgreSQL service.
2. Preserves the existing `/private/etc/zshenv` content and appends a block
   that points this account's Zsh sessions to `~/.config/zsh`. The account UID
   is detected on the new Mac; it is not fixed at `501`.
3. Installs nvm in `~/.nvm` without creating a home-directory `.zshrc`, then
   installs Node.js 24 and makes it the nvm default. Projects can use their own
   `.nvmrc` to select another Node version.
4. Starts Neovim to install plugins from `nvim/nvim-pack-lock.json`, its Mason
   tools, and the configured Treesitter parsers.
5. Verifies the Catppuccin Mocha Lazygit configuration, checks that the
   Brewfile is satisfied, and confirms Zsh uses the expected `ZDOTDIR`.

The script is safe to rerun after a failed or partial setup. It does not create
project-specific database connections or store credentials. Each SQL project
can add its own `postgres-language-server.jsonc`; see the
[Neovim README](nvim/README.md#postgresql-projects).

After bootstrap finishes, open a new terminal. See the
[Zsh README](zsh/README.md) and [Neovim README](nvim/README.md) for usage and
update commands.

## Open a project in Herdr

Run `hp` from a project repository, or `hp ~/Code/my-node-app` from a normal
Ghostty shell. A new named Herdr session gets `code` (Neovim / Codex) and `run`
(quiet dev server / shell) tabs, each split evenly left/right. The session name
comes from the repository folder. Existing sessions are reopened intact.

Use `h` to search sessions and `nds` to run a quiet dev server manually. Full
server logs are separate per project under `~/.local/state/herdr/logs/` (or the
configured `XDG_STATE_HOME`); the server prints its log path at startup.
See [the Zsh guide](zsh/README.md#herdr-project-launcher) for setup and options.

## Open a project in Ghostty

From a project directory, run `project-open`. To open a different directory,
run `project-open ~/Projects/my-app`. The launcher opens two Ghostty windows:
Neovim and Codex side by side in the first, and a development server pane plus
a plain terminal in the second. Neovim opens on its start page in the project
directory. To move from Neovim to the Codex pane, press Ctrl-Space, then `l`
(Ghostty split navigation); `<C-w>l` only moves between Neovim windows.
The launcher starts `npm run dev` only when the project has a `dev` script in
`package.json`; otherwise the server pane stays at a shell
prompt. Run `project-open --help` for a short usage reminder.

The first Codex CLI launch may ask you to sign in with ChatGPT. Ghostty may
also ask macOS for Automation permission when the launcher opens its windows.

From anywhere inside the project's Git repository, run `project-close` to
close every Ghostty window created for that project by `project-open`. You can
also pass a project directory, such as `project-close ~/code/my-dashboard`.
Ghostty may ask you to confirm closing windows that still have running programs
or unsaved editor work. Closing the panes ends their terminal processes; it
does not stop separately managed services such as Homebrew PostgreSQL.
Windows opened by older versions of `project-open` have no project label and
must be closed manually.

To start a new project, run `project-new` and enter a name when prompted, or
pass the name directly, for example `project-new my-dashboard`. It creates
`~/code/my-dashboard`, initializes a local Git repository on `main`, and opens
that directory with `project-open`. It makes no commit or remote. Names use
lowercase letters, digits, dots, hyphens, and underscores; an existing project
directory is never reused or overwritten. The new directory starts empty, so
the server pane waits at a shell prompt until the project has a dev server.

## Rex beta preflight

Checked on 2026-10-31 against Rex Beta 0.1.0 (1696), client label `anthill`.
The bundled CLI reports `rex 0.0.1793377904-ge6592f`, built
2026-10-30T16:31:44Z, API revision 8. Recheck these details after beta updates.

`bin/rex` forwards arguments to the CLI bundled in `/Applications/Rex Beta.app`.
The existing Zsh login configuration already puts `~/.config/bin` on PATH.
Inside Rex, prefer the server's injected CLI directory (`REX_BIN_DIR`) if a
shell startup change ever puts a different CLI first. The launcher assumes the
standard application name and installation location.

Useful inspection commands:

```sh
rex version
rex client ls
rex -C anthill actions
rex keymap
rex config check
```

The configuration target is `~/.config/rex/init.lua`; it did not exist during
preflight. The [Rex configuration guide](rex/README.md) describes the structure
now in place and the remaining implementation. No Rex bindings or appearance
preferences were changed during preflight.
In this build, `rex keymap` without `--request` shows only file bindings, even
with `-C`; it does not retrieve the app's default shortcuts. Inspect defaults
under Settings > Shortcuts. See `rex help keymap` for client request input.

### Confirmed actions for the planned controls

| Purpose | Client action | Arguments |
|---|---|---|
| Split | `pane.split` | `direction` (`right` or `down` for our layout) |
| Focus a pane | `pane.focus` | `direction` (`left`, `down`, `up`, `right`), optional `wrap` |
| Equalize | `pane.balance` | None |
| Zoom | `pane.zoom` | None |
| Close pane | `pane.close` | None |
| New / next / previous tab | `client.tab.new`, `client.tab.next`, `client.tab.previous` | None |
| Switch session | `session.switch` | None |
| Resize | `pane.resize` | `direction`, optional `amount` |
| Enter resize mode | `client.mode.enter` | `name`, optional `once` |
| Exit mode | `client.mode.exit` | None |
| Pass a key through | `pane.send_key` | `key` |

Observed shipped shortcuts include Cmd-D / Shift-Cmd-D for splits right/down,
Option-Cmd-Arrows for pane focus, Cmd-[ / Cmd-] for previous/next pane,
Cmd-T for a new tab, Cmd-K for session switching, and Shift-Cmd-P for the
command palette. Shortcuts recorded in the app take priority over Lua bindings.

### Appearance settings available in this build

- Interface: Auto/Light/Dark, Classic/Glass, theme tint, tab position,
  Comfortable/Compact pane style, pane headers, matching program backgrounds,
  trackpad gestures, and animation style.
- Themes: separate light/dark themes, custom themes, extended palettes, and
  Ghostty/iTerm theme-file import. Current dark theme: Merino Dark.
  Catppuccin Mocha was not listed among the installed themes.
- Terminal: font and size controls, style and advanced typography, contrast,
  color palette behavior, Display P3, cursor style/blink, Option-key behavior,
  scrolling, padding color, selection, titles, and shell startup command.
- Exact Ghostty equivalents for opacity, blur, numeric padding, borderless
  windows, inactive-pane opacity, and startup fullscreen were not established
  during this inspection.

Remote Control was off. It was left off; a separate decision is needed before
using agent actions that control the app. Existing sessions and old launchers
were left intact.
