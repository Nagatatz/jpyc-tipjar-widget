/**
 * Clipboard API バインディングモジュール
 *
 * ブラウザの Clipboard API へのアクセスを提供します。
 * クリップボードへのテキスト書き込みを行います。
 *
 * （nagatatz-jp の src/util/Clipboard.res から移植。本ウィジェットを
 *  ホストの util に依存させず自己完結させるため、パッケージ内に取り込んでいます。）
 */

/**
 * テキストをクリップボードに書き込む
 *
 * @val: グローバル変数へのバインディング
 * @scope(("navigator", "clipboard")): navigator.clipboard にアクセス
 *
 * navigator.clipboard.writeText() は Promise を返すため、戻り値の型は promise<unit>
 */
@val @scope(("navigator", "clipboard"))
external writeText: string => promise<unit> = "writeText"
