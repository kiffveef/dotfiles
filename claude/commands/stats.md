# Project Statistics

プロジェクト統計情報を表示します。

## Basic Usage

全プロジェクトの統計:

```
/stats
```

## Project Specific

特定プロジェクトの詳細統計:

```
/stats <project_name>
```

## Statistics Type

特定の統計のみ表示:

```
/stats --summary          # 概要のみ
/stats --tech-stack       # 技術スタック別
/stats --timeline         # 時系列推移
/stats --activity         # アクティビティ分析
```

## Execution

1. SQLite MCPを使用してhistory.dbに接続
2. 基本統計クエリ:

```sql
-- プロジェクト別統計
SELECT
  p.name AS project,
  p.tech_stack,
  COUNT(DISTINCT s.id) AS sessions,
  COUNT(DISTINCT c.id) AS conversations,
  COUNT(DISTINCT cc.id) AS code_changes,
  COUNT(DISTINCT l.id) AS learnings,
  datetime(p.created_at, 'localtime') AS created,
  datetime(p.updated_at, 'localtime') AS last_updated
FROM projects p
LEFT JOIN sessions s ON p.id = s.project_id
LEFT JOIN conversations c ON s.id = c.session_id
LEFT JOIN code_changes cc ON s.id = cc.session_id
LEFT JOIN learnings l ON p.id = l.project_id
GROUP BY p.id
ORDER BY conversations DESC;
```

3. テーブル別レコード数:

```sql
SELECT 'projects' AS table_name, COUNT(*) AS count FROM projects
UNION ALL SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL SELECT 'conversations', COUNT(*) FROM conversations
UNION ALL SELECT 'code_changes', COUNT(*) FROM code_changes
UNION ALL SELECT 'learnings', COUNT(*) FROM learnings
UNION ALL SELECT 'commands', COUNT(*) FROM commands;
```

4. 技術スタック別統計:

```sql
SELECT
  json_extract(tech_stack, '$[0]') AS primary_tech,
  COUNT(*) AS project_count,
  SUM(conversations) AS total_conversations
FROM (
  SELECT
    tech_stack,
    COUNT(DISTINCT c.id) AS conversations
  FROM projects p
  LEFT JOIN sessions s ON p.id = s.project_id
  LEFT JOIN conversations c ON s.id = c.session_id
  GROUP BY p.id
)
GROUP BY primary_tech
ORDER BY project_count DESC;
```

5. アクティビティ推移（直近30日）:

```sql
SELECT
  date(c.created_at) AS date,
  COUNT(*) AS conversations,
  COUNT(DISTINCT s.project_id) AS active_projects
FROM conversations c
JOIN sessions s ON c.session_id = s.id
WHERE c.created_at >= datetime('now', '-30 days')
GROUP BY date(c.created_at)
ORDER BY date DESC;
```

6. プロジェクト個別統計:

```sql
-- 基本情報
SELECT
  name,
  tech_stack,
  description,
  datetime(created_at, 'localtime') AS created,
  datetime(updated_at, 'localtime') AS last_updated
FROM projects
WHERE name = '<project_name>';

-- セッション統計
SELECT
  s.task_title,
  COUNT(c.id) AS messages,
  datetime(s.started_at, 'localtime') AS started,
  s.status
FROM sessions s
LEFT JOIN conversations c ON s.id = c.session_id
JOIN projects p ON s.project_id = p.id
WHERE p.name = '<project_name>'
GROUP BY s.id
ORDER BY s.started_at DESC
LIMIT 10;

-- ファイル変更頻度
SELECT
  cc.file_path,
  COUNT(*) AS changes,
  GROUP_CONCAT(DISTINCT cc.change_type) AS change_types
FROM code_changes cc
JOIN sessions s ON cc.session_id = s.id
JOIN projects p ON s.project_id = p.id
WHERE p.name = '<project_name>'
GROUP BY cc.file_path
ORDER BY changes DESC
LIMIT 10;

-- カテゴリ別学習メモ
SELECT
  l.category,
  COUNT(*) AS memo_count,
  GROUP_CONCAT(l.title, ', ') AS titles
FROM learnings l
JOIN projects p ON l.project_id = p.id
WHERE p.name = '<project_name>'
GROUP BY l.category;
```

## Output Format

**全体統計:**
```
📊 Claude支援履歴統計

📁 プロジェクト別統計:
┌─────────────────┬──────────┬──────────────┬─────────────┬──────────┐
│ project         │ sessions │ conversations│ code_changes│ learnings│
├─────────────────┼──────────┼──────────────┼─────────────┼──────────┤
│ backend-api     │ 15       │ 142          │ 38          │ 12       │
│ frontend-app    │ 12       │ 98           │ 25          │ 8        │
│ infrastructure  │ 8        │ 65           │ 15          │ 5        │
└─────────────────┴──────────┴──────────────┴─────────────┴──────────┘

📈 テーブル別レコード数:
- projects: 3
- sessions: 35
- conversations: 305
- code_changes: 78
- learnings: 25
- commands: 150

🔧 技術スタック別:
- Node.js/TypeScript: 2プロジェクト (240会話)
- Python/FastAPI: 1プロジェクト (65会話)
```

**個別プロジェクト統計:**
```
📊 プロジェクト詳細: backend-api

ℹ️ 基本情報:
- 技術スタック: ["Node.js", "TypeScript", "Express", "PostgreSQL"]
- 作成日: 2024-09-15 10:30
- 最終更新: 2024-10-06 20:15

📋 最近のセッション (10件):
1. ユーザー認証機能の実装 (25メッセージ) - 2024-10-06 完了
2. パフォーマンス最適化 (18メッセージ) - 2024-10-05 完了
3. API エンドポイント追加 (15メッセージ) - 2024-10-04 完了

📝 変更頻度の高いファイル:
1. src/auth/jwt.ts (12回) - update, add, refactor
2. src/middleware/auth.ts (8回) - add, update
3. src/routes/user.ts (6回) - update, fix

💡 カテゴリ別学習メモ:
- security (5件): JWT実装, CSRF対策, ...
- performance (4件): クエリ最適化, キャッシング, ...
- architecture (3件): レイヤー設計, DI, ...
```

**アクティビティ推移:**
```
📈 直近30日間のアクティビティ

2024-10-06: ████████████████ 45会話 (3プロジェクト)
2024-10-05: ████████████ 32会話 (2プロジェクト)
2024-10-04: ██████████ 28会話 (2プロジェクト)
2024-10-03: ████ 15会話 (1プロジェクト)
...

📊 サマリー:
- 総会話数: 520
- アクティブ日数: 18日
- 1日平均: 28.9会話
- 最もアクティブ: 2024-10-06 (45会話)
```

## Options Summary

| Option | Description | Example |
|--------|-------------|---------|
| (なし) | 全体統計 | `/stats` |
| `<project>` | プロジェクト詳細 | `/stats backend` |
| `--summary` | 概要のみ | `/stats --summary` |
| `--tech-stack` | 技術スタック別 | `/stats --tech-stack` |
| `--timeline` | 時系列推移 | `/stats --timeline` |
| `--activity` | アクティビティ分析 | `/stats --activity` |
| `--top=N` | 上位N件 | `/stats --top=5` |
| `--days=N` | N日間の統計 | `/stats --days=7` |

## Visualization

グラフ形式で表示（オプション）:

```
/stats --chart             # バーチャート表示
/stats --timeline --chart  # 時系列グラフ
```
