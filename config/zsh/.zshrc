# $ZDOTDIR/.zshrc — 対話シェルだけで読まれる。

# --- 履歴の挙動 (旧 .zshenv から移動) ---
setopt share_history
setopt inc_append_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt print_eight_bit

# HISTFILE の親ディレクトリが無いと履歴が保存されないため作っておく
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# --- 補完 (旧 .zshenv から移動) ---
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
  /usr/sbin /usr/bin /sbin /bin

# --- プラグイン ---
# conf.d (fzf/enhancd の設定) より先に読む。旧環境と同じ順序。
# 旧環境では .zshrc と conf.d/cargo.zsh の2か所で sheldon source していたが、
# PATH を .zshenv に移したのでここ1か所で済む
if (( $+commands[sheldon] )); then
  eval "$(sheldon source)"
fi

# --- conf.d/*.zsh を名前順に読み込む ---
# (N) は glob が0件でもエラーにしない修飾子
for conf in "$ZDOTDIR"/conf.d/*.zsh(N); do
  source "$conf"
done
unset conf
