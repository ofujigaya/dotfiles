if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

GHQ_ROOT_PATH=~/Projects/src
GIT_CLONE_PATH="$GHQ_ROOT_PATH"/github.com/ofujigaya
STOW_PACKAGES_PATH="$GIT_CLONE_PATH"/dotfiles/packages

### User configuration ###
# alias
alias code='open -a "Visual Studio Code"'
alias codei='code-insiders'
alias cat='bat'
alias ls='exa'
alias la='ls -a'
alias ll='ls -lah --git --no-user'
alias lt='ll -TL 3 --ignore-glob=.git --git-ignore'
alias g='git'
alias gll='git log --graph --all --format="%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s"'
alias gb='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# PATH
export PATH=$PATH:$STOW_PACKAGES_PATH/scripts/scripts
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/bin/yarn:$PATH"
export PATH="$HOME/.anyenv/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/src/github.com/bigH/git-fuzzy/bin:$PATH"

# Homebrew auto update
export HOMEBREW_NO_AUTO_UPDATE=1

# anyenv
eval "$(anyenv init -)"

# direnv
eval "$(direnv hook zsh)"

# asdf
. /opt/homebrew/opt/asdf/asdf.sh

### git-fuzzy ###
export GF_BASE_REMOTE=upstream
export GF_BASE_BRANCH=main

### Suggestion ###
# Auto suggestion
autoload -Uz compinit
compinit -C -u
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt list_packed

# GitHub CLI
eval "$(gh completion -s zsh)"

# colors
eval $(gdircolors $HOME/.colors/solarized/dircolors.ansi-dark)
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    else zstyle ':completion:*' list-colors ''
fi

### option ###
setopt auto_cd
setopt correct
setopt no_beep
setopt interactive_comments

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
# zinit light zdharma/history-search-multi-word

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### Configuration for peco
## コマンド履歴検索
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

## コマンド履歴からディレクトリ検索・移動
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi
function peco-cdr () {
    local selected_dir="$(cdr -l | sed 's/^[0-9]* *//' | peco)"
        if [ -n "$selected_dir" ]; then
            BUFFER="cd ${selected_dir}"
            zle accept-line
        fi
    zle clear-screen
}
zle -N peco-cdr
bindkey '^E' peco-cdr

## カレントディレクトリ以下のディレクトリ検索・移動
function find_cd() {
    local selected_dir=$(find . -type d | peco)
        if [ -n "$selected_dir" ]; then
            BUFFER="cd ${selected_dir}"
            zle accept-line
        fi
    zle clear-screen
}
zle -N find_cd
bindkey '^X' find_cd

## gitローカルリポジトリ検索・移動
function peco-src () {
    local selected_dir=$(ghq list -p | peco --prompt "REPOSITORY >" --query "$LBUFFER")
        if [ -n "$selected_dir" ]; then
            BUFFER="cd ${selected_dir}"
            zle accept-line
        fi
    zle clear-screen
}
zle -N peco-src
bindkey '^G' peco-src
