// EIP-1193 プロバイダのスタブを「ウィジェット読み込み前」に注入する。
// これにより MetaMaskProvider.make() が Ok となり、初期状態が Idle になる
// （未注入だと NoWallet 表示になる）。request は呼ばれても害のない no-op。
window.ethereum = {
  isMetaMask: true,
  request: () => Promise.resolve(null),
  on: () => {},
}

import React from 'react'
import { createRoot } from 'react-dom/client'
import TipJar from 'jpyc-tipjar-widget'
import './index.css'

function Column({ label, variant }) {
  return (
    <div style={{ flex: '1 1 0', maxWidth: '460px' }}>
      <h2
        style={{
          font: '600 13px system-ui, sans-serif',
          color: '#334155',
          margin: '0 0 8px',
        }}>
        {label}
      </h2>
      <TipJar variant={variant} />
    </div>
  )
}

function App() {
  return (
    <div
      style={{
        display: 'flex',
        gap: '28px',
        padding: '28px',
        alignItems: 'flex-start',
        background: '#f1f5f9',
        minHeight: '100vh',
        boxSizing: 'border-box',
      }}>
      <Column label='variant="rich"（既定）' variant="rich" />
      <Column label='variant="simple"' variant="simple" />
    </div>
  )
}

createRoot(document.getElementById('root')).render(<App />)

// レンダリング後に折りたたみ（金額選択 + QR）を開いて、フル UI を撮影できるようにする
setTimeout(() => {
  document.querySelectorAll('details').forEach((d) => {
    d.open = true
  })
}, 600)
