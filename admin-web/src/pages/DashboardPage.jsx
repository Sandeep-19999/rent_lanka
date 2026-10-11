import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, ArrowUpRight, Banknote, CircleCheck, CreditCard, Files, Undo2, Wallet } from 'lucide-react';
import { usePayments } from '../hooks/usePayments.js';
import { formatCurrency, formatDateTime } from '../utils/format.js';
import { distributions, filterPayments, paymentMetrics, volumeSeries } from '../utils/payments.js';
import StatCard from '../components/dashboard/StatCard.jsx';
import { MethodChart, StatusChart, VolumeChart } from '../components/dashboard/Charts.jsx';
import PaymentTable from '../components/payments/PaymentTable.jsx';
import { DetailLink, ErrorState, LoadingSkeleton, Notice, PageHeading } from '../components/common/Feedback.jsx';

export default function DashboardPage() {
  const { payments, loading, error, retry, bookingError, lastUpdated, refundsByBooking } = usePayments();
  const [interval, setInterval] = useState('daily');
  const metrics = useMemo(() => paymentMetrics(payments), [payments]);
  const breakdown = useMemo(() => distributions(payments), [payments]);
  const series = useMemo(() => volumeSeries(payments, interval), [payments, interval]);
  const recent = useMemo(() => filterPayments(payments).slice(0, 6), [payments]);
  return <><PageHeading eyebrow="YOUR FINANCIAL WORKSPACE" title="Payment overview" description="A complete view of the payments behind Rent Lanka rentals.">
    <Link to="/transactions" className="button secondary">View transactions<ArrowUpRight size={16} /></Link></PageHeading>
    {loading ? <LoadingSkeleton dashboard /> : error ? <ErrorState message={error} retry={retry} /> : <>
      {bookingError && <Notice tone="error">{bookingError}</Notice>}
      {!!metrics.excludedAmounts && <Notice tone="warning">{metrics.excludedAmounts} {metrics.excludedAmounts === 1 ? 'record is' : 'records are'} excluded from LKR amounts because the amount or currency is missing, invalid, or different. They remain visible in Transactions.</Notice>}
      <div className="overview-meta"><span><span className="live-dot" />Shared Firebase payment records</span><span>{lastUpdated ? `Updated ${formatDateTime(lastUpdated)}` : 'Waiting for server confirmation'} · All-time totals</span></div>
      <div className="stats-grid"><StatCard label="Total Payment Volume" value={formatCurrency(metrics.totalVolume, 'LKR', true)} description="All charges · includes cash obligations" icon={Wallet} />
        <StatCard label="Paid Payment Volume" value={formatCurrency(metrics.paidVolume, 'LKR', true)} description="Original paid charges · before refunds" icon={CircleCheck} tone="success" />
        <StatCard label="Refunded Amount" value={formatCurrency(metrics.refundedAmount, 'LKR', true)} description={`${metrics.refundCount} recorded ${metrics.refundCount === 1 ? 'refund' : 'refunds'}`} icon={Undo2} tone="refund" />
        <StatCard label="Total Payment Records" value={metrics.totalRecords.toLocaleString()} description="Charge and refund entries" icon={Files} />
      </div>
      <div className="overview-insights"><div><Banknote size={17} /><span>Pay-on-Pickup Bookings</span><strong>{metrics.pickupBookings}</strong></div><div><CircleCheck size={17} /><span>Paid charge records</span><strong>{metrics.paidCount}</strong></div><Link to="/refunds">Review refunds<ArrowRight size={14} /></Link></div>
      <div className="chart-grid"><section className="glass volume-panel"><div className="panel-header"><div><h2>Payment volume over time</h2><p>Paid charges and refunds · LKR</p></div><div className="segmented-control" aria-label="Chart interval">{['daily', 'weekly', 'monthly'].map((value) => <button key={value} className={interval === value ? 'active' : ''} aria-pressed={interval === value} onClick={() => setInterval(value)}>{value[0].toUpperCase() + value.slice(1)}</button>)}</div></div>
        <div className="volume-summary"><strong>{formatCurrency(series.reduce((sum, point) => sum + point.paid, 0), 'LKR', true)}</strong><span>paid charges in the last {interval === 'daily' ? '30 days' : interval === 'weekly' ? '12 calendar weeks' : '12 calendar months'}</span></div>
        <VolumeChart data={series} empty={!payments.length} /><div className="inline-legend"><span><i className="paid-legend" />Paid charges</span><span><i className="refund-legend" />Refunds</span></div>
      </section><section className="glass status-panel"><div className="panel-header"><div><h2>Payment status</h2><p>Stored status across all records</p></div></div><StatusChart data={breakdown.statuses} total={metrics.totalRecords} /></section></div>
      <section className="glass method-panel"><div className="method-description"><span className="panel-icon"><CreditCard size={19} /></span><h2>How players pay</h2><p>Payment methods from original charges. Refund entries are excluded from these counts.</p></div><MethodChart data={breakdown.methods} /></section>
      <section className="glass table-panel"><div className="panel-header"><div><h2>Recent transactions</h2><p>The latest charge and refund entries</p></div><DetailLink to="/transactions">View all</DetailLink></div>
        <PaymentTable rows={recent} total={recent.length} recent refundsByBooking={refundsByBooking} />
      </section><p className="financial-footnote">Payment volume includes rental charges, fees and deposits. It represents recorded payment activity, rather than platform revenue. Original charges remain in the ledger after refunds.</p>
    </>}
  </>;
}
