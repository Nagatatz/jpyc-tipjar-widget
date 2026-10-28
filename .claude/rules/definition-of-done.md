# Definition of Done (完了定義)

作業の完了条件の SSoT。作業ごとの DoD は GitHub Issue の本文に書き、各 Phase を順に満たす。詳細手順は各参照先を SSoT とする（Issue の作成・DoD の更新の `gh` 手順は `git-workflow` skill の issue モード、並行作業時の着手・「要判断」・手放し方は `issue-workflow.md`）。

## Phase 1: 計画（コード着手前）
- 作業ごとに Issue を 1 つ用意し（無ければ作る）、本文の `## DoD` 節にチェックリストで完了条件を書いてユーザー承認を得る。「すぐ実装して」の場合も DoD は書く
- DoD の各項目はテストやコマンドで確かめられる形にする（→ `testing.md`）。実装とセットで、テストの作成と影響ドキュメント（`README` / `docs/` / `AGENTS.md` / `sphinx-docs/`）の更新を含める
- 要求に解釈の幅がある場合は、仮定とトレードオフを Issue に書いてから着手する。設計の判断も Issue に残す
- `EnterWorktree` で隔離環境を用意する（中規模以上の変更）
- 例外: タイポ・1行設定変更など軽微な修正は Issue 省略可

## Phase 2: 実装（コーディング中）
- 変更コードにコメント規約を適用（→ `code-comments.md`）
- 変更内容に対応するユニットテストを作成・更新（省略時は Issue に理由明記）（→ `test-authoring.md`）
- 影響するドキュメントを実装と同じ作業内で更新する（各ファイルの役割は `docs/repository-structure.md`）
- DoD の項目を満たした都度、Issue 本文の該当項目を `[x]` に更新する。範囲が増えたら項目を追記する
- 最小変更原則を守る（→ `minimal-change.md`）

## Phase 3: コミット前（各コミット前）
- 変更に関連するテストが全件パスし、ビルド・型チェック・リンター（存在するもの）がエラー/警告なし（コマンドは `AGENTS.md`）
- コミットメッセージは絵文字プレフィックス + 英語動詞、1コミット1論理変更（→ `git-conventions.md`）
- Phase 2 で更新したドキュメントが、対応する変更と同一コミットに含まれる

## Phase 4: マージ前（master マージ前）
- Issue の DoD が全項目 `[x]`。PR 本文に `Closes #<Issue 番号>` を書く
- master へのマージ可否をユーザー（hobby workspace では指揮官）に確認する
- セキュリティ関連モジュールの変更があればセキュリティレビューを実施

## Phase 5: マージ後（クリーンアップ）
- 承認後は途中で止めず、worktree 削除・マージ済みブランチ削除・検証まで完了させる（順序・検証手順は `worktree-safety` skill）
