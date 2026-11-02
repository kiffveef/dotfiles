# ~/.zshenv — zsh が最初に読むファイル。ZDOTDIR を決める唯一の場所。
# /etc/zsh/zshenv を編集せずに済むよう、ここで XDG と ZDOTDIR を定義する。
# 実体は dotfiles/home/.zshenv で、~/.zshenv は symlink。

# 値は XDG Base Directory 仕様のデフォルトと同じ。
# 明示しておくのは「未設定なら ~/.foo に書く」実装のツールを XDG 側に寄せるため。
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# ZDOTDIR を変えても、zsh はこの後 $ZDOTDIR/.zshenv を読みにいく
