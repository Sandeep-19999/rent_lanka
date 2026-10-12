import { isAdminProfile } from '../utils/authorization.js';

export class WithdrawalError extends Error {
  constructor(message) { super(message); this.name = 'WithdrawalError'; }
}

const validId = (value) => typeof value === 'string' && !!value.trim() && !value.includes('/');

export function withdrawalEligibility(withdrawal) {
  if (!withdrawal) return { allowed: false, reason: 'This withdrawal is no longer available.' };
  if (withdrawal.status !== 'pending') return { allowed: false, reason: 'Only pending withdrawals can be approved.' };
  if (withdrawal.rejectedAt != null || withdrawal.rejectedBy != null) return { allowed: false, reason: 'This request already contains a rejection. Review its history.' };
  if (withdrawal.approvedAt != null || withdrawal.approvedBy != null) {
    return { allowed: false, reason: 'This request already contains an approval. Review its history.' };
  }
  if (typeof withdrawal.amount !== 'number' || !Number.isFinite(withdrawal.amount) || withdrawal.amount <= 0) {
    return { allowed: false, reason: 'The request must contain a valid positive amount.' };
  }
  if (!validId(withdrawal.providerId) || !validId(withdrawal.bankAccountId)
    || !['bankName', 'accountHolderName', 'branch'].every((key) => typeof withdrawal[key] === 'string' && !!withdrawal[key].trim())
    || typeof withdrawal.accountLast4 !== 'string' || !/^\d{4}$/.test(withdrawal.accountLast4)) {
    return { allowed: false, reason: 'Provider or bank details are incomplete. Review the source request.' };
  }
  return { allowed: true, reason: '' };
}

/** Approval preserves the reserved amount and does not perform a bank payout. */
export async function performWithdrawalApproval(transaction, { withdrawalId, uid, note = '', timestamp }) {
  if (!validId(withdrawalId) || !validId(uid)) throw new WithdrawalError('Invalid withdrawal or administrator reference.');
  if (typeof note !== 'string' || note.trim().length > 500) throw new WithdrawalError('Keep the approval note within 500 characters.');
  const profile = await transaction.read('users', uid);
  const withdrawal = await transaction.read('withdrawals', withdrawalId);
  if (!isAdminProfile(profile)) throw new WithdrawalError('Your account is no longer authorized as an administrator.');
  const eligibility = withdrawalEligibility(withdrawal);
  if (!eligibility.allowed) throw new WithdrawalError(eligibility.reason);
  const provider = await transaction.read('users', withdrawal.providerId);
  if (provider?.role !== 'provider') throw new WithdrawalError('The linked provider account could not be verified.');
  const now = timestamp();
  transaction.update('withdrawals', withdrawalId, {
    status: 'approved', approvedAt: now, approvedBy: uid, approvalNote: note.trim(), updatedAt: now, updatedBy: uid,
  });
  return withdrawalId;
}

/** Rejection releases the request reservation via the existing mobile balance calculation. */
export async function performWithdrawalRejection(transaction, { withdrawalId, uid, reason, timestamp }) {
  if (!validId(withdrawalId) || !validId(uid)) throw new WithdrawalError('Invalid withdrawal or administrator reference.');
  if (typeof reason !== 'string' || !reason.trim() || reason.trim().length > 500) throw new WithdrawalError('A rejection reason of 1-500 characters is required.');
  const profile = await transaction.read('users', uid);
  const withdrawal = await transaction.read('withdrawals', withdrawalId);
  if (!isAdminProfile(profile)) throw new WithdrawalError('Your account is no longer authorized as an administrator.');
  const eligibility = withdrawalEligibility(withdrawal);
  if (!eligibility.allowed) throw new WithdrawalError(eligibility.reason);
  const provider = await transaction.read('users', withdrawal.providerId);
  if (provider?.role !== 'provider') throw new WithdrawalError('The linked provider account could not be verified.');
  const now = timestamp();
  transaction.update('withdrawals', withdrawalId, {
    status: 'rejected', rejectedAt: now, rejectedBy: uid, rejectionReason: reason.trim(), updatedAt: now, updatedBy: uid,
  });
  return withdrawalId;
}
