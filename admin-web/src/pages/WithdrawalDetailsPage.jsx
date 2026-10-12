import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useDocument } from '../hooks/useDocument.js';
import { normalizeWithdrawal } from '../utils/withdrawals.js';
import { normalizeUser } from '../utils/platform.js';
import { formatCurrency, formatDateTime } from '../utils/format.js';
import { errorMessage } from '../utils/errors.js';
import { approveWithdrawal, rejectWithdrawal } from '../services/withdrawalService.js';
import { adminWithdrawalsEnabled, adminWithdrawalRejectionsEnabled } from '../services/firebase.js';
import { PageHeading, EmptyState, Notice } from '../components/common/Feedback.jsx';
import { Details, RecordState } from '../components/common/PlatformRecords.jsx';
import ConfirmModal from '../components/common/ConfirmModal.jsx';
import StatusBadge from '../components/payments/StatusBadge.jsx';
import { useToast } from '../context/ToastContext.jsx';
export default function WithdrawalDetailsPage() {
  const { withdrawalId } = useParams(); const state = useDocument('withdrawals',withdrawalId);
  const row = normalizeWithdrawal(withdrawalId,state.data || {});
  const provider = useDocument('users',row.providerId); const profile = normalizeUser(row.providerId,provider.data || {});
  const [action,setAction] = useState(''); const [note,setNote] = useState(''); const [busy,setBusy] = useState(false); const [error,setError] = useState(''); const notify = useToast();
  const enabled = action === 'reject' ? adminWithdrawalRejectionsEnabled : adminWithdrawalsEnabled;
  const valid = enabled && row.eligibility.allowed && note.trim().length <= 500 && (action !== 'reject' || !!note.trim());
  function open(value) { setAction(value); setNote(''); setError(''); }
  async function confirm() {
    if (!valid || busy) return;
    setBusy(true); setError('');
    try { if (action === 'reject') await rejectWithdrawal({ withdrawalId,reason:note }); else await approveWithdrawal({ withdrawalId,note }); notify(action === 'reject' ? 'Request rejected. Its reservation is released in the existing balance calculation.' : 'Request approved. No money was transferred.'); setAction(''); }
    catch (failure) { setError(errorMessage(failure)); }
    finally { setBusy(false); }
  }
  return <><PageHeading eyebrow="PLATFORM ADMINISTRATION" title="Withdrawal details" description="Review the request, provider and decision history"><Link className="button secondary" to="/withdrawals">Back to withdrawals</Link></PageHeading><RecordState state={state}>{state.missing ? <EmptyState title="Withdrawal not found" description="This request is no longer available." /> : <><Notice>Approval updates status only and leaves the amount reserved. Rejection releases the reservation through the mobile app's existing balance calculation. Neither action transfers money.</Notice><section className="glass platform-panel"><StatusBadge status={row.status} /><Details entries={[["Request ID",row.id],["Amount",formatCurrency(row.amount)],["Requested",formatDateTime(row.requestedAt)],["Bank",row.bankName],["Account holder",row.accountHolderName],["Account ending",row.accountLast4 ? `Ending ${row.accountLast4}` : ''],["Branch",row.branch],["Approved at",formatDateTime(row.approvedAt)],["Approved by",row.approvedBy],["Approval note",row.approvalNote],["Rejected at",formatDateTime(row.rejectedAt)],["Rejected by",row.rejectedBy],["Rejection reason",row.rejectionReason]]} />{row.status === 'pending' && <><div className="modal-actions"><button className="button secondary" disabled={!adminWithdrawalRejectionsEnabled || !row.eligibility.allowed || busy} onClick={() => open('reject')}>Reject request</button><button className="button primary" disabled={!adminWithdrawalsEnabled || !row.eligibility.allowed || busy} onClick={() => open('approve')}>Approve request</button></div>{!row.eligibility.allowed && <Notice tone="warning">{row.eligibility.reason}</Notice>}{(!adminWithdrawalsEnabled || !adminWithdrawalRejectionsEnabled) && <Notice tone="warning">Disabled decision actions require their reviewed security rules and local feature flag. Rejection requires the new rejection rules.</Notice>}</>}</section><section className="glass platform-panel"><h2>Provider</h2><RecordState state={provider}>{provider.missing ? <p>Provider profile not found.</p> : <Details entries={[["Provider",row.providerId ? <Link to={`/users/${encodeURIComponent(row.providerId)}`}>{profile.name || row.providerId}</Link> : 'Not recorded'],["Email",profile.email],["Phone",profile.phone],["Role",profile.role],["Location",profile.location]]} />}</RecordState></section></>}</RecordState><ConfirmModal open={!!action} title={action === 'reject' ? 'Reject withdrawal request?' : 'Approve withdrawal request?'} description={action === 'reject' ? 'This rejects the pending request and releases its reserved amount. No money is transferred.' : 'This approves the pending request for a future payout. No money is transferred.'} busy={busy} busyLabel="Recording decision..." onCancel={() => { if (!busy) setAction(''); }} onConfirm={confirm} confirmLabel={action === 'reject' ? 'Reject request' : 'Approve request'} disabled={!valid}><Details entries={[["Amount",formatCurrency(row.amount)],["Provider",profile.name || row.providerId],["Account ending",row.accountLast4 ? `Ending ${row.accountLast4}` : 'Not recorded']]} /><label className="form-label" htmlFor="decision-note">{action === 'reject' ? 'Rejection reason (required)' : 'Approval note (optional)'}</label><textarea id="decision-note" rows={3} maxLength={500} required={action === 'reject'} disabled={busy} value={note} onChange={e => setNote(e.target.value)} />{!row.eligibility.allowed && <p className="form-error" role="alert">{row.eligibility.reason}</p>}{error && <p className="form-error" role="alert">{error}</p>}</ConfirmModal></>;
}
