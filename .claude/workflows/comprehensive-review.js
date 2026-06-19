// pztn:260619 マルチエージェント Workflow テンプレート（包括レビュー）
//   起動: Workflow ツールに `{name: "comprehensive-review"}` を渡す、または
//         `args` に対象ファイル配列を渡す（例: ["src/a.ts","src/b.ts"]）。
//   パターン: dimension ごとにレビュー → 各 finding を別エージェントで
//             adversarial verify（pipeline で dimension 完了ごとに検証開始）。
//   ※ Workflow は明示 opt-in 機能。delegate-investigation.md の
//     「Agent vs Workflow 判断」を満たす場合のみ使う。

export const meta = {
  name: 'comprehensive-review',
  description: 'Review changed files across dimensions and adversarially verify each finding',
  phases: [
    { title: 'Review', detail: 'one agent per review dimension' },
    { title: 'Verify', detail: 'adversarially verify each finding' },
  ],
}

// レビュー観点。プロジェクトに合わせて増減してよい。
const DIMENSIONS = [
  { key: 'correctness', prompt: 'ロジックの誤り・境界条件・例外処理の漏れを探せ。' },
  { key: 'security', prompt: '入力検証・認証認可・インジェクション・機密漏洩を探せ。' },
  { key: 'performance', prompt: 'N+1・不要な再計算・メモリ/IO の無駄を探せ。' },
  { key: 'maintainability', prompt: '重複・過剰な抽象化・命名・テスト不足を探せ。' },
]

const TARGET = args && args.length
  ? `次のファイルのみを対象にせよ: ${args.join(', ')}`
  : '現在のブランチの変更（git diff main...HEAD）を対象にせよ。'

const FINDINGS_SCHEMA = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          title: { type: 'string' },
          file: { type: 'string' },
          line: { type: 'number' },
          severity: { type: 'string', enum: ['critical', 'warning', 'info'] },
          detail: { type: 'string' },
        },
        required: ['title', 'file', 'severity', 'detail'],
      },
    },
  },
  required: ['findings'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    isReal: { type: 'boolean' },
    reason: { type: 'string' },
  },
  required: ['isReal', 'reason'],
}

const results = await pipeline(
  DIMENSIONS,
  (d) =>
    agent(`${TARGET}\n\n観点[${d.key}]: ${d.prompt}\n各 finding は file/line/severity/detail を含めること。`, {
      label: `review:${d.key}`,
      phase: 'Review',
      schema: FINDINGS_SCHEMA,
    }),
  (review) =>
    parallel(
      (review?.findings ?? []).map((f) => () =>
        agent(
          `次の指摘を反証せよ（迷ったら isReal=false）。\nタイトル: ${f.title}\nファイル: ${f.file}:${f.line ?? '?'}\n内容: ${f.detail}`,
          { label: `verify:${f.file}`, phase: 'Verify', schema: VERDICT_SCHEMA },
        ).then((v) => ({ ...f, verdict: v })),
      ),
    ),
)

const confirmed = results
  .flat()
  .filter(Boolean)
  .filter((f) => f.verdict?.isReal)

log(`confirmed ${confirmed.length} findings`)
return { confirmed }
