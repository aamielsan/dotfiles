# Interactive shell setup. Environment and PATH live in .zprofile.

setopt HIST_IGNORE_ALL_DUPS   # a repeated command replaces its older history entry
bindkey -v                    # vi keys
KEYTIMEOUT=1                  # Esc switches to normal mode after 10 ms instead of 0.4 s
WORDCHARS=${WORDCHARS//[\/]}  # word motions stop at /

# Zim module settings; they must be set before Zim loads.
zstyle ':zim:git' aliases-prefix 'g'       # lowercase git aliases: gf, gr, gb, ...
ZSH_AUTOSUGGEST_MANUAL_REBIND=1            # faster prompts; autosuggestions loads last in .zimrc
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets) # also highlight matching brackets

# mise: put tools on PATH before Zim loads (Zim's fzf module needs fzf).
eval "$(mise activate zsh)"

# Zim: download zimfw on first start, reinstall modules whenever .zimrc
# changes, then load them.
ZIM_HOME=~/.zim
if [[ ! -e $ZIM_HOME/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o $ZIM_HOME/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! $ZIM_HOME/init.zsh -nt ~/.zimrc ]]; then
  source $ZIM_HOME/zimfw.zsh init
fi
source $ZIM_HOME/init.zsh
unalias gh # Zim's git module maps gh to `git help`; keep the GitHub CLI

# k/j in normal mode search history for what's typed so far (Zim's input
# module already binds Up/Down and Ctrl-P/Ctrl-N to the same search).
bindkey -M vicmd k history-substring-search-up
bindkey -M vicmd j history-substring-search-down

# Work aliases. ~/.aliases.work only exists on machines with the mise `work` env.
[[ -f ~/.aliases.work ]] && source ~/.aliases.work

# Worktrees: workmux gives each one its own tmux window.
alias wm='workmux'
alias wma='workmux add'   # wma <branch> [--base upstream/master]
alias wml='workmux ls'
alias wmo='workmux open'  # reopen a closed window
alias wmc='workmux close' # close the window, keep the worktree
alias wmx='workmux rm'    # remove worktree, window and branch

# zoxide (`z <dir>`): must come after compinit, so keep it at the end.
eval "$(zoxide init zsh)"
# z searches the current checkout first, so worktrees of one repo don't jump
# into each other. Falls back to zoxide's own z.
z() {
  local top dir
  if [[ $# -gt 0 && $1 != - && ! -d $1 ]] && top=$(git rev-parse --show-toplevel 2>/dev/null) &&
      dir=$(zoxide query --base-dir $top --exclude $PWD -- "$@" 2>/dev/null); then
    cd $dir
  else
    __zoxide_z "$@"
  fi
}
