# Git Operations

## Commit Guidelines
- **明示的な指示のみ**: ユーザーが明示的に要求した場合のみコミットを作成すること。
- **意味のあるコミットメッセージ**: コミットメッセージは「何を」変更したかではなく、「なぜ」変更したかを説明すること。
- **適切な粒度**: 論理的にまとまった変更を一つのコミットにまとめること。
- **ファイル名を含めない**: コミットメッセージには具体的なファイル名を記載せず、機能や変更内容を説明すること

## Commit Message Format
コミットメッセージは以下の形式で記述すること:

**形式:**
- **1行目**: アイコン + 英語での簡潔な要約(50文字以内推奨)
- **2行目**: 空行
- **3行目以降**: 日本語の箇条書きで簡潔な作業内容(必要に応じて)

**アイコンプレフィックス:**
- 🌱 **first**: Initial commit
- ✨ **add**: Add new feature
- 🔄 **update**: Update existing feature
- 🐛 **fix**: Fix bug
- 🚧 **wip**: Work in progress
- 🐤 **tweak**: Small adjustment
- 📝 **docs**: Documentation
- 🎨 **style**: Code style/formatting
- ♻️ **refactor**: Refactor code
- 🧪 **test**: Add or update tests
- 🔧 **config**: Configuration changes
- 🗑️ **remove**: Remove files or code

**例:**
```
✨ Add user authentication feature

- JWTトークンベースの認証を実装
- ログイン/ログアウトエンドポイントを追加
- Redisによるセッション管理を導入
```

```
🐛 Fix session error on login

- Redis接続タイムアウトを5秒に設定
- セッション保存時のエラーハンドリングを追加
```

```
🔄 Update API response format

- レスポンスにmetaフィールドを追加
- エラーメッセージの形式を統一
```

**重要:**
- 1行目は必ず英語で記述すること
- 2行目以降は箇条書き(-)で簡潔に作業内容を記述すること
- 各項目は「〜を実装」「〜を追加」「〜を修正」など、動詞で終わる形式にすること
- 簡潔な変更の場合は1行目のみでも可
- CLAUDEの署名は不要

## Safety Checks
- **破壊的な操作の回避**: `git push --force`、ハードリセットなどの破壊的な操作は、ユーザーが明示的に要求しない限り実行しないこと。
- **フックのスキップ禁止**: `--no-verify`や`--no-gpg-sign`などのフラグは、ユーザーが明示的に要求しない限り使用しないこと。
