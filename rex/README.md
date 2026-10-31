# Rex configuration

Configuration for the Rex Beta app on macOS, with Ctrl-Space pane controls,
tab/session navigation, and a resize mode. Development actions and project
launching are still pending.

## Files

| Path | Purpose |
|---|---|
| `init.lua` | Entry point; loads actions, projects, then keys |
| `keys.lua` | Keyboard shortcuts and modes |
| `actions.lua` | General development actions |
| `projects.lua` | Project session and layout actions |
| `scripts/` | Standalone scripts run explicitly with `rex do` |

Rex resolves `require("keys")` and the other modules beside `init.lua`.
The keys module defines shortcuts and a resize mode. The actions and projects
modules remain placeholders; loading the configuration creates no sessions or
processes.

## Location and CLI

The normal configuration path is `~/.config/rex/init.lua`. When
`XDG_CONFIG_HOME` is set, Rex instead uses `$XDG_CONFIG_HOME/rex/init.lua`.
`REX_CONFIG` in the server's environment overrides the file path.

The dotfiles launcher at `~/.config/bin/rex` runs the CLI bundled with
`/Applications/Rex Beta.app`. The existing Zsh login configuration puts that
launcher on PATH. Open a fresh login shell if `rex` is not found.

## Validate and reload

```sh
rex config check
rex config reload
rex keymap
```

Validate before reloading. Rex does not watch the configuration for changes.
Reload applies the file to the running local server and its connected clients;
run it on the server's machine. No server restart is needed.

In the inspected beta, `rex keymap` without a client request shows file bindings
only. Use Settings > Shortcuts to inspect the app's defaults. To check supported
client actions, run `rex client ls`, then `rex -C CLIENT_LABEL actions` with the
label from that list. Shortcuts recorded in the app take priority over Lua.

## Keyboard controls

Press Ctrl-Space, release it, then press the key below. Escape cancels a
sequence before its final key. The existing Cmd-based shortcuts remain available.

| Key after Ctrl-Space | Action |
|---|---|
| `\` / `-` | Split right / down |
| `h` / `j` / `k` / `l` | Focus left / down / up / right |
| `e` | Equalize pane sizes |
| `z` | Toggle focused pane zoom |
| `x` | Close focused pane |
| `c` | New tab |
| `n` / `p` | Next / previous tab |
| `s` | Open the session switcher |
| `r` | Enter resize mode |
| Ctrl-Space again | Send one Ctrl-Space to the terminal |

In resize mode, use `h/j/k/l` to resize, Shift with those keys for larger
steps (amount 15), and `=` to equalize. Enter or Escape exits. This mode is
exclusive, so other keys are ignored instead of being typed into the terminal.

The prefix leaves ordinary Ctrl-based Neovim and Zsh bindings available. For
programs that use Ctrl-Space themselves, press Ctrl-Space twice. The close
binding acts on the focused pane; use it deliberately around running programs.

## Remaining implementation

- Build the project launcher with Neovim/Codex and dev-server/shell tabs.
- Add Lazygit, test, log-viewing, and config-editing actions.
- Apply appearance preferences and set up the agent integration.
- Add optional event-driven scripts after the main workflow works.

Live Rex API calls belong in action callbacks or standalone scripts, not at
configuration load time. Background event listeners and timers belong in
standalone scripts under `scripts/`.

See the [dotfiles preflight notes](../README.md#rex-beta-preflight) for verified
client actions and appearance options, and the [Rex configuration docs](https://www.superlogical.com/rex/docs/customize/config).
