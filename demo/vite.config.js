import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// ウィジェットは process.env.NEXT_PUBLIC_* を参照するため、ブラウザバンドル向けに値を埋め込む
export default defineConfig({
  plugins: [react(), tailwindcss()],
  define: {
    'process.env.NEXT_PUBLIC_TIPJAR_RECIPIENT_ADDRESS': JSON.stringify(
      '0xAbC0000000000000000000000000000000001234',
    ),
    'process.env.NEXT_PUBLIC_ALCHEMY_API_KEY': JSON.stringify('demo-key'),
  },
})
