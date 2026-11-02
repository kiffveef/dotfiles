#!/usr/bin/env bash
# dotfiles を配置する。
#   1. *.tmpl を描画して同じ場所に生成 (既存ファイルは --force が無い限り上書きしない)
#   2. links.conf に従って symlink を張る (既存の実ファイルはバックアップへ退避)
#
# 使い方:
#   scripts/deploy.sh             # 実行
#   scripts/deploy.sh --dry-run   # 何が起きるかだけ表示
#   scripts/deploy.sh --force     # テンプレートも再生成
#
# テンプレート変数は環境変数で渡すか、未設定なら対話で聞く:
#   GIT_USER_NAME=... GIT_USER_EMAIL=... GITHUB_USER=... scripts/deploy.sh
#
# 素の Ubuntu (rg/fd 未導入) でも動くよう bash と coreutils だけで書いている。
set -euo pipefail

readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LINKS_FILE="${DOTFILES_LINKS_FILE:-$DOTFILES_DIR/links.conf}"
readonly BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=false
FORCE=false

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
act()  { printf '  \033[33m→\033[0m %s\n' "$*"; }
warn() { printf '  \033[1;33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# dry-run 時は実行せず表示だけ
run() {
  if $DRY_RUN; then
    printf '    (dry-run) %s\n' "$*"
  else
    "$@"
  fi
}

usage() { sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

parse_args() {
  while (($#)); do
    case "$1" in
      -n|--dry-run) DRY_RUN=true ;;
      -f|--force)   FORCE=true ;;
      -h|--help)    usage; exit 0 ;;
      *) die "不明なオプション: $1 (--help を参照)" ;;
    esac
    shift
  done
}

# --- テンプレート ---------------------------------------------------------

# 変数が未設定なら対話で聞いて、その名前のシェル変数に格納する。
# $(...) で呼ぶとサブシェルになり格納が消えるので、呼び出し側は ${!name} で値を読む。
# こうすることで同じ変数が複数テンプレートにあっても1回しか聞かない。
resolve_var() {
  local name="$1" value
  [[ -n "${!name:-}" ]] && return
  # dry-run では入力を求めず、仮の値で描画結果だけ示す
  if $DRY_RUN; then
    printf -v "$name" '<%s>' "$name"
    return
  fi
  [[ -t 0 ]] || die "テンプレート変数 $name が未設定 (非対話環境では環境変数で渡すこと)"
  read -rp "  $name: " value
  [[ -n "$value" ]] || die "$name が空"
  printf -v "$name" '%s' "$value"
}

render_template() {
  local tmpl="$1" out="${1%.tmpl}"
  local rel="${out#"$DOTFILES_DIR"/}"

  if [[ -e "$out" ]] && ! $FORCE; then
    ok "$rel (生成済み。再生成は --force)"
    return
  fi

  local content var
  content="$(<"$tmpl")"
  # {{VAR}} を出現順に、同名のものはまとめて置換
  while [[ "$content" =~ \{\{([A-Z_][A-Z0-9_]*)\}\} ]]; do
    var="${BASH_REMATCH[1]}"
    resolve_var "$var"
    content="${content//\{\{$var\}\}/${!var}}"
  done

  act "$rel を生成"
  if ! $DRY_RUN; then
    printf '%s\n' "$content" > "$out"
    chmod 600 "$out"   # 個人情報を含みうるので
  fi
}

render_templates() {
  log "テンプレートを描画"
  local found=false tmpl
  # find の結果は fd 3 で受ける。stdin で受けるとループ内の read (対話入力) が
  # 端末ではなく find の出力を読んでしまい、-t 0 も偽になる
  while IFS= read -r -d '' tmpl <&3; do
    found=true
    render_template "$tmpl"
  done 3< <(find "$DOTFILES_DIR" -path "$DOTFILES_DIR/.git" -prune -o -name '*.tmpl' -type f -print0)
  $found || ok "対象なし"
}

# --- symlink --------------------------------------------------------------

link_one() {
  local src="$DOTFILES_DIR/$1" dst="${2/#\~/$HOME}"

  [[ -e "$src" ]] || { warn "リポジトリに無い: $1 (スキップ)"; return; }

  # 既に正しいリンク
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ok "$2"
    return
  fi

  # 別の場所を指すリンクは張り替え、実ファイル/ディレクトリはバックアップへ退避
  if [[ -L "$dst" ]]; then
    act "$2 (リンク先を変更: $(readlink "$dst"))"
    run rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup="$BACKUP_DIR/${dst#"$HOME"/}"
    act "$2 (既存を退避 → ${backup/#$HOME/\~})"
    run mkdir -p "$(dirname "$backup")"
    run mv "$dst" "$backup"
  else
    act "$2"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
}

link_all() {
  log "symlink を作成 ($LINKS_FILE)"
  [[ -r "$LINKS_FILE" ]] || die "$LINKS_FILE が読めない"

  local line src dst extra lineno=0
  # render_templates と同じ理由で fd 3 から読む (将来 link_one が対話しても壊れないように)
  while IFS= read -r line <&3 || [[ -n "$line" ]]; do
    ((++lineno))
    line="${line%%#*}"
    read -r src dst extra <<<"$line" || true
    [[ -z "$src" ]] && continue
    [[ -n "$dst" && -z "$extra" ]] || die "$LINKS_FILE:$lineno 書式エラー (<src> <dst> の2列)"
    link_one "$src" "$dst"
  done 3< "$LINKS_FILE"
}

main() {
  parse_args "$@"
  $DRY_RUN && log "dry-run モード (変更はしない)"
  render_templates
  link_all
  if [[ -d "$BACKUP_DIR" ]]; then
    log "退避したファイル: $BACKUP_DIR"
  fi
  log "完了"
}

main "$@"
