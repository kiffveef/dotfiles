# zj-radar に状態を通知する方法 (producer 実装ガイド)

muyu のような自作 CLI やスクリプトから、zellij のサイドバー (zj-radar) に
「作業中 / 返事待ち / 完了」を表示させるための手順。別リポジトリで実装するときの引き継ぎ用。

- 対象バージョン: zj-radar0.11.0 (CLI と wasm は同じリリースに揃える)
- 一次情報: https://github.com/marktoda/zj-radar/blob/main/docs/producers.md
- セットアップ自体は `SETUP_MEMO.md` の「zj-radar」節を参照

## 1. 仕組みと前提

zj-radar は **push 型**。サイドバー (wasm プラグイン) は表示だけを担当し、状態は
producer (エージェントのフックや任意のスクリプト) が `zellij pipe` で送る。
画面やプロセスを覗いて推測することはしない。

したがって、通知しないツールについて zj-radar が分かるのは「フォアグラウンドで
コマンドが動いているか」だけ (コマンド追跡)。これだけでも次は出る。

- `cargo build` / テストなどは「有界の仕事」としてスピナーと経過時間が付く
- プロンプトに戻ると消える
- エディタや pager など対話的なものはスピナーなしで名前だけ

**通知を実装する価値があるのは**、以下のどれかに当たるとき。

- 人間の入力や承認で止まる場面があり、「返事待ち」を目立たせたい (`pending`)
- 工程名など「いま何をしているか」を 1 行で見せたい (`--msg`)
- 失敗を赤で残したい (`error`)
- 完了をサイドバーの履歴 (ledger) と通知に乗せたい (`done`)

muyu はバッチ処理で入力待ちが無いので、素のままでもスピナーは出る。
工程 (define / strip / convert / compare / refine) を表示したい、または失敗を目立たせたい、
という要求が出た時点で実装すればよい。

## 2. 状態の語彙

| status | 意味 | 表示 |
|---|---|---|
| `running` | 作業中 | スピナー。`--msg` が無ければ「working」 |
| `pending` | 人間の入力・承認待ち | ◆ 強調。待ち時間が付く。通知対象 |
| `done` | 完了 | ● 。プロンプトに戻ると履歴へ移る。通知対象 |
| `error` | 失敗 | ✗ 。通知対象 |
| `idle` | 何も無い | 行とタスク名を消す |

注意: **未知の文字列や空文字は `idle` に畳まれ、行が消える**。送る前に必ず検証する。
タイポ 1 つで更新したかった行が消える。

付随する文字列は 2 種類。

- `msg`: いまの活動 (「convert 3/8」など)。60 文字で切られる
- `task`: 粘着するタスク名。空なら前の値を保持。`idle` とプロンプト復帰で消える。60 文字

## 3. 方法 A: `zj-radar notify generic` (シェルから。最も簡単)

CLI が `PATH` にある前提。zellij の外では**何もせず正常終了**するので、
スクリプトに無条件で書いてよい。pane id は `$ZELLIJ_PANE_ID` から自動で取る。

```sh
zj-radar notify generic --status running --msg "convert 3/8" --task "文体変換: report.md" --source build
# … 処理 …
zj-radar notify generic --status done --msg "convert finished" --source build
# 失敗時
zj-radar notify generic --status error --msg "llama-server timeout" --source build
```

| フラグ | 説明 |
|---|---|
| `--status` | 必須。上の 5 値 |
| `--msg` | 活動行 |
| `--task` | 粘着ラベル。省略で保持 |
| `--source` | 行頭のマーク。`test` ⚗ / `build` ⚙ / `deploy` ⇡ / `server` ❯ / `remote` ⇄ / `command` `$`。それ以外 (既定 `generic` や `muyu`) は ⦿ |
| `--dry-run` | 送らず payload を表示 |

`server` と `remote` はスピナーではなく定常マーク (▸) になるので、終わる処理には使わない。
リポジトリ名とブランチは実行ディレクトリの `git` から自動で付く。

### muyu に対する最小の導入

muyu 本体を触らず、シェルのラッパーや zabrze のスニペットで囲むのが最小コスト。

```sh
muyu convert "$@" \
  && zj-radar notify generic --status done  --msg "convert finished" --source build \
  || zj-radar notify generic --status error --msg "convert failed"   --source build
```

開始時の `running` は、muyu 自身がフォアグラウンドで動いていればコマンド追跡が
スピナーを出すので省略できる。

## 4. 方法 B: 生の pipe payload (他言語・別ペインから)

CLI を使わない場合、または **送信元が対象ペインと別** (常駐サーバーが代理で送るなど) の
場合はこちら。`zj_radar.status.v1` という名前で JSON を **broadcast** する
(`--plugin` で宛先指定してはいけない。新しいプラグインインスタンスが立ってしまう)。

```sh
zellij pipe --name zj_radar.status.v1 -- \
  '{"v":1,"source":"muyu","pane":{"type":"terminal","id":12},"status":"running","repo":"muyu","branch":"main","msg":"convert 3/8","task":"文体変換: report.md"}'
```

| フィールド | 規則 |
|---|---|
| `v` | 1 固定 |
| `source` | 小文字。`claude` 等はエージェント扱い、それ以外は上の kind マーク。16 文字 |
| `pane.type` | `"terminal"` 固定 |
| `pane.id` | `$ZELLIJ_PANE_ID` から `terminal_` 接頭辞を外した整数 |
| `status` | 5 値のどれか。**それ以外は idle 扱い** |
| `repo` / `branch` | 任意。40 文字。タブの自動命名にも使われる |
| `msg` / `task` | 任意。60 文字 |
| `tasks` | 任意。バックグラウンドタスクの一覧 (Claude 用。通常は不要) |

未知のフィールドは無視される。ANSI や制御文字は剥がされる。64KB 超は捨てられる。
順序は「最後に届いたものが勝つ」で、シーケンス番号は無い。

### 別ペインのサーバーが代理で送る場合

例: llama-server のような常駐プロセスがリクエスト境界で状態を出したい。
サーバーのペインとクライアントのペインは別なので、**クライアントから pane id を
渡してもらう** 必要がある (HTTP ヘッダー `X-Zellij-Pane: terminal_12` など)。
Claude Code がクライアントなら `ANTHROPIC_CUSTOM_HEADERS` 環境変数で任意ヘッダーを足せる。
ただし Claude Code がクライアントのときはフックが既に状態を送っているので、代理送信は不要。

## 5. 送信の安全規則 (重要)

`zellij pipe` は fire-and-forget ではない。**全プラグインインスタンスが受け取るまで
ブロック**し、権限プロンプトで止まっているインスタンスがあると永久に返らない。
ツール呼び出しごとに送る producer がこれを放置すると、ブロックしたプロセスと
サーバー側の fd が溜まり、zellij サーバーが `EMFILE` で落ちる (実例あり)。

1. **毎回タイムアウトを付ける**。目安は状態の節目 (`done` / `pending` / `error` / `idle`) で 5 秒、
   `running` の心拍で 2 秒。`ZJ_RADAR_PIPE_TIMEOUT` (秒) で上書き可。期限切れで kill しても
   メッセージはサーバー側に積まれているので失われない
2. **自分が kill されてもタイムアウトが生きるようにする**。フックランナーは子を殺すので、
   `sleep <秒>; kill` の番犬を同じサブツリーで detach して走らせる。CLI の
   `notify` はこれを内蔵している。自前で送るときは `zj-radar-core` の
   `self_limiting_pipe_argv` を使うか、同等のラッパーを書く
3. **ランナー側のタイムアウトは送信期限 + 2 秒以上**にする

シェルで自前実装するなら最低限これ。

```sh
timeout 5 zellij pipe --name zj_radar.status.v1 -- "$payload" &
```

## 6. Rust から送る (muyu 本体に組み込む場合)

crates.io の `zj-radar-core` (0.11.0) が wire 形式を提供する。
`StatusPayload` を組み立てて `to_wire` で直列化すれば、手書き JSON のスキーマずれが無い。
`self_limiting_pipe_argv` が番犬付きの `zellij pipe` 引数列を返す。
`DEFAULT_PIPE_TIMEOUT_SECS` / `RUNNING_PIPE_TIMEOUT_SECS` に推奨値がある。

設計上の注意。

- zellij 外 (`$ZELLIJ` 未設定) では送らない。muyu をスキル経由で Claude Code から呼ぶ
  場合も zellij 内だが、そのときは Claude の行が「作業中」になっているので二重表示を避けたい
  なら `$CLAUDECODE` 等で抑制する判断もある
- 並列 (`parallel`) で複数リクエストが走っても pane は 1 つ。`msg` は「convert 3/8」のように
  集約して送り、リクエスト単位で連打しない (`running` の心拍は数秒に 1 回で十分)
- 送信は失敗してもよい副作用として扱い、本処理の結果に影響させない

## 7. 動作確認

サイドバーのあるセッション内で、任意のシェルから。

```sh
# CLI 経由
zj-radar notify generic --status running --msg "hello" --dry-run   # payload を見る
zj-radar notify generic --status running --msg "hello"             # 行が出る
zj-radar notify generic --status done

# 生 pipe
zellij pipe --name zj_radar.status.v1 -- \
  '{"v":1,"source":"test","pane":{"type":"terminal","id":'"${ZELLIJ_PANE_ID#terminal_}"'},"status":"running","msg":"hello"}'

# サイドバーが知っている状態を外から読む (zellij には問い合わせない)
zj-radar state --json
zj-radar state --needs-attention   # pending/error が無ければ exit 1
```

行が出ないときは `docs/troubleshooting.md` を参照。多いのは権限未付与
(サイドバーに「needs permission」) と、`--plugin` 宛先指定による別インスタンス起動。

## 8. ライフサイクルの細則

- `done` / `error` は、ペインがシェルプロンプトに戻ると行から消えて履歴 (ledger) に移る
- 後続の無い `running` は、プロンプト復帰からおよそ 15 秒で消える。終了時は必ず `done` か
  `error` を送り、この自動消去に頼らない
- ペインのルートプロセスが終了すると即消える (`zellij run` のスクリプトペインで効く)
- 同じ内容の `running` を 10 秒以内に再送しても CLI 側で間引かれる
  (`ZJ_RADAR_NO_DEDUP=1` で無効化)
- 通知 (デスクトップ) は状態遷移時のみ、見ていないペインだけ。WSL2 では通知デーモンが
  無いので鳴らない。表示だけで使う前提
