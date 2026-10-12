import { collection, doc, documentId, getDoc, getDocs, onSnapshot, query, runTransaction, serverTimestamp, where } from 'firebase/firestore';
import { adminRefundsEnabled, auth, db } from './firebase.js';
import { performRefundTransaction, RefundError } from './refundPolicy.js';

export function watchPayments(next, error) {
  // No orderBy: legacy documents without createdAt must remain visible.
  return onSnapshot(collection(db, 'payments'), { includeMetadataChanges: true }, next, error);
}

export function watchBookings(ids, next, error) {
  return onSnapshot(query(collection(db, 'rental_requests'), where(documentId(), 'in', ids)), next, error);
}

export function watchDocument(collectionName, id, next, error) {
  return onSnapshot(doc(db, collectionName, id), next, error);
}

export async function recordRefund({ paymentId, reason }) {
  if (!adminRefundsEnabled) throw new RefundError('Refund writes require the reviewed Firestore rules. This portal is currently read-only.');
  const uid = auth?.currentUser?.uid;
  if (!uid) throw new RefundError('Please sign in again before recording a refund.');
  if (typeof paymentId !== 'string' || !paymentId || paymentId.includes('/')) throw new RefundError('Invalid payment reference.');
  // Detect older refunds outside the deterministic document-ID convention.
  const paymentRef = doc(db, 'payments', paymentId);
  // The authoritative validation is repeated inside the transaction below.
  const initial = await getDoc(paymentRef);
  const bookingId = initial.data()?.bookingId;
  if (typeof bookingId !== 'string' || !bookingId || bookingId.includes('/')) throw new RefundError('The related booking could not be found.');
  const siblings = await getDocs(query(collection(db, 'payments'), where('bookingId', '==', bookingId)));
  if (siblings.docs.some((snapshot) => snapshot.data().type === 'refund')) {
    throw new RefundError('A refund has already been recorded for this booking.');
  }
  return runTransaction(db, (firebaseTransaction) => {
    if (auth.currentUser?.uid !== uid) throw new RefundError('Your session changed. Please sign in again.');
    return performRefundTransaction({
      async read(name, id) {
        const snapshot = await firebaseTransaction.get(doc(db, name, id));
        return snapshot.exists() ? snapshot.data() : null;
      },
      create(name, id, data) { firebaseTransaction.set(doc(db, name, id), data); },
      update(name, id, data) { firebaseTransaction.update(doc(db, name, id), data); },
    }, { paymentId, uid, reason, timestamp: serverTimestamp });
  });
}
