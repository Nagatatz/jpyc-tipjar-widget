---
description: 直近のコード変更を `code-reviewer` エージェントに委譲してレビューし、ビルド・テスト有無の確認と合わせて報告する（`/review`）。
allowed-tools: Read, Glob, Grep, Bash, Task
disable-model-invocation: true
---

# Review

```text
/review                    # 未コミット変更（git diff --name-only と --cached）
/review HEAD~3..HEAD       # git diff --name-only <範囲>
/review <ファイル>
```

1. 対象からドキュメント・設定ファイルを除き、ソース（`src/**/*.res`・`*.resi`）だけにする。
2. `Task(subagent_type="code-reviewer", prompt="Review the following files for project convention compliance: <ファイル>")` を起動する。`run_in_background` は使わず結果を待つ。
3. 自分でも確認する:
   - 変更の意図: `git log --oneline` と変更が一致するか
   - ビルド: `pnpm build`
   - テスト有無: テスト基盤は無い。`src/domain/` のロジック変更なのに検証手段が無ければ WARN
4. 報告:
   ```markdown
   ## Code Review Report
   ### Automated Checks (code-reviewer agent)
   <エージェント出力>
   ### Additional Checks
   | Check | Status | Details |    ← Build PASS/FAIL, Tests exist PASS/WARN, Commit messages PASS/WARN
   ### Recommendations
   - <優先度順>
   ```
