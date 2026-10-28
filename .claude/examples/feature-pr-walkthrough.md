# 機能追加 PR ウォークスルー（ゴールドスタンダード）

`.claude/rules/` 全体に準拠した「中規模機能追加」の模範的な工程例。本例は、(仮想の) Web アプリに「パスワードリセット機能」を追加する想定。

## シナリオ

- **要求:** "ユーザーがログイン画面からパスワードリセットをリクエストできるようにする"
- **規模判定:** 複数ファイル / 不慣れな領域 → Issue に DoD を書き、worktree で実装（→ `permission-modes` skill）

## Phase 1: 計画（コード着手前）

### 1.1 Issue の本文（抜粋）

背景・方針・DoD を 1 つの Issue に書く（フォーマットは `git-workflow` skill の issue モード）。

```markdown
## 背景
- セキュリティ: パスワードを覚えていないユーザーが安全にアクセス復旧できる
- UX: サポート問い合わせの 30% がパスワード関連 (運用データ) → セルフサービス化

## 方針
- POST /api/auth/password-reset/request → メール送信
- POST /api/auth/password-reset/confirm → トークン検証 + パスワード更新
- password_reset_tokens テーブル新設 (id, user_id, token_hash, expires_at, used_at)
- トークンは CSPRNG (crypto.randomBytes) で生成し、平文保存せず SHA-256 ハッシュで保存
- レスポンス時間を一定化 (タイミング攻撃対策)

## DoD
- [ ] ログイン画面に「パスワードを忘れた」リンクが存在する（検証: E2E テスト）
- [ ] 登録済みメールなら 1 時間有効のリセットトークンを生成・送信する（検証: PasswordResetService テスト）
- [ ] 未登録メールでも同じ応答・同等の応答時間になる（検証: PasswordResetService テスト）
- [ ] トークンは 1 回使用で無効化される（検証: エンドポイント統合テスト）
- [ ] 同一 IP から 5 リクエスト/時間を超えると 429（検証: エンドポイント統合テスト）
- [ ] リセットメール送信が p99 < 2 秒（検証: 負荷テスト）
- [ ] テスト: Repository / Service / エンドポイント統合テストを追加し `npm test` が全件パス
- [ ] ドキュメント: sphinx-docs/user/ の機能ページ、README の Features 節、AGENTS.md のアーキテクチャ節

## 対象外
- メール以外の通知チャネル (SMS / Slack)
```

→ **ユーザーが DoD を承認してから着手**（→ `.claude/rules/definition-of-done.md` Phase 1）

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
   (sphinx-docs + README + AGENTS.md = 1 ドキュメント更新コミット)
```

DoD の項目は、満たしたことを確かめた都度 Issue の本文で `[x]` にする（コミットには含めない）。

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
- [ ] Issue の DoD が全項目 `[x]`、PR 本文に `Closes #<Issue 番号>`
- [ ] セキュリティ関連変更につき `redblue-audit` skill で点検

## Phase 4: マージとクリーンアップ

→ `worktree-safety` skill のマージ・クリーンアップ手順に従い、CWD を main へ移動 → マージ → worktree 削除 → ブランチ削除 → 検証 3 点を実施。

## ポイント

- **検証手段の併設:** 各コミットに対応テストが付随（→ Verification-first 原則）
- **コミット粒度:** UI / ロジック / docs を分離し、レビュー負荷を最小化
- **YAGNI:** 拡張可能性は将来の要求が来てから対応
- **ドキュメント同期:** sphinx-docs / README / AGENTS.md を同じ PR で更新

## 関連規約

- `.claude/rules/definition-of-done.md` — Issue の DoD と Phase 1〜5 完了定義
- `.claude/rules/testing.md` — テスト規約と検証可能ゴール変換
- `.claude/rules/minimal-change.md` — YAGNI + Surgical Changes
- `.claude/rules/definition-of-done.md` Phase 3 — ドキュメント更新（旧 documentation.md を統合）
