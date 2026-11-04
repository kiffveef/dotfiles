# Zellij設定メモ

## 現在の構成

### バージョン
- **使用中**: Zellij 0.43.1
- **バックアップ**: `~/.cargo/bin/zellij-0.42.0.bak`

### 主な設定

#### キーバインド変更
- **`Ctrl+Q`**: `Detach`に変更(デフォルトは`Quit`)
  - 理由: Zellij0.42/0.43のバグでQuitするとセッションが保存されない
  - 参考: https://github.com/zellij-org/zellij/issues/4499
  - セッションはバックグラウンドで実行され続ける

- **`Ctrl+P` → `n`**: 下方向にペーン分割(`NewPane "Down"`)
  - デフォルトはフローティングペーン

#### セッション選択(fzf)
- **`Ctrl+Z`**: fzfでzellijセッションを選択
- 実装: `~/.config/zsh/conf.d/fzf.zsh`
- 動作:
  - セッションが存在する場合 → fzfでリスト表示、選択してattach
  - セッションが存在しない場合 → 新規セッション作成

## 使い方

### 基本操作
1. `Ctrl+Z` → zellijセッション選択/新規作成
2. 作業
3. `Ctrl+Q` → detach(セッション保持)
4. `Ctrl+Z` → セッション選択してattach

### セッション削除
```bash
# 特定セッションを削除
zellij delete-session <session-name> -f

# 全セッションを削除
zellij delete-all-sessions -y -f
```

### ペーン操作
- `Ctrl+P` → ペーンモード
  - `n`: 下に分割
  - `d`: 下に分割
  - `r`: 右に分割
  - `x`: 現在のペーンを閉じる

## 既知の問題

### Zellij 0.42/0.43のバグ
- 新規セッションでコマンドを実行しないと、セッションが保存されない
- `Quit`コマンドでセッションを終了すると、セッションが完全に削除される
- **回避策**: `Detach`を使用(セッションはバックグラウンドで実行され続ける)

## 設定ファイル
- Zellij設定: `~/.config/zellij/config.kdl`
- fzf連携: `~/.config/zsh/conf.d/fzf.zsh`
- レイアウト: `~/.config/zellij/layouts/default-with-command.kdl`

## バージョンダウングレード方法(必要時)

### 0.42.0に戻す
```bash
mv ~/.cargo/bin/zellij ~/.cargo/bin/zellij-0.43.1.bak
mv ~/.cargo/bin/zellij-0.42.0.bak ~/.cargo/bin/zellij
```

### 0.43.1に戻す
```bash
mv ~/.cargo/bin/zellij ~/.cargo/bin/zellij-0.42.0.bak
mv ~/.cargo/bin/zellij-0.43.1.bak ~/.cargo/bin/zellij
```

## 参考リンク
- Session Resurrection: https://zellij.dev/documentation/session-resurrection.html
- Issue #4499: https://github.com/zellij-org/zellij/issues/4499
- Issue #4536: https://github.com/zellij-org/zellij/issues/4536

## zj-radar (エージェント状態サイドバー)

Claude Code などの状態(作業中 / 返事待ち / 完了)を左サイドバーに表示する。
https://github.com/marktoda/zj-radar

- CLI: `packages/cargo.txt` の `zj-radar` (cargo binstall)
- wasm: `~/.config/zellij/plugins/zj_radar.wasm` は git 管理外。新しいマシンでは以下で再取得する
  ```sh
  zj-radar setup zellij --download --inject -y   # wasm 取得 + alias + layouts/default.kdl + 権限付与
  zj-radar setup claude -y                        # Claude Code プラグイン (settings.json に追記される)
  zj-radar setup --check                          # 診断
  ```
- `layouts/default.kdl` はサイドバー付きレイアウト。tab-bar は無く、タブ一覧はサイドバーが担う
- 更新: `cargo install zj-radar` (binstall) の後 `zj-radar setup zellij --download`。Claude 側は `/plugin update zj-radar-claude@zj-radar`
- 設定キー(density, glyphs, notify など)は `config.kdl` の `radar` alias に書く。managed マーカー内は setup で上書きされるため、変えるならマーカー外に自前の alias を置く
