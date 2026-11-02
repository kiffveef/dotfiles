# $ZDOTDIR/.zshenv — 全ての zsh (スクリプト・非対話含む) で読まれる。
# ここには環境変数だけを置く。setopt / compinit / zstyle は対話シェル専用なので .zshrc へ。
# XDG_* と ZDOTDIR は ~/.zshenv で定義済み。

# --- PATH ---
# 旧環境では conf.d/cargo.zsh と conf.d/claude.zsh にあった。
# 非対話シェル (スクリプト、ssh 経由のコマンド等) でも cargo/mise のツールを使えるようここへ集約
typeset -U path   # 重複を自動で除去
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
path=("$HOME/.local/bin" $path)

# --- 履歴 (ファイルの場所は非対話でも参照されうるので env 側に置く) ---
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=10000
export SAVEHIST=100000

# --- エディタ ---
export EDITOR=nvim
export GIT_EDITOR=nvim

# --- ページャ ---
if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
