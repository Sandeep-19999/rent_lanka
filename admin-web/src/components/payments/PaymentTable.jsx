import { ArrowDownLeft, ArrowUpRight, ChevronLeft, ChevronRight, CreditCard, Landmark, Banknote, Undo2 } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { formatCurrency, formatDate, formatMethod, shortId } from '../../utils/format.js';
import StatusBadge from './StatusBadge.jsx';
import { EmptyState } from '../common/Feedback.jsx';

const methodIcons = { card: CreditCard, online_banking: Landmark, cash: Banknote };

export default function PaymentTable({ rows, total, page = 1, pageSize = 10, onPageChange, onPageSizeChange,
  refundsByBooking = {}, refundView = false, originalCharges = {}, recent = false, onReset }) {
  const navigate = useNavigate();
  const pages = Math.max(1, Math.ceil(total / pageSize));
  if (!rows.length) return <EmptyState title="No matching records" description="Try a different search or date range. New records appear automatically when they are saved in Rent Lanka."
    action={onReset && <button className="button secondary" onClick={onReset}>Clear filters</button>} />;
  return <><div className="table-scroll"><table className={`payment-table ${recent ? 'recent-table' : ''}`}>
    <caption className="sr-only">{refundView ? 'Refund records' : 'Payment records'}. Dates use Asia/Colombo time.</caption>
    <thead><tr><th scope="col">{refundView ? 'Refund / transaction' : 'Transaction'}</th><th scope="col">Booking / customer</th>
      {!recent && <th scope="col">Provider</th>}<th scope="col">Method</th>{refundView && <th scope="col" className="align-right">Original amount</th>}
      <th scope="col" className="align-right">{refundView ? 'Refund amount' : 'Amount'}</th><th scope="col">Status</th><th scope="col">{refundView ? 'Refund date' : 'Date'}</th><th scope="col"><span className="sr-only">Actions</span></th></tr></thead>
    <tbody>{rows.map((payment) => {
      const MethodIcon = methodIcons[payment.method] || CreditCard;
      const refunded = payment.type === 'charge' && !!refundsByBooking[payment.bookingId]?.length;
      const original = originalCharges[payment.bookingId];
      return <tr key={payment.id} onClick={(event) => { if (!event.target.closest('a, button')) navigate(`/payments/${encodeURIComponent(payment.id)}`); }}>
        <td><div className="transaction-cell"><span className={`transaction-icon ${payment.type === 'refund' ? 'refund-icon' : ''}`}>{payment.type === 'refund' ? <ArrowDownLeft size={17} /> : <ArrowUpRight size={17} />}</span>
          <div><Link className="table-link mono" to={`/payments/${encodeURIComponent(payment.id)}`}>{payment.transactionId || shortId(payment.id)}</Link><small title={payment.id}>{payment.type === 'refund' ? 'Refund' : payment.type === 'charge' ? 'Charge' : payment.type} · {shortId(payment.id)}</small></div></div></td>
        <td><strong className="cell-main mono">{payment.bookingReference || 'Not recorded'}</strong><small>{payment.playerName || shortId(payment.playerId)}</small></td>
        {!recent && <td><strong className="cell-main">{payment.providerName || shortId(payment.providerId)}</strong><small>{payment.equipmentName || 'Equipment not recorded'}</small></td>}
        <td><span className="method-cell"><MethodIcon size={15} />{formatMethod(payment.method)}</span></td>
        {refundView && <td className="align-right"><strong className="amount-cell">{original ? formatCurrency(original.amount, original.currency) : 'Not available'}</strong></td>}
        <td className="align-right"><strong className="amount-cell">{formatCurrency(payment.amount, payment.currency)}</strong><small>{payment.currency || 'Currency unknown'}</small></td>
        <td><StatusBadge status={payment.status} />{refunded && <small className="refund-note"><Undo2 size={11} />Refund recorded</small>}</td>
        <td className="date-cell">{formatDate(payment.createdAt)}</td>
        <td><Link className="table-action" to={`/payments/${encodeURIComponent(payment.id)}`} aria-label={`View payment ${payment.id}`} title="View payment details"><ArrowUpRight size={18} /></Link></td>
      </tr>;
    })}</tbody></table></div>
    {onPageChange && <div className="pagination"><div className="pagination-info">Showing <strong>{(page - 1) * pageSize + 1}–{Math.min(page * pageSize, total)}</strong> of <strong>{total}</strong> records
      {onPageSizeChange && <label className="page-size"><span className="sr-only">Records per page</span><select value={pageSize} onChange={(event) => onPageSizeChange(Number(event.target.value))}><option value={10}>10 / page</option><option value={25}>25 / page</option><option value={50}>50 / page</option></select></label>}</div>
      <div className="pagination-buttons"><button className="icon-button" aria-label="Previous page" disabled={page <= 1} onClick={() => onPageChange(page - 1)}><ChevronLeft size={18} /></button><span>{page} <span className="muted">/ {pages}</span></span><button className="icon-button" aria-label="Next page" disabled={page >= pages} onClick={() => onPageChange(page + 1)}><ChevronRight size={18} /></button></div>
    </div>}</>;
}
