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

# Up/down (k/j in normal mode) search history for what's typed so far.
# Bound here as well as by the module, so they work before zle-line-init too.
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey $key history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey $key history-substring-search-down
bindkey -M vicmd k history-substring-search-up
bindkey -M vicmd j history-substring-search-down
unset key

# Work aliases. ~/.aliases.work only exists on machines with the mise `work` env.
[[ -f ~/.aliases.work ]] && source ~/.aliases.work

# zoxide (`z <dir>`): must come after compinit, so keep it last.
eval "$(zoxide init zsh)"
