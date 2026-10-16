# Interactive shell configuration.
[[ -o interactive ]] || return

export EDITOR=nvim
export VISUAL=nvim

if (($+commands[bat])); then
  export MANPAGER="sh -c 'col -bx | bat -plman --color=always | less -R'"
fi

# Keep history in the XDG state directory.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_VERIFY

# Docker Desktop provides completions here for Docker and its CLI plugins.
fpath=("$HOME/.docker/completions" $fpath)

autoload -Uz compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zsh_compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p -- "${zsh_compdump:h}"
compinit -d "$zsh_compdump"
unset zsh_compdump

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/prompt.zsh"

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

zsh-tools-update() {
  brew bundle --file="${XDG_CONFIG_HOME:-$HOME/.config}/Brewfile"
}

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Use Graffiti Archive's pinned Node version when entering its directory tree.
autoload -Uz add-zsh-hook
_graffiti_archive_node() {
  local repo="$HOME/Code/Graffiti_Archive"
  [[ "$PWD" == "$repo" || "$PWD" == "$repo"/* ]] || return 0
  (( $+functions[nvm] )) || return 0
  [[ -r "$repo/.nvmrc" ]] || return 0

  local requested="$(<"$repo/.nvmrc")"
  local resolved="$(nvm version "$requested")"
  if [[ "$resolved" == "N/A" ]]; then
    print -u2 -- "Graffiti Archive needs Node $requested. Run: nvm install $requested"
    return 0
  fi
  [[ "$(nvm current)" == "$resolved" ]] || nvm use --silent "$requested"
}
add-zsh-hook chpwd _graffiti_archive_node
_graffiti_archive_node
