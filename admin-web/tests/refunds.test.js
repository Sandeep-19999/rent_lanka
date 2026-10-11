import test from 'node:test';
import assert from 'node:assert/strict';
import { performRefundTransaction, refundEligibility } from '../src/services/refundPolicy.js';

function fixture(changes = {}) {
  const charge = { bookingId: 'booking-1', bookingReference: 'RL-TEST01', type: 'charge', method: 'card', amount: 15000,
    currency: 'LKR', status: 'paid', transactionId: 'TXN-TEST', playerId: 'player-1', providerId: 'provider-1' };
  const booking = { status: 'rejected', paymentStatus: 'paid', totalPayable: 15000,
    paymentMethod: 'card', transactionId: 'TXN-TEST', playerId: 'player-1', providerId: 'provider-1', ...changes };
  const documents = new Map([['payments/charge-1', charge], ['rental_requests/booking-1', booking], ['users/admin-1', { role: 'admin' }]]);
  const writes = [];
  const adapter = {
    async read(name, id) { assert.equal(writes.length, 0, 'all reads must occur before writes'); return documents.get(`${name}/${id}`) || null; },
    create(name, id, data) { writes.push({ operation: 'create', path: `${name}/${id}`, data }); },
    update(name, id, data) { writes.push({ operation: 'update', path: `${name}/${id}`, data }); },
  };
  return { charge, booking, documents, writes, adapter };
}
const options = { paymentId: 'charge-1', uid: 'admin-1', reason: 'Provider declined the rental request.', timestamp: () => 'SERVER_TIMESTAMP' };

test('a valid terminal-booking refund creates a separate deterministic record and preserves the original charge', async () => {
  const { adapter, writes, charge, documents } = fixture();
  const before = structuredClone(charge);
  const id = await performRefundTransaction(adapter, options);
  assert.equal(id, 'booking-1_refund');
  assert.equal(writes.length, 2);
  assert.equal(writes[0].path, 'payments/booking-1_refund');
  assert.equal(writes[0].data.type, 'refund');
  assert.equal(writes[0].data.status, 'refunded');
  assert.equal(writes[0].data.amount, 15000);
  assert.equal(writes[0].data.originalPaymentId, 'charge-1');
  assert.equal(writes[0].data.refundedBy, 'admin-1');
  assert.equal(writes[0].data.createdAt, 'SERVER_TIMESTAMP');
  assert.deepEqual(writes[1].data, { paymentStatus: 'refunded', updatedAt: 'SERVER_TIMESTAMP', updatedBy: 'admin-1' });
  assert.deepEqual(documents.get('payments/charge-1'), before);
  assert.ok(writes.every((write) => !/equipment|booking_slots|withdrawals|notifications/.test(write.path)));
});

test('duplicate refund validation prevents a second write', async () => {
  const { adapter, documents, writes } = fixture();
  documents.set('payments/booking-1_refund', { type: 'refund' });
  await assert.rejects(performRefundTransaction(adapter, options), /already been recorded/);
  assert.equal(writes.length, 0);
});

test('refunds never change active, upcoming or completed rental earnings', async () => {
  for (const status of ['pending', 'accepted', 'active', 'completed']) {
    const { adapter, writes } = fixture({ status });
    await assert.rejects(performRefundTransaction(adapter, options), /rejected or cancelled/);
    assert.equal(writes.length, 0);
  }
  const cancelled = fixture({ status: 'cancelled' });
  await assert.doesNotReject(performRefundTransaction(cancelled.adapter, options));
});

test('revoked or non-admin accounts cannot write refunds', async () => {
  for (const role of ['player', 'provider', 'Admin']) {
    const { adapter, documents, writes } = fixture();
    documents.set('users/admin-1', { role });
    await assert.rejects(performRefundTransaction(adapter, options), /no longer authorized/);
    assert.equal(writes.length, 0);
  }
});

test('mismatched amount, method, identities, currency and transaction reject without writes', async () => {
  for (const change of [{ totalPayable: 999 }, { providerId: 'wrong' }, { playerId: 'wrong' },
    { paymentMethod: 'cash' }, { transactionId: 'TXN-OTHER' }, { paymentStatus: 'refunded' }]) {
    const { adapter, writes } = fixture(change);
    await assert.rejects(performRefundTransaction(adapter, options));
    assert.equal(writes.length, 0);
  }
  const { charge, booking } = fixture();
  assert.equal(refundEligibility({ ...charge, status: 'pay_on_pickup' }, booking).allowed, false);
  assert.equal(refundEligibility({ ...charge, currency: 'USD' }, booking).allowed, false);
  assert.equal(refundEligibility({ ...charge, amount: '15000' }, booking).allowed, false);
  assert.equal(refundEligibility({ ...charge, transactionId: '' }, booking).allowed, false);
});

test('missing booking and invalid reason are rejected before any writes', async () => {
  const missing = fixture();
  missing.documents.delete('rental_requests/booking-1');
  await assert.rejects(performRefundTransaction(missing.adapter, options), /both be available/);
  assert.equal(missing.writes.length, 0);
  const invalid = fixture();
  await assert.rejects(performRefundTransaction(invalid.adapter, { ...options, reason: 'bad' }), /5 and 500/);
  assert.equal(invalid.writes.length, 0);
});
