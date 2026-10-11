import { getApp, getApps, initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const fields = {
  apiKey: 'VITE_FIREBASE_API_KEY', authDomain: 'VITE_FIREBASE_AUTH_DOMAIN',
  projectId: 'VITE_FIREBASE_PROJECT_ID', storageBucket: 'VITE_FIREBASE_STORAGE_BUCKET',
  messagingSenderId: 'VITE_FIREBASE_MESSAGING_SENDER_ID', appId: 'VITE_FIREBASE_APP_ID',
};
const config = Object.fromEntries(Object.entries(fields).map(([key, variable]) => [key, import.meta.env[variable]?.trim()]));
const missing = Object.entries(fields).filter(([key]) => !config[key]).map(([, variable]) => variable);
let setupError = missing.length
  ? `Firebase configuration is missing: ${missing.join(', ')}. Copy .env.example to .env.local and restart Vite.`
  : config.projectId !== 'rent-lanka' ? 'This portal must use the existing rent-lanka Firebase project.' : '';

let initializedAuth = null;
let initializedFirestore = null;
if (!setupError) {
  try {
    const app = getApps().length ? getApp() : initializeApp(config);
    initializedAuth = getAuth(app);
    initializedFirestore = getFirestore(app);
  } catch {
    initializedAuth = null;
    initializedFirestore = null;
    setupError = 'Firebase could not initialize. Review the Firebase Web configuration in .env.local and restart Vite.';
  }
}
export const configurationError = setupError;
export const auth = initializedAuth;
export const db = initializedFirestore;
export const adminRefundsEnabled = import.meta.env.VITE_ENABLE_ADMIN_REFUNDS === 'true';
