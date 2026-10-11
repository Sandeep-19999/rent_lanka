import test from 'node:test';
import assert from 'node:assert/strict';
import { performWithdrawalApproval, withdrawalEligibility } from '../src/services/withdrawalPolicy.js';
import { normalizeWithdrawal } from '../src/utils/withdrawals.js';

const options = { withdrawalId: 'withdrawal-1', uid: 'admin-1', note: ' Reviewed request. ', timestamp: () => 'SERVER_TIMESTAMP' };
function fixture(changes = {}) {
  const withdrawal = { providerId: 'provider-1', bankAccountId: 'bank-1', bankName: 'Test Bank',
    accountHolderName: 'Test Provider', accountLast4: '1234', branch: 'Test Branch',
    amount: 12000, status: 'pending', requestedAt: new Date(), ...changes };
  const documents = new Map([['withdrawals/withdrawal-1', withdrawal], ['users/admin-1', { role: 'admin' }],
    ['users/provider-1', { role: 'provider' }]]);
  const writes = [];
  const transaction = {
    async read(name, id) { assert.equal(writes.length, 0, 'read before writing'); return documents.get(`${name}/${id}`) || null; },
    update(name, id, patch) { writes.push({ path: `${name}/${id}`, patch }); },
  };
  return { withdrawal, documents, writes, transaction };
}

test('approval changes only the pending request status and audit, preserving the reserved amount and payout details', async () => {
  const setup = fixture();
  const original = structuredClone(setup.withdrawal);
  await performWithdrawalApproval(setup.transaction, options);
  assert.deepEqual(setup.writes, [{ path: 'withdrawals/withdrawal-1', patch: {
    status: 'approved', approvedAt: 'SERVER_TIMESTAMP', approvedBy: 'admin-1',
    approvalNote: 'Reviewed request.', updatedAt: 'SERVER_TIMESTAMP', updatedBy: 'admin-1',
  } }]);
  assert.deepEqual(setup.withdrawal, original);
  assert.equal(setup.writes.some((write) => /payments|rental_requests|equipment|bank_accounts/.test(write.path)), false);
});

test('repeated or stale approvals and terminal withdrawals are rejected without writes', async () => {
  for (const status of ['approved', 'completed', 'rejected', 'cancelled', '', 'processing']) {
    const setup = fixture({ status });
    await assert.rejects(performWithdrawalApproval(setup.transaction, options), /Only pending/);
    assert.equal(setup.writes.length, 0);
  }
  const setup = fixture({ approvedBy: 'another-admin' });
  await assert.rejects(performWithdrawalApproval(setup.transaction, options), /already contains an approval/);
  assert.equal(setup.writes.length, 0);
});

test('revoked admin roles and missing or non-provider accounts cannot approve', async () => {
  for (const role of ['player', 'provider', 'Admin', null]) {
    const setup = fixture();
    setup.documents.set('users/admin-1', role ? { role } : null);
    await assert.rejects(performWithdrawalApproval(setup.transaction, options), /no longer authorized/);
    assert.equal(setup.writes.length, 0);
  }
  for (const provider of [null, { role: 'player' }]) {
    const setup = fixture(); setup.documents.set('users/provider-1', provider);
    await assert.rejects(performWithdrawalApproval(setup.transaction, options), /provider account/);
    assert.equal(setup.writes.length, 0);
  }
});

test('invalid amounts and incomplete bank snapshots cannot authorize approval', async () => {
  for (const change of [{ amount: '12000' }, { amount: 0 }, { amount: -1 }, { amount: NaN }, { amount: Infinity },
    { providerId: 'invalid/id' }, { bankAccountId: '' }, { accountLast4: '12345678' },
    { accountLast4: 1234 }, { bankName: '' }, { accountHolderName: null }, { branch: '' }]) {
    const setup = fixture(change);
    await assert.rejects(performWithdrawalApproval(setup.transaction, options));
    assert.equal(setup.writes.length, 0);
  }
});

test('missing requests and invalid approval notes or IDs cannot write', async () => {
  const setup = fixture(); setup.documents.delete('withdrawals/withdrawal-1');
  await assert.rejects(performWithdrawalApproval(setup.transaction, options), /no longer available/);
  for (const change of [{ note: 'x'.repeat(501) }, { note: null }, { withdrawalId: 'bad/id' }]) {
    const invalid = fixture();
    await assert.rejects(performWithdrawalApproval(invalid.transaction, { ...options, ...change }));
    assert.equal(invalid.writes.length, 0);
  }
});

test('legacy display mapping masks account digits and does not turn numeric strings into approval authorization', () => {
  const setup = fixture({ amount: '12000', accountLast4: '12345678' });
  const display = normalizeWithdrawal('legacy', setup.withdrawal);
  assert.equal(display.amount, 12000);
  assert.equal(display.accountLast4, '5678');
  assert.equal(display.eligibility.allowed, false);
  assert.equal(withdrawalEligibility(null).allowed, false);
});
