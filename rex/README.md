# Rex configuration

Configuration for the Rex Beta app on macOS, with Ctrl-Space pane controls,
tab/session navigation, a resize mode, a project launcher, and development
actions for Git, tests, logs, and config editing.

## Files

| Path | Purpose |
|---|---|
| `init.lua` | Entry point; loads actions, appearance, projects, then keys |
| `keys.lua` | Keyboard shortcuts and modes |
| `actions.lua` | General development actions |
| `appearance.lua` | Import and select the saved Catppuccin Mocha theme |
| `themes/` | Portable Mocha palette files |
| `projects.lua` | Project session and layout actions |
| `scripts/` | Standalone scripts run explicitly with `rex do` |

Rex resolves `require("keys")` and the other modules beside `init.lua`.
The keys module defines shortcuts and a resize mode. The projects module defines
the Open Project action. The actions module defines development tools. Loading
the configuration creates no sessions or processes.

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
| `g` | Open Lazygit |
| `t` | Run project tests |
| `o` | Open project logs |
| `,` | Edit Rex config |
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

## Development actions

Search for these titles in the command palette (Shift-Cmd-P), or use the
Ctrl-Space shortcuts above. Each invocation opens a new, focused tab in the
current session. The existing panes and programs are left running. Command
output is retained after the program exits; close the tab when finished.

| Palette title | Action name | Behavior |
|---|---|---|
| Open Lazygit | `open_lazygit` | Opens Lazygit at the Git root; refuses non-Git directories |
| Run Project Tests | `run_tests` | Runs `npm run test` and retains successful or failed output |
| Open Project Logs | `open_project_logs` | Follows the full log saved by `project-dev` using `less -R +F` |
| Edit Rex Config | `edit_rex_config` | Opens the effective `init.lua` in Neovim |

Project actions use the focused program's working directory, falling back to
the terminal's reported directory and the launcher's saved project identity,
then resolve the Git root. New action tabs explicitly report their startup
directory to work around missing process metadata in this beta. Non-Git projects
use that directory for tests and logs. Use an explicit directory to target a
project from another pane. Outside Rex, select the destination session with
`-s SESSION`:

```sh
rex do open_lazygit
rex do run_tests
rex do run_tests script=test:integration
rex do open_project_logs
rex do edit_rex_config
rex do run_tests -s SESSION directory=/absolute/path/to/project
```

Tests currently support npm scripts, matching the project launcher. The default
is `test`; use `script=NAME` for another package script. Test tabs print the
actual command exit status explicitly. In the inspected beta, the terminal
process API reported 0 for a failing command, so use the printed result. Missing or malformed
`package.json`, a missing script, a missing executable, and a missing log are
reported before a tab is created. Scripts run as configured by the project, so
a watch-mode test script will remain running until stopped. Programs load your
interactive Zsh setup, including NVM.

In logs, press Ctrl-C to stop following and inspect earlier output; `q` quits.
The log filename uses the same project path hash as `project-dev`, under
`${XDG_STATE_HOME:-$HOME/.local/state}/herdr/logs/`. Start the project's dev
server through `project-dev` before opening its log.

The config action honors the server's `REX_CONFIG` and `XDG_CONFIG_HOME`.
Use `:edit keys.lua`, `:edit actions.lua`, or `:edit projects.lua` in Neovim to
edit other modules. After saving, validate with `rex config check` and apply
with `rex config reload`.

These actions create tabs through the session API, so they do not require
Remote Control to be enabled in the app.

Live fixture checks exercised real Lazygit and Neovim, npm scripts returning
0 and 7, retained test results, the full project-dev log in less, and Git-root
resolution from a nested directory with spaces and shell characters, and
launching a project action from a running tool tab. Missing
scripts, malformed package JSON, non-Git Lazygit requests, and missing logs
reported errors without creating tabs. The original shell pane stayed running;
the temporary session and its generated log were removed after verification.

## Appearance

The macOS app now uses:

| Setting | Value |
|---|---|
| Color scheme | Dark |
| Dark theme | Catppuccin Mocha |
| Terminal font | Iosevka Term SS05, Regular, 14pt |
| Interface / pane style | Classic / Comfortable |
| Inactive-pane fading | Surface & Content |
| Focused-pane edge highlight | On |
| Padding color / program backgrounds | Extend / Match program backgrounds on |
| Option key | Left sends Alt |

Font and interface preferences belong to the app's settings, not `init.lua`.
On another Mac, set these values in Settings > Terminal and Settings > Interface
(the latter has Customize pane behavior). The Lua config and theme assets live
here so they can be cloned with the dotfiles.

Search **Apply Catppuccin Mocha** in the Rex command palette to import and select
`themes/Catppuccin Mocha.itermcolors`. This invokes the app's supported import
action directly; the beta's file-picker Open button stayed disabled for both
Ghostty and iTerm theme files during setup. The `.conf` file retains the exact
source palette copied from the installed Ghostty theme; the iTerm file contains
the same 16 ANSI colors, background/foreground, cursor, and selection colors.
The palette action was verified with Remote Control off.

Comfortable pane spacing is the available approximation of the old Ghostty
padding. Exact numeric padding, 95% opacity, blur radius, borderless windows,
and 80% inactive-pane opacity were not exposed in the inspected settings.
No undocumented preference keys were written to approximate them.

## Codex integration

Rex's user-level skill and SessionStart hook are installed and current:

- Skill: `~/.agents/skills/rex/SKILL.md`
- Hook definition: `~/.codex/hooks.json`

The skill asks the installed Rex CLI for its current guide. The hook supplies
Rex session and terminal context at the start of a Codex session. Automatic
session naming is off so project labels stay under your control. These are
account-level installations outside this Git repository; reproduce them with:

```sh
rex skill setup --agent codex --dry-run
rex skill setup --agent codex
rex skill status
```

In Codex CLI, enter `/hooks` directly at the prompt to review and approve the
Rex SessionStart hook. The interactive screen showed SessionStart installed 1,
active 1 after setup. Start a new Codex session inside Rex to receive the
startup context. Installation does not automatically approve a new or changed
hook; see the [official hook documentation](https://learn.chatgpt.com/docs/hooks).

Verification also ran a temporary program inside Rex, checked its inherited
`REX_SESSION` and `REX_BLOCK` against the actual IDs, and had it open a split
beside itself through the CLI. The temporary session was removed afterward.
This verified the context and pane-control mechanism without making a model
request. Remote Control remains off; terminal/session operations work, while
CLI requests to switch the app still require that app setting.

## Remaining implementation

- Add optional event-driven scripts after the main workflow works.

Live Rex API calls belong in action callbacks or standalone scripts, not at
configuration load time. Background event listeners and timers belong in
standalone scripts under `scripts/`.

See the [dotfiles preflight notes](../README.md#rex-beta-preflight) for verified
client actions and appearance options, and the [Rex configuration docs](https://www.superlogical.com/rex/docs/customize/config).
