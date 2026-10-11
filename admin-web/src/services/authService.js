import { browserSessionPersistence, setPersistence, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { auth, configurationError } from './firebase.js';
import { loginEmail } from '../utils/loginIdentifier.js';

export async function login(email, password) {
  if (!auth) throw new Error(configurationError);
  // Survives a refresh; ends when this browser session is closed.
  await setPersistence(auth, browserSessionPersistence);
  return signInWithEmailAndPassword(auth, loginEmail(email), password);
}

export function logout() {
  return auth ? signOut(auth) : Promise.resolve();
}
