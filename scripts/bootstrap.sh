#!/usr/bin/env bash
# 開発環境のセットアップを段階ごとに実行する。順序の管理は Makefile 側で行う。
#
# 使い方: scripts/bootstrap.sh <step>
#   apt      packages/apt.txt のパッケージ
#   rust     rustup + cargo-binstall + packages/cargo.txt
#   mise     mise 本体 + ~/.config/mise/config.toml のランタイム
#   plugins  sheldon のプラグイン取得
#   docker   Docker Engine (公式リポジトリ)
#   update   上記すべてを更新
#
# どのステップも何度実行しても同じ結果になる (入っていればスキップ/更新のみ)。
set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# インストーラの URL (差し替え可能にしておく)
readonly RUSTUP_URL="${RUSTUP_URL:-https://sh.rustup.rs}"
readonly BINSTALL_URL="${BINSTALL_URL:-https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh}"
readonly MISE_URL="${MISE_URL:-https://mise.run}"
readonly DOCKER_REPO_URL="${DOCKER_REPO_URL:-https://download.docker.com/linux/ubuntu}"

# 新しいシェルを開かなくても、このスクリプト内で入れたツールを使えるようにする
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# cargo の git 取得をシステムの git に任せる。
# 内蔵の libgit2 だと url.insteadOf (HTTPS→SSH 書き換え) と ssh-agent の扱いが不安定なため
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# --- apt ------------------------------------------------------------------

step_apt() {
  log "apt パッケージ (packages/apt.txt)"
  local -a pkgs
  mapfile -t pkgs < <(read_list "$DOTFILES_DIR/packages/apt.txt")
  ((${#pkgs[@]})) || { ok "対象なし"; return; }
  as_root apt-get update -qq
  as_root apt-get install -y "${pkgs[@]}"
  ok "${#pkgs[@]} 個"
}

# --- rust -----------------------------------------------------------------

install_rustup() {
  if has rustup; then
    ok "rustup ($(rustup --version 2>/dev/null | head -1))"
    return
  fi
  act "rustup をインストール"
  # --no-modify-path: PATH は dotfiles の .zshenv で ~/.cargo/env を読んで通す
  curl --proto '=https' --tlsv1.2 -sSf "$RUSTUP_URL" | sh -s -- -y --no-modify-path
}

install_binstall() {
  if has cargo-binstall; then
    ok "cargo-binstall"
    return
  fi
  act "cargo-binstall をインストール (ビルド済みバイナリ)"
  curl -L --proto '=https' --tlsv1.2 -sSf "$BINSTALL_URL" | bash
}

install_cargo_tools() {
  local -a registry=() line_args
  local line crate installed

  # 先に一度だけ取得する。cargo install --list | grep -q とすると、grep が先に終了した際に
  # cargo が SIGPIPE で落ち、pipefail によって「未インストール」と誤判定されることがある
  installed="$(cargo install --list)"

  while IFS= read -r line; do
    read -ra line_args <<<"$line"
    crate="${line_args[0]}"
    if ((${#line_args[@]} == 1)); then
      registry+=("$crate")
    else
      # git 等: 既にあればスキップ (更新は update ステップで cargo install-update が行う)
      if grep -q "^${crate} " <<<"$installed"; then
        ok "$crate (git)"
      else
        act "$crate を ${line_args[*]:1} からビルド"
        cargo install "${line_args[@]:1}" "$crate"
      fi
    fi
  done < <(read_list "$DOTFILES_DIR/packages/cargo.txt")

  if ((${#registry[@]})); then
    act "crates.io から ${#registry[@]} 個 (インストール済みはスキップ)"
    cargo binstall --no-confirm "${registry[@]}"
  fi
}

step_rust() {
  log "Rust ツールチェーンと cargo ツール"
  install_rustup
  install_binstall
  install_cargo_tools
}

# --- mise -----------------------------------------------------------------

step_mise() {
  log "mise とランタイム"
  if has mise; then
    ok "mise ($(mise --version))"
  else
    act "mise をインストール (~/.local/bin)"
    curl -fsSL "$MISE_URL" | sh
  fi

  [[ -e "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml" ]] \
    || die "mise の設定が無い。先に make deploy を実行すること"

  act "mise install (初回は Ruby のビルド等で時間がかかる)"
  mise install -y
}

# --- sheldon --------------------------------------------------------------

step_plugins() {
  log "sheldon プラグイン"
  has sheldon || die "sheldon が無い。先に make rust を実行すること"
  sheldon lock
  ok "取得完了。新しいシェルで有効になる"
}

# --- docker ---------------------------------------------------------------

step_docker() {
  log "Docker Engine"
  local keyring=/etc/apt/keyrings/docker.asc
  local sources=/etc/apt/sources.list.d/docker.sources

  if [[ -e "$sources" ]]; then
    ok "リポジトリ追加済み"
  else
    # shellcheck source=/dev/null
    . /etc/os-release
    act "公式リポジトリを追加 (${VERSION_CODENAME})"
    as_root install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "$DOCKER_REPO_URL/gpg" | as_root tee "$keyring" >/dev/null
    as_root chmod a+r "$keyring"
    as_root tee "$sources" >/dev/null <<EOF
Types: deb
URIs: $DOCKER_REPO_URL
Suites: $VERSION_CODENAME
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: $keyring
EOF
  fi

  as_root apt-get update -qq
  as_root apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if id -nG "$USER" | grep -qw docker; then
    ok "$USER は docker グループに所属済み"
  else
    act "$USER を docker グループに追加 (再ログイン後に有効)"
    as_root usermod -aG docker "$USER"
  fi
}

# --- update ---------------------------------------------------------------

step_update() {
  log "apt"
  as_root apt-get update -qq
  as_root apt-get upgrade -y

  if has rustup; then
    log "rustup"
    rustup update
  fi
  if has cargo-install-update; then
    log "cargo ツール"
    # -g: git からのものも対象
    cargo install-update -a -g
  fi
  if has mise; then
    log "mise"
    mise self-update -y || warn "mise self-update に失敗 (パッケージ管理で入れた場合は不要)"
    mise upgrade -y
  fi
  if has sheldon; then
    log "sheldon"
    sheldon lock --update
  fi
}

# --------------------------------------------------------------------------

usage() { print_header_help "${BASH_SOURCE[0]}"; }

main() {
  (($# == 1)) || { usage; exit 1; }
  case "$1" in
    apt|rust|mise|plugins|docker|update) "step_$1" ;;
    -h|--help) usage; exit 0 ;;
    *) usage; die "不明なステップ: $1" ;;
  esac
  log "完了: $1"
}

main "$@"
