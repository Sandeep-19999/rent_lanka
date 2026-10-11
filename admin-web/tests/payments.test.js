import test from 'node:test';
import assert from 'node:assert/strict';
import { dateKey, formatCurrency, formatDate, numberValue, toDate } from '../src/utils/format.js';
import { EMPTY_FILTERS, distributions, filterPayments, normalizePayment, paymentMetrics, volumeSeries } from '../src/utils/payments.js';
import { csvCell, paymentsCsv } from '../src/utils/csv.js';
import { isAdminProfile, safeReturnPath } from '../src/utils/authorization.js';

const payment = (id, changes = {}) => normalizePayment(id, { bookingId: `booking-${id}`, type: 'charge', amount: 12500,
  currency: 'LKR', method: 'card', status: 'paid', createdAt: '2026-10-10T06:00:00Z', ...changes });

test('normalization handles missing and malformed legacy fields without fabricating paid status or amounts', () => {
  const row = normalizePayment('legacy', { amount: { invalid: true }, createdAt: { toDate() { throw Error('bad timestamp'); } } });
  assert.equal(row.amount, null);
  assert.equal(row.status, '');
  assert.equal(row.currency, '');
  assert.equal(row.createdAt, null);
  assert.equal(row.type, 'charge');
  assert.doesNotThrow(() => normalizePayment('null', null, null));
  assert.equal(normalizePayment('old', { amount: '125.50' }).amount, 125.5);
  assert.equal(normalizePayment('id', { status: 'legacy_custom', type: 'legacy_type' }).status, 'legacy_custom');
  assert.equal(normalizePayment('id', { type: 'legacy_type' }).type, 'legacy_type');
});

test('related rental fields supply names and method without overwriting stored payment values', () => {
  const row = normalizePayment('id', { status: 'paid', method: 'card', bookingId: 'b' },
    { playerName: 'Test Player', providerName: 'Test Provider', paymentMethod: 'cash', paymentStatus: 'refunded', status: 'cancelled' });
  assert.equal(row.playerName, 'Test Player');
  assert.equal(row.providerName, 'Test Provider');
  assert.equal(row.method, 'card');
  assert.equal(row.status, 'paid');
  assert.equal(row.bookingPaymentStatus, 'refunded');
});

test('date handling respects Asia/Colombo boundaries and accepts real Firestore timestamp shapes', () => {
  assert.equal(dateKey('2026-10-09T19:00:00Z'), '2026-10-10');
  assert.equal(dateKey('2026-10-09T18:29:00Z'), '2026-10-09');
  assert.equal(toDate({ seconds: 0 }).getTime(), 0);
  assert.equal(toDate({ toDate: () => new Date('2026-01-01') }).getUTCFullYear(), 2026);
  assert.equal(toDate('invalid'), null);
  assert.equal(toDate({}), null);
  assert.equal(formatDate(undefined), 'Not recorded');
  assert.equal(numberValue(false), null);
  assert.equal(numberValue(-1), null);
  assert.equal(numberValue(''), null);
  assert.equal(numberValue(Infinity), null);
  assert.equal(formatCurrency(null), 'Not recorded');
});

test('financial metrics count original charge volume once and refund records separately', () => {
  const rows = [payment('a'), payment('b', { method: 'cash', status: 'pay_on_pickup', amount: 3000 }),
    payment('r', { bookingId: 'booking-a', type: 'refund', status: 'refunded' }),
    payment('usd', { currency: 'USD', amount: 100 }), payment('bad', { amount: null }),
    payment('custom', { type: 'unknown', amount: 200 })];
  const metrics = paymentMetrics(rows);
  assert.equal(metrics.totalVolume, 15500);
  assert.equal(metrics.paidVolume, 12500);
  assert.equal(metrics.refundedAmount, 12500);
  assert.equal(metrics.totalRecords, 6);
  assert.equal(metrics.pickupBookings, 1);
  assert.equal(metrics.excludedAmounts, 2);
  assert.equal(metrics.refundCount, 1);
  assert.equal(distributions(rows).methods.reduce((sum, entry) => sum + entry.value, 0), 4);
  assert.equal(distributions(rows).statuses.find((entry) => entry.name === 'refunded').value, 1);
});

test('search, status, method and date filters combine and never mutate the source records', () => {
  const rows = [payment('a', { transactionId: 'TXN-ABC', playerName: 'Test Player' }),
    payment('b', { createdAt: '2026-10-08T12:00:00Z', amount: 100 }), payment('missing', { createdAt: null })];
  const matches = filterPayments(rows, { ...EMPTY_FILTERS, search: 'PLAYER', status: 'paid', method: 'card', from: '2026-10-10', to: '2026-10-10' });
  assert.deepEqual(matches.map((row) => row.id), ['a']);
  assert.equal(filterPayments(rows, { ...EMPTY_FILTERS, search: 'txn-abc' }).length, 1);
  assert.deepEqual(filterPayments(rows, { ...EMPTY_FILTERS, sort: 'oldest' }).map((row) => row.id), ['b', 'a', 'missing']);
  assert.equal(filterPayments(rows, { ...EMPTY_FILTERS, sort: 'amount_asc' })[0].id, 'b');
  assert.deepEqual(rows.map((row) => row.id), ['a', 'b', 'missing']);
});

test('chart buckets separate refunds and exclude cash obligations and foreign currency', () => {
  const rows = [payment('a'), payment('r', { type: 'refund', status: 'refunded', amount: 2000 }),
    payment('cash', { status: 'pay_on_pickup', method: 'cash' }), payment('foreign', { currency: 'USD' })];
  for (const interval of ['daily', 'weekly', 'monthly']) {
    const series = volumeSeries(rows, interval, new Date('2026-10-10T12:00:00Z'));
    assert.equal(series.reduce((sum, point) => sum + point.paid, 0), 12500);
    assert.equal(series.reduce((sum, point) => sum + point.refunded, 0), 2000);
  }
});

test('unfamiliar legacy values cannot collide with object prototype keys in chart counts', () => {
  const rows = [payment('a', { status: '__proto__', method: 'constructor' }), payment('b', { status: '__proto__', method: 'constructor' })];
  assert.deepEqual(distributions(rows).statuses, [{ name: '__proto__', value: 2 }]);
  assert.deepEqual(distributions(rows).methods, [{ name: 'constructor', value: 2 }]);
});

test('CSV exports only supplied filtered records and neutralizes spreadsheet formula injection', () => {
  for (const value of ['=SUM(A1)', '+123', '-1', '@command', '\tcommand', '   =formula']) assert.ok(csvCell(value).startsWith('"\''));
  assert.equal(csvCell('a"b,c'), '"a""b,c"');
  const rows = [payment('a', { status: 'paid' }), payment('b', { status: 'pay_on_pickup' })];
  const csv = paymentsCsv(filterPayments(rows, { ...EMPTY_FILTERS, status: 'paid' }));
  assert.ok(csv.includes('"a"'));
  assert.ok(!csv.includes('"b"'));
  assert.ok(csv.includes('Asia/Colombo'));
});

test('authorization requires the exact admin role and return paths stay inside protected routes', () => {
  assert.equal(isAdminProfile({ role: 'admin' }), true);
  for (const role of ['player', 'provider', 'Admin', ' admin ', '', null]) assert.equal(isAdminProfile({ role }), false);
  assert.equal(isAdminProfile(null), false);
  assert.equal(safeReturnPath('//outside.example'), '/dashboard');
  assert.equal(safeReturnPath('/payments-elsewhere'), '/dashboard');
  assert.equal(safeReturnPath('/payments/id?search=abc'), '/payments/id?search=abc');
});
