# shellcheck shell=bash
# scripts/ 配下で共有する関数。source して使う (単体実行はしない)。
# prerequisites.sh は clone 前に単体で動かすため、これを読まずに自前で同じものを持っている。

# source 元のスクリプトで使う
# shellcheck disable=SC2034
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 1
readonly DOTFILES_DIR

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
act()  { printf '  \033[33m→\033[0m %s\n' "$*"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# スクリプト先頭のコメントブロック (shebang の次から最初の非コメント行まで) をヘルプとして表示する。
# 行番号で切り出すとコメントを編集するたびにずれるため
print_header_help() {
  awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$1"
}

# root なら sudo なしで実行する
as_root() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  else
    has sudo || die "sudo が無い"
    sudo "$@"
  fi
}

# パッケージ一覧ファイルから「# 以降」と空行を除いた行を出力する
read_list() {
  local file="$1" line
  [[ -r "$file" ]] || die "$file が読めない"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"    # 先頭の空白を除去
    line="${line%"${line##*[![:space:]]}"}"    # 末尾の空白を除去
    [[ -n "$line" ]] && printf '%s\n' "$line"
  done < "$file"
}
