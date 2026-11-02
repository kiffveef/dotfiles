# Search Project History

プロジェクト横断で過去の支援履歴を検索します。

## Quick Search

最も関連性の高い結果を表示（デフォルト5件）:

```
/search <keyword>
```

## Full Search

全ての一致結果を表示:

```
/search <keyword> --all
```

## Search Scope

特定のテーブルのみを検索:

```
/search <keyword> --conversations  # 会話履歴のみ
/search <keyword> --code           # コード変更のみ
/search <keyword> --learnings      # 学習メモのみ
```

## Project Filter

特定プロジェクトに限定:

```
/search <keyword> --project=<project_name>
```

## Execution

1. SQLite MCPを使用してhistory.dbに接続
2. 以下のクエリを実行:

```sql
-- デフォルト検索（全テーブル横断）
SELECT
  p.name AS project,
  'conversation' AS type,
  substr(c.user_message, 1, 100) AS content,
  datetime(c.created_at, 'localtime') AS time
FROM conversations c
JOIN sessions s ON c.session_id = s.id
JOIN projects p ON s.project_id = p.id
WHERE c.user_message LIKE '%<keyword>%'
   OR c.assistant_message LIKE '%<keyword>%'

UNION ALL

SELECT
  p.name AS project,
  'code_change' AS type,
  cc.file_path || ': ' || cc.reason AS content,
  datetime(cc.created_at, 'localtime') AS time
FROM code_changes cc
JOIN sessions s ON cc.session_id = s.id
JOIN projects p ON s.project_id = p.id
WHERE cc.file_path LIKE '%<keyword>%'
   OR cc.reason LIKE '%<keyword>%'

UNION ALL

SELECT
  p.name AS project,
  'learning' AS type,
  l.title || ': ' || substr(l.content, 1, 80) AS content,
  datetime(l.created_at, 'localtime') AS time
FROM learnings l
JOIN projects p ON l.project_id = p.id
WHERE l.title LIKE '%<keyword>%'
   OR l.content LIKE '%<keyword>%'

ORDER BY time DESC
LIMIT 5;  -- デフォルト5件、--allなら削除
```

3. 結果を整形して表示:

```
🔍 検索結果: "<keyword>"

📁 [project-name] (2024-10-06 20:30)
   💬 conversation: ユーザーが認証機能について質問...

📁 [another-project] (2024-10-05 15:20)
   📝 code_change: src/auth.ts: JWT認証を実装

📁 [project-name] (2024-10-03 10:15)
   💡 learning: 認証のベストプラクティス: セッション管理は...
```

4. --projectフィルター指定時は WHERE句に追加:
```sql
AND p.name = '<project_name>'
```

5. --conversationsなど指定時は該当テーブルのみクエリ

## Output Format

結果は以下の形式で表示:
- アイコンで種類を識別（💬会話, 📝コード, 💡学習）
- プロジェクト名、日時を表示
- 内容の要約（100文字以内）
- 関連性の高い順にソート

## Options Summary

| Option | Description | Example |
|--------|-------------|---------|
| (なし) | クイック検索（5件） | `/search 認証` |
| `--all` | 全件表示 | `/search 認証 --all` |
| `--conversations` | 会話履歴のみ | `/search バグ --conversations` |
| `--code` | コード変更のみ | `/search リファクタ --code` |
| `--learnings` | 学習メモのみ | `/search パターン --learnings` |
| `--project=NAME` | プロジェクト指定 | `/search API --project=backend` |
| `--limit=N` | 件数指定 | `/search 最適化 --limit=10` |
