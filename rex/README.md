# Rex configuration

Configuration for the Rex Beta app on macOS, with Ctrl-Space pane controls,
tab/session navigation, a resize mode, and a project launcher. General
development actions are still pending.

## Files

| Path | Purpose |
|---|---|
| `init.lua` | Entry point; loads actions, projects, then keys |
| `keys.lua` | Keyboard shortcuts and modes |
| `actions.lua` | General development actions |
| `projects.lua` | Project session and layout actions |
| `scripts/` | Standalone scripts run explicitly with `rex do` |

Rex resolves `require("keys")` and the other modules beside `init.lua`.
The keys module defines shortcuts and a resize mode. The projects module defines
the Open Project action. The actions module remains a placeholder. Loading the
configuration creates no sessions or processes.

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

## Project launcher

From a project directory, run:

```sh
rex-project
rex-project ~/code/my-app
rex-project ~/code/my-app --no-attach
rex-project ~/code/my-app --name my-app-review --client anthill
```

The command uses the Git root when there is one, or the supplied directory
otherwise. Paths with spaces can be quoted normally. Symlinks resolve to the
same project. Labels default to a sanitized folder name; `--name` chooses a
label for a new session, not a second session for an already registered project.

A new project gets two tabs, each split evenly left/right:

| Tab | Left pane | Right pane |
|---|---|---|
| `code` | `editor`: `nvim .` | `agent`: `codex` |
| `run` | `dev`: `project-dev`, or a shell without an npm dev script | `shell`: interactive shell |

All panes start in the project root. The editor is initially focused. Programs
load your interactive login Zsh configuration before starting, including NVM;
arguments and paths are passed separately, never interpolated as shell code.
Command panes stay visible when their programs exit. Reopening preserves the
session's current layout, focus, programs, and Codex conversation, even if you
renamed the session or changed a pane's working directory.

The launcher needs Python 3, Git, Rex, Neovim, and Codex. A nonempty string in
`package.json` at `scripts.dev` enables the development server. Invalid JSON
fails before any session is created. The existing `project-dev` helper also
needs npm, rg, tee, and shasum. It continues to save full logs under
`${XDG_STATE_HOME:-$HOME/.local/state}/herdr/logs/` and prints the exact path.
No packages, databases, Docker services, or project files are created by the
launcher. Codex may show its usual trust/sign-in prompt on first use. Projects
must already have their dependencies and distinct server ports configured.

### Open from the command palette

Inside Rex, search for **Open Project** (Shift-Cmd-P). It uses the focused
program's working directory, falling back to the terminal's reported directory.
You can also supply a directory explicitly:

```sh
rex do open_project directory=/absolute/path/to/project
```

From a shell, `rex-project` asks the Rex app to display the result. This needs
Remote Control enabled in that app. With multiple app clients, pass `--client`
(or set `REX_CLIENT`). If app switching is refused, the prepared session is
retained and the command reports the failure. Use `--no-attach` to prepare
without app control, then select the session in Rex. The palette action queues
the switch in its invoking client. Remote Control is not enabled by the launcher.

### Saved identity and interrupted launches

Project-to-session IDs are saved outside Git under
`${XDG_STATE_HOME:-$HOME/.local/state}/rex/projects/`, scoped to the Rex server's
host ID. A lock serializes creation, and the two-tab layout is created in one
server request. Keep that state directory to preserve project identity; losing
it does not delete sessions, but the launcher refuses to adopt an existing
same-named session without its saved identity. Choose `--name` for a different
project with the same folder name. Deleted sessions are recreated on the next
launch. The launcher supports local Unix-socket servers only.

A creation that fails or times out leaves a `pending` record. Subsequent launches
stop instead of risking duplicates. Inspect `rex ls`, the affected session, and
the reported registry file. After confirming the outcome, replace that project's
pending entry with its verified `session_id`, `root`, `label`, and `has_dev`, or
remove the entry if no session was created. Do not remove a pending entry and
retry without inspecting the server first.

### Verification

Live fixture checks covered Git-root resolution, non-Git directories, paths with
spaces and shell characters, symlinks, labels and equal splits, pane working
directories, unchanged pane IDs/process IDs on reopening, renamed sessions,
label collision refusal, interrupted-creation protection, malformed package JSON,
simultaneous launches, and an actual dependency-free npm dev server through
`project-dev`. The Open Project action reused a prepared fixture; app switching
was correctly refused with Remote Control off. Fixtures used
stub editor/agent processes; a real Codex sign-in was not part of the checks.

## Remaining implementation

- Add Lazygit, test, log-viewing, and config-editing actions.
- Apply appearance preferences and set up the agent integration.
- Add optional event-driven scripts after the main workflow works.

Live Rex API calls belong in action callbacks or standalone scripts, not at
configuration load time. Background event listeners and timers belong in
standalone scripts under `scripts/`.

See the [dotfiles preflight notes](../README.md#rex-beta-preflight) for verified
client actions and appearance options, and the [Rex configuration docs](https://www.superlogical.com/rex/docs/customize/config).
