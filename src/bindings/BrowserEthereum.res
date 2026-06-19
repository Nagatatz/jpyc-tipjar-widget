/**
 * window.ethereum 検出のための最小バインディング
 *
 * MetaMask が注入する EIP-1193 プロバイダ (`window.ethereum`) にアクセスするための
 * 薄いバインディング。SSR (Node.js) で `globalThis.ethereum` が未定義でも安全な
 * `Js.Nullable.t` 経由のアクセスとし、UI 層で None 分岐を提供する。
 */

// EIP-1193 プロバイダを表す不透明型。中身には触らず request だけ呼ぶ。
type ethereum

// EIP-1193 の request メソッドの引数型
//   method: 例 "eth_requestAccounts" / "wallet_switchEthereumChain"
//   params: メソッド固有の任意 JSON 配列。空でもよい。
type requestArgs = {
  method: string,
  params: array<JSON.t>,
}

/**
 * ethereum.request(args) を呼び出す。
 *
 * @send は ReScript の「メソッド呼び出し」を表すアトリビュート。
 * `ethereum->request(args)` のように第一引数（this）に対するメソッドとして使う。
 */
@send external request: (ethereum, requestArgs) => promise<JSON.t> = "request"

/**
 * `globalThis.ethereum` を Js.Nullable<ethereum> として読む。
 *
 * window/globalThis に ethereum が存在しなければ undefined となり、
 * Js.Nullable.toOption で None に変換される。
 */
@val external _globalEthereum: Nullable.t<ethereum> = "globalThis.ethereum"

/**
 * 現在の環境で MetaMask（または他の EIP-1193 互換プロバイダ）を取得する。
 *
 * 戻り値:
 * - Some(ethereum): プロバイダが利用可能（ブラウザ + MetaMask 等）
 * - None: SSR 中・ウォレット未インストールなど
 */
let getEthereum = (): option<ethereum> => {
  Nullable.toOption(_globalEthereum)
}
