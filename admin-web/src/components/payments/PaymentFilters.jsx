import { RotateCcw, Search, SlidersHorizontal } from 'lucide-react';
import { formatMethod, formatStatus } from '../../utils/format.js';

export default function PaymentFilters({ filters, onChange, onReset, statuses, methods, showType = false }) {
  return <div className="payment-filters"><div className="filter-primary"><label className="search-field input-with-icon"><Search size={18} /><span className="sr-only">Search payments</span><input type="search" placeholder="Search transaction, booking or customer…" value={filters.search} onChange={(event) => onChange('search', event.target.value)} /></label>
    <div className="filter-controls"><label><span className="sr-only">Payment status</span><select aria-label="Payment status" value={filters.status} onChange={(event) => onChange('status', event.target.value)}><option value="">All statuses</option>{statuses.map((value) => <option key={value} value={value}>{formatStatus(value)}</option>)}</select></label>
      <label><span className="sr-only">Payment method</span><select aria-label="Payment method" value={filters.method} onChange={(event) => onChange('method', event.target.value)}><option value="">All methods</option>{methods.map((value) => <option key={value} value={value}>{formatMethod(value)}</option>)}</select></label>
      {showType && <label><span className="sr-only">Record type</span><select aria-label="Record type" value={filters.type} onChange={(event) => onChange('type', event.target.value)}><option value="">All types</option><option value="charge">Charges</option><option value="refund">Refunds</option></select></label>}
    </div></div><div className="filter-secondary"><span className="filter-date-label"><SlidersHorizontal size={14} />Date range</span>
      <label className="date-filter"><span>From</span><input type="date" aria-label="From date (Asia/Colombo)" value={filters.from} max={filters.to || undefined} onChange={(event) => onChange('from', event.target.value)} /></label>
      <label className="date-filter"><span>To</span><input type="date" aria-label="To date (Asia/Colombo)" value={filters.to} min={filters.from || undefined} onChange={(event) => onChange('to', event.target.value)} /></label>
      <label className="sort-filter"><span className="sr-only">Sort records</span><select aria-label="Sort records" value={filters.sort} onChange={(event) => onChange('sort', event.target.value)}><option value="latest">Latest first</option><option value="oldest">Oldest first</option><option value="amount_desc">Amount: high to low</option><option value="amount_asc">Amount: low to high</option></select></label>
      <button className="text-button reset-filters" onClick={onReset}><RotateCcw size={14} />Reset filters</button>
    </div>{filters.from && filters.to && filters.from > filters.to && <p className="form-error" role="alert">The end date must be on or after the start date.</p>}</div>;
}
