import { createContext, useCallback, useEffect, useMemo, useState } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, onSnapshot } from 'firebase/firestore';
import { auth, configurationError, db } from '../services/firebase.js';
import { isAdminProfile } from '../utils/authorization.js';
import { errorMessage } from '../utils/errors.js';

export const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [state, setState] = useState({ user: null, profile: null, loading: !!auth, error: configurationError });
  const [revision, setRevision] = useState(0);
  const retryAuthorization = useCallback(() => setRevision((value) => value + 1), []);
  useEffect(() => {
    if (!auth) return;
    let active = true;
    let profileSubscription;
    let generation = 0;
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      const current = ++generation;
      profileSubscription?.();
      if (!user) { setState({ user: null, profile: null, loading: false, error: '' }); return; }
      setState({ user, profile: null, loading: true, error: '' });
      profileSubscription = onSnapshot(doc(db, 'users', user.uid), (snapshot) => {
        if (!active || current !== generation) return;
        const profile = snapshot.data() || null;
        setState({ user, profile, loading: false,
          error: isAdminProfile(profile) ? '' : 'Access denied. This account is not authorized for the Rent Lanka admin portal.' });
      }, (error) => {
        if (active && current === generation) setState({ user, profile: null, loading: false, error: errorMessage(error) });
      });
    }, (error) => setState({ user: null, profile: null, loading: false, error: errorMessage(error) }));
    return () => { active = false; generation++; profileSubscription?.(); unsubscribe(); };
  }, [revision]);
  const value = useMemo(() => ({ ...state, isAdmin: !!state.user && isAdminProfile(state.profile), retryAuthorization }), [state, retryAuthorization]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
