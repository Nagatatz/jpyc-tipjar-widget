# Permission Mode 運用規約

Claude Code の Permission Mode（Plan Mode / auto mode / sandbox / accept-edits）と本テンプレートの steering ワークフローの住み分けを明文化する。

## 判断フロー

| 作業の種類 | 推奨モード | 理由 |
|----------|----------|------|
| タイポ修正、1 行の設定変更 | 通常モード（直接実行） | steering / Plan Mode は過剰 |
| 軽微な変更（差分を 1 文で説明できる） | Plan Mode | 探索→実装の小サイクル |
| 中規模以上（複数ファイル、不慣れなコード） | steering ワークフロー | requirements / design / tasklist 必須 |
| CI / 非対話バッチ | auto mode (`--permission-mode auto`) | プロンプト無しで進める |
| 信頼できないコード実行 / 大量ファイル操作 | sandbox | OS レベルの分離 |

## Plan Mode と steering ワークフローの違い

- **Plan Mode** は「セッション内で計画 → 確認 → 実行」の軽量サイクル。Claude Code 標準機能。`Esc Esc` または `--permission-mode plan` で起動。
- **steering ワークフロー** は「`.steering/` にドキュメントを永続化、worktree で隔離、PR 単位でマージ」の重量プロセス。本テンプレート固有規約（`steering-workflow.md` 参照）。

両者は排他ではなく階層関係: Plan Mode で計画した結果が「中規模以上」と判明したら steering に昇格する。

## Think Before Coding（曖昧指示への対応）

> 出典: [Karpathy Guidelines](https://zenn.dev/kotai/articles/050f0220c3f4de) 原則 1。

ユーザー要求に複数の解釈余地がある場合、**黙って一つを選んで実装してはならない**。Plan Mode / steering いずれでも、計画フェーズで以下を実行すること:

- **仮定を明示する:** 「X と解釈して進めます」と宣言してから着手する
- **トレードオフを表面化する:** 複数のアプローチが妥当な場合、選択肢と各々の利点・欠点を提示してユーザーに判断を仰ぐ（例: 認証は「セッションベース vs JWT」）
- **不明点で立ち止まる:** 「何が分からないか」を名指しで質問する。曖昧なまま進めない
- **より簡潔な代替がある場合は提案する:** 要求された実装より小さい解で済むなら指摘する（`minimal-change.md` と連動）

**例外:** 解釈の幅が小さくユーザー意図が明白な場合（タイポ修正等）は宣言を省略してよい。

## auto mode の扱い

`--permission-mode auto` は分類器が破壊的操作を弾くが、本テンプレートの `validate-bash.sh` hook も並行して動作する。CI / バッチ実行では併用、対話セッションでは原則使わない。

## sandbox の扱い

`--sandbox` は信頼できない外部コードの動作確認や、大量のファイル操作を安全に行う場合に有用。本テンプレートのデフォルト規約は sandbox を要求しないが、上記シナリオでは推奨する。

## 関連ドキュメント

- [Choose a permission mode（公式 ja）](https://code.claude.com/docs/ja/permission-modes)
- [Configure permissions（公式 ja）](https://code.claude.com/docs/ja/permissions)
- [Sandboxing（公式 en）](https://code.claude.com/docs/en/sandboxing)
- 本テンプレート: `.claude/rules/steering-workflow.md`
