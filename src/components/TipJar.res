/**
 * JPYC 投げ銭ウィジェットのメインコンポーネント
 *
 * 状態遷移は useReducer で管理する。各状態とその意味:
 *
 * - Idle: 初期状態。接続ボタンを表示。
 * - NoWallet: MetaMask 未注入。QR フォールバック + インストール案内を表示。
 * - Connecting: eth_requestAccounts 進行中。
 * - Connected: 接続完了。金額入力 + 送信ボタンを表示。
 * - Submitting: walletClient.writeContract 進行中（ユーザーが MetaMask で承認待ち）。
 * - Pending: tx ハッシュは取得済み、receipt 待ち。
 * - Confirmed: receipt 成功。
 * - Failed: 任意のステップで失敗。
 *
 * `recipientAddress` を省略した場合は環境変数から取得する。
 * 環境変数も空のときは UI 上で警告を表示し、送信ボタンを無効化する。
 *
 * リデザイン (20260513-003) で追加:
 * - グラデーション背景 + 角丸の温かみのあるコンテナ
 * - NoWallet 時に QrFallback (Primary) を主導線として描画
 *
 * QR 常時表示化 (20260513-005):
 * - Idle / Connecting / Connected / Submitting / Pending では QrFallback (Secondary) を
 *   表示する。
 * - AmountSelector も Idle から有効化し、MetaMask 接続前から金額を選択できる。
 *
 * 初期折りたたみ (20260513-006):
 * - Idle / Connecting では AmountSelector + QrFallback を `<details>` 折りたたみに収納し、
 *   初期は閉じた状態にする。ConnectButton を主導線として目立たせる。
 * - Connected / Submitting / Pending では AmountSelector は送金フローの中心として展開表示し、
 *   QR は別の `<details>` に格納する（20260513-005 以前の挙動を復元）。
 */

@val
external recipientFromEnv: string = "process.env.NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS"

type state =
  | Idle
  | NoWallet({reason: string})
  | Connecting
  | Connected({address: string})
  | Submitting({address: string, amount: TipAmount.t})
  | Pending({address: string, hash: string})
  | Confirmed({hash: string})
  | Failed({reason: string})

type action =
  | InitNoWallet({reason: string})
  | StartConnect
  | ConnectSucceeded({address: string})
  | ConnectFailed({reason: string})
  | StartSubmit({amount: TipAmount.t})
  | SubmitSucceeded({hash: string})
  | SubmitFailed({reason: string})
  | ConfirmSucceeded
  | ConfirmFailed({reason: string})
  | Reset

/**
 * State machine の reducer
 *
 * 全ての (state, action) 組み合わせを網羅するのは冗長なため、
 * 想定外の遷移は現在の state を保持する（`| (_, _) => state`）。
 */
let reducer = (state: state, action: action): state => {
  switch (state, action) {
  | (_, InitNoWallet({reason})) => NoWallet({reason: reason})
  | (Idle, StartConnect) | (Failed(_), StartConnect) | (Connected(_), StartConnect) => Connecting
  | (Connecting, ConnectSucceeded({address})) => Connected({address: address})
  | (Connecting, ConnectFailed({reason})) => Failed({reason: reason})
  | (Connected({address}), StartSubmit({amount})) =>
    Submitting({address: address, amount: amount})
  | (Submitting({address}), SubmitSucceeded({hash})) =>
    Pending({address: address, hash: hash})
  | (Submitting(_), SubmitFailed({reason})) => Failed({reason: reason})
  | (Pending({hash}), ConfirmSucceeded) => Confirmed({hash: hash})
  | (Pending(_), ConfirmFailed({reason})) => Failed({reason: reason})
  | (_, Reset) => Idle
  | (_, _) => state
  }
}

/**
 * 入力された円文字列を TipAmount.t に変換する
 *
 * 空文字や数値以外、または 0 以下の場合は None を返す。
 */
let parseYen = (input: string): option<TipAmount.t> => {
  let trimmed = String.trim(input)
  if trimmed == "" {
    None
  } else {
    switch Int.fromString(trimmed) {
    | Some(yen) if yen > 0 => Some(TipAmount.fromYen(yen))
    | _ => None
    }
  }
}

@react.component
let make = (~recipientAddress: option<string>=?, ~theme: Theme.t=#rich) => {
  // 受取アドレスの解決: prop > env > 空
  let recipient = switch recipientAddress {
  | Some(a) => a
  | None => recipientFromEnv
  }

  let (state, dispatch) = React.useReducer(reducer, Idle)
  let (selectedYen, setSelectedYen) = React.useState(_ => Some(100))
  let (customYen, setCustomYen) = React.useState(_ => "")

  // ProviderRef: コンポーネントの寿命中に一度だけ MetaMaskProvider を構築する
  // (Connecting → ... → Confirmed まで同じ provider を使い回したい)
  let providerRef = React.useRef(None)

  // 初回マウント時に MetaMask の有無を検出
  React.useEffect0(() => {
    switch MetaMaskProvider.make() {
    | Ok(p) => providerRef.current = Some(p)
    | Error(reason) => dispatch(InitNoWallet({reason: reason}))
    }
    None
  })

  // 現在送る予定の金額（プリセット優先、なければカスタム入力）
  let pendingAmount = switch selectedYen {
  | Some(yen) => Some(TipAmount.fromYen(yen))
  | None => parseYen(customYen)
  }

  let canSubmit = switch (state, pendingAmount, recipient) {
  | (Connected(_), Some(_), r) if r != "" => true
  | _ => false
  }

  let handleConnect = () => {
    switch providerRef.current {
    | None => dispatch(ConnectFailed({reason: "ウォレットプロバイダが初期化されていません"}))
    | Some(provider) => {
        dispatch(StartConnect)
        let _ = {
          // チェーン切替 → 接続 の順に実行
          provider.switchToPolygon()
          ->Promise.then(switchResult => {
            switch switchResult {
            | Error(e) => Promise.resolve(Error(e))
            | Ok() => provider.connect()
            }
          })
          ->Promise.then(result => {
            switch result {
            | Ok(addr) => dispatch(ConnectSucceeded({address: addr}))
            | Error(e) => dispatch(ConnectFailed({reason: e}))
            }
            Promise.resolve()
          })
        }
      }
    }
  }

  let handleSubmit = () => {
    switch (providerRef.current, pendingAmount, recipient) {
    | (Some(provider), Some(amount), r) if r != "" => {
        dispatch(StartSubmit({amount: amount}))
        let _ = {
          provider.sendJpyc(~to_=r, ~amount)
          ->Promise.then(result => {
            switch result {
            | Error(e) => {
                dispatch(SubmitFailed({reason: e}))
                Promise.resolve()
              }
            | Ok(hash) => {
                dispatch(SubmitSucceeded({hash: hash}))
                provider.waitForReceipt(~hash)
                ->Promise.then(receipt => {
                  switch receipt {
                  | Ok() => dispatch(ConfirmSucceeded)
                  | Error(e) => dispatch(ConfirmFailed({reason: e}))
                  }
                  Promise.resolve()
                })
              }
            }
          })
        }
      }
    | _ => ()
    }
  }

  let handleSelectPreset = (yen: int) => {
    setSelectedYen(_ => Some(yen))
    setCustomYen(_ => "")
  }

  let handleChangeCustom = (input: string) => {
    setCustomYen(_ => input)
    setSelectedYen(_ => None)
  }

  // 接続中（Connecting）と送金中（Submitting/Pending）は入力を無効化
  // - Connecting 中: MetaMask の承認ダイアログ表示中の誤操作を防ぐ
  // - Submitting/Pending 中: tx 送信中の金額変更を防ぐ
  let inputsDisabled = switch state {
  | Connecting | Submitting(_) | Pending(_) => true
  | _ => false
  }

  // Connected/Submitting/Pending 用: 「別のウォレットで送る（QR コード）」折りたたみ
  // - 接続済みユーザーは MetaMask 経由の送金が主導線なので、QR は控えめに `<details>` に格納する
  // - `group` + `group-open:rotate-90` で ▶ の回転アニメーションを付与（list-none で marker 抑制）
  let connectedQrFold =
    if recipient == "" {
      React.null
    } else {
      <details className="mt-4 group">
        <summary className={Theme.foldSummary(theme)}>
          <span
            className="inline-block w-4 text-center transition-transform group-open:rotate-90">
            {React.string("▶")}
          </span>
          {React.string("別のウォレットで送る（QR コード）")}
        </summary>
        <div className="mt-3">
          <QrFallback recipient amount=pendingAmount variant=#Secondary theme />
        </div>
      </details>
    }

  // Idle/Connecting 用: 「金額を選んで QR で送る」折りたたみ
  // - 初期は閉じた状態で、ConnectButton を主導線として目立たせる
  // - 開くと AmountSelector で金額を選び、QrFallback の QR をスキャンしてモバイル送金できる
  // - Idle と Connecting で同じ DOM 構造を保ち、open 状態がブラウザに維持される
  let idleAmountAndQrFold =
    if recipient == "" {
      React.null
    } else {
      <details className="mt-4 group">
        <summary className={Theme.foldSummary(theme)}>
          <span
            className="inline-block w-4 text-center transition-transform group-open:rotate-90">
            {React.string("▶")}
          </span>
          {React.string("金額を選んで QR で送る")}
        </summary>
        <div className="mt-3 space-y-4">
          <AmountSelector
            selectedYen
            customYen
            onSelectPreset=handleSelectPreset
            onChangeCustom=handleChangeCustom
            disabled=inputsDisabled
            theme
          />
          <QrFallback recipient amount=pendingAmount variant=#Secondary theme />
        </div>
      </details>
    }

  <section className={Theme.container(theme)}>
    // ヘッダ: アイコン + タイトル + バッジ（絵文字とバッジは rich のみ表示）
    <header className="mb-4">
      <div className="flex items-center gap-2 mb-2">
        {Theme.showHeaderEmoji(theme)
          ? <span className="text-2xl leading-none" ariaHidden=true> {React.string("💴")} </span>
          : React.null}
        <h3 className={Theme.heading(theme)}>
          {React.string("JPYC で投げ銭")}
        </h3>
        {Theme.showBadge(theme)
          ? <span
              className="ml-auto text-[11px] font-medium text-rose-700 bg-rose-100 rounded-full px-2 py-0.5">
              {React.string("Polygon × JPYC")}
            </span>
          : React.null}
      </div>
      <p className={Theme.description(theme)}>
        {React.string(
          "資金移動業型 JPYC を Polygon 上で直接送金します。サーバーは資金を一切預かりません。",
        )}
      </p>
    </header>
    {switch state {
    | NoWallet({reason}) =>
      <div className="space-y-3">
        // QR が主導線
        <QrFallback recipient amount=pendingAmount variant=#Primary theme />
        // PC ユーザー向けの MetaMask 案内（補助）
        <div className={Theme.subtleBox(theme)}>
          <p className="font-medium text-gray-900 mb-1">
            {React.string("PC で MetaMask を使う場合")}
          </p>
          <p className="text-gray-600">
            {React.string("MetaMask 拡張機能がインストールされていません。")}
          </p>
          <a
            className={Theme.link(theme)}
            href="https://metamask.io/"
            target="_blank"
            rel="noopener noreferrer">
            {React.string("MetaMask をインストール")}
            <span ariaHidden=true> {React.string("↗")} </span>
          </a>
          <p className="mt-2 text-xs text-gray-500">
            {React.string(reason)}
          </p>
        </div>
      </div>
    | Idle =>
      // Idle 状態: ConnectButton を主導線として表示し、金額/QR は折りたたみに格納する。
      <div>
        <ConnectButton onClick=handleConnect theme />
        {idleAmountAndQrFold}
      </div>
    | Connecting =>
      // Connecting 状態: 接続中の進捗表示。折りたたみは Idle と同じ DOM 構造を維持する
      // （`<details>` の open 状態をブラウザに引き継がせるため）。
      <div>
        <ConnectButton onClick={() => ()} connecting=true theme />
        {idleAmountAndQrFold}
      </div>
    | Connected({address})
    | Submitting({address, _})
    | Pending({address, _}) => {
        <div>
          <ConnectButton onClick={() => ()} address theme />
          <div className="mt-4">
            <AmountSelector
              selectedYen
              customYen
              onSelectPreset=handleSelectPreset
              onChangeCustom=handleChangeCustom
              disabled=inputsDisabled
              theme
            />
          </div>
          <div className="mt-4">
            <button
              type_="button"
              disabled={!canSubmit || inputsDisabled}
              className={
                // レイアウトは共通、塗りのみ theme + 有効/無効で切り替える
                let base = "w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-lg "
                if !canSubmit || inputsDisabled {
                  base ++ Theme.primaryButtonDisabled(theme)
                } else {
                  base ++ Theme.primaryButton(theme)
                }
              }
              onClick={_ => handleSubmit()}>
              {Theme.showActionEmoji(theme)
                ? <span ariaHidden=true> {React.string("💸")} </span>
                : React.null}
              {React.string(
                switch pendingAmount {
                | Some(a) => `${TipAmount.toDisplay(a)} ${Jpyc.symbol} を送る`
                | None => "金額を入力"
                },
              )}
            </button>
          </div>
          {if recipient == "" {
            <p className="mt-2 text-sm text-red-600">
              {React.string("受取アドレスが設定されていません（NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS）")}
            </p>
          } else {
            React.null
          }}
          {switch state {
          | Submitting(_) =>
            <p className="mt-3 text-sm text-gray-700">
              {React.string("ウォレットで承認してください...")}
            </p>
          | Pending({hash}) => <TxStatus status={Pending({hash: hash})} />
          | _ => React.null
          }}
          // 接続済みユーザー向け: 別ウォレット QR は `<details>` 折りたたみで提供する
          {connectedQrFold}
        </div>
      }
    | Confirmed({hash}) =>
      <div>
        <TxStatus status={Confirmed({hash: hash})} />
        <button
          type_="button"
          className={"mt-3 inline-flex items-center gap-2 px-4 py-2 rounded-lg " ++ Theme.primaryButton(theme)}
          onClick={_ => dispatch(Reset)}>
          {Theme.showActionEmoji(theme)
            ? <span ariaHidden=true> {React.string("↻")} </span>
            : React.null}
          {React.string("もう一度投げ銭する")}
        </button>
      </div>
    | Failed({reason}) =>
      <div>
        <TxStatus status={Failed({reason: reason})} />
        <button
          type_="button"
          className={"mt-3 inline-flex items-center gap-2 px-4 py-2 rounded-lg " ++ Theme.primaryButton(theme)}
          onClick={_ => dispatch(Reset)}>
          {Theme.showActionEmoji(theme)
            ? <span ariaHidden=true> {React.string("↻")} </span>
            : React.null}
          {React.string("もう一度試す")}
        </button>
      </div>
    }}
  </section>
}

let default = make
