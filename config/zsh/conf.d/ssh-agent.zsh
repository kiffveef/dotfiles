# ssh-agent の接続先を決める。
# systemd --user の ssh-agent.socket が動いていればそれを使い、
# WSL で user session が立ち上がらなかった場合は自前の agent に固定ソケットで繋ぐ。
# 固定ソケットにしているのは、タブ/ペインを開くたびに agent が増殖するのを防ぐため。

() {
  local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}"
  local systemd_sock="${runtime_dir}/ssh-agent.socket"
  local fallback_sock="${XDG_STATE_HOME:-$HOME/.local/state}/ssh-agent.sock"

  # 1. systemd の socket activation が有効ならそれを優先
  if [[ -S "$systemd_sock" ]]; then
    export SSH_AUTH_SOCK="$systemd_sock"
    return
  fi

  # 2. 前回起動した自前 agent が生きていれば再利用
  export SSH_AUTH_SOCK="$fallback_sock"
  ssh-add -l &>/dev/null
  # ssh-add -l の終了コード: 0=鍵あり, 1=鍵なし(agentは生存), 2=接続不可
  (( $? != 2 )) && return

  # 3. 死んだソケットを片付けて新規起動
  mkdir -p "${fallback_sock:h}"
  rm -f "$fallback_sock"
  eval "$(ssh-agent -s -a "$fallback_sock")" >/dev/null
}
