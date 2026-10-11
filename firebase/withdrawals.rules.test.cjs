// Uses the existing browser SDK. Never connects to the production project.
const { createRequire } = require('node:module');
const { test, before, beforeEach, after } = require('node:test');
const assert = require('node:assert/strict');
const sdk = createRequire(require('node:path').resolve(__dirname, '../admin-web/package.json'));
const { initializeApp, deleteApp } = sdk('firebase/app');
const { getFirestore, connectFirestoreEmulator, doc, setDoc, updateDoc, deleteDoc,
  getDocFromServer, getDocsFromServer, collection, query, where, serverTimestamp,
  terminate, runTransaction } = sdk('firebase/firestore');
const project = 'demo-rent-lanka-withdrawals';
const host = process.env.FIRESTORE_EMULATOR_HOST;
if (host !== '127.0.0.1:8180') throw new Error('Tests require the local emulator at 127.0.0.1:8180.');
const base = `http://${host}/v1/projects/${project}/databases/(default)/documents`;
const contexts = new Map();
function db(uid) {
  const key = uid || 'anonymous';
  if (!contexts.has(key)) {
    const app = initializeApp({ projectId: project, apiKey: 'emulator-only' }, key);
    const firestore = getFirestore(app);
    connectFirestoreEmulator(firestore, '127.0.0.1', 8180,
      uid ? { mockUserToken: { sub: uid } } : {});
    contexts.set(key, { app, firestore });
  }
  return contexts.get(key).firestore;
}
async function seed(path, data) {
  const fields = Object.fromEntries(Object.entries(data).map(([key, value]) => [key,
    typeof value === 'number' ? { doubleValue: value } : { stringValue: value }]));
  const response = await fetch(`${base}/${path}`, {
    method: 'PATCH', headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields }),
  });
  assert.equal(response.ok, true, await response.text());
}
const bank = { providerId: 'provider', bankName: 'Test Bank', accountHolderName: 'Provider',
  accountNumber: '001234', branch: 'Colombo' };
const pending = { providerId: 'provider', bankAccountId: 'bank', bankName: bank.bankName,
  accountHolderName: bank.accountHolderName, accountLast4: '1234', branch: bank.branch,
  amount: 12000, status: 'pending' };
function request(changes = {}) { return { ...pending, requestedAt: serverTimestamp(), ...changes }; }
function approval(uid = 'admin', changes = {}) {
  return { status: 'approved', approvedAt: serverTimestamp(), approvedBy: uid,
    updatedAt: serverTimestamp(), updatedBy: uid, approvalNote: 'Reviewed.', ...changes };
}
async function denied(operation) {
  await assert.rejects(operation, (error) => error.code === 'permission-denied');
}
before(() => { db('admin'); db('provider'); db('player'); db('other'); db(null); });
beforeEach(async () => {
  const cleared = await fetch(`http://${host}/emulator/v1/projects/${project}/databases/(default)/documents`,
    { method: 'DELETE' });
  assert.equal(cleared.ok, true);
  await Promise.all([
    seed('users/admin', { role: 'admin' }), seed('users/provider', { role: 'provider' }),
    seed('users/player', { role: 'player' }), seed('users/other', { role: 'provider' }),
    seed('bank_accounts/bank', bank), seed('withdrawals/existing', pending),
  ]);
});
after(async () => {
  await Promise.all([...contexts.values()].map(async ({ app, firestore }) => {
    await terminate(firestore); await deleteApp(app);
  }));
});

test('provider submission and admin reads leave the request pending until explicit approval', async () => {
  await setDoc(doc(db('provider'), 'withdrawals/new'), request());
  assert.equal((await getDocFromServer(doc(db('provider'), 'withdrawals/new'))).data().status, 'pending');
  const rows = await getDocsFromServer(collection(db('admin'), 'withdrawals'));
  assert.equal(rows.size, 2);
  assert.ok(rows.docs.every((row) => row.data().status === 'pending'));
  await updateDoc(doc(db('admin'), 'withdrawals/new'), approval());
  const approved = (await getDocFromServer(doc(db('provider'), 'withdrawals/new'))).data();
  assert.equal(approved.status, 'approved');
  assert.equal(approved.approvedBy, 'admin');
  assert.equal(approved.amount, pending.amount);
  assert.equal(approved.bankAccountId, pending.bankAccountId);
  assert.equal(approved.approvedAt.toMillis(), approved.updatedAt.toMillis());
});

test('providers, players and unauthenticated callers cannot approve or delete withdrawals', async () => {
  for (const uid of ['provider', 'player', 'other', null]) {
    await denied(updateDoc(doc(db(uid), 'withdrawals/existing'), approval(uid || 'admin')));
    await denied(deleteDoc(doc(db(uid), 'withdrawals/existing')));
  }
  await denied(deleteDoc(doc(db('admin'), 'withdrawals/existing')));
  await denied(setDoc(doc(db('provider'), 'withdrawals/preapproved'), request({ status: 'approved' })));
  await denied(setDoc(doc(db('provider'), 'withdrawals/audit'), request({ approvedBy: 'admin' })));
  await denied(setDoc(doc(db('admin'), 'withdrawals/admin-created'), request()));
});

test('request validation rejects spoofed payees, invalid amounts and client timestamps', async () => {
  for (const patch of [{ providerId: 'other' }, { bankAccountId: 'missing' },
    { bankName: 'Fake Bank' }, { accountHolderName: 'Other' }, { accountLast4: '9999' },
    { branch: 'Other' }, { amount: 0 }, { amount: -1 }, { amount: '12000' },
    { amount: Infinity }, { requestedAt: 'client date' }]) {
    await denied(setDoc(doc(db('provider'), 'withdrawals/invalid'), request(patch)));
  }
  await seed('bank_accounts/foreign', { ...bank, providerId: 'other' });
  await denied(setDoc(doc(db('provider'), 'withdrawals/foreign'), request({ bankAccountId: 'foreign' })));
  await denied(setDoc(doc(db('player'), 'withdrawals/player'), request({ providerId: 'player' })));
});

test('approval preserves amount/payee and requires authentic server audit fields', async () => {
  for (const patch of [{ amount: 1 }, { bankAccountId: 'other' }, { accountLast4: '9999' },
    { providerId: 'other' }, { approvedBy: 'provider' }, { updatedBy: 'provider' },
    { approvedAt: 'client date' }, { updatedAt: 'client date' }, { approvalNote: 'x'.repeat(501) },
    { status: 'completed' }]) {
    await denied(updateDoc(doc(db('admin'), 'withdrawals/existing'), approval('admin', patch)));
  }
  await updateDoc(doc(db('admin'), 'withdrawals/existing'), approval());
  await denied(updateDoc(doc(db('admin'), 'withdrawals/existing'), approval()));
  await denied(updateDoc(doc(db('admin'), 'withdrawals/existing'), { status: 'pending' }));
  await seed('users/provider', { role: 'player' });
  await seed('withdrawals/revoked', pending);
  await denied(updateDoc(doc(db('admin'), 'withdrawals/revoked'), approval()));
});

test('only one of two concurrent admin transactions can approve', async () => {
  const target = doc(db('admin'), 'withdrawals/existing');
  const attempt = () => runTransaction(db('admin'), async (transaction) => {
    const snapshot = await transaction.get(target);
    if (snapshot.data().status !== 'pending') throw new Error('Already approved');
    transaction.update(target, approval());
  });
  const results = await Promise.allSettled([attempt(), attempt()]);
  assert.equal(results.filter((result) => result.status === 'fulfilled').length, 1);
  assert.equal((await getDocFromServer(target)).data().status, 'approved');
});

test('private bank/withdrawal reads require an owner filter; admin reads all', async () => {
  await getDocsFromServer(query(collection(db('provider'), 'withdrawals'), where('providerId', '==', 'provider')));
  await getDocsFromServer(query(collection(db('provider'), 'bank_accounts'), where('providerId', '==', 'provider')));
  await denied(getDocsFromServer(collection(db('provider'), 'withdrawals')));
  await denied(getDocFromServer(doc(db('other'), 'withdrawals/existing')));
  await denied(getDocFromServer(doc(db(null), 'bank_accounts/bank')));
  await getDocsFromServer(collection(db('admin'), 'bank_accounts'));
  await setDoc(doc(db('provider'), 'bank_accounts/new'), bank);
  await updateDoc(doc(db('provider'), 'bank_accounts/new'), { branch: 'Galle' });
  await denied(updateDoc(doc(db('provider'), 'bank_accounts/new'), { providerId: 'other' }));
  await denied(updateDoc(doc(db('other'), 'bank_accounts/bank'), { branch: 'Galle' }));
  await denied(setDoc(doc(db('other'), 'bank_accounts/spoof'), bank));
  await deleteDoc(doc(db('provider'), 'bank_accounts/new'));
});

test('mobile signup/role/profile/favourites work without permitting self-promotion or admin replacement', async () => {
  await setDoc(doc(db('new-user'), 'users/new-user'), { name: 'New user' });
  await updateDoc(doc(db('new-user'), 'users/new-user'), { role: 'player' });
  await updateDoc(doc(db('new-user'), 'users/new-user'), { role: 'provider' });
  await updateDoc(doc(db('new-user'), 'users/new-user'), { name: 'Updated' });
  await denied(updateDoc(doc(db('new-user'), 'users/new-user'), { role: 'admin' }));
  await denied(setDoc(doc(db('new-admin'), 'users/new-admin'), { role: 'admin' }));
  await denied(setDoc(doc(db('provider'), 'users/admin'), { role: 'provider' }));
  await denied(deleteDoc(doc(db('provider'), 'users/admin')));
  await denied(deleteDoc(doc(db('admin'), 'users/admin')));
  await denied(updateDoc(doc(db('admin'), 'users/admin'), { role: 'provider' }));
  await denied(updateDoc(doc(db(null), 'users/admin'), { role: 'provider' }));
  await setDoc(doc(db('player'), 'users/player/favourites/equipment'), { equipmentId: 'equipment' });
  await denied(getDocFromServer(doc(db('other'), 'users/player/favourites/equipment')));
  await deleteDoc(doc(db('player'), 'users/player/favourites/equipment'));
  await deleteDoc(doc(db('player'), 'users/player'));
});

test('unrelated legacy mobile collections retain the existing test grant', async () => {
  await setDoc(doc(db('player'), 'payments/legacy-flow'), { status: 'pay_on_pickup' });
  await getDocFromServer(doc(db('provider'), 'payments/legacy-flow'));
});
