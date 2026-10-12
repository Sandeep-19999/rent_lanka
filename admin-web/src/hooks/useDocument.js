import { useEffect, useState } from 'react';
import { watchDocument } from '../services/paymentService.js';
import { errorMessage } from '../utils/errors.js';

export function useDocument(collectionName, id) {
  const [state, setState] = useState({ data: null, loading: !!id, error: '', missing: false });
  useEffect(() => {
    const valid = typeof id === 'string' && id && !id.includes('/');
    setState({ data: null, loading: !!valid, error: '', missing: false });
    if (!valid) return;
    return watchDocument(collectionName, id, (snapshot) => {
      setState({ data: snapshot.exists() ? { ...snapshot.data(), id: snapshot.id } : null,
        loading: false, missing: !snapshot.exists(), error: '' });
    }, (failure) => setState({ data: null, loading: false, missing: false, error: errorMessage(failure) }));
  }, [collectionName, id]);
  return state;
}
