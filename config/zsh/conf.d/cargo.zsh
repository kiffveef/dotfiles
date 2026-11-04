# git の insteadOf で自分のリポジトリが SSH に書き換わるため、内蔵 libgit2 では認証に失敗する。
# cargo install --git / hagi update が通るよう取得を git CLI に任せる (cargo は XDG 非対応で config.toml を置けない)
export CARGO_NET_GIT_FETCH_WITH_CLI=true
