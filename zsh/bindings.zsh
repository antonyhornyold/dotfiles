# zsh-vi-mode calls this after it replaces the initial key bindings.
function zvm_after_init() {
  [[ -r "$ZDOTDIR/fzf.zsh" ]] && source "$ZDOTDIR/fzf.zsh"
  [[ -r /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
}

# Preserve familiar history navigation until vi mode is installed.
if [[ ! -r /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
  bindkey '^[[A' history-search-backward
  bindkey '^[[B' history-search-forward
fi
