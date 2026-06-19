/**
 * MetaMask 実装の WalletProvider
 *
 * `BrowserEthereum.getEthereum()` で取得した EIP-1193 プロバイダに対し、
 * - connect: `eth_requestAccounts`
 * - switchToPolygon: `wallet_switchEthereumChain` → 失敗時 `wallet_addEthereumChain`
 * - sendJpyc: viem の walletClient.writeContract で transfer(to, amount)
 * - waitForReceipt: viem の publicClient.waitForTransactionReceipt
 *
 * `make` は ethereum が未注入なら Error("MetaMaskが見つかりません") を返す。
 * UI 層はこの分岐で「インストール案内」を表示する。
 */

/**
 * JSON.t を string 配列として扱うためのランタイム no-op キャスト。
 *
 * MetaMask の `eth_requestAccounts` / `eth_accounts` は string 配列を返すため、
 * 信頼してキャストする。
 */
external asAddressArray: JSON.t => array<string> = "%identity"

/**
 * Promise の rejection から人間可読なメッセージを取り出す
 *
 * MetaMask は EIP-1193 RpcError を投げるため `.message` を含む。
 */
let formatError = (err: exn): string => {
  switch JsExn.fromException(err) {
  | Some(jsErr) => JsExn.message(jsErr)->Option.getOr("不明なエラー")
  | None => "不明なエラー"
  }
}

/**
 * 4001 はユーザーが MetaMask のポップアップでキャンセルした場合のコード。
 * 4902 は wallet_switchEthereumChain がチェーン未登録時に返すコード。
 *
 * これらを文字列マッチで判定するのは脆いが、現状の MetaMask は
 * メッセージにコードを含めるので暫定対応とする。
 */
let isChainNotAddedError = (msg: string): bool => {
  String.includes(msg, "4902") || String.includes(msg, "Unrecognized chain")
}

/**
 * 受取アドレスとして既に接続済みのアカウントを返す。
 * 接続前なら Error。
 */
let getConnectedAccount = async (eth: BrowserEthereum.ethereum): result<string, string> => {
  try {
    let result = await eth->BrowserEthereum.request({method: "eth_accounts", params: []})
    let accounts = asAddressArray(result)
    switch accounts[0] {
    | Some(addr) => Ok(addr)
    | None => Error("先にウォレットを接続してください")
    }
  } catch {
  | err => Error(formatError(err))
  }
}

/**
 * MetaMask 実装を生成する。
 *
 * ethereum が未注入の場合は Error を返し、UI 側で案内に分岐する。
 */
let make = (): result<WalletProvider.t, string> => {
  switch BrowserEthereum.getEthereum() {
  | None =>
    Error("MetaMask が見つかりませんでした。https://metamask.io/ からインストールしてください。")
  | Some(eth) => {
      // 接続要求: EIP-1193 の eth_requestAccounts
      let connect = async (): result<string, string> => {
        try {
          let result = await eth->BrowserEthereum.request({
            method: "eth_requestAccounts",
            params: [],
          })
          let accounts = asAddressArray(result)
          switch accounts[0] {
          | Some(addr) => Ok(addr)
          | None => Error("アカウントを取得できませんでした")
          }
        } catch {
        | err => Error(formatError(err))
        }
      }

      // チェーン切替: 失敗時は addEthereumChain にフォールバック
      let switchToPolygon = async (): result<unit, string> => {
        // wallet_switchEthereumChain は { chainId: "0x89" } を要求
        let switchParam = JSON.Encode.object(
          Dict.fromArray([("chainId", JSON.Encode.string(Chain.polygonChainIdHex))]),
        )
        try {
          let _ = await eth->BrowserEthereum.request({
            method: "wallet_switchEthereumChain",
            params: [switchParam],
          })
          Ok()
        } catch {
        | err => {
            let msg = formatError(err)
            if isChainNotAddedError(msg) {
              // 未登録なら追加してから再試行扱いとする
              let p = Chain.polygonAddChainParams()
              // EIP-3085 の addChainParams は dict そのままでも viem/MetaMask が受ける
              let addParam: JSON.t =
                p->JSON.stringifyAny->Option.getOrThrow->JSON.parseOrThrow
              try {
                let _ = await eth->BrowserEthereum.request({
                  method: "wallet_addEthereumChain",
                  params: [addParam],
                })
                Ok()
              } catch {
              | addErr => Error(formatError(addErr))
              }
            } else {
              Error(msg)
            }
          }
        }
      }

      // 送金: viem の walletClient.writeContract で transfer を呼ぶ
      let sendJpyc = async (~to_: string, ~amount: TipAmount.t): result<string, string> => {
        switch await getConnectedAccount(eth) {
        | Error(e) => Error(e)
        | Ok(account) => {
            let walletClient = Viem.createWalletClient({
              chain: Viem.polygon,
              transport: Viem.custom(eth),
            })
            try {
              let hash = await walletClient->Viem.writeContract({
                address: Jpyc.contractAddress,
                abi: Jpyc.transferAbi,
                functionName: "transfer",
                // [to, amount] の順。アドレスは string、量は bigint。
                args: [Viem.argFromString(to_), Viem.argFromBigint(TipAmount.toBigint(amount))],
                account,
                chain: Viem.polygon,
              })
              Ok(hash)
            } catch {
            | err => Error(formatError(err))
            }
          }
        }
      }

      // レシート待ち: 成功時のみ Ok、reverted は Error
      let waitForReceipt = async (~hash: string): result<unit, string> => {
        let publicClient = Viem.createPublicClient({
          chain: Viem.polygon,
          transport: Viem.http(Chain.rpcUrl()),
        })
        try {
          let receipt = await publicClient->Viem.waitForTransactionReceipt({hash: hash})
          if receipt.status == "success" {
            Ok()
          } else {
            Error("トランザクションが失敗しました（status: " ++ receipt.status ++ "）")
          }
        } catch {
        | err => Error(formatError(err))
        }
      }

      Ok({connect, switchToPolygon, sendJpyc, waitForReceipt})
    }
  }
}
