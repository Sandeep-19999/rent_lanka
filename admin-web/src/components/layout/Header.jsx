import { ChevronDown, ChevronRight, LogOut, Menu, RefreshCw } from 'lucide-react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth.js';
import { usePayments } from '../../hooks/usePayments.js';
import { logout } from '../../services/authService.js';
import { useToast } from '../../context/ToastContext.jsx';
import { errorMessage } from '../../utils/errors.js';
import { textValue } from '../../utils/format.js';

export default function Header({ onOpenMenu }) {
  const { profile, user } = useAuth();
  const { fromCache, loading, error, retry } = usePayments();
  const location = useLocation();
  const notify = useToast();
  const section = location.pathname.split('/')[1];
  const title = { dashboard: 'Overview', payments: 'Payments', transactions: 'Transactions', refunds: 'Refunds', withdrawals: 'Withdrawals' }[section] || 'Overview';
  const detail = section === 'payments' && location.pathname.split('/').length > 2;
  const name = textValue(profile?.name) || user?.email?.split('@')[0] || 'Administrator';
  return <header className="topbar"><div className="topbar-left"><button className="icon-button mobile-menu-button" aria-label="Open navigation" onClick={onOpenMenu}><Menu size={22} /></button>
    <nav className="breadcrumb" aria-label="Breadcrumb"><span>Workspace</span><ChevronRight size={14} />{detail ? <><Link to="/payments">Payments</Link><ChevronRight size={14} /><strong>Details</strong></> : <strong>{title}</strong>}</nav>
  </div><div className="topbar-right"><span className={`connection-badge ${fromCache || error ? 'cached' : ''}`} title="Record source; does not indicate whether security rules have been reviewed"><span />{loading ? 'Connecting' : error ? 'Data unavailable' : fromCache ? 'Cached records' : 'Live records'}</span>
    <button className="icon-button" title="Refresh records" aria-label="Refresh records" onClick={retry}><RefreshCw size={17} /></button>
    <details className="profile-menu"><summary aria-label="Open account menu"><span className="avatar small">{name.slice(0, 1).toUpperCase()}</span><div className="header-profile-text"><strong>{name}</strong><small>Administrator</small></div><ChevronDown size={15} /></summary>
      <div className="profile-popover glass"><strong>{name}</strong><p>{user?.email}</p><button className="button secondary" onClick={async () => { try { await logout(); } catch (failure) { notify(errorMessage(failure), 'error'); } }}><LogOut size={16} />Log out</button></div>
    </details>
  </div></header>;
}
