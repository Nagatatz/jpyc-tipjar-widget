/**
 * EIP-681 (`ethereum:` URI) 生成モジュール
 *
 * EIP-681 は ERC-20 transfer などのオンチェーン操作を URI で表現する仕様。
 * モバイルウォレット (MetaMask Mobile, Rainbow など) はこの URI を含む QR を
 * 読み取ると送金画面を直接開ける。
 *
 * 仕様: https://eips.ethereum.org/EIPS/eip-681
 *
 * 形式:
 *   ethereum:<token>@<chainId>/transfer?address=<to>&uint256=<amount-wei>
 *
 * `<token>` は JPYC のコントラクトアドレス（Polygon mainnet 上）、
 * `<chainId>` は十進整数（Polygon = 137）、
 * `<amount-wei>` は小数点なしの整数（wei 単位）。本プロジェクトでは
 * `TipAmount.t` (bigint, decimals=18 を反映済み) をそのまま bigint→string に変換する。
 */

/**
 * JPYC transfer を表現する EIP-681 URI を生成する
 *
 * 引数:
 * - ~recipient: 受取アドレス (0x...)
 * - ~amount: option<TipAmount.t>
 *   - Some(_): `uint256` クエリパラメータを付与する（受取ウォレットで初期値として表示される）
 *   - None: クエリパラメータなし。受取側ウォレットでユーザーが手動入力する
 *
 * 戻り値: EIP-681 URI 文字列。recipient が空文字なら空文字を返す
 * （呼び出し側で QR 描画を抑止する用途）。
 */
let buildJpycTransferUri = (~recipient: string, ~amount: option<TipAmount.t>): string => {
  if recipient == "" {
    ""
  } else {
    let base =
      "ethereum:" ++
      Jpyc.contractAddress ++
      "@" ++
      Belt.Int.toString(Chain.polygonChainId) ++
      "/transfer?address=" ++
      recipient

    switch amount {
    | None => base
    | Some(a) => base ++ "&uint256=" ++ TipAmount.toBigint(a)->BigInt.toString
    }
  }
}
