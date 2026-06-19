// pztn:260619 マルチエージェント Workflow テンプレート（リサーチ fan-out）
//   起動: Workflow ツールに `{name: "research-fanout", args: "調査したい問い"}`。
//   パターン: multi-modal sweep（観点別に並行探索）→ 各観点を deep-read →
//             synthesize（全結果を1エージェントで統合 = barrier が正当）。

export const meta = {
  name: 'research-fanout',
  description: 'Multi-modal codebase sweep, deep-read each angle, then synthesize',
  phases: [
    { title: 'Sweep', detail: 'parallel search from different angles' },
    { title: 'Synthesize', detail: 'merge all angles into one answer' },
  ],
}

const QUESTION =
  (typeof args === 'string' && args) ||
  (args && args.question) ||
  'このコードベースの認証フローはどう実装されているか。'

// 探索観点。問いに応じて入れ替えてよい。
const ANGLES = [
  { key: 'by-entrypoint', prompt: 'エントリポイント/ルーティングから辿って関係箇所を特定せよ。' },
  { key: 'by-keyword', prompt: '関連キーワード（grep）で定義・参照箇所を網羅せよ。' },
  { key: 'by-data', prompt: 'データモデル/スキーマ/設定の観点から関係箇所を特定せよ。' },
  { key: 'by-test', prompt: 'テスト/フィクスチャから期待挙動と仕様を読み取れ。' },
]

const ANGLE_SCHEMA = {
  type: 'object',
  properties: {
    findings: { type: 'array', items: { type: 'string' } },
    files: { type: 'array', items: { type: 'string' } },
  },
  required: ['findings', 'files'],
}

// barrier: 統合には全観点の結果が同時に必要。
const swept = await parallel(
  ANGLES.map((a) => () =>
    agent(`問い: ${QUESTION}\n観点[${a.key}]: ${a.prompt}\n発見事項と関連ファイルを返せ。`, {
      label: `sweep:${a.key}`,
      phase: 'Sweep',
      schema: ANGLE_SCHEMA,
    }),
  ),
)

const merged = swept.filter(Boolean)
const allFiles = [...new Set(merged.flatMap((m) => m.files ?? []))]
const allFindings = merged.flatMap((m) => m.findings ?? [])
log(`swept ${merged.length} angles, ${allFiles.length} files`)

phase('Synthesize')
const answer = await agent(
  `次の問いに、複数観点の調査結果を統合して回答せよ。\n問い: ${QUESTION}\n\n` +
    `関連ファイル:\n${allFiles.map((f) => `- ${f}`).join('\n')}\n\n` +
    `発見事項:\n${allFindings.map((f) => `- ${f}`).join('\n')}\n\n` +
    '矛盾があれば明示し、未確認の箇所は「要確認」と注記せよ。',
  { label: 'synthesize' },
)

return { question: QUESTION, files: allFiles, answer }
