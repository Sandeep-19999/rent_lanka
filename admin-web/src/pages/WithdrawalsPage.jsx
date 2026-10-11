import { useEffect, useMemo, useState } from 'react';
import { ArrowDownToLine, CheckCheck, ChevronLeft, ChevronRight, Clock3, Download, Landmark, RotateCcw, Search, Wallet } from 'lucide-react';
import { adminWithdrawalsEnabled } from '../services/firebase.js';
import { approveWithdrawal, watchWithdrawals } from '../services/withdrawalService.js';
import { dateKey, formatCurrency, formatDate, formatDateTime, formatStatus, shortId } from '../utils/format.js';
import { normalizeWithdrawal } from '../utils/withdrawals.js';
import { csvCell, downloadCsv } from '../utils/csv.js';
import { errorMessage } from '../utils/errors.js';
import { useToast } from '../context/ToastContext.jsx';
import StatCard from '../components/dashboard/StatCard.jsx';
import StatusBadge from '../components/payments/StatusBadge.jsx';
import ConfirmModal from '../components/common/ConfirmModal.jsx';
import { EmptyState, ErrorState, LoadingSkeleton, Notice, PageHeading } from '../components/common/Feedback.jsx';

export default function WithdrawalsPage() {
  const [state, setState] = useState({ rows: [], loading: true, error: '' });
  const [revision, setRevision] = useState(0);
  useEffect(() => {
    setState({ rows: [], loading: true, error: '' });
    return watchWithdrawals((snapshot) => setState({ loading: false, error: '',
      rows: snapshot.docs.map((document) => normalizeWithdrawal(document.id, document.data())) }),
    (failure) => setState({ rows: [], loading: false, error: errorMessage(failure) }));
  }, [revision]);
  return <WithdrawalsView state={state} onRetry={() => setRevision((value) => value + 1)} />;
}

export function WithdrawalsView({ state, onRetry, approvalEnabled = adminWithdrawalsEnabled, onApprove = approveWithdrawal }) {
  const [filters, setFilters] = useState({ search: '', status: '', from: '', to: '', sort: 'latest' });
  const [page, setPage] = useState(1);
  const [selectedId, setSelectedId] = useState(null);
  const [note, setNote] = useState('');
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState('');
  const notify = useToast();
  const selected = state.rows.find((row) => row.id === selectedId);
  async function confirmApproval() {
    if (!approvalEnabled || !selected?.eligibility.allowed || busy) return;
    setBusy(true); setActionError('');
    try {
      await onApprove({ withdrawalId: selectedId, note });
      setSelectedId(null); setNote(''); notify('Withdrawal approved. Bank payout is still outstanding.');
    } catch (failure) {
      const message = errorMessage(failure, 'The withdrawal could not be approved. Please try again.');
      setActionError(message); notify(message, 'error');
    } finally { setBusy(false); }
  }
  const rows = useMemo(() => state.rows.filter((row) => {
    const term = filters.search.trim().toLowerCase();
    const key = dateKey(row.requestedAt);
    return (!term || [row.id, row.providerId, row.accountHolderName, row.bankName].some((value) => value.toLowerCase().includes(term)))
      && (!filters.status || row.status === filters.status) && (!filters.from || key && key >= filters.from) && (!filters.to || key && key <= filters.to);
  }).sort((a, b) => {
    if (!a.requestedAt) return b.requestedAt ? 1 : a.id.localeCompare(b.id);
    if (!b.requestedAt) return -1;
    return (a.requestedAt - b.requestedAt) * (filters.sort === 'oldest' ? 1 : -1);
  }), [state.rows, filters]);
  const statuses = [...new Set(state.rows.map((row) => row.status).filter(Boolean))].sort();
  const currentPage = Math.min(page, Math.max(1, Math.ceil(rows.length / 10)));
  const visible = rows.slice((currentPage - 1) * 10, currentPage * 10);
  function change(key, value) { setPage(1); setFilters((previous) => ({ ...previous, [key]: value })); }
  function reset() { setPage(1); setFilters({ search: '', status: '', from: '', to: '', sort: 'latest' }); }
  function exportRows() {
    const content = [['Withdrawal ID', 'Provider ID', 'Bank', 'Account Holder', 'Account Last 4', 'Branch', 'Amount (LKR)', 'Status', 'Requested Date (Asia/Colombo)', 'Approved Date (Asia/Colombo)', 'Approved By', 'Approval Note'],
      ...rows.map((row) => [row.id, row.providerId, row.bankName, row.accountHolderName, row.accountLast4, row.branch, row.amount, row.status, formatDate(row.requestedAt), row.approvedAt ? formatDateTime(row.approvedAt) : '', row.approvedBy, row.approvalNote])]
      .map((cells) => cells.map(csvCell).join(',')).join('\r\n');
    downloadCsv(content, `rent-lanka-withdrawals-${dateKey(new Date())}.csv`); notify(`Exported ${rows.length} filtered withdrawals.`);
  }
  return <><PageHeading title="Withdrawals" description="Provider withdrawal requests, connected to the existing rental earnings flow.">
    <button className="button secondary" onClick={exportRows} disabled={!rows.length || state.loading || !!state.error}><Download size={16} />Export CSV</button></PageHeading>
    {state.loading ? <LoadingSkeleton dashboard /> : state.error ? <ErrorState message={state.error} retry={onRetry} /> : <>
      <div className="stats-grid withdrawal-stats"><StatCard label="Requested amount" value={formatCurrency(state.rows.reduce((sum, row) => sum + (row.amount || 0), 0), 'LKR', true)} description="All requests · includes terminal requests" icon={Wallet} />
        <StatCard label="Pending requests" value={state.rows.filter((row) => row.status === 'pending').length} description="Awaiting provider payout review" icon={Clock3} />
        <StatCard label="Approved requests" value={state.rows.filter((row) => row.status === 'approved').length} description="Approved · awaiting bank payout" icon={CheckCheck} tone="success" />
        <StatCard label="Completed requests" value={state.rows.filter((row) => row.status === 'completed').length} description="Records marked completed" icon={ArrowDownToLine} tone="success" /></div>
      <Notice>Approval confirms a provider’s request for payout. It does not transfer money or mark the payout completed. The requested amount remains reserved in the existing provider balance.</Notice>
      {!approvalEnabled && <Notice tone="warning"><strong>Withdrawal approval requires reviewed security rules.</strong> Review requests now; approval writes are disabled until secure admin permissions are verified.</Notice>}
      <section className="glass table-panel"><div className="panel-header"><div className="panel-heading"><span className="panel-icon"><Landmark size={18} /></span><h2>Withdrawal requests</h2><span className="count-badge">{state.rows.length}</span></div><span className="panel-meta">{rows.length} matching records</span></div>
        <div className="payment-filters"><div className="filter-primary"><label className="search-field input-with-icon"><Search size={18} /><span className="sr-only">Search withdrawals</span><input type="search" value={filters.search} placeholder="Search provider ID, holder or bank…" onChange={(event) => change('search', event.target.value)} /></label><label><span className="sr-only">Withdrawal status</span><select aria-label="Withdrawal status" value={filters.status} onChange={(event) => change('status', event.target.value)}><option value="">All statuses</option>{statuses.map((status) => <option key={status} value={status}>{formatStatus(status)}</option>)}</select></label></div>
          <div className="filter-secondary"><label className="date-filter"><span>From</span><input type="date" aria-label="Withdrawal from date" value={filters.from} max={filters.to || undefined} onChange={(event) => change('from', event.target.value)} /></label><label className="date-filter"><span>To</span><input type="date" aria-label="Withdrawal to date" value={filters.to} min={filters.from || undefined} onChange={(event) => change('to', event.target.value)} /></label>
            <select aria-label="Sort withdrawals" value={filters.sort} onChange={(event) => change('sort', event.target.value)}><option value="latest">Latest first</option><option value="oldest">Oldest first</option></select><button className="text-button reset-filters" onClick={reset}><RotateCcw size={14} />Reset filters</button></div>
        </div>
        {!rows.length ? <EmptyState title="No matching withdrawal requests" description="Requests submitted by providers will appear here. Try clearing any filters." action={<button className="button secondary" onClick={reset}>Clear filters</button>} /> : <>
          <div className="table-scroll"><table className="payment-table withdrawal-table"><caption className="sr-only">Provider withdrawals with masked bank details</caption><thead><tr><th scope="col">Request / provider</th><th scope="col">Bank account</th><th scope="col">Branch</th><th scope="col" className="align-right">Amount</th><th scope="col">Status</th><th scope="col">Requested</th><th scope="col">Approval / action</th></tr></thead><tbody>{visible.map((row) => <tr key={row.id}>
            <td><strong className="cell-main mono" title={row.id}>{shortId(row.id)}</strong><small className="mono" title={row.providerId}>{shortId(row.providerId)}</small></td>
            <td><strong className="cell-main">{row.bankName || 'Not recorded'} {row.accountLast4 && `· •••• ${row.accountLast4}`}</strong><small>{row.accountHolderName || 'Holder not recorded'}</small></td><td>{row.branch || 'Not recorded'}</td>
            <td className="align-right"><strong className="amount-cell">{formatCurrency(row.amount)}</strong></td><td><StatusBadge status={row.status} />{row.status === 'approved' && <small>Awaiting payout</small>}</td><td>{formatDate(row.requestedAt)}</td>
            <td>{row.status === 'pending' ? <><button className="button primary approval-button" aria-label={`Approve withdrawal ${row.id}`}
              disabled={!approvalEnabled || !row.eligibility.allowed || busy}
              title={!row.eligibility.allowed ? row.eligibility.reason : !approvalEnabled ? 'Approval requires reviewed security rules.' : 'Review and approve this request'}
              onClick={() => { setSelectedId(row.id); setNote(''); setActionError(''); }}><CheckCheck size={14} />Approve</button>
              {!row.eligibility.allowed && <small className="withdrawal-validation">{row.eligibility.reason}</small>}</>
              : row.status === 'approved' ? <><strong className="cell-main">{formatDateTime(row.approvedAt)}</strong><small title={row.approvedBy}>By {shortId(row.approvedBy)}</small>{row.approvalNote && <small className="withdrawal-validation">{row.approvalNote}</small>}</>
                : <span className="muted">No approval action</span>}</td>
          </tr>)}</tbody></table></div><div className="pagination"><span>Showing {(currentPage - 1) * 10 + 1}–{Math.min(currentPage * 10, rows.length)} of {rows.length} requests</span><div className="pagination-buttons"><button className="icon-button" aria-label="Previous withdrawal page" disabled={currentPage === 1} onClick={() => setPage(currentPage - 1)}><ChevronLeft size={18} /></button><span>{currentPage} / {Math.max(1, Math.ceil(rows.length / 10))}</span><button className="icon-button" aria-label="Next withdrawal page" disabled={currentPage * 10 >= rows.length} onClick={() => setPage(currentPage + 1)}><ChevronRight size={18} /></button></div></div>
        </>}
      </section>
    </>}
    <ConfirmModal open={selectedId !== null} title="Approve provider withdrawal?"
      description="This approves the existing request for payout. No money is transferred, and the requested amount remains reserved. The payout will not be marked completed."
      busy={busy} busyLabel="Approving withdrawal…" onCancel={() => { if (!busy) setSelectedId(null); }} onConfirm={confirmApproval}
      confirmLabel="Approve withdrawal" disabled={!approvalEnabled || !selected?.eligibility.allowed || note.trim().length > 500}>
      <dl className="approval-summary"><div><dt>Amount</dt><dd>{formatCurrency(selected?.amount)}</dd></div>
        <div><dt>Provider</dt><dd className="mono">{selected?.providerId || 'Not available'}</dd></div>
        <div><dt>Bank account</dt><dd>{selected?.bankName || 'Not recorded'} · •••• {selected?.accountLast4 || 'Not recorded'}</dd></div>
        <div><dt>Account holder</dt><dd>{selected?.accountHolderName || 'Not recorded'}</dd></div></dl>
      <label className="form-label" htmlFor="approval-note">Approval note (optional)</label>
      <textarea id="approval-note" rows={3} maxLength={500} value={note} disabled={busy} placeholder="Add a note for the approval history…" onChange={(event) => setNote(event.target.value)} />
      {!selected?.eligibility.allowed && <p className="form-error" role="alert">{selected?.eligibility.reason || 'This request is no longer available.'}</p>}
      {actionError && <p className="form-error" role="alert">{actionError}</p>}
    </ConfirmModal>
  </>;
}
