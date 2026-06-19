/**
 * QR コードによる送金フォールバック UI
 *
 * MetaMask 拡張機能が未注入のユーザーや、別のモバイルウォレットで送金したい
 * ユーザー向けに、EIP-681 URI を埋め込んだ QR コードと、受取アドレスを
 * 表示する。アドレスはコピーボタンで簡単にクリップボードへコピーできる。
 *
 * `variant` で 2 つのレイアウトを切り替える:
 * - #Primary: NoWallet 状態でメイン表示として使う（縁取り強め）
 * - #Secondary: 接続済みユーザー向けの折りたたみセクション内で使う（控えめ）
 */

/**
 * レイアウト種別。Primary は背景色付きで目立たせ、Secondary は淡い枠線のみ。
 */
type variant = [#Primary | #Secondary]

/**
 * アドレスを 0x12...abcd の形に短縮する
 *
 * 短すぎるアドレスはそのまま返す（テストや異常系の防御）。
 */
let shortenAddress = (addr: string): string => {
  let len = String.length(addr)
  if len <= 12 {
    addr
  } else {
    String.slice(addr, ~start=0, ~end=6) ++ "..." ++ String.slice(addr, ~start=len - 4, ~end=len)
  }
}

/**
 * @react.component の引数:
 * - ~recipient: 受取アドレス（0x...）。空文字の場合は QR を出さず警告を出す。
 * - ~amount: option<TipAmount.t>。Some なら EIP-681 URI に uint256 を含める。
 * - ~variant: #Primary | #Secondary（強調レベル。上記参照）
 * - ~theme=#rich: 見た目テーマ（rich / simple）。variant（強調レベル）とは別軸で
 *   配色（rose グラデ or gray ベース）を切り替える。
 */
@react.component
let make = (
  ~recipient: string,
  ~amount: option<TipAmount.t>,
  ~variant: variant,
  ~theme: Theme.t=#rich,
) => {
  // コピーボタンの一時的な「コピー済み」表示用 state
  let (copied, setCopied) = React.useState(_ => false)

  // EIP-681 URI を組み立てる
  // recipient が空なら空文字列 → QR 描画を抑止
  let uri = PaymentUri.buildJpycTransferUri(~recipient, ~amount)

  // コピーボタン押下時のハンドラ
  // navigator.clipboard が無い環境では Promise が reject されるので
  // catch でフォールバック表示にする
  let handleCopy = () => {
    let _ = Clipboard.writeText(recipient)
    ->Promise.then(() => {
      setCopied(_ => true)
      // 1.5 秒後に「コピー済み」表示を解除する
      let _ = setTimeout(() => setCopied(_ => false), 1500)
      Promise.resolve()
    })
    ->Promise.catch(_ => {
      // 失敗時もユーザーに何も伝えない（手動コピーで対応してもらう）
      Promise.resolve()
    })
  }

  // #Primary なら強調レベル「高」。theme と組み合わせて配色を決める。
  let primary = variant == #Primary

  // コンテナ・見出しのスタイルは theme（rich/simple）× 強調レベル（primary）で決定する
  let containerClass = Theme.qrContainer(theme, ~primary)
  let headingClass = Theme.qrHeading(theme, ~primary)

  if recipient == "" {
    <p className="p-3 rounded bg-red-50 border border-red-200 text-sm text-red-700">
      {React.string("受取アドレスが設定されていないため QR を表示できません。")}
    </p>
  } else {
    <div className={containerClass}>
      <div className="flex items-center gap-2 mb-3">
        <span ariaHidden=true> {React.string("📱")} </span>
        <h4 className={headingClass}>
          {React.string("モバイルウォレットで送金")}
        </h4>
      </div>
      <div className="flex flex-col sm:flex-row gap-4 items-center sm:items-start">
        // QR コード本体: 白背景 + 内側余白で読み取りやすく
        <div className="shrink-0 p-3 bg-white rounded-lg border border-gray-200">
          <QRCode.QRCodeSVG
            value={uri}
            size={160}
            level="M"
            marginSize={1}
            bgColor="#ffffff"
            fgColor="#1f2937"
          />
        </div>
        // 補助情報: アドレス・金額・案内文
        <div className="flex-1 w-full text-sm text-gray-700 space-y-2">
          <div>
            <p className="text-xs text-gray-500 mb-0.5">
              {React.string("受取アドレス（Polygon 上の JPYC）")}
            </p>
            <div className="flex items-center gap-2">
              <code
                className="font-mono text-sm text-gray-900 bg-gray-100 rounded px-2 py-1 break-all"
                title={recipient}>
                {React.string(shortenAddress(recipient))}
              </code>
              <button
                type_="button"
                onClick={_ => handleCopy()}
                className={
                  if copied {
                    "px-2 py-1 rounded bg-emerald-100 text-emerald-800 text-xs font-medium"
                  } else {
                    "px-2 py-1 rounded bg-gray-200 hover:bg-gray-300 text-gray-800 text-xs font-medium"
                  }
                }
                ariaLabel="受取アドレスをコピー">
                {React.string(if copied {"✅ コピー済み"} else {"📋 コピー"})}
              </button>
            </div>
          </div>
          {switch amount {
          | Some(a) =>
            <p className="text-xs text-gray-600">
              {React.string(`送金額（QR に埋込済み）: ${TipAmount.toDisplay(a)} ${Jpyc.symbol}`)}
            </p>
          | None =>
            <p className="text-xs text-gray-500">
              {React.string("送金額はウォレット側で入力してください")}
            </p>
          }}
          <p className="text-xs text-gray-500 leading-relaxed">
            {React.string(
              "EIP-681 対応のウォレット (MetaMask Mobile, Rainbow など) で QR を読み取ると、Polygon 上の JPYC 送金画面が開きます。",
            )}
          </p>
        </div>
      </div>
    </div>
  }
}

let default = make
