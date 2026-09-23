#!/usr/bin/env bash
set -euo pipefail

config_dir="$HOME/.config"
zshenv=/private/etc/zshenv
temporary_file=

cleanup() {
  if [[ -n "$temporary_file" ]]; then
    rm -f -- "$temporary_file"
  fi
}
trap cleanup EXIT

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'bootstrap: %s\n' "$*" >&2; exit 1; }

if [[ ${1:-} == --help ]]; then
  printf 'Usage: bash ~/.config/bootstrap.sh\nInstall the tools and initialize the Zsh and Neovim config on macOS.\n'
  exit 0
fi
[[ $# -eq 0 ]] || die 'No arguments are supported; use --help for usage.'
[[ $(uname -s) == Darwin ]] || die 'This bootstrap script is for macOS.'
[[ -f "$config_dir/Brewfile" && -d "$config_dir/zsh" && -f "$config_dir/nvim/init.lua" ]] ||
  die 'Clone the dotfiles repository into ~/.config before running this script.'

export XDG_CONFIG_HOME="$config_dir"

log 'Install Homebrew if needed'
if [[ -x /opt/homebrew/bin/brew ]]; then
  brew_bin=/opt/homebrew/bin/brew
elif [[ -x /usr/local/bin/brew ]]; then
  brew_bin=/usr/local/bin/brew
elif command -v brew >/dev/null 2>&1; then
  brew_bin=$(command -v brew)
else
  command -v curl >/dev/null 2>&1 || die 'curl is required to install Homebrew.'
  temporary_file=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$temporary_file"
  /bin/bash "$temporary_file"
  rm -f -- "$temporary_file"
  temporary_file=
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_bin=/usr/local/bin/brew
  else
    die 'Homebrew installed, but its brew executable was not found.'
  fi
fi
eval "$("$brew_bin" shellenv)"

log 'Install packages from the Brewfile'
"$brew_bin" bundle --file="$config_dir/Brewfile"

log 'Configure Zsh to read ~/.config/zsh'
if [[ -f "$zshenv" ]] && grep -Fq 'export ZDOTDIR="$XDG_CONFIG_HOME/zsh"' "$zshenv"; then
  printf 'ZDOTDIR is already configured in %s.\n' "$zshenv"
else
  temporary_file=$(mktemp)
  if [[ -f "$zshenv" ]]; then
    cat "$zshenv" > "$temporary_file"
  fi
  printf '\n# >>> dotfiles bootstrap >>>\nif [[ $EUID -eq %s ]]; then\n  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"\n  if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then\n    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"\n  fi\nfi\n# <<< dotfiles bootstrap <<<\n' "$(id -u)" >> "$temporary_file"
  sudo install -o root -g wheel -m 644 "$temporary_file" "$zshenv"
  rm -f -- "$temporary_file"
  temporary_file=
fi

log 'Install nvm and Node.js 24'
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  temporary_file=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh -o "$temporary_file"
  PROFILE=/dev/null NVM_DIR="$NVM_DIR" /bin/bash "$temporary_file"
  rm -f -- "$temporary_file"
  temporary_file=
fi
[[ -s "$NVM_DIR/nvm.sh" ]] || die 'nvm did not install correctly.'
# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"
nvm install 24
nvm alias default 24
nvm use default

log 'Install Neovim plugins, Mason tools, and Treesitter parsers'
nvim -i NONE --headless \
  '+MasonInstall lua-language-server typescript-language-server html-lsp css-lsp json-lsp tailwindcss-language-server postgres-language-server prettier stylua shfmt htmlhint' \
  '+lua require("nvim-treesitter").install({"html", "javascript", "tsx", "sql"}):wait(300000)' \
  '+lua local r = require("mason-registry"); for _, name in ipairs({"lua-language-server", "typescript-language-server", "html-lsp", "css-lsp", "json-lsp", "tailwindcss-language-server", "postgres-language-server", "prettier", "stylua", "shfmt", "htmlhint"}) do assert(r.is_installed(name), "Mason package missing: " .. name) end; assert(vim.treesitter.language.add("sql"), "SQL parser missing")' \
  +qa

log 'Verify Zsh routing and Brewfile packages'
actual_zdotdir=$(/bin/zsh -lc 'print -r -- "$ZDOTDIR"')
[[ "$actual_zdotdir" == "$config_dir/zsh" ]] || die "Zsh reported ZDOTDIR=$actual_zdotdir"
"$brew_bin" bundle check --file="$config_dir/Brewfile"

log 'Bootstrap complete. Open a new terminal to load the Zsh configuration.'
