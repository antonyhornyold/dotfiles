# Modern directory listings with concise and detailed variants.
if (($+commands[eza])); then
  # Catppuccin Mocha: text for files, blue for directories, green for executables,
  # flamingo for project files, mauve for source, and lavender for compiled files.
  export EZA_COLORS='fi=38;2;205;214;244:di=38;2;137;180;250:ex=38;2;166;227;161:bu=38;2;242;205;205:sc=38;2;203;166;247:cm=38;2;180;190;254'

  alias ls='eza -1h --color=auto --icons=auto --git'
  alias ll='eza --color=auto --long --git --no-filesize --icons=auto --no-time --no-user --no-permissions'
  alias la='eza --color=auto --long --git --no-filesize --icons=auto --no-time --no-user --no-permissions --all'
  alias tr1='eza --color=auto --tree --level=2 --git-ignore --git --icons=auto --all'
  alias tr2='eza --color=auto --tree --level=3 --git-ignore --git --icons=auto --all'

  compdef eza=ls
fi

alias cl='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'

alias vim='nvim'
alias df='df -h'

alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
alias dots='git -C ~/.config'
