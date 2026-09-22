# Preserve the existing eza shortcuts.
if (( $+commands[eza] )); then
  alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
  alias la='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --all'
  alias tr1='eza --color=always --tree --level=2 --git-ignore --git --icons=always --all'
  alias tr2='eza --color=always --tree --level=3 --git-ignore --git --icons=always --all'
fi

alias cl='clear'
alias ..='cd ..'
alias ...='cd ../..'
