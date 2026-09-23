# Give every fzf picker the same compact layout and Catppuccin Mocha colors.
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="
    --height=60%
    --layout=reverse
    --border=rounded
    --info=inline-right
    --prompt='❯ '
    --pointer='›'
    --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8
    --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC
    --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8
    --color=selected-bg:#45475A,border:#6C7086,label:#CDD6F4
  "

  # Search hidden files while respecting ignore rules; keep directories in Ctrl-T.
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --strip-cwd-prefix --exclude .git'
  fi

  if (( $+commands[bat] && $+commands[eza] )); then
    export FZF_CTRL_T_OPTS="
      --preview 'if [ -d {} ]; then eza --tree --level=2 --color=always --icons=auto -- {}; else bat --color=always --style=numbers --line-range=:500 -- {}; fi'
      --preview-window=right:60%:wrap:border-left
    "
  fi

  source <(fzf --zsh)
fi
