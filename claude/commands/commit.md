# Git Commit

変更をコミットします。コミットメッセージは自動生成されます。

## Usage

```bash
/commit                    # 全変更をコミット
/commit <message>          # メッセージ指定
/commit --amend            # 直前のコミットを修正
```

## Workflow

### 1. Git状態確認

```bash
git status --porcelain
git diff --cached --stat
```

出力内容を分析:
- 変更ファイル一覧
- 変更の種類（追加/更新/削除）

**IMPORTANT: コミットメッセージの形式はCLAUDE.mdに定義されているルールに従うこと。git logの確認は不要。**

### 2. コミットメッセージ生成

CLAUDE.mdのルールに従って、変更内容から適切なアイコンと要約を自動生成:

**アイコン選択ルール:**
- 新規ファイル追加 → ✨ add
- 既存ファイル更新 → 🔄 update
- バグ修正 → 🐛 fix
- ドキュメント → 📝 docs
- 設定変更 → 🔧 config
- リファクタリング → ♻️ refactor
- 削除 → 🗑️ remove

**メッセージ形式:**
```
<アイコン> <英語の要約> (50文字以内)

- 作業内容1
- 作業内容2
- 作業内容3
```

### 3. コミット実行

```bash
git add <変更ファイル>
git commit -m "$(cat <<'EOF'
<生成されたメッセージ>
EOF
)"
```

### 4. 結果確認

```bash
git log -1 --stat
git status
```

## Options

### --amend (直前のコミット修正)

```bash
/commit --amend
```

**実行内容:**
1. 作者確認: `git log -1 --format='%an %ae'`
2. pushされていないか確認: `git status`
3. 安全確認後に amend実行

**安全チェック:**
- ✅ 作者が自分
- ✅ まだpushされていない
- ❌ 他人のコミット → 新規コミット作成
- ❌ 既にpush済み → 警告

### --staged (ステージング済みのみ)

```bash
/commit --staged
```

**実行内容:**
- `git add`をスキップ
- 既にステージングされた変更のみコミット

### --files (特定ファイルのみ)

```bash
/commit --files=src/auth.ts,src/middleware.ts
```

**実行内容:**
- 指定されたファイルのみ `git add`
- 他の変更は無視

## Examples

### 基本的なコミット

```bash
/commit
```

**実行例:**
```
📊 変更内容を分析中...

変更ファイル:
M  src/auth/jwt.ts
M  src/middleware/auth.ts
A  src/types/auth.d.ts

📝 コミットメッセージ:
✨ Add JWT authentication middleware

- JWT検証ミドルウェアを実装
- 型定義ファイルを追加
- トークン生成処理を更新

✅ コミット完了
[main a1b2c3d] ✨ Add JWT authentication middleware
 3 files changed, 125 insertions(+), 8 deletions(-)
 create mode 100644 src/types/auth.d.ts
```

### メッセージ指定

```bash
/commit "Fix login bug"
```

**実行例:**
```
📊 変更内容:
M  src/routes/auth.ts

📝 コミットメッセージ:
🐛 Fix login bug

- ログイン処理のバグを修正

✅ コミット完了
[main b2c3d4e] 🐛 Fix login bug
 1 file changed, 5 insertions(+), 3 deletions(-)
```

### Amend (前回コミット修正)

```bash
/commit --amend
```

**実行例:**
```
🔍 前回のコミット:
[main c3d4e5f] ✨ Add authentication
Author: user <user@example.com>

✅ 作者確認: あなたのコミット
✅ Push状態: まだpushされていません

📝 変更を追加してamendします:
M  src/auth/jwt.ts (追加の修正)

✅ Amend完了
[main c3d4e5f] ✨ Add authentication
 2 files changed, 130 insertions(+), 8 deletions(-)
```

### 特定ファイルのみ

```bash
/commit --files=README.md
```

**実行例:**
```
📁 対象ファイル: README.md

📝 コミットメッセージ:
📝 Update README

- ドキュメントを更新

✅ コミット完了
[main d4e5f6g] 📝 Update README
 1 file changed, 15 insertions(+), 5 deletions(-)
```

## Commit Message Rules

### 1行目（必須）
- アイコン + 英語の要約
- 50文字以内推奨
- 命令形で記述

### 2行目
- 空行

### 3行目以降（オプション）
- 日本語の箇条書き
- 各項目は「〜を実装」「〜を追加」「〜を修正」形式
- 簡潔な変更の場合は省略可

### アイコン一覧

| アイコン | 種別 | 使用例 |
|---------|------|--------|
| 🌱 first | 初回コミット | Initial commit |
| ✨ add | 新機能追加 | Add user authentication |
| 🔄 update | 既存機能更新 | Update API response format |
| 🐛 fix | バグ修正 | Fix session error on login |
| 🚧 wip | 作業中 | WIP: Implement dashboard |
| 🐤 tweak | 小さな調整 | Tweak button style |
| 📝 docs | ドキュメント | Update API documentation |
| 🎨 style | スタイル/フォーマット | Format code with prettier |
| ♻️ refactor | リファクタリング | Refactor auth module |
| 🧪 test | テスト | Add unit tests for auth |
| 🔧 config | 設定変更 | Update build configuration |
| 🗑️ remove | 削除 | Remove deprecated API |

## Safety Checks

### Pre-commit
1. 変更内容の確認
2. コミットメッセージの妥当性チェック
3. 秘密情報の含有確認（.env等）

### Amend Safety
1. 作者確認（他人のコミットはamendしない）
2. Push状態確認（push済みはamendしない）
3. 安全でない場合は新規コミット作成

### Secret Detection
以下のファイルはコミット前に警告:
- `.env*`
- `credentials.json`
- `*_rsa`, `*_ed25519`
- パスワードを含むファイル

## Error Handling

### No changes to commit
```
❌ コミットする変更がありません

git statusを確認してください:
git status
```

### Merge conflict
```
❌ マージコンフリクトが検出されました

以下のファイルを解決してください:
- src/auth.ts
- src/config.ts

解決後に再度 /commit を実行してください
```

### Amend not safe
```
⚠️  Amendは安全ではありません

理由: 既にpushされています

新規コミットを作成しますか？
→ /commit (新規コミット)
```

## Integration

### With zabrze
手動コミット時にzabrzeの省略形を使用可能:

```bash
# zabrze設定（~/.config/zabrze/git.yaml）
ga  → git add
gc  → git commit
gca → git commit --amend
```

### With hooks
- pre-commit: リンター自動実行
- commit-msg: メッセージ形式チェック
- post-commit: 統計更新
