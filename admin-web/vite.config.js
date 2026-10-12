import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            if (/recharts|d3-|victory-vendor/.test(id)) return 'charts';
            if (id.includes('/@firebase/auth/')) return 'firebase-auth';
            if (id.includes('/@firebase/firestore/')) return 'firebase-firestore';
            if (id.includes('/@firebase/')) return 'firebase-core';
          }
        },
      },
    },
  },
});
