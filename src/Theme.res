/**
 * 見た目テーマ（variant）ごとのスタイル集約モジュール
 *
 * ウィジェットは見た目を 2 つ持つ:
 * - #rich:   rose グラデーション + バッジ + 絵文字を使った装飾的なデザイン（従来）
 * - #simple: 装飾を排した素朴なデザイン（白背景・グレー枠・絵文字最小化）
 *
 * ロジック（状態遷移・送金）は共通で、theme は描画にのみ影響する。
 * 各コンポーネントは `~theme` を受け取り、ここの関数でクラス文字列や表示有無を解決する。
 *
 * 命名: 関数名は「スタイルの用途（slot）」を表す。引数は theme（必要なら追加フラグ）。
 */

/**
 * テーマ種別。payload を持たない polyvariant なので、コンパイル後は
 * JS の文字列 "rich" / "simple" になり、JS / ReScript 双方から授受できる。
 */
type t = [#rich | #simple]

// ルートコンテナ（section）
let container = (theme: t) =>
  switch theme {
  | #rich =>
    "my-6 p-5 md:p-6 rounded-2xl border border-rose-100 bg-gradient-to-br from-rose-50 via-white to-amber-50 shadow-md"
  | #simple => "my-6 p-5 rounded-lg border border-gray-200 bg-white"
  }

// ヘッダの 💴 絵文字を出すか
let showHeaderEmoji = (theme: t) =>
  switch theme {
  | #rich => true
  | #simple => false
  }

// 「Polygon × JPYC」バッジを出すか
let showBadge = (theme: t) =>
  switch theme {
  | #rich => true
  | #simple => false
  }

// 見出し（h3）
let heading = (theme: t) =>
  switch theme {
  | #rich => "text-lg md:text-xl font-bold text-gray-900"
  | #simple => "text-base font-semibold text-gray-900"
  }

// 説明文（p）
let description = (theme: t) =>
  switch theme {
  | #rich => "text-sm text-gray-600 leading-relaxed"
  | #simple => "text-sm text-gray-500 leading-relaxed"
  }

// 主要ボタン（接続 / 送信 / もう一度）の有効時の塗り・文字・装飾部分。
// レイアウト（padding/rounded/inline-flex）は呼び出し側の base に持たせ、ここでは色のみ返す。
let primaryButton = (theme: t) =>
  switch theme {
  | #rich => "bg-rose-600 hover:bg-rose-700 text-white font-semibold shadow-sm transition-colors"
  | #simple => "bg-gray-900 hover:bg-gray-800 text-white font-medium transition-colors"
  }

// 送信ボタンの無効時の塗り
let primaryButtonDisabled = (theme: t) =>
  switch theme {
  | #rich => "bg-rose-300 text-white font-semibold cursor-not-allowed"
  | #simple => "bg-gray-300 text-white font-medium cursor-not-allowed"
  }

// 接続中（待機）ボタンの塗り
let connectingButton = (theme: t) =>
  switch theme {
  | #rich => "bg-rose-400 text-white font-semibold cursor-wait shadow-sm"
  | #simple => "bg-gray-400 text-white font-medium cursor-wait"
  }

// 接続ボタンの 🦊 絵文字を出すか
let showConnectEmoji = (theme: t) =>
  switch theme {
  | #rich => true
  | #simple => false
  }

// 送信 💸 / もう一度 ↻ などのアクション絵文字を出すか
let showActionEmoji = (theme: t) =>
  switch theme {
  | #rich => true
  | #simple => false
  }

// `<details>` の summary（折りたたみ見出し）テキスト色
let foldSummary = (theme: t) =>
  switch theme {
  | #rich =>
    "cursor-pointer list-none flex items-center gap-2 text-sm text-rose-700 hover:text-rose-800 select-none"
  | #simple =>
    "cursor-pointer list-none flex items-center gap-2 text-sm text-gray-600 hover:text-gray-800 select-none"
  }

// NoWallet 時の補助ボックス（白背景の枠）
let subtleBox = (theme: t) =>
  switch theme {
  | #rich => "p-3 rounded-lg bg-white border border-rose-100 text-sm text-gray-700"
  | #simple => "p-3 rounded-lg bg-white border border-gray-200 text-sm text-gray-700"
  }

// テキストリンク（MetaMask インストール導線など）
let link = (theme: t) =>
  switch theme {
  | #rich =>
    "inline-flex items-center gap-1 mt-2 text-rose-700 hover:text-rose-800 underline font-medium"
  | #simple =>
    "inline-flex items-center gap-1 mt-2 text-gray-700 hover:text-gray-900 underline font-medium"
  }

// AmountSelector: 選択中プリセットカード
let presetSelected = (theme: t) =>
  switch theme {
  | #rich => "border-rose-500 bg-rose-50 text-rose-900 ring-2 ring-rose-300"
  | #simple => "border-gray-800 bg-gray-50 text-gray-900 ring-2 ring-gray-300"
  }

// AmountSelector: 未選択プリセットカード
let presetUnselected = (theme: t) =>
  switch theme {
  | #rich => "border-gray-200 bg-white text-gray-800 hover:border-rose-300 hover:bg-rose-50/50"
  | #simple => "border-gray-200 bg-white text-gray-800 hover:border-gray-400 hover:bg-gray-50"
  }

// AmountSelector: カスタム入力のフォーカスリング
let inputFocus = (theme: t) =>
  switch theme {
  | #rich => "focus:ring-2 focus:ring-rose-400 focus:border-rose-400"
  | #simple => "focus:ring-2 focus:ring-gray-400 focus:border-gray-400"
  }

// QrFallback: コンテナ。~primary は QrFallback の強調レベル（#Primary か）。
let qrContainer = (theme: t, ~primary: bool) =>
  switch (theme, primary) {
  | (#rich, true) =>
    "p-4 rounded-2xl border border-rose-200 bg-gradient-to-br from-rose-50 via-white to-amber-50"
  | (#rich, false) => "p-4 rounded-xl border border-gray-200 bg-white"
  | (#simple, true) => "p-4 rounded-lg border border-gray-300 bg-gray-50"
  | (#simple, false) => "p-4 rounded-lg border border-gray-200 bg-white"
  }

// QrFallback: 見出し
let qrHeading = (theme: t, ~primary: bool) =>
  switch (theme, primary) {
  | (#rich, true) => "text-base font-semibold text-rose-900"
  | (#rich, false) => "text-sm font-medium text-gray-700"
  | (#simple, _) => "text-sm font-medium text-gray-700"
  }
