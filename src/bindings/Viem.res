/**
 * viem の最小バインディング
 *
 * 必要な API のみをバインドする方針:
 * - createPublicClient / createWalletClient
 * - custom / http (transport)
 * - polygon (viem/chains)
 * - parseAbi
 * - writeContract / waitForTransactionReceipt
 *
 * 高レベル API（型生成・ABI 推論）は使わず、コントラクト引数は
 * `contractArg` という不透明型で受け渡し、各値型から `argFrom*` で
 * 構築する。これは ReScript の bigint / string / etc を JS 配列として
 * viem に渡すための薄いラッパー。
 */

// すべて中身に触れない不透明型。viem 側で内部表現を保持する。
type chain
type abi
type transport
type publicClient
type walletClient

/**
 * Polygon mainnet チェーン定義（viem/chains 由来）
 */
@module("viem/chains") external polygon: chain = "polygon"

/**
 * HTTP RPC トランスポート（PublicClient 用）。引数は RPC URL。
 */
@module("viem") external http: string => transport = "http"

/**
 * EIP-1193 プロバイダを使うトランスポート（WalletClient 用）。
 *
 * 引数は `window.ethereum` のような EIP-1193 互換プロバイダ。
 * `'eip1193` は呼び出し側が型を決める多相パラメータ。
 */
@module("viem") external custom: 'eip1193 => transport = "custom"

/**
 * 人間可読な ABI 配列をパースして viem 内部表現の Abi を生成する。
 *
 * 例: parseAbi(["function transfer(address to, uint256 amount) returns (bool)"])
 */
@module("viem") external parseAbi: array<string> => abi = "parseAbi"

/**
 * PublicClient を作成する。読み取り（receipt 待ち等）に使う。
 */
type publicClientConfig = {chain: chain, transport: transport}
@module("viem") external createPublicClient: publicClientConfig => publicClient = "createPublicClient"

/**
 * WalletClient を作成する。書き込み（writeContract）に使う。
 */
type walletClientConfig = {chain: chain, transport: transport}
@module("viem") external createWalletClient: walletClientConfig => walletClient = "createWalletClient"

/**
 * writeContract の `args` に渡す不透明な値。
 *
 * viem は JS の `[address, bigint, ...]` のような配列を受け取るが、
 * ReScript からは型の異なる値を 1 つの配列にまとめにくいため、
 * `contractArg` という単一の型を経由させる。
 *
 * - argFromString: アドレス文字列など
 * - argFromBigint: uint256 の量など
 *
 * %identity は「ランタイムでは何もしない（単に値を返す）」キャスト。
 */
type contractArg
external argFromString: string => contractArg = "%identity"
external argFromBigint: bigint => contractArg = "%identity"

/**
 * writeContract の引数。viem の書式に合わせる。
 *
 * フィールド:
 * - address: コントラクトアドレス（0x...）
 * - abi: parseAbi の戻り値
 * - functionName: 呼び出す関数名（"transfer" 等）
 * - args: その関数の引数配列
 * - account: tx を送信するアカウント（0x...）
 * - chain: 期待するチェーン（不一致時に viem がガードする）
 */
type writeContractArgs = {
  address: string,
  abi: abi,
  functionName: string,
  args: array<contractArg>,
  account: string,
  chain: chain,
}

@send
external writeContract: (walletClient, writeContractArgs) => promise<string> = "writeContract"

/**
 * waitForTransactionReceipt のレシート（最小フィールドだけ）。
 *
 * status: "success" | "reverted"
 */
type receipt = {status: string}

type waitForReceiptArgs = {hash: string}

@send
external waitForTransactionReceipt: (publicClient, waitForReceiptArgs) => promise<receipt> =
  "waitForTransactionReceipt"
