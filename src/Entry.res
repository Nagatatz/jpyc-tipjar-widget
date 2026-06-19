/**
 * パッケージの公開エントリポイント
 *
 * 使い方の例（ReScript ファイルから）:
 *
 *   <Entry />                          // rich（既定）レイアウト
 *   <Entry variant=#simple />          // simple レイアウト
 *   <Entry recipientAddress="0x..." /> // 受取アドレスを明示指定
 *
 * JS から使う場合（npm パッケージとして import）:
 *
 *   import TipJar from "jpyc-tipjar-widget"
 *   <TipJar variant="simple" recipientAddress="0x..." />
 *
 * `~variant` は見た目テーマ（#rich / #simple）。payload を持たない polyvariant のため
 * コンパイル後は文字列 "rich" / "simple" になり、JS からも文字列で渡せる。
 * 内部では `~theme` という名前で各コンポーネントに伝播する
 * （QrFallback が別軸の `~variant` を持つため、名前衝突を避ける目的）。
 */

@react.component
let make = (~recipientAddress: option<string>=?, ~variant: Theme.t=#rich) => {
  <TipJar ?recipientAddress theme=variant />
}

let default = make
