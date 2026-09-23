# Modern directory listings with concise and detailed variants.
if (($+commands[eza])); then
  # Catppuccin Mocha: text for files, blue for directories, green for executables,
  # flamingo for project files, mauve for source, and lavender for compiled files.
  export EZA_COLORS='fi=38;2;205;214;244:di=38;2;137;180;250:ex=38;2;166;227;161:bu=38;2;242;205;205:sc=38;2;203;166;247:cm=38;2;180;190;254'

  alias ls='eza -1h --color=auto --icons=auto --git'
  alias ll='eza --color=auto --long --git --no-filesize --icons=auto --no-time --no-user --no-permissions'
  alias la='eza --color=auto --long --git --no-filesize --icons=auto --no-time --no-user --no-permissions --all'
  alias lt='eza --long --header --group --git --icons=auto --color=auto'
  alias lta='eza --long --header --group --git --icons=auto --color=auto --all'
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

# Optional Zsh suffix aliases: uncomment the extensions you want to open in nvim.
# For example, typing app.ts at the prompt would run nvim app.ts.
# alias -s js=nvim
# alias -s jsx=nvim
# alias -s ts=nvim
# alias -s tsx=nvim
# alias -s html=nvim
# alias -s css=nvim
# alias -s scss=nvim
# alias -s json=nvim
# alias -s yaml=nvim
# alias -s yml=nvim
# alias -s md=nvim
# alias -s vue=nvim
# alias -s svelte=nvim
# alias -s astro=nvim

alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
alias dots='git -C ~/.config'

# Git: inspect, stage, commit, and push.
alias gs='git status --short --branch'
alias ga='git add'
alias gap='git add -p'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit'
alias gp='git push'

# npm: common project commands.
alias nr='npm run'
alias nd='npm run dev'
alias nb='npm run build'
alias nt='npm test'
alias ni='npm install'
alias nci='npm ci'

if (( $+commands[bat] )); then
  alias cat='bat'
fi
