# 機能追加 PR ウォークスルー（ゴールドスタンダード）

`.claude/rules/` 全体に準拠した「中規模機能追加」の模範的な工程例。本例は、(仮想の) Web アプリに「パスワードリセット機能」を追加する想定。

## シナリオ

- **要求:** "ユーザーがログイン画面からパスワードリセットをリクエストできるようにする"
- **規模判定:** 複数ファイル / 不慣れな領域 → steering ワークフロー（→ `.claude/rules/permission-modes.md`）

## Phase 1: 計画（コード着手前）

### 1.1 steering ディレクトリ作成

```bash
mkdir -p .steering/20260512-001-password-reset
```

### 1.2 requirements.md（抜粋）

```markdown
# パスワードリセット機能 要件

## 動機
- セキュリティ: パスワードを覚えていないユーザーが安全にアクセス復旧できる
- UX: サポート問い合わせの 30% がパスワード関連 (運用データ) → セルフサービス化

## 受け入れ条件
- [ ] ログイン画面に「パスワードを忘れた」リンクが存在する
- [ ] メール入力後、登録済みなら 1 時間有効のリセットトークンを生成・送信する
- [ ] 未登録メールでも同じ応答 (アカウント存在の漏洩防止)
- [ ] トークンは 1 回使用で無効化される
- [ ] レート制限: 同一 IP から 5 リクエスト/時間

## 非機能要件
- リセットメール送信は p99 < 2 秒
- トークン生成は CSPRNG ベース (Node.js crypto.randomBytes)
```

### 1.3 design.md（抜粋）

```markdown
## アーキテクチャ
- POST /api/auth/password-reset/request → メール送信
- POST /api/auth/password-reset/confirm → トークン検証 + パスワード更新

## DB 変更
- password_reset_tokens テーブル新設 (id, user_id, token_hash, expires_at, used_at)

## セキュリティ判断
- トークンは平文保存せず SHA-256 ハッシュで保存
- レスポンス時間を一定化 (タイミング攻撃対策)
```

### 1.4 tasklist.md

```markdown
# パスワードリセット タスクリスト

- [ ] DB マイグレーション作成 (password_reset_tokens テーブル)
- [ ] PasswordResetTokenRepository 実装
- [ ] PasswordResetTokenRepository テスト
- [ ] PasswordResetService 実装 (リクエスト処理 + 確認処理)
- [ ] PasswordResetService テスト (受け入れ条件 5 件 + タイミング攻撃テスト)
- [ ] POST /api/auth/password-reset/request エンドポイント実装
- [ ] POST /api/auth/password-reset/confirm エンドポイント実装
- [ ] エンドポイント統合テスト
- [ ] ログイン画面に「パスワードを忘れた」リンク追加 (UI 変更)
- [ ] レート制限ミドルウェア適用
- [ ] sphinx-docs/user/ に機能ページ追加
- [ ] README.md Features 節を更新
- [ ] CLAUDE.md (アーキテクチャ節) を更新
- [ ] main へのマージ
```

→ **ユーザー承認待ち**（→ `.claude/rules/steering-workflow.md`）

## Phase 2: 実装（worktree 隔離）

```bash
# Claude Code のビルトイン worktree 機能
# (実コマンドは EnterWorktree ツール経由)
```

### コミット粒度の模範例

`git-conventions.md`「コミットは最低でも機能単位」に従い、独立した論理変更ごとに分離:

```
1. ✨ Add password_reset_tokens migration and repository
   (DB 変更 + Repository + Repository テスト = 1 コミット)

2. ✨ Add PasswordResetService with rate limiting
   (Service + Service テスト = 1 コミット)

3. ✨ Add password reset API endpoints
   (controller + 統合テスト = 1 コミット)

4. 🎨 Add forgot-password link to login screen
   (UI 変更のみ = 1 コミット)

5. 📝 Document password reset flow in user guide and README
   (sphinx-docs + README + CLAUDE.md = 1 ドキュメント更新コミット)

6. 📝 Mark password-reset tasklist complete and prepare merge
   (tasklist.md の `[x]` 一括更新 = マージ直前の最終コミット)
```

### コメント規約準拠例

```typescript
/**
 * パスワードリセットトークンを生成・送信する。
 *
 * - 既存ユーザーの場合: トークンを発行しメール送信
 * - 未登録ユーザーの場合: 何もしないが、レスポンス時間は同等化
 *   (タイミング攻撃によるアカウント列挙を防ぐ)
 *
 * @param email リクエスト対象のメールアドレス
 * @returns 常に同じ成功レスポンス (情報漏洩防止)
 */
async requestPasswordReset(email: string): Promise<void> {
  // 一定時間遅延でタイミング攻撃を緩和
  const start = Date.now();
  // ...
}
```

### YAGNI / minimal-change 準拠例

- ❌ "将来のために" 通知チャネルを email 以外（SMS / Slack）に拡張可能な Strategy パターンを導入
- ✅ email のみ実装し、SMS が必要になったタイミングで抽象化

- ❌ ついでに隣接するログイン処理のリファクタリング
- ✅ password-reset の差分だけにスコープを限定

## Phase 3: マージ前自己検証

- [ ] `npm test` 全件パス
- [ ] `npm run typecheck` エラー 0
- [ ] `npm run lint` 警告 0
- [ ] `npm run build` 成功
- [ ] tasklist.md 全項目 `[x]`
- [ ] セキュリティ関連変更につき `security-review` skill で点検

## Phase 4: マージとクリーンアップ

→ `.claude/rules/steering-workflow.md`「worktree マージ・クリーンアップ手順」に従い、CWD を main へ移動 → マージ → worktree 削除 → ブランチ削除 → 検証 3 点を実施。

## ポイント

- **検証手段の併設:** 各コミットに対応テストが付随（→ Verification-first 原則）
- **コミット粒度:** UI / ロジック / docs を分離し、レビュー負荷を最小化
- **YAGNI:** 拡張可能性は将来の要求が来てから対応
- **ドキュメント同期:** sphinx-docs / README / CLAUDE.md を同じ PR で更新

## 関連規約

- `.claude/rules/steering-workflow.md` — ワークフロー全体
- `.claude/rules/definition-of-done.md` — Phase 1〜5 完了定義
- `.claude/rules/testing.md` — テスト規約と検証可能ゴール変換
- `.claude/rules/minimal-change.md` — YAGNI + Surgical Changes
- `.claude/rules/documentation.md` — ドキュメント更新規約
