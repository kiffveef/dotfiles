# hagi更新後のrefreshをリポジトリごとに回るのは手間なので、配置バージョンが古いものをまとめて選んで適用する。
# 引数はそのまま hagi install --refresh に渡す (例: hagi-refresh --dry-run)
function hagi-refresh() {
    local current="$(hagi --version | awk '{print $2}')"
    local version_file

    fd -H -I -t f '^hagi-version$' "$(ghq root)" |
        while read -r version_file; do
            printf '%s\t%s\n' "$(<"$version_file")" "${version_file%/.claude/hagi-version}"
        done |
        awk -F'\t' -v current="$current" '$1 != current' |
        sort |
        fzf -m --bind 'start:select-all' --header="hagi ${current} より古いリポジトリ (Tab: 選択切替, Enter: 実行)" |
        cut -f2 |
        while read -r repo; do
            echo "==> ${repo}"
            # ループが読んでいる一覧をhagiに消費させない。enhancdのcdは標準入力(この一覧)を移動先として読むためbuiltinを使う
            (builtin cd "$repo" && hagi install --refresh "$@" </dev/null)
        done
}
