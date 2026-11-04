#!/usr/bin/env bash
# dotfiles を配置する。
#   1. *.tmpl を描画して同じ場所に生成 (既存ファイルは --force が無い限り上書きしない)
#   2. git のアカウント一覧からアカウント別の設定と user.conf を生成 (内容が変わったときだけ書き込む)
#   3. links.conf に従って symlink を張る (既存の実ファイルはバックアップへ退避)
#
# 使い方:
#   scripts/deploy.sh             # 実行
#   scripts/deploy.sh --dry-run   # 何が起きるかだけ表示
#   scripts/deploy.sh --force     # テンプレートも再生成
#
# テンプレート変数は環境変数で渡すか、未設定なら対話で聞く:
#   VAR=... scripts/deploy.sh
#
# git のアカウントは config/git/conf.d/accounts/accounts.list に書く (書式は accounts.list.example)。
#
# 素の Ubuntu (rg/fd 未導入) でも動くよう bash と coreutils だけで書いている。
set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"   # DOTFILES_DIR, log/ok/act/warn/die

readonly LINKS_FILE="${DOTFILES_LINKS_FILE:-$DOTFILES_DIR/links.conf}"
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backup/$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR

readonly GIT_ACCOUNTS_DIR="$DOTFILES_DIR/config/git/conf.d/accounts"
readonly GIT_ACCOUNTS_LIST="$GIT_ACCOUNTS_DIR/accounts.list"
readonly GIT_USER_CONF="$DOTFILES_DIR/config/git/conf.d/user.conf"
# user.conf の中で使うパス。~/.config/git は config/git への symlink なので、配置先側のパスで書く
# shellcheck disable=SC2088  # git が展開するので ~ のままでよい
readonly GIT_ACCOUNTS_INCLUDE_DIR="~/.config/git/conf.d/accounts"

DRY_RUN=false
FORCE=false

# dry-run 時は実行せず表示だけ
run() {
  if $DRY_RUN; then
    printf '    (dry-run) %s\n' "$*"
  else
    "$@"
  fi
}

usage() { print_header_help "${BASH_SOURCE[0]}"; }

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
  # accounts/ のテンプレートはアカウントごとに描画するので render_git_accounts に任せる
  done 3< <(find "$DOTFILES_DIR" \( -path "$DOTFILES_DIR/.git" -o -path "$GIT_ACCOUNTS_DIR" \) -prune \
              -o -name '*.tmpl' -type f -print0)
  $found || ok "対象なし"
}

# --- git アカウント -------------------------------------------------------

# 生成物を書き込む。内容が同じなら触らない (再実行のたびに差分を出さないため)
write_generated() {
  local out="$1" content="$2"
  local rel="${out#"$DOTFILES_DIR"/}"

  if [[ -f "$out" && "$(<"$out")" == "$content" ]]; then
    ok "$rel"
    return
  fi
  act "$rel を生成"
  if ! $DRY_RUN; then
    printf '%s\n' "$content" > "$out"
    chmod 600 "$out"   # 個人情報を含むので
  fi
}

# テンプレートの {{KEY}} を、名前で渡した連想配列の値に置換して出力する。
# 同じテンプレートを複数アカウントで使うので、render_template と違い環境変数や対話からは引かない
fill_placeholders() {
  local tmpl="$1" context="$3" content key
  # 呼び出し側の変数名と同じだと循環参照になるので、ぶつからない名前にしている
  local -n _fill_values="$2"
  content="$(<"$tmpl")"
  while [[ "$content" =~ \{\{([A-Z_][A-Z0-9_]*)\}\} ]]; do
    key="${BASH_REMATCH[1]}"
    [[ -v "_fill_values[$key]" ]] || die "$context: $key が未指定 (${tmpl#"$DOTFILES_DIR"/} で使用)"
    # 置換文字列をクォートしないと、bash5.2 以降は値の中の & がマッチ文字列に化ける
    content="${content//\{\{$key\}\}/"${_fill_values[$key]}"}"
  done
  printf '%s' "$content"
}

# accounts.list の各行 (<service> <name> [KEY=VALUE ...]) から <service>.conf.tmpl を描画して
# <service>-<name>.conf を作り、それらを読み込む user.conf を生成する。
# GITDIR を持つアカウントはそのディレクトリ配下でだけ有効 (includeIf)、持たないものは既定 (include)
render_git_accounts() {
  log "git アカウントの設定を生成"
  if [[ ! -r "$GIT_ACCOUNTS_LIST" ]]; then
    local msg="${GIT_ACCOUNTS_LIST#"$DOTFILES_DIR"/} が無い (accounts.list.example を元に作ること)"
    if $DRY_RUN; then warn "$msg"; return; fi
    die "$msg"
  fi

  local -a fields defaults=() scoped=() generated=()
  local -A values
  local line service name kv context tmpl file rendered gitdir include
  while IFS= read -r line; do
    read -r -a fields <<<"$line"
    service="${fields[0]}" name="${fields[1]:-}"
    context="$service/$name"
    [[ -n "$name" ]] || die "accounts.list の書式エラー: $line"
    tmpl="$GIT_ACCOUNTS_DIR/$service.conf.tmpl"
    [[ -r "$tmpl" ]] || die "$context: テンプレートが無い (${tmpl#"$DOTFILES_DIR"/})"

    values=([NAME]="$name")
    for kv in "${fields[@]:2}"; do
      [[ "$kv" =~ ^[A-Z_][A-Z0-9_]*= ]] || die "$context: KEY=VALUE の形式でない: $kv"
      values["${kv%%=*}"]="${kv#*=}"
    done

    file="$service-$name.conf"
    # 代入を分けているのは、$(...) 内の die はサブシェルしか終了しないため。
    # 単独の代入なら失敗が set -e に拾われる (引数に直接渡すと空のまま書き込まれる)
    rendered="$(fill_placeholders "$tmpl" values "$context")"
    write_generated "$GIT_ACCOUNTS_DIR/$file" "$rendered"
    generated+=("$file")

    include=$'\tpath = '"$GIT_ACCOUNTS_INCLUDE_DIR/$file"
    gitdir="${values[GITDIR]:-}"
    if [[ -n "$gitdir" ]]; then
      # 末尾の / が無いと配下のリポジトリに一致しない
      scoped+=("[includeIf \"gitdir:${gitdir%/}/\"]"$'\n'"$include")
    else
      defaults+=("[include]"$'\n'"$include")
    fi
  done < <(read_list "$GIT_ACCOUNTS_LIST")

  ((${#defaults[@]} <= 1)) || die "GITDIR の無いアカウント (既定) は1つまで"

  # git は後から読んだ値を優先するので、既定を先に、ディレクトリ別の上書きを後に並べる
  local content="# deploy.sh が accounts.list から生成する。変更は accounts.list に対して行うこと。" block
  for block in "${defaults[@]}" "${scoped[@]}"; do
    content+=$'\n\n'"$block"
  done
  write_generated "$GIT_USER_CONF" "$content"

  # 一覧から消したアカウントの生成物を残すと、どこからも読まれないまま個人情報が残る
  local path keep
  for path in "$GIT_ACCOUNTS_DIR"/*.conf; do
    [[ -e "$path" ]] || continue
    keep=false
    for file in "${generated[@]}"; do
      [[ "${path##*/}" == "$file" ]] && keep=true
    done
    if ! $keep; then
      act "${path#"$DOTFILES_DIR"/} を削除 (accounts.list に無い)"
      run rm "$path"
    fi
  done
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
  render_git_accounts
  link_all
  if [[ -d "$BACKUP_DIR" ]]; then
    log "退避したファイル: $BACKUP_DIR"
  fi
  log "完了"
}

main "$@"
