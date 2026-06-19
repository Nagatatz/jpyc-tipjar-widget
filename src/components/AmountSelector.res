/**
 * 投げ銭金額セレクタ
 *
 * `TipAmount.presets` のプリセットボタン（100/500/1000 JPYC）と
 * カスタム数値入力の両方を提供する。プリセット選択時はカスタム入力をクリアし、
 * カスタム入力時はプリセット選択を解除する（同時に有効にしない）。
 *
 * プリセットは「金額カード」風の縦並びレイアウトを採用し、選択中は
 * rose 系のリングで強調する。
 */

/**
 * @react.component の引数:
 * - ~selectedYen: 現在選択中の円換算額（None の場合はプリセット未選択 = カスタム入力）
 * - ~customYen: カスタム入力値（円。空文字列許可）
 * - ~onSelectPreset: プリセットボタン押下時のコールバック
 * - ~onChangeCustom: カスタム入力変更時のコールバック
 * - ~disabled=false: 入力全体を無効化（送信中など）
 * - ~theme=#rich: 見た目テーマ（rich / simple）。選択リングや focus 色を切り替える。
 */
@react.component
let make = (
  ~selectedYen: option<int>,
  ~customYen: string,
  ~onSelectPreset: int => unit,
  ~onChangeCustom: string => unit,
  ~disabled: bool=false,
  ~theme: Theme.t=#rich,
) => {
  let isPresetSelected = (yen: int) =>
    switch selectedYen {
    | Some(v) => v == yen
    | None => false
    }

  // 選択状態 + disabled でクラスを切り替える
  // - 選択中 / 未選択 の配色は theme（rich=rose / simple=gray）で切り替える
  // - disabled: 半透明
  let presetClass = (~selected: bool, ~disabled: bool) => {
    let base =
      "min-w-[5.5rem] px-4 py-3 rounded-xl border-2 flex flex-col items-center justify-center transition-colors font-semibold"
    let stateClass = if selected {
      Theme.presetSelected(theme)
    } else {
      Theme.presetUnselected(theme)
    }
    let cursorClass = if disabled {
      " opacity-60 cursor-not-allowed"
    } else {
      " cursor-pointer"
    }
    base ++ " " ++ stateClass ++ cursorClass
  }

  <div>
    // プリセットカード: モバイルでも 3 列で並ぶように grid を使う
    <div className="grid grid-cols-3 gap-2">
      {TipAmount.presets
      ->Belt.Array.map(yen => {
        let selected = isPresetSelected(yen)
        <button
          key={Belt.Int.toString(yen)}
          type_="button"
          disabled
          className={presetClass(~selected, ~disabled)}
          onClick={_ => onSelectPreset(yen)}>
          // 金額（大きめ）+ 単位（小さく）を 2 行で表示
          <span className="text-lg leading-none">
            {React.string(`¥${Belt.Int.toString(yen)}`)}
          </span>
          <span className="text-[10px] uppercase tracking-wider text-gray-500 mt-1">
            {React.string(Jpyc.symbol)}
          </span>
        </button>
      })
      ->React.array}
    </div>
    // カスタム金額入力: ¥ プレフィックスを overlay で重ねる
    <div className="mt-4">
      <label className="block text-sm text-gray-700 mb-1">
        {React.string("カスタム金額（円 / JPYC）")}
      </label>
      <div className="relative">
        <span
          className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 text-lg pointer-events-none">
          {React.string("¥")}
        </span>
        <input
          type_="number"
          inputMode="numeric"
          min="1"
          step=1.0
          disabled
          value={customYen}
          onChange={ev => onChangeCustom((ev->ReactEvent.Form.target)["value"])}
          placeholder="例: 250"
          className={"w-full pl-8 pr-3 py-2 text-lg rounded-lg border border-gray-300 focus:outline-none " ++
          Theme.inputFocus(theme) ++
          " disabled:bg-gray-50 disabled:text-gray-500"}
        />
      </div>
    </div>
  </div>
}

let default = make
