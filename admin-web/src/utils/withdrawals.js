import { numberValue, textValue, toDate } from './format.js';
import { withdrawalEligibility } from '../services/withdrawalPolicy.js';

export function normalizeWithdrawal(id, data = {}) {
  return { id, providerId: textValue(data.providerId), bankAccountId: textValue(data.bankAccountId),
    bankName: textValue(data.bankName), accountHolderName: textValue(data.accountHolderName),
    accountLast4: textValue(data.accountLast4).slice(-4), branch: textValue(data.branch),
    amount: numberValue(data.amount), status: textValue(data.status), requestedAt: toDate(data.requestedAt),
    approvedAt: toDate(data.approvedAt), approvedBy: textValue(data.approvedBy),
    rejectedAt: toDate(data.rejectedAt), rejectedBy: textValue(data.rejectedBy), rejectionReason: textValue(data.rejectionReason),
    approvalNote: textValue(data.approvalNote), eligibility: withdrawalEligibility(data) };
}
