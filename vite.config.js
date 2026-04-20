import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // 将/api开头的请求代理到后端服务
      '/api': {
        target: 'http://159.75.35.186:5000',
        changeOrigin: true
      }
    }
  }
})
