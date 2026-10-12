import { Users, Package, ArrowDownToLine, ArrowLeftRight, ChevronLeft, ChevronRight, CreditCard, LayoutDashboard, LogOut, ShieldCheck, Undo2, X } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth.js';
import { logout } from '../../services/authService.js';
import { useToast } from '../../context/ToastContext.jsx';
import { errorMessage } from '../../utils/errors.js';
import { textValue } from '../../utils/format.js';
import { useState } from 'react';
import Brand from './Brand.jsx';

const navigation = [
  { to: '/dashboard', label: 'Overview', icon: LayoutDashboard, end: true },
  { to: '/payments', label: 'Payments', icon: CreditCard },
  { to: '/transactions', label: 'Transactions', icon: ArrowLeftRight },
  { to: '/refunds', label: 'Refunds', icon: Undo2 },
  { to: '/withdrawals', label: 'Withdrawals', icon: ArrowDownToLine },
  { to: '/users', label: 'Users', icon: Users },
  { to: '/equipment', label: 'Equipment / Listings', icon: Package },
];

export default function Sidebar({ collapsed, onCollapse, onNavigate, drawer = false }) {
  const { profile, user } = useAuth();
  const notify = useToast();
  const [busy, setBusy] = useState(false);
  const name = textValue(profile?.name) || user?.email?.split('@')[0] || 'Administrator';
  async function signOut() {
    setBusy(true);
    try { await logout(); } catch (error) { notify(errorMessage(error, 'Unable to sign out. Please try again.'), 'error'); setBusy(false); }
  }
  return <div className={`sidebar ${collapsed ? 'collapsed' : ''} ${drawer ? 'drawer-sidebar' : ''}`}>
    <div className="sidebar-brand"><Brand compact={collapsed} />{drawer && <button className="icon-button" aria-label="Close navigation" onClick={onNavigate}><X size={20} /></button>}</div>
    <div className="sidebar-section-label">WORKSPACE</div>
    <nav aria-label="Main navigation">{navigation.map(({ to, label, icon: Icon, end }) =>
      <NavLink key={to} to={to} end={end} title={collapsed ? label : undefined} onClick={onNavigate}
        className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}><Icon size={20} /><span>{label}</span></NavLink>)}</nav>
    <div className="sidebar-bottom"><div className="workspace-note"><ShieldCheck size={19} /><div><strong>Platform administration</strong><p>Rent Lanka · LKR</p></div></div>
      <div className="sidebar-profile"><span className="avatar">{name.slice(0, 1).toUpperCase()}</span><div><strong title={name}>{name}</strong><small>Administrator</small></div></div>
      <button className="nav-item logout-button" onClick={signOut} disabled={busy} title="Log out"><LogOut size={19} /><span>{busy ? 'Signing out…' : 'Log out'}</span></button>
      {!drawer && <button className="collapse-button" onClick={onCollapse} aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}>{collapsed ? <ChevronRight size={17} /> : <><ChevronLeft size={17} /><span>Collapse sidebar</span></>}</button>}
    </div>
  </div>;
}
