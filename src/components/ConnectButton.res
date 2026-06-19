/**
 * MetaMask 接続ボタン
 *
 * 接続前 / 接続中（スピナー） / 接続後（chip 状の接続済みバッジ）の 3 状態。
 *
 * リデザイン後はブログの色味に合わせて rose 系のカラーで描画する。
 * 接続済み表示は「ボタン」ではなく状態バッジに役割を変えるため、
 * クリック不可で配色も emerald 系に切り替える。
 */

// アドレスを 0x12...abcd に短縮する内部ヘルパ
let shorten = (addr: string): string => {
  let len = String.length(addr)
  if len <= 10 {
    addr
  } else {
    String.slice(addr, ~start=0, ~end=6) ++ "..." ++ String.slice(addr, ~start=len - 4, ~end=len)
  }
}

/**
 * インラインスピナー（CSS のみ。外部依存なし）
 *
 * Tailwind の animate-spin で SVG を回転させる。
 */
module Spinner = {
  @react.component
  let make = () => {
    <svg
      className="animate-spin h-4 w-4 text-white"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24">
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
      />
    </svg>
  }
}

/**
 * @react.component の引数:
 * - ~onClick: ボタン押下時のコールバック（接続済み表示時は呼ばれない）
 * - ~connecting=false: 接続中（スピナー + 無効化）
 * - ~address=?: 接続済みアドレス。Some の場合は emerald chip を表示。
 *   `=?` はオプショナルプロップ（省略時 None）。
 * - ~theme=#rich: 見た目テーマ（rich / simple）。色味のみ切り替える。
 *   接続済み chip は意味のある emerald 色のため theme に依らず共通。
 */
@react.component
let make = (
  ~onClick: unit => unit,
  ~connecting: bool=false,
  ~address: option<string>=?,
  ~theme: Theme.t=#rich,
) => {
  switch (connecting, address) {
  | (false, Some(addr)) =>
    // 接続済み: ボタンではなく状態バッジ風に（emerald は意味のある色なので共通）
    <div
      className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm font-medium"
      title={addr}>
      <span className="w-2 h-2 rounded-full bg-emerald-500" />
      {React.string("接続済み: " ++ shorten(addr))}
    </div>
  | (true, _) =>
    // 接続中: レイアウトは共通、塗りは theme で切替
    <button
      type_="button"
      disabled=true
      className={"inline-flex items-center gap-2 px-4 py-2 rounded-lg " ++ Theme.connectingButton(theme)}>
      <Spinner />
      {React.string("接続中...")}
    </button>
  | (false, None) =>
    // 接続前: 主導線ボタン。塗りは theme、🦊 絵文字は rich のみ
    <button
      type_="button"
      className={"inline-flex items-center gap-2 px-4 py-2.5 rounded-lg " ++ Theme.primaryButton(theme)}
      onClick={_ => onClick()}>
      {Theme.showConnectEmoji(theme)
        ? <span ariaHidden=true> {React.string("🦊")} </span>
        : React.null}
      {React.string("MetaMask で接続して投げ銭")}
    </button>
  }
}

let default = make
