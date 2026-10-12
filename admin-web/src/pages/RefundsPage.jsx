import { useMemo, useState } from 'react';
import { ShieldCheck, Undo2 } from 'lucide-react';
import { usePayments } from '../hooks/usePayments.js';
import { adminRefundsEnabled } from '../services/firebase.js';
import PaymentExplorer from '../components/payments/PaymentExplorer.jsx';
import { ErrorState, LoadingSkeleton, Notice, PageHeading } from '../components/common/Feedback.jsx';

export default function RefundsPage() {
  const { payments, loading, error, retry, bookingError, bookingsLoading, refundsByBooking } = usePayments();
  const [tab, setTab] = useState('recorded');
  const refunds = useMemo(() => payments.filter((payment) => payment.type === 'refund'), [payments]);
  const candidates = useMemo(() => payments.filter((payment) => payment.type === 'charge' && payment.status === 'paid'
    && ['rejected', 'cancelled'].includes(payment.bookingStatus) && payment.bookingPaymentStatus === 'paid' && !refundsByBooking[payment.bookingId]?.length), [payments, refundsByBooking]);
  const originals = useMemo(() => payments.filter((payment) => payment.type === 'charge').reduce((map, payment) => { map[payment.bookingId] = payment; return map; }, Object.create(null)), [payments]);
  if (loading || error) return <><PageHeading title="Refunds" description="Track recorded refunds and review terminal rentals awaiting a refund." />{loading ? <LoadingSkeleton /> : <ErrorState message={error} retry={retry} />}</>;
  return <PaymentExplorer key={tab} rows={tab === 'recorded' ? refunds : candidates} title="Refunds" description="A clear trail of system-side refunds, with original charges preserved."
    tableTitle={tab === 'recorded' ? 'Recorded refunds' : 'Awaiting refund review'} refundView={tab === 'recorded'} originalCharges={originals} exportReady={!bookingsLoading}>
    {bookingError && <Notice tone="error">{bookingError}</Notice>}
    {!adminRefundsEnabled && <Notice tone="warning"><strong>Refund recording requires reviewed security rules.</strong> You can inspect records now. Write actions remain disabled until the project administrator verifies and enables them.</Notice>}
    <div className="refund-explanation glass"><span className="panel-icon"><ShieldCheck size={21} /></span><div><strong>Academic payment flow</strong><p>Recording a refund updates Rent Lanka’s records. It does not transfer money through a bank or payment gateway.</p></div></div>
    <div className="tabs" aria-label="Refund views"><button className={tab === 'recorded' ? 'active' : ''} aria-pressed={tab === 'recorded'} onClick={() => setTab('recorded')}><Undo2 size={16} />Recorded refunds<span>{refunds.length}</span></button>
      <button className={tab === 'review' ? 'active' : ''} aria-pressed={tab === 'review'} onClick={() => setTab('review')}>Awaiting review<span>{bookingsLoading ? '…' : candidates.length}</span></button></div>
    {tab === 'review' && <div className="ledger-note">Open a payment to validate eligibility and record its refund. Only rejected or cancelled rentals can be refunded here.</div>}
  </PaymentExplorer>;
}
