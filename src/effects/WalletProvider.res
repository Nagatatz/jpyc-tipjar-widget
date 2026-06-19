/**
 * ウォレットプロバイダの抽象インターフェース
 *
 * UI 層はこの型のみに依存し、具体実装（MetaMask / WalletConnect 等）に
 * 依存しない。L3 で WalletConnect を追加する際も、この型を実装する形で
 * 提供する。
 *
 * 各メソッドが `promise<result<_, string>>` を返すのは、
 * - JS の reject ではなく Result で正常系/異常系を分けて扱いたい
 * - 失敗理由はとりあえず文字列で受け、UI 側で人間可読に表示する
 *   （構造化エラーは L3 で必要になったときに追加）
 * という設計判断による。
 */
type t = {
  /**
   * ウォレット接続を要求し、選ばれたアドレスを返す。
   *
   * 戻り値: Ok(0x...) | Error(理由の説明)
   */
  connect: unit => promise<result<string, string>>,
  /**
   * 接続中チェーンを Polygon mainnet に切り替える。
   * 未追加なら追加（EIP-3085 / EIP-3326）。
   */
  switchToPolygon: unit => promise<result<unit, string>>,
  /**
   * JPYC.transfer(to_, amount) を呼ぶ。
   *
   * 引数:
   * - `~to_: string`: 受取アドレス（0x...）。`to` は予約語に近いため `to_` を使う。
   * - `~amount: TipAmount.t`: 抽象化された JPYC 量（必ず fromYen 経由）。
   *
   * 戻り値: Ok(txHash) | Error(理由)
   */
  sendJpyc: (~to_: string, ~amount: TipAmount.t) => promise<result<string, string>>,
  /**
   * 指定の tx ハッシュが Polygon にマインされるまで待ち、
   * 成功 (status="success") かを判定する。
   */
  waitForReceipt: (~hash: string) => promise<result<unit, string>>,
}
