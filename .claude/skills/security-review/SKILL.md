---
description: Red Team（攻撃者）/ Blue Team（防御者）の 2 エージェントでセキュリティレビューし、ギャップを統合レポートにする。`/security-review [<範囲>|<ファイル>]` で起動。
allowed-tools: Read, Glob, Grep, Bash, Task
disable-model-invocation: true
effort: xhigh
---

# Security Review

```text
/security-review                    # 未コミット変更（git diff --name-only と --cached）
/security-review HEAD~3..HEAD       # git diff --name-only <範囲>
/security-review <ファイル>
```

## 手順

1. **対象**: 設定ファイルは含め、`.md` は除く。0 件なら「レビュー対象のファイルがありません」と報告して終了。
2. **2 エージェントを同じメッセージで並列起動**する（逐次にしない、`run_in_background` は使わない）。このリポジトリに `red-team` / `blue-team` エージェントは無いので、`.claude/agents/security-reviewer.md` を役割を変えて 2 回使う:
   ```text
   Task(subagent_type="security-reviewer", prompt="Red Team（攻撃者視点）として次のファイルの脅威を分析し、脅威ごとに深刻度・ファイル:行を返して: <ファイル>")
   Task(subagent_type="security-reviewer", prompt="Blue Team（防御者視点）として次のファイルの既存の防御・緩和策を評価して: <ファイル>")
   ```
3. **突き合わせ**: Red の各脅威に Blue の防御を対応させ、防御の無いもの（ギャップ）に推奨対策と優先度を付ける。
4. **レポート**:
   ```markdown
   ## Security Review Report
   ### レビュー対象
   ### Threat Analysis (Red Team)      ← 出力をそのまま
   ### Defense Assessment (Blue Team)  ← 出力をそのまま
   ### Confrontation Matrix
   | # | 脅威 | 深刻度 | 現在の防御 | ギャップ | 推奨対策 | 対応優先度 |
   ### Action Items                     ← ギャップのみ、[Critical]→[Low] 順に「項目 — ファイル:行 — 対策」
   ### Summary                          ← 脅威総数 / 防御確認数 / ギャップ数 / 優先度別内訳
   ```

静的分析なので、悪用可能性が不確かなもの・false positive の可能性があるものはその旨を書く。
