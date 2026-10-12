import { createContext, useCallback, useEffect, useMemo, useState } from 'react';
import { watchBookings, watchPayments } from '../services/paymentService.js';
import { normalizePayment } from '../utils/payments.js';
import { errorMessage } from '../utils/errors.js';
import { useAuth } from '../hooks/useAuth.js';

export const PaymentContext = createContext(null);

export function PaymentProvider({ children }) {
  const { user, isAdmin } = useAuth();
  const [raw, setRaw] = useState([]);
  const [bookings, setBookings] = useState(() => Object.create(null));
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [bookingError, setBookingError] = useState('');
  const [bookingsLoading, setBookingsLoading] = useState(false);
  const [fromCache, setFromCache] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [revision, setRevision] = useState(0);
  const retry = useCallback(() => setRevision((value) => value + 1), []);
  useEffect(() => {
    setRaw([]); setBookings(Object.create(null)); setError(''); setLoading(true); setLastUpdated(null);
    if (!isAdmin) return;
    return watchPayments((snapshot) => {
      setRaw(snapshot.docs.map((document) => ({ id: document.id, data: document.data() })));
      setFromCache(snapshot.metadata.fromCache);
      setLoading(false); setError('');
      if (!snapshot.metadata.fromCache) setLastUpdated(new Date());
    }, (failure) => { setError(errorMessage(failure)); setRaw([]); setLoading(false); });
  }, [user?.uid, isAdmin, revision]);

  const bookingIds = useMemo(() => JSON.stringify([...new Set(raw.map(({ data }) => data.bookingId)
    .filter((id) => typeof id === 'string' && id && !id.includes('/')))].sort()), [raw]);
  useEffect(() => {
    setBookings(Object.create(null)); setBookingError('');
    const ids = JSON.parse(bookingIds);
    if (!isAdmin || !ids.length) { setBookingsLoading(false); return; }
    const chunks = Array.from({ length: Math.ceil(ids.length / 30) }, (_, index) => ids.slice(index * 30, index * 30 + 30));
    const pending = new Set(chunks.map((_, index) => index));
    setBookingsLoading(true);
    const unsubscribes = chunks.map((chunk, index) => watchBookings(chunk, (snapshot) => {
      setBookings((previous) => {
        const next = Object.assign(Object.create(null), previous);
        chunk.forEach((id) => { delete next[id]; });
        snapshot.docs.forEach((document) => { next[document.id] = document.data(); });
        return next;
      });
      pending.delete(index);
      setBookingsLoading(pending.size > 0);
    }, (failure) => {
      setBookingError(errorMessage(failure, 'Some booking details could not be loaded. Payment records remain available.'));
      pending.delete(index); setBookingsLoading(pending.size > 0);
    }));
    return () => unsubscribes.forEach((unsubscribe) => unsubscribe());
  }, [bookingIds, user?.uid, isAdmin, revision]);

  const payments = useMemo(() => raw.map(({ id, data }) => normalizePayment(id, data, bookings[data.bookingId])), [raw, bookings]);
  const refundsByBooking = useMemo(() => payments.reduce((map, payment) => {
    if (payment.type === 'refund' && payment.bookingId) (map[payment.bookingId] ||= []).push(payment);
    return map;
  }, Object.create(null)), [payments]);
  const value = useMemo(() => ({ payments, bookings, raw, loading, error, bookingError, bookingsLoading,
    refundsByBooking, fromCache, lastUpdated, retry }),
  [payments, bookings, raw, loading, error, bookingError, bookingsLoading, refundsByBooking, fromCache, lastUpdated, retry]);
  return <PaymentContext.Provider value={value}>{children}</PaymentContext.Provider>;
}
