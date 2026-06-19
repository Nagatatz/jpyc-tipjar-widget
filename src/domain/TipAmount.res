/**
 * 投げ銭金額のドメインモデル（実装）
 *
 * 詳細は対応する `.resi` を参照。
 * 内部表現は単に bigint だが、`.resi` で抽象化することで外部公開を制限している。
 */

type t = bigint

/**
 * 10^18（JPYC の decimals）。bigint リテラル `n` 接尾辞は ReScript 12 で利用可。
 */
let scale: bigint = 1000000000000000000n

let fromYen = (yen: int): t => {
  // BigInt.fromInt は int → bigint 変換。
  // bigint 同士の乗算には ReScript 12 の統一演算子 (*) を使用。
  BigInt.fromInt(yen) * scale
}

let toBigint = (t: t): bigint => t

let toDisplay = (t: t): string => {
  // 整数部のみ表示（端数は出さない）。
  // bigint の除算は端数切り捨て。fromYen 経由なので必ず割り切れる。
  (t / scale)->BigInt.toString
}

let presets: array<int> = [100, 500, 1000]
