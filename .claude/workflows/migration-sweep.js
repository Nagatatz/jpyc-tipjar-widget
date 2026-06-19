// pztn:260619 マルチエージェント Workflow テンプレート（移行スイープ）
//   起動: Workflow ツールに `{name: "migration-sweep", args: {task: "...変換内容..."}}`。
//   パターン: 変換対象を discover（1エージェント）→ 各対象を pipeline で
//             transform（worktree 隔離で並行編集）→ verify。
//   worktree 隔離はファイルを並行編集して衝突する場合のみ（高コスト）。

export const meta = {
  name: 'migration-sweep',
  description: 'Discover migration sites, transform each in isolation, then verify',
  phases: [
    { title: 'Discover', detail: 'find all sites needing the change' },
    { title: 'Transform', detail: 'apply the change per site (worktree-isolated)' },
    { title: 'Verify', detail: 'confirm each transform builds/tests clean' },
  ],
}

// 変換内容。args.task で上書き可能。
const TASK =
  (args && args.task) ||
  'インライン型注釈を共通型エイリアスに置き換える（具体内容はプロジェクトに合わせて指定）。'

const SITES_SCHEMA = {
  type: 'object',
  properties: {
    sites: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          file: { type: 'string' },
          reason: { type: 'string' },
        },
        required: ['file', 'reason'],
      },
    },
  },
  required: ['sites'],
}

const RESULT_SCHEMA = {
  type: 'object',
  properties: {
    changed: { type: 'boolean' },
    summary: { type: 'string' },
    verified: { type: 'boolean' },
  },
  required: ['changed', 'summary'],
}

phase('Discover')
const discovery = await agent(
  `次の移行作業の対象箇所をすべて列挙せよ（変更はまだ行わない）。\n作業: ${TASK}\n各対象は file と理由を含めること。`,
  { label: 'discover', schema: SITES_SCHEMA },
)

const sites = discovery?.sites ?? []
log(`discovered ${sites.length} sites`)

const results = await pipeline(
  sites,
  (site) =>
    agent(
      `次のファイルに移行を適用せよ。\n作業: ${TASK}\n対象: ${site.file}（理由: ${site.reason}）\n最小差分で行い、変更後に該当ファイルのテスト/型チェックを実行せよ。`,
      { label: `transform:${site.file}`, phase: 'Transform', isolation: 'worktree', schema: RESULT_SCHEMA },
    ),
  (res, site) =>
    agent(
      `次の移行が正しく完了したか検証せよ（ビルド/型/テスト観点）。\n対象: ${site.file}\n適用サマリ: ${res?.summary ?? '(none)'}`,
      { label: `verify:${site.file}`, phase: 'Verify', schema: RESULT_SCHEMA },
    ).then((v) => ({ file: site.file, transform: res, verify: v })),
)

const ok = results.filter(Boolean).filter((r) => r.verify?.verified)
log(`migrated ${ok.length}/${sites.length} sites verified`)
return { results: results.filter(Boolean) }
