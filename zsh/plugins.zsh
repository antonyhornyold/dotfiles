plugin=/opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
if [[ -r $plugin ]]; then
  # Initialize bindings now, before fzf installs its own widgets.
  ZVM_INIT_MODE=sourcing
  source "$plugin"
  unset ZVM_INIT_MODE
fi

plugin=/opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r $plugin ]] && source "$plugin"

source "$ZDOTDIR/fzf.zsh"

# Syntax highlighting wraps line-editor widgets, so load it last.
plugin=/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
[[ -r $plugin ]] && source "$plugin"

unset plugin
