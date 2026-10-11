import { usePayments } from '../hooks/usePayments.js';
import PaymentExplorer from '../components/payments/PaymentExplorer.jsx';
import { ErrorState, LoadingSkeleton, Notice, PageHeading } from '../components/common/Feedback.jsx';

export default function TransactionsPage() {
  const { payments, loading, error, retry, bookingError, bookingsLoading, refundsByBooking } = usePayments();
  if (loading || error) return <><PageHeading title="Transactions" description="The complete payment and refund record." />{loading ? <LoadingSkeleton /> : <ErrorState message={error} retry={retry} />}</>;
  return <PaymentExplorer rows={payments} title="Transactions" description="Explore all charge and refund entries from the shared Rent Lanka ledger." tableTitle="Transaction history" showType refundsByBooking={refundsByBooking} exportReady={!bookingsLoading}>
    {bookingError && <Notice tone="error">{bookingError}</Notice>}{bookingsLoading && <Notice>Loading linked bookings and customer names…</Notice>}
  </PaymentExplorer>;
}
