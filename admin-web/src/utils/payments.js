import { dateKey, numberValue, textValue, toDate } from './format.js';

export function normalizePayment(id, data = {}, booking = {}) {
  const source = data && typeof data === 'object' ? data : {};
  const rental = booking && typeof booking === 'object' ? booking : {};
  return {
    id, bookingId: textValue(source.bookingId),
    bookingReference: textValue(source.bookingReference) || textValue(rental.bookingReference) || textValue(source.bookingId),
    playerId: textValue(source.playerId) || textValue(rental.playerId),
    providerId: textValue(source.providerId) || textValue(rental.providerId),
    playerName: textValue(source.playerName) || textValue(rental.playerName),
    providerName: textValue(source.providerName) || textValue(rental.providerName),
    equipmentName: textValue(rental.equipmentName),
    // The mobile transaction mapper treats missing type as a payment.
    // Preserve explicit unfamiliar types and statuses rather than hiding them.
    type: textValue(source.type) || 'charge',
    method: textValue(source.method) || textValue(rental.paymentMethod),
    amount: numberValue(source.amount), currency: textValue(source.currency).toUpperCase(),
    status: textValue(source.status), transactionId: textValue(source.transactionId),
    cardLast4: textValue(source.cardLast4), bank: textValue(source.bank),
    createdAt: toDate(source.createdAt), updatedAt: toDate(source.updatedAt),
    updatedBy: textValue(source.updatedBy), refundReason: textValue(source.refundReason),
    refundedBy: textValue(source.refundedBy),
    originalPaymentId: textValue(source.originalPaymentId),
    bookingStatus: textValue(rental.status), bookingPaymentStatus: textValue(rental.paymentStatus),
  };
}

export const EMPTY_FILTERS = { search: '', status: '', method: '', from: '', to: '', sort: 'latest', type: '' };

export function filterPayments(payments, filters = EMPTY_FILTERS) {
  const term = (filters.search || '').trim().toLowerCase();
  const records = payments.filter((payment) => {
    const key = dateKey(payment.createdAt);
    return (!term || [payment.id, payment.transactionId, payment.bookingReference, payment.bookingId,
      payment.playerName, payment.playerId, payment.providerName, payment.providerId].some((value) => (value || '').toLowerCase().includes(term)))
      && (!filters.status || payment.status === filters.status)
      && (!filters.method || payment.method === filters.method)
      && (!filters.type || payment.type === filters.type)
      && (!filters.from || (!!key && key >= filters.from))
      && (!filters.to || (!!key && key <= filters.to));
  });
  return records.sort((a, b) => {
    if (filters.sort === 'amount_desc' || filters.sort === 'amount_asc') {
      if (a.amount == null) return b.amount == null ? a.id.localeCompare(b.id) : 1;
      if (b.amount == null) return -1;
      const delta = a.amount - b.amount;
      return (filters.sort === 'amount_asc' ? delta : -delta) || a.id.localeCompare(b.id);
    }
    if (!a.createdAt) return b.createdAt ? 1 : a.id.localeCompare(b.id);
    if (!b.createdAt) return -1;
    const delta = a.createdAt - b.createdAt;
    return (filters.sort === 'oldest' ? delta : -delta) || a.id.localeCompare(b.id);
  });
}

export function paymentMetrics(payments) {
  const charges = payments.filter((payment) => payment.type === 'charge');
  const refunds = payments.filter((payment) => payment.type === 'refund' && payment.status === 'refunded');
  const sum = (rows) => rows.reduce((total, payment) =>
    total + (payment.currency === 'LKR' && payment.amount != null ? payment.amount : 0), 0);
  return {
    totalVolume: sum(charges), paidVolume: sum(charges.filter((payment) => payment.status === 'paid')),
    refundedAmount: sum(refunds), totalRecords: payments.length,
    pickupBookings: new Set(charges.filter((payment) => payment.status === 'pay_on_pickup').map((payment) => payment.bookingId || payment.id)).size,
    paidCount: charges.filter((payment) => payment.status === 'paid').length,
    refundCount: refunds.length,
    excludedAmounts: payments.filter((payment) => payment.amount == null || payment.currency !== 'LKR').length,
  };
}

export function distributions(payments) {
  const count = (rows, key) => {
    const counts = new Map();
    for (const row of rows) {
      const value = row[key] || 'unknown';
      counts.set(value, (counts.get(value) || 0) + 1);
    }
    return Array.from(counts, ([name, value]) => ({ name, value }));
  };
  return { statuses: count(payments, 'status'), methods: count(payments.filter((payment) => payment.type === 'charge'), 'method') };
}

export function volumeSeries(payments, interval = 'daily', now = new Date()) {
  const today = dateKey(now);
  const anchor = new Date(`${today}T00:00:00Z`);
  const count = interval === 'daily' ? 30 : 12;
  const buckets = [];
  for (let index = count - 1; index >= 0; index--) {
    const start = new Date(anchor);
    if (interval === 'monthly') { start.setUTCDate(1); start.setUTCMonth(start.getUTCMonth() - index); }
    else if (interval === 'weekly') {
      start.setUTCDate(start.getUTCDate() - ((start.getUTCDay() + 6) % 7) - index * 7);
    } else start.setUTCDate(start.getUTCDate() - index);
    const end = new Date(start);
    if (interval === 'monthly') end.setUTCMonth(end.getUTCMonth() + 1);
    else end.setUTCDate(end.getUTCDate() + (interval === 'weekly' ? 7 : 1));
    const from = start.toISOString().slice(0, 10);
    const to = end.toISOString().slice(0, 10);
    buckets.push({ key: from, end: to,
      label: new Intl.DateTimeFormat('en-GB', { timeZone: 'UTC', month: 'short', ...(interval !== 'monthly' ? { day: 'numeric' } : {}) }).format(start),
      paid: 0, refunded: 0 });
  }
  for (const payment of payments) {
    if (payment.amount == null || payment.currency !== 'LKR') continue;
    const key = dateKey(payment.createdAt);
    if (!key || key > today) continue;
    const bucket = buckets.find((item) => key >= item.key && key < item.end);
    if (!bucket) continue;
    if (payment.type === 'charge' && payment.status === 'paid') bucket.paid += payment.amount;
    if (payment.type === 'refund' && payment.status === 'refunded') bucket.refunded += payment.amount;
  }
  return buckets;
}
