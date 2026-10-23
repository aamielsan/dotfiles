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
# Worktrees of one repo share one history: folders are recorded under the main
# checkout's path, and z/zi open them in whichever checkout you're in. Worktrees
# are recognised from their .git file, without running git.
eval "$(zoxide init zsh --hook none)" # _zo_add below records directories instead

# reply=(checkout root, main checkout root) for $1 (default $PWD); fails outside a repo.
# A linked worktree's .git file says "gitdir: <main>/.git/worktrees/<name>".
_zo_checkout() {
  local d=${1:-$PWD} gitdir
  while [[ $d != / ]]; do
    if [[ -f $d/.git ]]; then
      read -r gitdir < $d/.git; gitdir=${gitdir#gitdir: }
      [[ $gitdir == /* ]] || gitdir=$d/$gitdir # relative with worktree.useRelativePaths
      gitdir=${gitdir:A}
      # <main>/.git/worktrees/<name>; anything else (a submodule) is its own repo
      [[ ${gitdir:h:t} == worktrees && ${gitdir:h:h:t} == .git ]] && reply=($d ${gitdir:h:h:h}) || reply=($d $d)
      return 0
    fi
    [[ -d $d/.git ]] && { reply=($d $d); return 0 }
    d=${d:h}
  done
  return 1
}
# REPLY=$1, moved into the current checkout if it's in another checkout of the same repo.
_zo_here() {
  local reply top main
  REPLY=$1
  _zo_checkout && top=$reply[1] main=$reply[2] && _zo_checkout $1 && [[ $reply[2] == $main ]] &&
    REPLY=$top${1#$reply[1]}
}
_zo_add() {
  local reply dir=$PWD
  _zo_checkout && [[ $reply[1] != $reply[2] && -d $reply[2]${PWD#$reply[1]} ]] && dir=$reply[2]${PWD#$reply[1]}
  zoxide add -- $dir
}
autoload -Uz add-zsh-hook && add-zsh-hook chpwd _zo_add
z() {
  local dir REPLY
  [[ $1 == -- ]] && shift
  # A full path (what z foo<Space><Tab> inserts) opens in this checkout too
  [[ $# -eq 1 && $1 == /* && -d $1 ]] && _zo_here $1 && [[ -d $REPLY ]] && { cd $REPLY; return }
  if [[ $# -eq 0 || ( $# -eq 1 && ( $1 == - || $1 == [-+]<-> || -d $1 ) ) ]]; then
    __zoxide_z "$@"; return
  fi
  for dir in ${(f)"$(zoxide query -la -- "$@" 2>/dev/null)"}; do
    _zo_here $dir
    [[ $REPLY != $PWD && -d $REPLY ]] && { cd $REPLY; return }
  done
  print -u2 'zoxide: no match found'; return 1
}
zi() {
  local dir REPLY
  dir=$(zoxide query -i -- "$@") || return
  _zo_here $dir; [[ -d $REPLY ]] && cd $REPLY || cd $dir
}
