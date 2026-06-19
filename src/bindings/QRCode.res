/**
 * qrcode.react ライブラリの ReScript バインディング
 *
 * `QRCodeSVG` は SVG として QR コードを描画する React コンポーネントで、
 * canvas に依存しないため SSR (Next.js のサーバーレンダリング) でも安全に扱える。
 *
 * 公開しているプロップは本ウィジェットで使うものだけに絞っている。
 * 必要に応じて imageSettings 等を追加する。
 */

module QRCodeSVG = {
  /**
   * @react.component の引数:
   * - ~value: QR にエンコードする文字列（本ウィジェットでは EIP-681 URI）
   * - ~size=?: 描画サイズ（px）。指定しない場合は qrcode.react のデフォルト (128) になる。
   * - ~level=?: エラー訂正レベル。"L" | "M" | "Q" | "H"。
   *   高いほど読み取り耐性が増すがデータ密度も上がる。
   * - ~marginSize=?: QR コードの外側に確保する余白セル数（quiet zone）。
   * - ~bgColor=?: 背景色（CSS 形式）
   * - ~fgColor=?: 前景（モジュール）色
   * - ~className=?: 追加クラス
   *
   * `=?` はオプショナルプロップ（省略時 None として扱われる）。
   */
  @react.component @module("qrcode.react")
  external make: (
    ~value: string,
    ~size: int=?,
    ~level: string=?,
    ~marginSize: int=?,
    ~bgColor: string=?,
    ~fgColor: string=?,
    ~className: string=?,
  ) => React.element = "QRCodeSVG"
}
