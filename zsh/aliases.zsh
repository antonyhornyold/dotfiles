# Preserve the existing eza shortcuts.
if (( $+commands[eza] )); then
  # Catppuccin Mocha: text for files, blue for directories, green for executables,
  # lavender for project files, and mauve for source code.
  export EZA_COLORS='fi=38;2;205;214;244:di=38;2;137;180;250:ex=38;2;166;227;161:bu=38;2;180;190;254:sc=38;2;203;166;247'

  alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
  alias la='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --all'
  alias tr1='eza --color=always --tree --level=2 --git-ignore --git --icons=always --all'
  alias tr2='eza --color=always --tree --level=3 --git-ignore --git --icons=always --all'
fi

alias cl='clear'
alias ..='cd ..'
alias ...='cd ../..'
