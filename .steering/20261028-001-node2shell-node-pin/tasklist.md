# tasklist
- [x] Node の版指定箇所と Brotli 展開経路を洗い出す
- [x] docs.yml / release.yml の node-version を `^24.22.1` にする
- [x] changelog (EN) に追記し、`make update-po` で JA .po を更新・翻訳
- [x] テスト省略理由: CI 設定と docs のみの変更でユニットテスト対象のコードが無い。検証は `pnpm build`・`make html` (heavy.sh 経由) と actionlint 相当の YAML 構文確認で行う
- [x] heavy.sh 経由で build を通す
- [x] PR を作って指揮官に報告 (merge は指揮官判断)
