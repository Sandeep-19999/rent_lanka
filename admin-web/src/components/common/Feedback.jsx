import { AlertCircle, ArrowRight, Inbox, LoaderCircle, RefreshCw } from 'lucide-react';
import { Link } from 'react-router-dom';

export function LoadingSpinner({ label = 'Loading…' }) {
  return <span className="loading-inline" role="status"><LoaderCircle className="spin" size={18} /><span>{label}</span></span>;
}

export function LoadingSkeleton({ rows = 5, dashboard = false }) {
  return <div className="skeleton-group" role="status" aria-label="Loading records">
    {dashboard && <div className="stats-grid">{Array.from({ length: 4 }, (_, index) => <div className="glass skeleton-card" key={index}><span className="skeleton skeleton-label" /><span className="skeleton skeleton-value" /><span className="skeleton skeleton-line" /></div>)}</div>}
    <div className="glass skeleton-table">{Array.from({ length: rows }, (_, index) => <div key={index} className="skeleton-row"><span className="skeleton" /><span className="skeleton" /><span className="skeleton" /><span className="skeleton" /></div>)}</div>
    <span className="sr-only">Loading payment records…</span>
  </div>;
}

export function EmptyState({ title = 'No payment records yet', description = 'Payment records will appear here when bookings are made in the Rent Lanka mobile app.', action, compact = false }) {
  return <div className={`empty-state ${compact ? 'compact' : ''}`}><div className="empty-icon"><Inbox size={27} /></div>
    <h3>{title}</h3><p>{description}</p>{action}</div>;
}

export function ErrorState({ message, retry, title = 'Unable to load records' }) {
  return <div className="glass error-state" role="alert"><AlertCircle size={28} /><h3>{title}</h3><p>{message}</p>
    {retry && <button className="button secondary" onClick={retry}><RefreshCw size={16} />Try again</button>}</div>;
}

export function Notice({ children, tone = 'neutral' }) {
  return <div className={`notice notice-${tone}`} role={tone === 'error' ? 'alert' : 'status'}><AlertCircle size={17} /><div>{children}</div></div>;
}

export function PageHeading({ eyebrow = 'PLATFORM ADMINISTRATION', title, description, children }) {
  return <div className="page-heading"><div><p className="eyebrow">{eyebrow}</p><h1>{title}</h1><p className="page-description">{description}</p></div>
    {children && <div className="page-actions">{children}</div>}</div>;
}

export function DetailLink({ to, children = 'View details' }) {
  return <Link className="text-link" to={to}>{children}<ArrowRight size={15} /></Link>;
}
