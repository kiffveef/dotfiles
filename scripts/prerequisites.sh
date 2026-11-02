#!/usr/bin/env bash
# dotfiles を clone して make を使えるようにするまでの事前準備。
#   - git (git-core PPA の最新版)
#   - build-essential (make を含む。Ruby のビルドにも必要)
#   - curl, ca-certificates (後続のインストーラ取得用)
#
# clone 前に単体で実行する想定なので、scripts/lib.sh には依存しない。
# 素の Ubuntu にある道具だけで動くようにしている (rg/fd などはまだ無いため grep を使う)。
#
# 使い方:
#   curl -fsSL https://raw.githubusercontent.com/kiffveef/dotfiles/main/scripts/prerequisites.sh | bash
#   GIT_PPA=ppa:git-core/candidate bash prerequisites.sh   # PPA を差し替える場合
set -euo pipefail

readonly GIT_PPA="${GIT_PPA:-ppa:git-core/ppa}"
readonly BASE_PACKAGES=(git build-essential curl ca-certificates)

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

# --- git-core PPA ---------------------------------------------------------
# "ppa:git-core/ppa" -> sources ファイル内の URL で既存判定する。
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

# --- 基本パッケージ -------------------------------------------------------
git_before="$(git --version 2>/dev/null || echo 'none')"
log "インストール/更新: ${BASE_PACKAGES[*]}"
$SUDO apt-get update -qq
$SUDO apt-get install -y -qq "${BASE_PACKAGES[@]}"

log "git: ${git_before} -> $(git --version)"
log "make: $(make --version | head -1)"
log "完了。次は dotfiles を clone して make bootstrap"
