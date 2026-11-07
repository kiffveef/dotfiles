# dotfiles

WSL2 + Ubuntu の開発環境。

## セットアップ

### 1. ディストリビューションのインストール (PowerShell)

```powershell
wsl --install -d Ubuntu-26.04 --name Ubuntu2604 --location D:\_Workspace\wsl\Ubuntu-2604
```

- `--name` を省くとディストリ名は `Ubuntu-26.04` になる。`--location` はインストール先のフォルダで、ディストリ名には影響しない
- 初回起動時の `Help improve Ubuntu!` (テレメトリ) の回答は Windows 側に保存され、以後のディストリでも使われる
- `apt upgrade` で systemd が更新されたら、`wsl --terminate <ディストリ名>` でディストリを再起動する
- 起動時に `Failed to start the systemd user session` が出る場合は「トラブルシューティング」を参照

### 2. 事前準備

```bash
curl -fsSL https://raw.githubusercontent.com/kiffveef/dotfiles/main/scripts/prerequisites.sh | bash
```

- git (git-core PPA)、build-essential (make)、curl を入れる
- 何度実行してもいい

### 3. SSH 鍵

```bash
ssh-keygen -t ed25519 -C "kiffveef@<ディストリ名>"
ssh -T git@github.com
```

- 公開鍵を GitHub (Settings → SSH and GPG keys) に登録してから接続テストする
- 鍵は `~/.ssh/` に置く。別の名前にしたりサブディレクトリに置いたりする場合は、`~/.ssh/config` に `IdentityFile` を書く
- 初回接続のフィンガープリントは [GitHub 公式](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints) と照合し、`yes` と省略せずに入力する
- **deploy 前に済ませること**。deploy 後は GitHub アカウント設定の `insteadOf` で自分のリポジトリへの通信が全て SSH になる

### 4. clone

```bash
git clone https://github.com/kiffveef/dotfiles.git ~/workspace/github.com/kiffveef/dotfiles
cd ~/workspace/github.com/kiffveef/dotfiles
```

- 公開リポジトリなので、HTTPS なら認証なしで clone できる
- 場所は ghq の root (`~/workspace`) に合わせる

### 5. 設定ファイルの配置

```bash
make deploy        # = scripts/deploy.sh
```

- 何が変わるかは、先に `scripts/deploy.sh --dry-run` で確認できる
- 先に git のアカウント一覧を作っておく。`config/git/conf.d/accounts/accounts.list.example` を同じ場所の `accounts.list` にコピーして編集する。GitHub のメールは noreply (`35710205+kiffveef@users.noreply.github.com`) を使う
- 既存のファイルは `~/.local/state/dotfiles/backup/<日時>/` に退避される
- zsh の初回起動で `zsh-newuser-install` が出たら `q` で抜ける (ファイルを作らせない)

### 6. ツールのインストール

```bash
make bootstrap     # = deploy → apt → rust → mise → plugins
```

段階ごとに実行する場合は `make apt` → `make rust` → `make mise` → `make plugins`。

- `apt`: GUI 系の開発ライブラリを含むため、ダウンロードが数百 MB になる
- `rust`: binstall の `WARN ... downloaded from ...` は取得元の報告で、エラーではない
- `rust`: git から入れるツールは `--locked` でビルドする。ビルドに失敗したら、`packages/cargo.txt` でリビジョンを固定する
- `mise`: Ruby はビルド済みバイナリが入る (YJIT 有効)。ソースからビルドしたい場合は、`config/mise/config.toml` の `[settings]` に `ruby.compile = true` を書く
- `plugins`: 初回のシェル起動時に fzf のバイナリがダウンロードされる (curl の進捗が表示される)

### 7. ログインシェル

```bash
chsh -s /usr/bin/zsh
exec zsh
```

- 反映は次回ログインから
- ホーム直下に `~/.zcompdump` が残っていたら消す (補完キャッシュは `~/.cache/zsh/` に作られる)

### 8. GitHub CLI の認証

```bash
gh auth login
```

- `Authentication credentials saved in plain text` と出るのは、WSL にキーリングが無いため。トークンは `~/.config/gh/hosts.yml` (権限 600、リポジトリ外) に保存される

### 9. 手動で持ち込むもの

リポジトリに含めていないもの。旧環境から `/mnt/wsl` 経由でコピーする。

| 対象 | 置き場所 | 注意 |
|---|---|---|
| `CLAUDE.md` | `~/.claude/` | |
| `mcp.json` | `~/.claude/` | API キー入り。`chmod 600`、`/mnt/wsl` から即削除 |
| Claude の memory | `~/.claude/projects/*/memory/` | 必要なら |
| ghq の一覧 | - | 非公開リポジトリの名前を含むため、リポジトリに入れていない |

ほかに手作業で入れるもの:

- Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`。初回起動前に上記ファイルを置く
- claude-plugins: `settings.json` が参照しているため、Claude Code を起動する前に `ghq get kiffveef/claude-plugins` する
- hisho-cli: hisho を ghq get してから `cargo install --path <hisho>/crates/hisho-cli`
- Docker: `make docker`。docker グループへの追加は再ログイン後に有効

### 10. Neovim の初回起動

- Neovim は mise で 0.12 系に固定して入る (`config/mise/config.toml` の `neovim = "0.12"`)。設定は `config/nvim` が `~/.config/nvim` にリンクされる
- プラグイン管理は mini.nvim の mini.deps。初回起動時に `init.lua` が mini.nvim を自動 clone し、他のプラグインも起動中に順次 clone される (ネットワークが必要)
- バージョンはスナップショット `config/nvim/mini-deps-snap` に固定している。自動では適用されないので、初回起動のあと `:DepsSnapLoad` を実行してスナップショットの版に揃える
- プラグインを更新するときは `:DepsUpdate` のあと `:DepsSnapSave` でスナップショットを書き換えてコミットする
- treesitter のパーサ (24言語) は初回起動時に非同期でコンパイルされる。tree-sitter CLI は mise で入り、C コンパイラは事前準備の build-essential を使う。コンパイル前に開いていたバッファはハイライトが付かないので、開き直す
- LSP サーバ (lua_ls, ruby_lsp, dockerls, docker_compose_language_service, ts_ls, eslint, cssls, html, rust_analyzer の9個) は mason が初回起動時に自動インストールする。進捗は `:Mason` で見る。node / ruby は mise のものが使われる
- ruby_lsp は Ruby プロジェクトを初めて開いたときに gem を自動インストールする
- Windows 側に置くもの:
  - `win32yank.exe`: クリップボード連携に必須。`winget install equalsraf.win32yank` で入り、PATH も winget が通す
  - `zenhan.exe` または `im-select.exe`: ノーマルモードに戻ったときに IME を切るために使う。任意で、無ければ警告なしで無効になる。Windows のユーザー PATH が通ったフォルダに置く (PATH の変更は WezTerm を再起動するまで WSL に反映されない)
- `Space ?` でキーマップのチートシート (`config/nvim/cheatsheet.md`) が開く

## 日常の操作

```bash
make help          # メニュー
make update        # apt / rustup / cargo / mise / sheldon をまとめて更新
make deploy        # リンクの張り直し
```

- アプリが設定を書き換えると、symlink 経由でリポジトリに差分が出る。`git status` で確認してコミットする
- アプリが symlink を実ファイルに置き換えることがある (`~/.claude/settings.json` など)。`scripts/deploy.sh --dry-run` で `→` が出るものはリンクが外れている
- 新しく管理したい設定は `links.conf` に1行足して `make deploy`
- 個人情報を含む設定は `*.tmpl` にして、生成されるファイルを `.gitignore` に書く
- git のアカウントを増やすときは `accounts.list` に1行足して `make deploy`。新しいサービスなら `accounts/<service>.conf.tmpl` も作る

## トラブルシューティング

### `Failed to start the systemd user session`

```bash
sudo systemctl daemon-reexec
sudo systemctl reset-failed user@1000.service
sudo systemctl start user@1000.service
```

- WSL 本体と新しい systemd の組み合わせで起きる。再起動のたびに再発する場合は PowerShell で `wsl --update`
- 直らなくても通常の作業はできる。ssh-agent は `config/zsh/conf.d/ssh-agent.zsh` が systemd を使わずに起動する

### Windows の実行ファイルが動かない (`MZ: not found`)

- systemd 有効時に WSLInterop の binfmt 登録が消える既知の問題。`wsl --shutdown` で復旧することが多い

### zellij でコピーした文字が化ける (`❯` → `笶ｯ`)

- `copy_command "clip.exe"` が原因。clip.exe は入力をコンソールのコードページ (CP932) として読むため UTF-8 が化ける
- `config/zellij/config.kdl` の `copy_command` を消すと OSC52 (WezTerm / Windows Terminal が対応) でコピーされ、化けなくなる

