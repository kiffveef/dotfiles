# Token-Efficient Search

File SearchとSerenaを組み合わせた超効率的な検索ワークフローです。

**IMPORTANT: このコマンドは引数なしで実行されます。必ずユーザーに検索クエリを尋ねてください。**

## ユーザーへの質問

検索したいキーワードまたはフレーズを教えてください。

**検索例:**
- `install script` - インストール関連のファイル
- `hook` - フックスクリプト
- `database` - データベース関連
- `MCP config` - MCP設定ファイル
- `error handling` - エラーハンドリングのコード

**オプション指定も可能:**
- `--symbols-only` - 概要のみ表示（最速）
- `--limit=3` - 上位3件のみ
- `--with-body` - 詳細も自動取得

---

## Workflow (検索クエリ取得後に実行)

### Phase 1: File Search (50-100 tokens)

File Search MCPでインデックス検索（最優先）:

1. Query: `<user_query>`
2. Limit: 5 files maximum
3. Output: File paths only
4. Token cost: ~50-100 tokens

### Phase 2: Symbol Overview (200-500 tokens per file)

File Searchの結果に対してのみSerenaを実行:

1. Use `mcp__serena__get_symbols_overview` for each file
2. Get symbol names, types, signatures only
3. No body content yet
4. Token cost: ~200-500 tokens per file

### Phase 3: Targeted Detail (500-2000 tokens per symbol)

ユーザーが必要とするシンボルのみ詳細読み込み:

1. Use `mcp__serena__find_symbol` with `include_body=True`
2. Read only necessary symbols
3. Skip irrelevant code
4. Token cost: ~500-2000 tokens per symbol

## Output Format

結果を優先度順に表示:

```
🔍 検索結果: "<query>"

📁 ファイル候補 (5件):
1. src/auth/jwt.ts (関連度: 高)
2. src/middleware/auth.ts (関連度: 中)
3. src/routes/user.ts (関連度: 中)
...

📊 シンボル構造 (上位3ファイル):

src/auth/jwt.ts:
  - generateToken(payload, options) → string
  - verifyToken(token) → object
  - refreshToken(token) → string

src/middleware/auth.ts:
  - authenticateJWT(req, res, next) → void
  - requireRole(role) → middleware

📝 詳細コード (必要な部分のみ):

[ユーザーが選択したシンボルの実装を表示]
```

## Options

```
/search-efficient <query> --limit=N      # ファイル数制限 (default: 5)
/search-efficient <query> --with-body    # 自動で詳細も取得
/search-efficient <query> --symbols-only # 概要のみ
```

## Token Savings

通常のRead使用と比較:

| 操作 | 通常 | Efficient | 削減率 |
|------|------|-----------|--------|
| ファイル検索 | 5000+ | 50-100 | 98% |
| 概要取得 | 3000+ | 200-500 | 85% |
| 詳細読み込み | 2000+ | 500-1000 | 60% |

**Total: 60-80% reduction**

## Examples

### Basic Search

```bash
/search-efficient "JWT authentication"
```

**実行結果:**
```
🔍 検索結果: "JWT authentication"

📁 ファイル候補 (5件):
1. ✨ src/auth/jwt.ts (関連度: 高)
2. 📄 src/middleware/auth.ts (関連度: 中)
3. 📄 src/routes/user.ts (関連度: 低)

📊 シンボル構造:

src/auth/jwt.ts:
  - generateToken(payload, options) → string
  - verifyToken(token) → object | null
  - refreshToken(token) → string

💡 次のステップ:
詳細を見たいシンボルを指定してください
例: /serena "generateTokenの実装を確認"
```

### With Auto Detail

```bash
/search-efficient "error handling" --with-body
```

**実行結果:**
最も関連性の高いシンボルの実装も自動表示

### Symbols Only

```bash
/search-efficient "database query" --symbols-only
```

**実行結果:**
ファイル一覧とシンボル構造のみ（コード本体なし）

### Limited Results

```bash
/search-efficient "API endpoint" --limit=3
```

**実行結果:**
上位3ファイルのみ分析

## Use Cases

### 1. 機能の場所を特定
```bash
/search-efficient "user registration"
# → どのファイルに実装されているか即座に把握
```

### 2. 実装パターン調査
```bash
/search-efficient "validation middleware"
# → 既存の実装パターンを素早く確認
```

### 3. エラー箇所の特定
```bash
/search-efficient "TypeError: Cannot read"
# → エラーが発生している箇所を高速検索
```

### 4. リファクタリング対象の発見
```bash
/search-efficient "deprecated function"
# → 古い実装を見つけて更新対象を把握
```

## vs 通常検索との比較

| 方法 | トークン | 時間 | 精度 |
|------|----------|------|------|
| Read + Grep | 5000+ | 遅い | 高 |
| Serena only | 3000+ | 中 | 高 |
| **search-efficient** | **500-1500** | **速い** | **高** |

## Tips

1. **最初は--symbols-onlyで全体把握**
   ```bash
   /search-efficient "auth" --symbols-only
   ```

2. **必要な部分だけ詳細取得**
   ```bash
   # 概要確認後、Serenaで詳細取得
   /serena "generateToken関数の実装を表示"
   ```

3. **File Search結果を活用**
   ```bash
   # search-efficientで場所特定 → 直接編集
   /search-efficient "config" --symbols-only
   # → src/config.tsを特定
   # → Editツールで直接修正
   ```