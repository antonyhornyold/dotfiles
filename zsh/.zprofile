# Homebrew's environment for login shells.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Make dotfiles launchers available from project directories.
path=("${XDG_CONFIG_HOME:-$HOME/.config}/bin" $path)
typeset -U path
