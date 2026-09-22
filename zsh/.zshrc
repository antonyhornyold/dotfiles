# Interactive shell configuration.
[[ -o interactive ]] || return

export EDITOR=nvim
export VISUAL=nvim

# Keep the existing history file so previous commands remain available.
HISTFILE="$HOME/.zhistory"
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_VERIFY

autoload -Uz compinit
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
