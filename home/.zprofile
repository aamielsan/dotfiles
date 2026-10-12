# Login shell setup: environment and PATH. Interactive setup lives in .zshrc.

export EDITOR='nvim'
export VISUAL='nvim'
export LANG='en_US.UTF-8' # tmux needs a UTF-8 locale

typeset -U path # tmux panes are nested login shells; keep PATH free of duplicates
path=(
  # Real git from the Xcode Command Line Tools. /usr/bin/git is an xcrun wrapper
  # that adds ~5ms per call, and the prompt runs git several times per command.
  # If you switch to full Xcode with `xcode-select`, update this path.
  /Library/Developer/CommandLineTools/usr/bin
  $HOME/.local/bin # mise
  $HOME/bin
  $path
)

# mise shims for non-interactive login shells, e.g. Ghostty's tmux command.
# Interactive shells switch to full `mise activate` in .zshrc.
eval "$(mise activate zsh --shims)"
