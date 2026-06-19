/**
 * Polygon mainnet 関連のドメイン定数
 *
 * このモジュールは Polygon の chainId・RPC URL・ブロックエクスプローラ URL
 * など、ウォレット側のチェーン切り替え（EIP-3085 / EIP-3326）に必要な情報を
 * 一元管理する。Alchemy の API Key は環境変数から取得する。
 */

/**
 * Polygon mainnet の chainId（10進）
 */
let polygonChainId: int = 137

/**
 * Polygon mainnet の chainId（16進文字列）
 *
 * EIP-3085/3326 の `wallet_switchEthereumChain` 等は 16 進文字列
 * （例: "0x89"）を要求するため両方公開する。
 */
let polygonChainIdHex: string = "0x89"

/**
 * 公式ブロックエクスプローラ
 */
let blockExplorerUrl: string = "https://polygonscan.com"

/**
 * トランザクションハッシュからエクスプローラ URL を組み立てる
 */
let txUrl = (hash: string): string => {
  blockExplorerUrl ++ "/tx/" ++ hash
}

/**
 * Alchemy の Polygon mainnet RPC エンドポイントを組み立てる
 *
 * 環境変数 `NEXT_PUBLIC_ALCHEMY_API_KEY` から API Key を取得する。
 */
@val
external alchemyApiKey: string = "process.env.NEXT_PUBLIC_ALCHEMY_API_KEY"

let rpcUrl = (): string => {
  "https://polygon-mainnet.g.alchemy.com/v2/" ++ alchemyApiKey
}

/**
 * `wallet_addEthereumChain` 用パラメータ（EIP-3085）
 *
 * MetaMask に Polygon mainnet が未追加の場合、`wallet_switchEthereumChain`
 * は失敗する。失敗時に本パラメータを `wallet_addEthereumChain` で渡す。
 */
type nativeCurrency = {
  name: string,
  symbol: string,
  decimals: int,
}

type addChainParams = {
  chainId: string,
  chainName: string,
  nativeCurrency: nativeCurrency,
  rpcUrls: array<string>,
  blockExplorerUrls: array<string>,
}

let polygonAddChainParams = (): addChainParams => {
  chainId: polygonChainIdHex,
  chainName: "Polygon Mainnet",
  nativeCurrency: {
    name: "POL",
    symbol: "POL",
    decimals: 18,
  },
  // Alchemy が落ちた場合のフォールバックも兼ねて公式 RPC も列挙
  rpcUrls: [rpcUrl(), "https://polygon-rpc.com"],
  blockExplorerUrls: [blockExplorerUrl],
}
