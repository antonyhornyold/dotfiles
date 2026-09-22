plugin=/opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
if [[ -r $plugin ]]; then
  source "$plugin"
else
  source "$ZDOTDIR/fzf.zsh"
fi

plugin=/opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r $plugin ]] && source "$plugin"

# Syntax highlighting wraps line-editor widgets, so load it last.
if [[ ! -r /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
  plugin=/opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
  [[ -r $plugin ]] && source "$plugin"
fi

unset plugin
