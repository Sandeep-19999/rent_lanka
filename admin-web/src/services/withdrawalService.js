import { collection, doc, onSnapshot, runTransaction, serverTimestamp } from 'firebase/firestore';
import { adminWithdrawalsEnabled, auth, db } from './firebase.js';
import { performWithdrawalApproval, WithdrawalError } from './withdrawalPolicy.js';

export function watchWithdrawals(next, error) {
  return onSnapshot(collection(db, 'withdrawals'), next, error);
}

export function approveWithdrawal({ withdrawalId, note }) {
  if (!adminWithdrawalsEnabled) throw new WithdrawalError('Withdrawal approval requires reviewed security rules. Write actions are disabled.');
  const uid = auth?.currentUser?.uid;
  if (!uid) throw new WithdrawalError('Please sign in again before approving a withdrawal.');
  return runTransaction(db, (firebaseTransaction) => {
    if (auth.currentUser?.uid !== uid) throw new WithdrawalError('Your session changed. Please sign in again.');
    return performWithdrawalApproval({
      async read(name, id) {
        const snapshot = await firebaseTransaction.get(doc(db, name, id));
        return snapshot.exists() ? snapshot.data() : null;
      },
      update(name, id, data) { firebaseTransaction.update(doc(db, name, id), data); },
    }, { withdrawalId, uid, note, timestamp: serverTimestamp });
  });
}
