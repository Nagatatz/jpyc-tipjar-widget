# コミットメッセージ模範例

`.claude/rules/git-conventions.md` に定義された 9 種の絵文字プレフィックスごとに、模範的なコミットメッセージの例を示す。

## 形式

```
<絵文字> <英語動詞で始まる簡潔な説明> (≤ 70 文字)

<本文（任意）: なぜこの変更が必要か / どう動作するか / 関連 issue>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

- **タイトル:** 英語動詞で開始（"Add" / "Fix" / "Update" / "Refactor"）。70 文字以内
- **本文:** "Why" を中心に。"What" は diff が示す
- **Co-Authored-By:** Claude が補助した場合は必須

## 9 種の絵文字別模範例

### ✨ 新機能追加

```
✨ Add OAuth login flow for Google accounts

セッション固定化攻撃を防ぐため state パラメータの検証を含む。
コールバックハンドラのテストカバレッジは 95% を達成。

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### 🐛 バグ修正

```
🐛 Fix session timeout regression in token refresh flow

リフレッシュトークンの有効期限チェックが UTC でなくローカル
タイム比較されていたため、特定タイムゾーンで早期失効。
src/auth/refresh.ts:88 を UTC 統一。再現テストを追加。

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### ♻️ リファクタリング

```
♻️ Extract pagination helper from list endpoints

7 つの list エンドポイントで重複していたページング処理を
src/utils/pagination.ts に抽出。既存テストは無変更でパス。
```

### 📝 ドキュメント更新

```
📝 Update setup guide with uv installation steps

Python 環境セットアップを pip から uv に変更。前提条件と
トラブルシューティング節を更新。
```

### 🎨 UI / スタイル改善

```
🎨 Increase form field spacing for readability on mobile

Material Design ガイドラインに沿って vertical-gap を 12px →
16px に調整。タップターゲットの最小サイズ要件を満たす。
```

### ⚡ パフォーマンス改善

```
⚡ Cache user permissions in Redis for 60s TTL

権限チェックが DB を毎回叩いており API レイテンシ p99 が
180ms。60s TTL の Redis キャッシュ導入で 18ms 達成。
キャッシュ失効テストを追加。
```

### 🔧 設定変更

```
🔧 Bump ESLint to 9.x with flat config migration

eslint.config.js に統合。旧 .eslintrc は削除。
CI lint コマンドは無変更で動作確認済み。
```

### ✅ テスト追加・修正

```
✅ Add regression tests for date-parser edge cases

うるう年・タイムゾーン境界・ISO 8601 拡張形式の 3 ケースを
追加。既知の境界バグは未発見。
```

### 🗑️ 不要コード削除

```
🗑️ Remove deprecated legacy v1 API handlers

v2 移行完了から 3 ヶ月経過。アクセスログで v1 利用 0 件を確認。
関連テストとドキュメントも同時削除（純減 1,200 行）。
```

## 反パターン

```
❌ updated some files                     # 動詞欠如・内容不明
❌ ✨ いろいろ修正                          # 絵文字選択誤り (バグ修正→🐛)・複数変更混在
❌ Fix bug                                # スコープ不明
❌ ✨ Add login feature and refactor auth  # 1 コミット = 1 論理変更 違反
❌ wip                                    # 完了済みコミットに使わない
```

## 関連規約

- `.claude/rules/git-conventions.md` — 絵文字 9 種と判定優先順位
- `.claude/rules/minimal-change.md` — 1 コミット 1 論理変更の根拠
- `.claude/skills/git-workflow/` — コミット自動化スキル
