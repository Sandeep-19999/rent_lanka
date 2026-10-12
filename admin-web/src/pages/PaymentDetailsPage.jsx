import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, ArrowUpRight, Copy, CreditCard, LockKeyhole, ShieldCheck, Undo2 } from 'lucide-react';
import { useDocument } from '../hooks/useDocument.js';
import { usePayments } from '../hooks/usePayments.js';
import { useToast } from '../context/ToastContext.jsx';
import { adminRefundsEnabled } from '../services/firebase.js';
import { recordRefund } from '../services/paymentService.js';
import { refundEligibility } from '../services/refundPolicy.js';
import { normalizePayment } from '../utils/payments.js';
import { formatCurrency, formatDateTime, formatMethod, formatStatus, textValue } from '../utils/format.js';
import { errorMessage } from '../utils/errors.js';
import StatusBadge from '../components/payments/StatusBadge.jsx';
import ConfirmModal from '../components/common/ConfirmModal.jsx';
import { ErrorState, LoadingSkeleton, Notice, PageHeading } from '../components/common/Feedback.jsx';

function InfoGrid({ entries }) {
  return <dl className="info-grid">{entries.map(([label, value, mono]) => <div key={label}><dt>{label}</dt><dd className={mono ? 'mono' : ''}>{value == null || value === '' ? 'Not recorded' : value}</dd></div>)}</dl>;
}

function PersonCard({ label, record, fallbackName, uid }) {
  const name = textValue(record.data?.name) || fallbackName || 'Name not recorded';
  return <section className="glass detail-card"><h2>{label}</h2><div className="person-heading"><span className="avatar large">{name.slice(0, 1).toUpperCase()}</span><div><strong>{name}</strong><p>{textValue(record.data?.email) || 'Email not available'}</p></div></div>
    <InfoGrid entries={[[`${label === 'Customer / player' ? 'Player' : 'Provider'} ID`, uid, true]]} />
    {record.loading && <p className="muted small-text">Loading account information…</p>}
    {record.error && <p className="muted small-text">Account information is unavailable with the current permissions.</p>}
    {record.missing && <p className="muted small-text">The linked account record is no longer available.</p>}
  </section>;
}

export default function PaymentDetailsPage() {
  const { paymentId } = useParams();
  return <PaymentDetails key={paymentId} paymentId={paymentId} />;
}

function PaymentDetails({ paymentId }) {
  const paymentRecord = useDocument('payments', paymentId);
  const bookingRecord = useDocument('rental_requests', paymentRecord.data?.bookingId);
  const booking = bookingRecord.data;
  const payment = useMemo(() => normalizePayment(paymentId, paymentRecord.data, booking), [paymentId, paymentRecord.data, booking]);
  const player = useDocument('users', payment.playerId);
  const provider = useDocument('users', payment.providerId);
  const equipment = useDocument('equipment', booking?.equipmentId);
  const { refundsByBooking, payments, loading: ledgerLoading } = usePayments();
  const relatedRefunds = refundsByBooking[payment.bookingId] || [];
  const originalCharges = payments.filter((item) => item.bookingId === payment.bookingId && item.type === 'charge');
  const eligibility = refundEligibility(paymentRecord.data, booking, relatedRefunds.length > 0);
  const notify = useToast();
  const [modal, setModal] = useState(false);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState('');
  const validId = typeof paymentId === 'string' && !!paymentId && !paymentId.includes('/');
  async function copy(value) {
    try { await navigator.clipboard.writeText(value); notify('Reference copied.'); }
    catch { notify('Copy was unavailable. You can select the reference directly.', 'error'); }
  }
  async function confirmRefund() {
    setBusy(true); setActionError('');
    try { await recordRefund({ paymentId, reason }); setModal(false); setReason(''); notify('System-side refund recorded. No money was transferred.'); }
    catch (failure) { const message = errorMessage(failure, 'The refund could not be recorded. No changes were confirmed.'); setActionError(message); notify(message, 'error'); }
    finally { setBusy(false); }
  }
  if (!validId) return <ErrorState title="Invalid payment reference" message="Return to Payments and select a valid record." />;
  if (paymentRecord.loading) return <><PageHeading title="Payment details" description="Loading the payment and related rental information." /><LoadingSkeleton rows={4} /></>;
  if (paymentRecord.error) return <ErrorState message={paymentRecord.error} retry={() => window.location.reload()} />;
  if (paymentRecord.missing) return <><PageHeading title="Payment not found" description="This record may be unavailable or the reference may be incorrect." /><Link className="button secondary" to="/payments"><ArrowLeft size={16} />Back to payments</Link></>;
  const pickup = textValue(booking?.pickupLocation) || textValue(equipment.data?.location);
  return <><Link className="back-link" to={payment.type === 'refund' ? '/refunds' : '/payments'}><ArrowLeft size={16} />Back to {payment.type === 'refund' ? 'refunds' : 'payments'}</Link>
    <PageHeading title={payment.type === 'refund' ? 'Refund details' : 'Payment details'} description={`${payment.bookingReference || 'Booking reference unavailable'} · ${payment.type === 'refund' ? 'Refund entry' : 'Original charge'}`}>
      <button className="button secondary" onClick={() => copy(payment.id)}><Copy size={15} />Copy payment ID</button></PageHeading>
    {bookingRecord.error && <Notice tone="error">Linked booking information could not be loaded. {bookingRecord.error}</Notice>}
    {bookingRecord.missing && <Notice tone="warning">The related booking is no longer available. The payment record is preserved.</Notice>}
    <section className="glass payment-hero"><div className="payment-hero-main"><span className="payment-hero-icon">{payment.type === 'refund' ? <Undo2 size={27} /> : <CreditCard size={27} />}</span><div><p>{payment.type === 'refund' ? 'REFUNDED AMOUNT' : 'PAYMENT AMOUNT'}</p><strong>{formatCurrency(payment.amount, payment.currency)}</strong><span>{formatMethod(payment.method)}{payment.cardLast4 && ` · •••• ${payment.cardLast4}`}</span></div></div>
      <div className="payment-hero-status"><StatusBadge status={payment.status} /><p>{formatDateTime(payment.createdAt)}</p></div></section>
    <div className="detail-grid"><div className="detail-main"><section className="glass detail-card"><div className="detail-card-heading"><h2>Payment information</h2><span className="panel-icon"><CreditCard size={17} /></span></div>
      <InfoGrid entries={[
        ['Payment ID', payment.id, true], ['Transaction ID', payment.transactionId, true], ['Record type', payment.type],
        ['Amount', formatCurrency(payment.amount, payment.currency)], ['Currency', payment.currency], ['Payment method', formatMethod(payment.method)],
        ['Payment status', <StatusBadge key="status" status={payment.status} />], ['Created date', formatDateTime(payment.createdAt)],
        ...(payment.bank ? [['Bank', payment.bank]] : []), ...(payment.cardLast4 ? [['Card last four digits', payment.cardLast4]] : []),
      ]} />
    </section><section className="glass detail-card"><h2>Booking information</h2>
      {bookingRecord.loading ? <p className="muted">Loading linked rental…</p> : <InfoGrid entries={[
        ['Booking ID', payment.bookingId, true], ['Booking reference', payment.bookingReference, true],
        ['Equipment', textValue(booking?.equipmentName) || textValue(equipment.data?.name)], ['Equipment ID', textValue(booking?.equipmentId), true],
        ['Rental start', textValue(booking?.startDate)], ['Rental end', textValue(booking?.endDate)], ['Rental days', textValue(booking?.rentalDays)],
        ['Pickup location', pickup], ['Rental status', booking ? formatStatus(textValue(booking.status)) : null],
        ['Booking payment status', booking ? formatStatus(textValue(booking.paymentStatus)) : null],
        ['Rental value', formatCurrency(typeof booking?.totalAmount === 'number' ? booking.totalAmount : null)],
        ['Deposit', formatCurrency(typeof booking?.depositAmount === 'number' ? booking.depositAmount : null)],
        ['Total payable', formatCurrency(typeof booking?.totalPayable === 'number' ? booking.totalPayable : null)],
      ]} />}
    </section>
    {(payment.type === 'refund' || relatedRefunds.length > 0) && <section className="glass detail-card"><h2>Refund information</h2>
      {payment.type === 'refund' ? <><InfoGrid entries={[
        ['Refund status', <StatusBadge key="refund" status={payment.status} />], ['Refund amount', formatCurrency(payment.amount, payment.currency)],
        ['Refund date', formatDateTime(payment.createdAt)], ['Recorded by', payment.refundedBy || payment.updatedBy, true],
        ['Reason', payment.refundReason],
      ]} /><div className="related-links">{originalCharges.map((charge) => <Link key={charge.id} to={`/payments/${encodeURIComponent(charge.id)}`}>View original charge<ArrowUpRight size={15} /></Link>)}</div></>
        : relatedRefunds.map((refund) => <div className="related-refund" key={refund.id}><div><strong>{formatCurrency(refund.amount, refund.currency)}</strong><p>{formatDateTime(refund.createdAt)}</p></div><Link className="button secondary" to={`/payments/${encodeURIComponent(refund.id)}`}>View refund<ArrowUpRight size={15} /></Link></div>)}
      <p className="detail-footnote">This is a system-side record in the academic payment flow. The original charge is retained.</p>
    </section>}
    <section className="glass detail-card"><h2>Administration history</h2><InfoGrid entries={[
      ['Payment updated at', formatDateTime(payment.updatedAt)], ['Payment updated by', payment.updatedBy, true],
      ['Booking updated at', formatDateTime(booking?.updatedAt)], ['Booking updated by', textValue(booking?.updatedBy), true],
    ]} /></section></div>
    <div className="detail-side"><PersonCard label="Customer / player" record={player} fallbackName={payment.playerName} uid={payment.playerId} />
      <PersonCard label="Provider" record={provider} fallbackName={payment.providerName} uid={payment.providerId} />
      {payment.type !== 'refund' && <section className="glass detail-card action-card"><span className="action-card-icon"><ShieldCheck size={24} /></span><h2>Payment controls</h2>
        <p>The original charge is retained. Eligible refunds create a separate record and update the booking’s payment status.</p>
        {!eligibility.allowed && <p className="action-explanation">{eligibility.reason}</p>}
        {!adminRefundsEnabled && <div className="write-lock"><LockKeyhole size={16} /><span>Refund writes require the reviewed security rules.</span></div>}
        <button className="button primary" disabled={!adminRefundsEnabled || !eligibility.allowed || busy || ledgerLoading || bookingRecord.loading}
          onClick={() => { setActionError(''); setModal(true); }}><Undo2 size={16} />Record system refund</button>
        <small>No bank transfer or gateway refund is performed.</small>
      </section>}
    </div></div>
    <ConfirmModal open={modal} title="Record a system-side refund?" description="This creates a full refund entry and marks the related booking payment as refunded. It does not transfer money. The original charge and rental lifecycle remain unchanged."
      busy={busy} onCancel={() => setModal(false)} onConfirm={confirmRefund} confirmLabel="Record refund" disabled={reason.trim().length < 5 || reason.trim().length > 500}>
      <div className="refund-confirm-summary"><span>Refund amount</span><strong>{formatCurrency(payment.amount, payment.currency)}</strong></div>
      <label className="form-label" htmlFor="refund-reason">Refund reason</label><textarea id="refund-reason" value={reason} minLength={5} maxLength={500} rows={3} disabled={busy} placeholder="Explain why this rental payment is being refunded…" onChange={(event) => setReason(event.target.value)} />
      <p className="field-hint">5–500 characters. This reason is saved with the refund record.</p>
      {actionError && <div className="form-error" role="alert">{actionError}</div>}
    </ConfirmModal>
  </>;
}
