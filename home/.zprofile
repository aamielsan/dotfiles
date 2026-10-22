# Login shell setup: environment and PATH. Interactive setup lives in .zshrc.

export EDITOR='nvim'
export LANG='en_US.UTF-8' # tmux needs a UTF-8 locale

typeset -U path # tmux panes are nested login shells; keep PATH free of duplicates
path=($HOME/.local/bin $path) # mise

# mise shims for non-interactive login shells, e.g. Ghostty's tmux command.
# Interactive shells switch to full `mise activate` in .zshrc.
eval "$(mise activate zsh --shims)"
