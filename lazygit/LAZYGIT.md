# Lazygit guide

Lazygit is a visual control panel for Git. Run it from inside any repository:

```sh
cd ~/path/to/repository
lazygit
```

## Mental model

The left side contains five panels:

1. Repository status
2. Changed files
3. Local branches
4. Commits
5. Stashes

The large panel on the right previews the selected item, usually a diff or
commit.

Navigation is Vim-like:

| Key | Action |
|---|---|
| `j` / `k` | Move down/up |
| `h` / `l` | Move between panels |
| `1`–`5` | Jump directly to a panel |
| `Enter` | Open or inspect the selected item |
| `Esc` | Go back or cancel |
| `?` | Show every action available in the current panel |
| `q` | Quit |
| `/` | Search or filter the current panel |

The most useful key is `?`. Lazygit's shortcuts are contextual, so it shows
different commands depending on the selected panel.

## Everyday workflow

### Review changes

Open Lazygit and move to the **Files** panel with `2`.

Select a changed file with `j`/`k`. Its diff appears on the right.

| Key | Action |
|---|---|
| `e` | Open the file in Neovim |
| `Space` | Stage or unstage the entire file |
| `a` | Stage or unstage all files |
| `d` | Discard changes; review the confirmation carefully |
| `Enter` | Open the diff for line/hunk staging |

### Stage only part of a file

Select the file and press `Enter`. Inside the diff:

| Key | Action |
|---|---|
| `h` / `l` | Previous/next hunk |
| `Space` | Stage or unstage the selected line |
| `a` | Switch between line and whole-hunk selection |
| `v` | Start selecting a range |
| `Tab` | Switch between staged and unstaged changes |
| `Esc` | Return to the Files panel |

This is one of Lazygit's strongest everyday features: it makes creating clean,
focused commits much easier.

### Commit staged changes

From the Files panel, press `c`, enter the commit message, and press `Enter`.

| Key | Action |
|---|---|
| `c` | Commit with an inline message |
| `C` | Compose the message in the configured Git editor |
| `A` | Amend the most recent commit |

Be careful with `A`: amending a commit that has already been pushed rewrites
its history.

### Pull and push

These work globally from almost any panel:

| Key | Action |
|---|---|
| `p` | Pull |
| `P` | Push |
| `f` | Fetch when focused on Files or Remotes |

Remember: lowercase `p` pulls; uppercase `P` pushes. If a new branch has no
upstream, pushing will prompt you to create one.

## Branches

Press `3` to open the **Branches** panel.

| Key | Action |
|---|---|
| `n` | Create a branch |
| `Space` | Check out the selected branch |
| `-` | Return to the previous branch |
| `R` | Rename the selected branch |
| `d` | Delete a branch |
| `M` | Merge the selected branch into the current branch |
| `r` | Rebase the current branch onto the selected branch |
| `Enter` | Show the selected branch's commits |

The direction matters:

- Selecting `feature` and pressing `Space` checks out `feature`.
- While on `main`, selecting `feature` and pressing `M` merges `feature` into
  `main`.
- While on `feature`, selecting `main` and pressing `r` rebases `feature` onto
  `main`.

Read the confirmation prompt before merging or rebasing.

## Commit history

Press `4` for the **Commits** panel.

| Key | Action |
|---|---|
| `Enter` | View files in the commit |
| `y` | Copy commit information such as its hash |
| `r` | Reword the selected commit |
| `A` | Amend the selected commit with staged changes |
| `t` | Revert the selected commit |
| `T` | Create a tag |
| `C` | Copy a commit for cherry-picking |
| `V` | Cherry-pick the copied commit |
| `i` | Begin an interactive rebase |
| `g` | Open reset options |

History-editing actions can rewrite commits. Avoid rewording, squashing, fixing
up, or rebasing commits that other people may already have pulled unless you
deliberately intend to rewrite the branch.

## Stashing work

From the Files panel:

| Key | Action |
|---|---|
| `s` | Stash all changes |
| `S` | Open detailed stash options |

Press `5` to view saved stashes:

| Key | Action |
|---|---|
| `Space` | Apply without deleting the stash |
| `g` | Pop: apply and delete the stash |
| `d` | Delete the stash |
| `n` | Create a branch from the stash |
| `r` | Rename the stash |

Applying is safer than popping when you are uncertain because the stash remains
available.

## Merge conflicts

When conflicted files appear:

1. Select a conflicted file in the Files panel.
2. Press `Enter` to focus its conflict view.
3. Use `h`/`l` to move between conflicts.
4. Use `j`/`k` to move between available hunks.
5. Press `Space` to select a hunk or `b` to take both.
6. Press `e` if the conflict is easier to resolve manually in Neovim.
7. Press `Esc` to return to the file list.
8. Stage the resolved file with `Space`.

## First-session routine

For normal work, you can do nearly everything with:

```text
lazygit
2
j/k       inspect files
Space     stage files
Enter     stage individual lines
c         commit
p         pull
P         push
q         quit
```

Treat `d`, `D`, force checkout, reset, rebase, amend, and force-push options
with care. Lazygit normally presents a confirmation before destructive
operations, so read those menus rather than accepting them automatically.

See the [official Lazygit keybindings documentation][keybindings] for the full,
current shortcut reference.

[keybindings]: https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md
