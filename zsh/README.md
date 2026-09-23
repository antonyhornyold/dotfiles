# Zsh configuration

A fast, modular Zsh setup for macOS, built around XDG paths, Vim-style command-line editing, fuzzy finding, and a Catppuccin Mocha Starship prompt.

## What is included

- **Starship** provides a two-line, context-aware prompt.
- **zsh-vi-mode** adds Vim-style command-line editing.
- **zsh-autosuggestions** suggests commands from shell history.
- **fast-syntax-highlighting** colours valid and invalid shell input.
- **fzf** provides fuzzy file, directory, and history selection.
- **zoxide** remembers frequently used directories.
- **eza**, **bat**, **fd**, and **ripgrep** replace or complement classic Unix tools.
- **Neovim** is the default editor.
- **NVM** supplies Node.js versions when installed.

The tools are declared in `~/.config/Brewfile` and can be installed or updated together with:

```sh
brew bundle --file="$HOME/.config/Brewfile"
```

The `zsh-tools-update` shell function runs the same command.

## Layout

Zsh reads its configuration from `~/.config/zsh`, selected through `ZDOTDIR`.

| File | Purpose |
|---|---|
| `.zprofile` | Loads the Homebrew environment for login shells |
| `.zshrc` | Sets environment variables and history, initializes completion, and loads the modules below |
| `aliases.zsh` | Navigation, Git, `eza`, `bat`, and Neovim aliases |
| `bindings.zsh` | Fallback history bindings when `zsh-vi-mode` is unavailable |
| `plugins.zsh` | Loads vi mode, autosuggestions, fzf, and syntax highlighting in the required order |
| `fzf.zsh` | Catppuccin styling, `fd` file discovery, and `bat`/`eza` previews |
| `prompt.zsh` | Initializes zoxide and Starship |
| `~/.config/starship.toml` | Prompt layout, modules, symbols, and colours |

For a new machine, `ZDOTDIR` should be set before Zsh looks for `.zprofile` and `.zshrc`. A typical `~/.zshenv` contains:

```sh
export ZDOTDIR="$HOME/.config/zsh"
```

Start a fresh login shell after changing it:

```sh
exec zsh -l
```

## Shell behaviour

`EDITOR` and `VISUAL` are both set to `nvim`. If `bat` is installed, it also renders manual pages with syntax highlighting.

History is stored at `${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history`. It is shared between shell sessions, duplicate entries are discarded preferentially, and recalled commands are presented for confirmation before execution.

Completion data is cached at `${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump`.

## Aliases and functions

| Command | Meaning |
|---|---|
| `ls` | Compact one-item-per-line `eza` listing |
| `ll` / `la` | Concise long listing, without / with hidden files |
| `lt` / `lta` | Detailed table listing, without / with hidden files |
| `tr1` / `tr2` | Directory tree two / three levels deep |
| `cl` | Clear the terminal |
| `..` / `...` | Move up one / two directories |
| `-` | Return to the previous directory |
| `vim` | Open Neovim |
| `cat` | Use `bat` when available |
| `df` | Show human-readable disk usage |
| `glog` | Git log with a pager that exits when output fits on screen |
| `gadog` | Decorated, one-line Git graph of all branches |
| `dots` | Run Git against `~/.config`, for example `dots status` |
| `mkcd DIR` | Create a directory and enter it |
| `zsh-tools-update` | Install or update tools from the Brewfile |

Git shortcuts: `gs` (status), `ga` (add), `gap` (interactive add), `gd` (diff), `gds` (staged diff), `gc` (commit), and `gp` (push).

npm shortcuts: `nr` (run), `nd` (run dev), `nb` (run build), `nt` (test), `ni` (install), and `nci` (clean install from the lockfile).

Optional Zsh suffix aliases for web-development files are documented but disabled in `aliases.zsh`. When enabled, entering a filename such as `app.ts` directly at the prompt opens it in Neovim.

## Fuzzy finding

The fzf interface uses a compact reverse layout and Catppuccin Mocha colours. When `fd` is available, searches include hidden files while excluding `.git` and respecting ignore rules.

Useful default fzf bindings include:

| Keys | Action |
|---|---|
| `Ctrl-T` | Find a file or directory and insert its path |
| `Ctrl-R` | Search command history |
| `Alt-C` | Find and enter a directory |

`Ctrl-T` previews directories with `eza` and files with `bat` when both tools are installed.

## Prompt

The Starship prompt shows the current directory, Git state, detected language or infrastructure context, and a mode-aware input character. The right prompt shows commands taking at least three seconds, a non-zero exit status, and background jobs.

Additional details appear only when relevant:

- Remote OS, username, and hostname over SSH.
- Container, Docker, Kubernetes, Terraform, and Nix context.
- Major or major/minor versions for detected programming languages.
- AWS profile and region, Google Cloud project, or Azure subscription.
- Production cloud contexts in red when their name contains `prod` or `production`.
- A warning when a local `.envrc` has not been allowed by direnv.
- A sudo credential indicator.

The prompt and fzf interface share the Catppuccin Mocha palette.

## Plugin loading order

Plugin order is deliberate:

1. `zsh-vi-mode` initializes immediately so its bindings exist first.
2. `zsh-autosuggestions` adds history-based suggestions.
3. fzf installs its own widgets without being overwritten by vi mode.
4. `fast-syntax-highlighting` loads last because it wraps line-editor widgets.

If `zsh-vi-mode` is missing, the up and down arrow keys fall back to prefix-based history search.

## zsh-vi-mode quick reference

You normally type in **Insert mode**. Press `Esc` or `Ctrl-[` to enter **Normal mode**, edit the command with Vim keys, and press `Enter` from either mode to run it. The prompt uses `❯` in Insert mode and `❮` in Normal or Visual mode.

### Movement and insertion

| Keys | Action |
|---|---|
| `Esc` / `Ctrl-[` | Enter Normal mode |
| `i` / `a` | Insert before / after the cursor |
| `I` / `A` | Insert at the start / end of the line |
| `h` `j` `k` `l` | Left / newer history / older history / right |
| `w` / `b` / `e` | Next word / previous word / end of word |
| `0` / `^` / `$` | Start / first non-space / end of line |
| `f<char>` / `F<char>` | Jump to the next / previous `<char>` |
| `t<char>` / `T<char>` | Jump just before the next / previous `<char>` |
| `;` / `,` | Repeat the last character jump forward / backward |

### Editing

Vim operators combine with movements and text objects: `d` deletes, `c` changes, and `y` copies.

| Keys | Action |
|---|---|
| `x` | Delete the character under the cursor |
| `dw` / `db` | Delete forward / backward by a word |
| `d$` or `D` | Delete to the end of the line |
| `dd` | Delete the whole command line |
| `cw` / `ciw` | Change the next / current word |
| `ci"` / `ci(` | Change inside quotes / parentheses |
| `C` | Change to the end of the line |
| `yy` | Copy the whole command line |
| `p` / `P` | Paste after / before the cursor |
| `u` / `Ctrl-R` | Undo / redo |
| `.` | Repeat the last change |
| `r<char>` | Replace one character |
| `~` | Toggle the case of a character |

Counts work as in Vim: `3w` moves three words, `2dw` deletes two words, and `5x` deletes five characters.

### History and visual mode

| Keys | Action |
|---|---|
| `k` or `Ctrl-P` | Previous command |
| `j` or `Ctrl-N` | Next command |
| `/text` then `Enter` | Search backward through history |
| `n` / `N` | Repeat the search in the same / opposite direction |
| `v` | Start a visual selection |

After selecting with `v`, press `d` to delete, `c` to replace, or `y` to copy. Press `Esc` to cancel.

### Surrounds

The configuration uses the plugin's default `classic` surround bindings.

| Keys | Action |
|---|---|
| `cs"'` | Change surrounding double quotes to single quotes |
| `ds"` | Delete surrounding double quotes |
| `vi"` then `S(` | Select inside quotes and wrap the text in parentheses |
| Visual selection then `S"` | Wrap the selection in double quotes |

### Edit a long command in Neovim

Press `vv` in Normal mode to open the current command in Neovim through `$EDITOR`. Save and quit to return the edited command to the prompt.

For example, with `git commit -m "old message"` at the prompt, press `Esc`, type `ci"`, enter the new message, then press `Enter`. `ci"`—“change inside quotes”—is especially useful on the command line.

See the [zsh-vi-mode documentation](https://github.com/jeffreytse/zsh-vi-mode#usage) for the complete command and configuration reference.
