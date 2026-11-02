# Project History

プロジェクトの最近の支援履歴を表示します。

## Basic Usage

最近の履歴を表示（デフォルト20件）:

```
/history
```

## Filtered History

特定プロジェクトの履歴:

```
/history <project_name>
```

## History Type

特定タイプの履歴のみ:

```
/history --conversations   # 会話履歴のみ
/history --code           # コード変更のみ
/history --learnings      # 学習メモのみ
/history --commands       # 実行コマンドのみ
```

## Time Range

期間指定:

```
/history --today          # 今日
/history --week           # 今週
/history --month          # 今月
/history --days=N         # N日以内
```

## Execution

1. SQLite MCPを使用してhistory.dbに接続
2. プロジェクト指定なしの場合:

```sql
SELECT
  p.name AS project,
  s.task_title AS task,
  substr(c.user_message, 1, 60) AS question,
  datetime(c.created_at, 'localtime') AS time
FROM conversations c
JOIN sessions s ON c.session_id = s.id
JOIN projects p ON s.project_id = p.id
ORDER BY c.created_at DESC
LIMIT 20;
```

3. プロジェクト指定ありの場合:

```sql
WHERE p.name = '<project_name>'
```

4. 期間指定の場合:

```sql
-- 今日
WHERE date(c.created_at) = date('now', 'localtime')

-- 今週
WHERE c.created_at >= datetime('now', 'localtime', 'weekday 0', '-7 days')

-- 今月
WHERE c.created_at >= datetime('now', 'localtime', 'start of month')

-- N日以内
WHERE c.created_at >= datetime('now', 'localtime', '-N days')
```

5. タイプ別の場合:

**会話履歴:**
```sql
SELECT
  p.name AS project,
  c.user_message,
  c.assistant_message,
  datetime(c.created_at, 'localtime') AS time
FROM conversations c
JOIN sessions s ON c.session_id = s.id
JOIN projects p ON s.project_id = p.id
ORDER BY c.created_at DESC
LIMIT 20;
```

**コード変更:**
```sql
SELECT
  p.name AS project,
  cc.file_path,
  cc.change_type,
  cc.reason,
  datetime(cc.created_at, 'localtime') AS time
FROM code_changes cc
JOIN sessions s ON cc.session_id = s.id
JOIN projects p ON s.project_id = p.id
ORDER BY cc.created_at DESC
LIMIT 20;
```

**学習メモ:**
```sql
SELECT
  p.name AS project,
  l.category,
  l.title,
  l.content,
  datetime(l.created_at, 'localtime') AS time
FROM learnings l
JOIN projects p ON l.project_id = p.id
ORDER BY l.created_at DESC
LIMIT 20;
```

**コマンド履歴:**
```sql
SELECT
  p.name AS project,
  cmd.command,
  cmd.description,
  cmd.exit_code,
  datetime(cmd.created_at, 'localtime') AS time
FROM commands cmd
JOIN sessions s ON cmd.session_id = s.id
JOIN projects p ON s.project_id = p.id
ORDER BY cmd.created_at DESC
LIMIT 20;
```

## Output Format

**デフォルト表示:**
```
📋 最近の支援履歴 (最新20件)

📁 [project-name] (2024-10-06 20:30)
   タスク: ユーザー認証機能の実装
   質問: JWTトークンの有効期限設定について...

📁 [another-project] (2024-10-06 18:15)
   タスク: パフォーマンス最適化
   質問: データベースクエリを改善したい...
```

**コード変更表示:**
```
📝 コード変更履歴

📁 [project-name] (2024-10-06 20:25)
   📄 src/auth/jwt.ts
   🔄 update: トークン有効期限を24時間に延長

📁 [project-name] (2024-10-06 19:30)
   📄 src/middleware/auth.ts
   ✨ add: JWT検証ミドルウェアを追加
```

**学習メモ表示:**
```
💡 学習メモ

📁 [project-name] (2024-10-05 15:00)
   🏷️ security
   認証のベストプラクティス

   - JWTトークンはHttpOnlyクッキーで保存
   - リフレッシュトークンの実装
   - CSRF対策の重要性
```

## Options Summary

| Option | Description | Example |
|--------|-------------|---------|
| (なし) | 最近20件 | `/history` |
| `<project>` | プロジェクト指定 | `/history backend` |
| `--conversations` | 会話のみ | `/history --conversations` |
| `--code` | コード変更のみ | `/history --code` |
| `--learnings` | 学習メモのみ | `/history --learnings` |
| `--commands` | コマンド履歴のみ | `/history --commands` |
| `--today` | 今日 | `/history --today` |
| `--week` | 今週 | `/history --week` |
| `--month` | 今月 | `/history --month` |
| `--days=N` | N日以内 | `/history --days=7` |
| `--limit=N` | 件数指定 | `/history --limit=50` |

## Combined Options

```
/history backend --code --week        # backendプロジェクトの今週のコード変更
/history --conversations --today      # 今日の全会話
/history myapp --learnings --month    # myappの今月の学習メモ
```
