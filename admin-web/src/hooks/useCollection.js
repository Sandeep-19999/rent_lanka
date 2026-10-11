import { useEffect, useState } from 'react';
import { collection, onSnapshot, query, where } from 'firebase/firestore';
import { db } from '../services/firebase.js';
import { errorMessage } from '../utils/errors.js';
// Only used beneath the existing ProtectedRoute. Rules enforce collection access.
export function useCollection(name, normalize, field = '', value = '') {
  const [revision, setRevision] = useState(0);
  const [state, setState] = useState({ rows: [], loading: true, error: '' });
  useEffect(() => {
    setState({ rows: [], loading: true, error: '' });
    if (field && !value) { setState({ rows: [], loading: false, error: '' }); return; }
    if (!db) { setState({ rows: [], loading: false, error: 'Firebase is not configured.' }); return; }
    const source = field ? query(collection(db, name), where(field, '==', value)) : collection(db, name);
    return onSnapshot(source, snapshot => setState({ rows: snapshot.docs.map(d => normalize(d.id, d.data())), loading: false, error: '' }), failure => setState({ rows: [], loading: false, error: errorMessage(failure) }));
  }, [name, normalize, field, value, revision]);
  return { ...state, retry: () => setRevision(v => v + 1) };
}
