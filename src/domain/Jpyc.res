/**
 * JPYC（資金移動業型, 2025年10月発行版）のドメイン定数
 *
 * 重要:
 * - 旧 JPYC v2 (`0x431D5dfF03120AFA4bDf332c61A6e1766eF37BDB`) は
 *   現在「JPYC Prepaid」にリブランドされており、本ウィジェットの対象外。
 * - 旧 v1 (`0x2370f9d504c7a6E775bf6E14B3F12846b594cD53`, Ethereum) も対象外。
 *
 * 本ウィジェットでは下記の Polygon mainnet 上の JPYC のみを取り扱う。
 */

/**
 * Polygon mainnet 上の JPYC（資金移動業型）コントラクトアドレス
 *
 * 出典: JPYC 公式の契約前準備書面
 *   https://jpyc.co.jp/legal/pre-contract-disclosure.pdf
 */
let contractAddress: string = "0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29"

/**
 * トークンの小数点以下桁数（10^18 で 1 JPYC）
 */
let decimals: int = 18

/**
 * トークンシンボル（表示・確認用）
 */
let symbol: string = "JPYC"

/**
 * transfer(address,uint256) のみを含む最小 ABI
 *
 * viem の parseAbi で人間可読形式から内部表現に変換する。
 * Transfer イベントは送金後に他クライアントから observe したい場合に
 * 備えて含めるが、本ウィジェットは receipt の status のみを見るため
 * 必須ではない。
 */
let transferAbi: Viem.abi = Viem.parseAbi([
  "function transfer(address to, uint256 amount) returns (bool)",
  "event Transfer(address indexed from, address indexed to, uint256 value)",
])
