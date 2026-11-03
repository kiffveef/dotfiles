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

# zsh は .zshenv を1回しか読まないため、ここで ZDOTDIR を変えても $ZDOTDIR/.zshenv は
# 自動では読まれない (変更後の ZDOTDIR が効くのは .zprofile / .zshrc 以降)。明示的に読み込む。
# 子プロセスの zsh は export 済みの ZDOTDIR から直接 $ZDOTDIR/.zshenv を読むので、二重には読まれない
[[ -r "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
