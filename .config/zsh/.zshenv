export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state

setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt inc_append_history
setopt extended_history
setopt print_eight_bit
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
  /usr/sbin /usr/bin /sbin /bin

export HISTFILE=$XDG_STATE_HOME/zsh/history
export HISTSIZE=10000
export SAVEHIST=100000

export EDITOR=nvim
export GIT_EDITOR=nvim

. "$HOME/.cargo/env"

if type bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

