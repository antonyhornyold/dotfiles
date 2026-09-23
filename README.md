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
