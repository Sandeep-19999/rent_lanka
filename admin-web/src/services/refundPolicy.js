import { isAdminProfile } from '../utils/authorization.js';

export class RefundError extends Error {
  constructor(message) { super(message); this.name = 'RefundError'; }
}

export function refundEligibility(payment, booking, existingRefund = false) {
  if (existingRefund) return { allowed: false, reason: 'A refund has already been recorded for this booking.' };
  if (!payment || !booking) return { allowed: false, reason: 'The payment and its booking must both be available.' };
  if ((payment.type || 'charge') !== 'charge' || payment.status !== 'paid') {
    return { allowed: false, reason: 'Only a paid original charge can be refunded.' };
  }
  if (!['rejected', 'cancelled'].includes(booking.status)) {
    return { allowed: false, reason: 'Refunds are available only for rejected or cancelled rentals. Completed rentals affect provider earnings.' };
  }
  if (booking.paymentStatus !== 'paid') return { allowed: false, reason: 'The booking is not awaiting a paid-payment refund.' };
  if (typeof payment.amount !== 'number' || !Number.isFinite(payment.amount) || payment.amount <= 0 || payment.currency !== 'LKR') {
    return { allowed: false, reason: 'The payment must have a valid positive LKR amount.' };
  }
  if (!payment.bookingId || !payment.playerId || !payment.providerId || !payment.transactionId
      || !['card', 'online_banking'].includes(payment.method)
      || payment.amount !== booking.totalPayable
      || payment.playerId !== booking.playerId || payment.providerId !== booking.providerId
      || payment.method !== booking.paymentMethod || payment.transactionId !== booking.transactionId) {
    return { allowed: false, reason: 'Payment and booking details do not match. Review the source records before refunding.' };
  }
  return { allowed: true, reason: '' };
}

/** Adapter keeps the policy testable without production Firebase access. */
export async function performRefundTransaction(transaction, { paymentId, uid, reason, timestamp }) {
  const payment = await transaction.read('payments', paymentId);
  if (!payment) throw new RefundError('This payment no longer exists.');
  const bookingId = payment.bookingId;
  if (typeof bookingId !== 'string' || !bookingId || bookingId.includes('/')) {
    throw new RefundError('This payment has no valid booking link.');
  }
  // Complete every read before writing, as required by Firestore transactions.
  const profile = await transaction.read('users', uid);
  const booking = await transaction.read('rental_requests', bookingId);
  const refundId = `${bookingId}_refund`;
  const existing = await transaction.read('payments', refundId);
  if (!isAdminProfile(profile)) throw new RefundError('Your account is no longer authorized as an administrator.');
  const eligibility = refundEligibility(payment, booking, !!existing);
  if (!eligibility.allowed) throw new RefundError(eligibility.reason);
  const note = typeof reason === 'string' ? reason.trim() : '';
  if (note.length < 5 || note.length > 500) throw new RefundError('Enter a refund reason between 5 and 500 characters.');
  const now = timestamp();
  transaction.create('payments', refundId, {
    originalPaymentId: paymentId,
    bookingId, bookingReference: payment.bookingReference || booking.bookingReference || '',
    playerId: payment.playerId, providerId: payment.providerId,
    type: 'refund', method: payment.method, amount: payment.amount, currency: 'LKR',
    status: 'refunded', transactionId: payment.transactionId, createdAt: now,
    refundReason: note, refundedBy: uid, updatedAt: now, updatedBy: uid,
  });
  transaction.update('rental_requests', bookingId, {
    paymentStatus: 'refunded', updatedAt: now, updatedBy: uid,
  });
  return refundId;
}
