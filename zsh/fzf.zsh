# zsh-vi-mode loads this from zvm_after_init so its key bindings survive.
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
