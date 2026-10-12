import test from 'node:test';
import assert from 'node:assert/strict';
import { imageSource, normalizeUser, normalizeEquipment, normalizeBooking, matchesSearch } from '../src/utils/platform.js';
import { isAdminProfile, safeReturnPath } from '../src/utils/authorization.js';

test('missing fields remain unknown and malformed dates do not crash details', () => {
  assert.equal(normalizeUser('u').isVerified, null);
  assert.equal(normalizeEquipment('e').isAvailable, null);
  assert.equal(normalizeEquipment('e').pricePerDay, null);
  assert.deepEqual(normalizeEquipment('e', { unavailableDates: 'invalid' }).unavailableDates, []);
  assert.deepEqual(normalizeEquipment('e', { unavailableDates: ['2026-10-12', null, 123] }).unavailableDates, ['2026-10-12']);
  assert.equal(normalizeBooking('b').totalPayable, null);
  assert.equal(normalizeBooking('b').status, '');
});
test('profile and booking projections omit secrets and bank details', () => {
  const sensitive = { password: 'secret', token: 'secret', accountNumber: '123456789', name: 'Provider' };
  for (const normalize of [normalizeUser, normalizeEquipment, normalizeBooking]) {
    const row = normalize('id', sensitive);
    for (const key of ['password', 'token', 'accountNumber']) assert.equal(key in row, false);
  }
});
test('stored HTTPS photos are retained; missing and executable sources are rejected', () => {
  const url = 'https://res.cloudinary.com/gg8wheuw/image/upload/v1/photo.jpg';
  assert.equal(normalizeEquipment('e', { imageUrl: url }).imageUrl, url);
  assert.equal(normalizeUser('u', { photoUrl: url }).photoUrl, url);
  for (const src of ['', null, {}, 'javascript:alert(1)', 'data:image/svg+xml,x', 'http://example.com/photo.jpg', 'https://user:secret@example.com/a']) assert.equal(imageSource(src), '');
});
test('search finds names, email, phone, IDs and providers', () => {
  const row = normalizeUser('user-123', { name: 'Nimal', email: 'nimal@example.com', phone: '0771234567' });
  for (const term of ['NIMAL', ' example.com ', '077123', 'user-123']) assert.equal(matchesSearch(row, ['name', 'email', 'phone', 'id'], term), true);
  assert.equal(matchesSearch(row, ['name', 'email'], 'missing'), false);
  assert.equal(matchesSearch(normalizeEquipment('e', { providerName: 'Kamal' }), ['providerName'], 'kamal'), true);
});
test('verification cannot confer administrator authorization', () => {
  for (const role of ['player', 'provider', 'Admin', '', null]) assert.equal(isAdminProfile({ role, isVerified: true }), false);
  assert.equal(isAdminProfile({ role: 'admin', isVerified: false }), true);
});

test('new protected routes support login return paths without permitting external redirects', () => {
  for (const route of ['/users','/users/provider-1','/equipment','/equipment/item-1','/withdrawals/request-1']) assert.equal(safeReturnPath(route),route);
  for (const route of ['//example.com','https://example.com','/users-other']) assert.equal(safeReturnPath(route),'/dashboard');
});
