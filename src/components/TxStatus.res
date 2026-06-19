/**
 * トランザクションステータス表示コンポーネント
 *
 * 状態遷移のうち UI 表示が必要な後半（Pending / Confirmed / Failed）を
 * 受け取り、PolygonScan へのリンクや成功・失敗メッセージを描画する。
 *
 * リデザイン後はアイコン + 短縮 hash + 「PolygonScan で見る ↗」リンクで
 * 視認性とコンパクトさを両立する。
 */

/**
 * 表示する状態
 *
 * - Pending: tx をブロードキャストしてマインを待っている状態
 * - Confirmed: マイン完了 + status=success
 * - Failed: 何らかのエラー（ユーザーキャンセル含む）
 */
type status =
  | Pending({hash: string})
  | Confirmed({hash: string})
  | Failed({reason: string})

// トランザクションハッシュを 0x1234...abcd の形に短縮する
let shortenHash = (hash: string): string => {
  let len = String.length(hash)
  if len <= 14 {
    hash
  } else {
    String.slice(hash, ~start=0, ~end=8) ++ "..." ++ String.slice(hash, ~start=len - 6, ~end=len)
  }
}

/**
 * Pending 用の小さなスピナー（DOM 直書き）
 */
module MiniSpinner = {
  @react.component
  let make = (~className: string) => {
    <svg
      className={`animate-spin ${className}`}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24">
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
      />
    </svg>
  }
}

/**
 * トランザクションハッシュ + PolygonScan リンクのブロック
 *
 * 各状態の色味に合わせて color (Tailwind の色名 prefix) を切り替える。
 */
module HashLink = {
  @react.component
  let make = (~hash: string, ~colorClass: string) => {
    <a
      className={`inline-flex items-center gap-1 ${colorClass} underline break-all font-mono text-xs`}
      href={Chain.txUrl(hash)}
      target="_blank"
      rel="noopener noreferrer"
      title={hash}>
      {React.string(shortenHash(hash))}
      <span ariaHidden=true> {React.string("↗")} </span>
    </a>
  }
}

/**
 * @react.component の引数:
 * - ~status: 上記 variant
 */
@react.component
let make = (~status: status) => {
  switch status {
  | Pending({hash}) =>
    <div
      className="mt-3 p-3 rounded-lg bg-amber-50 border border-amber-200 text-sm flex items-start gap-2">
      <MiniSpinner className="h-4 w-4 text-amber-600 mt-0.5" />
      <div>
        <p className="font-medium text-amber-900">
          {React.string("トランザクションを確認中...")}
        </p>
        <HashLink hash colorClass="text-amber-800" />
      </div>
    </div>
  | Confirmed({hash}) =>
    <div
      className="mt-3 p-3 rounded-lg bg-emerald-50 border border-emerald-200 text-sm flex items-start gap-2">
      <span className="text-emerald-600 text-lg leading-none mt-0.5" ariaHidden=true>
        {React.string("✓")}
      </span>
      <div>
        <p className="font-medium text-emerald-900">
          {React.string("ありがとうございました！送金が完了しました。")}
        </p>
        <HashLink hash colorClass="text-emerald-800" />
      </div>
    </div>
  | Failed({reason}) =>
    <div
      className="mt-3 p-3 rounded-lg bg-red-50 border border-red-200 text-sm flex items-start gap-2">
      <span className="text-red-600 text-lg leading-none mt-0.5" ariaHidden=true>
        {React.string("⚠")}
      </span>
      <div>
        <p className="font-medium text-red-900">
          {React.string("送金に失敗しました")}
        </p>
        <p className="text-red-700 break-words">
          {React.string(reason)}
        </p>
      </div>
    </div>
  }
}

let default = make
