import { Link } from 'react-router-dom';
import { EmptyState, ErrorState, LoadingSkeleton } from './Feedback.jsx';
import StatusBadge from '../payments/StatusBadge.jsx';
import { formatCurrency } from '../../utils/format.js';
export function RecordState({ state, children }) {
  return state.loading ? <LoadingSkeleton rows={3} /> : state.error ? <ErrorState message={state.error} retry={state.retry} /> : children;
}
export function Details({ entries }) {
  return <dl className="platform-details">{entries.map(([label, value]) => <div key={label}><dt>{label}</dt><dd>{value === '' || value == null ? 'Not recorded' : value}</dd></div>)}</dl>;
}
export function Bookings({ state }) {
  return <section className="glass platform-panel"><h2>Bookings</h2><RecordState state={state}>{!state.rows.length ? <EmptyState compact title="No bookings found" description="No matching rental requests are recorded." /> : <div className="table-scroll"><table className="payment-table"><thead><tr><th>Reference / equipment</th><th>Dates</th><th>Status</th><th>Payment</th><th>Total</th></tr></thead><tbody>{state.rows.map(row => <tr key={row.id}><td><strong>{row.bookingReference || row.id}</strong><small><Link to={`/equipment/${encodeURIComponent(row.equipmentId)}`}>{row.equipmentName || row.equipmentId || 'Equipment not recorded'}</Link></small></td><td>{row.startDate || 'Not recorded'} to {row.endDate || 'Not recorded'}</td><td><StatusBadge status={row.status} /></td><td><StatusBadge status={row.paymentStatus} /></td><td>{formatCurrency(row.totalPayable)}</td></tr>)}</tbody></table></div>}</RecordState></section>;
}
export function Pagination({ page, count, onChange, size = 12 }) {
  const pages = Math.max(1, Math.ceil(count / size));
  return <div className="pagination"><span>{count} records - Page {page} of {pages}</span><div className="pagination-buttons"><button className="button secondary" disabled={page <= 1} onClick={() => onChange(page - 1)}>Previous</button><button className="button secondary" disabled={page >= pages} onClick={() => onChange(page + 1)}>Next</button></div></div>;
}
