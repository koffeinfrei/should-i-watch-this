import { defineConfig } from 'vite'
import Rails from 'vite-plugin-rails'

export default defineConfig({
  plugins: [
    Rails({
      envVars: { RAILS_ENV: 'development' },
    }),
  ],
})
