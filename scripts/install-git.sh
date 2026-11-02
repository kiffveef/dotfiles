#!/usr/bin/env bash
# git-core PPA から最新の git を入れる。
# dotfiles を clone する前に実行する想定なので、素の Ubuntu にある道具だけで動くようにしている
# (rg/fd などはまだ無いため grep を使う)。
#
# 使い方:
#   bash install-git.sh
#   GIT_PPA=ppa:git-core/candidate bash install-git.sh   # PPA を差し替える場合
set -euo pipefail

readonly GIT_PPA="${GIT_PPA:-ppa:git-core/ppa}"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# --- 前提チェック ---------------------------------------------------------
[[ -r /etc/os-release ]] || die "/etc/os-release が読めない。Ubuntu 以外では動かない"
# shellcheck source=/dev/null
. /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "Ubuntu 専用 (検出: ${ID:-unknown})"

if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  command -v sudo >/dev/null || die "sudo が無い"
  SUDO="sudo"
fi

# --- PPA 追加 -------------------------------------------------------------
# "ppa:git-core/ppa" -> sources ファイル名に含まれる "git-core" "ppa" で既存判定する。
# 26.04 は deb822 形式 (.sources)、古い版は .list なので両方を見る。
ppa_owner="${GIT_PPA#ppa:}"; ppa_owner="${ppa_owner%%/*}"
ppa_name="${GIT_PPA##*/}"

if grep -rqs "ppa.launchpadcontent.net/${ppa_owner}/${ppa_name}" /etc/apt/sources.list.d/; then
  log "${GIT_PPA} は追加済み。スキップ"
else
  if ! command -v add-apt-repository >/dev/null; then
    log "software-properties-common をインストール"
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq software-properties-common
  fi
  log "${GIT_PPA} を追加 (${VERSION_CODENAME:-?})"
  # PPA 側にこの Ubuntu 版向けのビルドが無いと apt update で 404 になるため、失敗時は明示的に止める
  $SUDO add-apt-repository -y "$GIT_PPA" \
    || die "${GIT_PPA} の追加に失敗。${VERSION_CODENAME:-この版} 向けのビルドが PPA にあるか確認"
fi

# --- git インストール -----------------------------------------------------
before="$(git --version 2>/dev/null || echo 'none')"
log "git をインストール/更新"
$SUDO apt-get update -qq
$SUDO apt-get install -y -qq git

after="$(git --version)"
log "完了: ${before} -> ${after}"
