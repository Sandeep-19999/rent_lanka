import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Download, FileText } from 'lucide-react';
import { EMPTY_FILTERS, filterPayments } from '../../utils/payments.js';
import { dateKey } from '../../utils/format.js';
import { downloadCsv, paymentsCsv } from '../../utils/csv.js';
import { useToast } from '../../context/ToastContext.jsx';
import PaymentFilters from './PaymentFilters.jsx';
import PaymentTable from './PaymentTable.jsx';
import { PageHeading } from '../common/Feedback.jsx';

export default function PaymentExplorer({ rows, title, description, tableTitle, refundsByBooking, refundView = false, showType = false, originalCharges, exportReady = true, children }) {
  const [params, setParams] = useSearchParams();
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const notify = useToast();
  const filters = useMemo(() => {
    const next = Object.fromEntries(Object.entries(EMPTY_FILTERS).map(([key, value]) => [key, params.get(key) ?? value]));
    if (!['latest', 'oldest', 'amount_desc', 'amount_asc'].includes(next.sort)) next.sort = 'latest';
    for (const key of ['from', 'to']) if (next[key] && !/^\d{4}-\d{2}-\d{2}$/.test(next[key])) next[key] = '';
    return next;
  }, [params]);
  const filtered = useMemo(() => filterPayments(rows, filters), [rows, filters]);
  const statuses = useMemo(() => [...new Set(rows.map((row) => row.status).filter(Boolean))].sort(), [rows]);
  const methods = useMemo(() => [...new Set(rows.map((row) => row.method).filter(Boolean))].sort(), [rows]);
  const currentPage = Math.min(page, Math.max(1, Math.ceil(filtered.length / pageSize)));
  function change(key, value) {
    setPage(1);
    setParams((previous) => { const next = new URLSearchParams(previous); if (!value || value === EMPTY_FILTERS[key]) next.delete(key); else next.set(key, value); return next; }, { replace: true });
  }
  function reset() { setPage(1); setParams({}, { replace: true }); }
  function exportRecords() {
    downloadCsv(paymentsCsv(filtered), `rent-lanka-${refundView ? 'refunds' : 'payments'}-${dateKey(new Date())}.csv`);
    notify(`Exported ${filtered.length} filtered ${filtered.length === 1 ? 'record' : 'records'}.`);
  }
  return <><PageHeading title={title} description={description}><button className="button secondary" onClick={exportRecords} disabled={!filtered.length || !exportReady}><Download size={16} />Export CSV</button></PageHeading>
    {children}
    <section className="glass table-panel"><div className="panel-header"><div className="panel-heading"><span className="panel-icon"><FileText size={18} /></span><h2>{tableTitle}</h2><span className="count-badge">{rows.length}</span></div><span className="panel-meta">{filtered.length} matching records</span></div>
      <PaymentFilters filters={filters} onChange={change} onReset={reset} statuses={statuses} methods={methods} showType={showType} />
      <PaymentTable rows={filtered.slice((currentPage - 1) * pageSize, currentPage * pageSize)} total={filtered.length} page={currentPage} pageSize={pageSize}
        onPageChange={setPage} onPageSizeChange={(size) => { setPageSize(size); setPage(1); }} refundsByBooking={refundsByBooking}
        refundView={refundView} originalCharges={originalCharges} onReset={reset} />
    </section></>;
}
