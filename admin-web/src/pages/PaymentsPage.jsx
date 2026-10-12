import { useMemo } from 'react';
import { usePayments } from '../hooks/usePayments.js';
import PaymentExplorer from '../components/payments/PaymentExplorer.jsx';
import { ErrorState, LoadingSkeleton, Notice, PageHeading } from '../components/common/Feedback.jsx';

export default function PaymentsPage() {
  const { payments, loading, error, retry, bookingError, bookingsLoading, refundsByBooking } = usePayments();
  const charges = useMemo(() => payments.filter((payment) => payment.type === 'charge'), [payments]);
  if (loading || error) return <><PageHeading title="Payments" description="Review the original charges behind every rental." />{loading ? <LoadingSkeleton /> : <ErrorState message={error} retry={retry} />}</>;
  return <PaymentExplorer rows={charges} title="Payments" description="Original rental charges, with every payment detail in one place." tableTitle="Payment records" refundsByBooking={refundsByBooking} exportReady={!bookingsLoading}>
    {bookingError && <Notice tone="error">{bookingError}</Notice>}
    {bookingsLoading && <Notice>Loading linked bookings and customer names…</Notice>}
    <div className="ledger-note">Original charges are retained after a refund. Separate refund records appear in Transactions and Refunds.</div>
  </PaymentExplorer>;
}
