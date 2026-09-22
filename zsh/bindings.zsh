# Preserve familiar history navigation when vi mode is unavailable.
if [[ ! -r /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
  bindkey '^[[A' history-search-backward
  bindkey '^[[B' history-search-forward
fi
