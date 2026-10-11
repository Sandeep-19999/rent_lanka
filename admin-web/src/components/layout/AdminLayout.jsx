import { useEffect, useRef, useState } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { PaymentProvider } from '../../context/PaymentContext.jsx';
import Sidebar from './Sidebar.jsx';
import Header from './Header.jsx';

export function AdminWorkspace() {
  const [collapsed, setCollapsed] = useState(() => { try { return localStorage.getItem('rent-lanka-sidebar') === 'collapsed'; } catch { return false; } });
  const [open, setOpen] = useState(false);
  const drawer = useRef(null);
  const { pathname } = useLocation();
  useEffect(() => { setOpen(false); document.getElementById('main-content')?.focus({ preventScroll: true }); window.scrollTo(0, 0); }, [pathname]);
  useEffect(() => {
    if (!open) return;
    const element = drawer.current;
    const previousFocus = document.activeElement;
    const previousOverflow = document.body.style.overflow;
    element.showModal(); document.body.style.overflow = 'hidden';
    const media = window.matchMedia('(min-width: 901px)');
    const onResize = () => { if (media.matches) setOpen(false); };
    media.addEventListener('change', onResize);
    return () => { element.close(); document.body.style.overflow = previousOverflow; previousFocus?.focus(); media.removeEventListener('change', onResize); };
  }, [open]);
  function toggleSidebar() {
    setCollapsed((value) => { try { localStorage.setItem('rent-lanka-sidebar', value ? 'expanded' : 'collapsed'); } catch { /* preference is optional */ } return !value; });
  }
  return <div className={`app-shell ${collapsed ? 'sidebar-is-collapsed' : ''}`}>
    <a href="#main-content" className="skip-link">Skip to content</a>
    <aside className="desktop-sidebar"><Sidebar collapsed={collapsed} onCollapse={toggleSidebar} /></aside>
    <dialog className="navigation-dialog" ref={drawer} aria-label="Main navigation" onCancel={(event) => { event.preventDefault(); setOpen(false); }}>
      <Sidebar drawer onNavigate={() => setOpen(false)} />
    </dialog>
    <div className="workspace"><Header onOpenMenu={() => setOpen(true)} /><main id="main-content" className="main-content" tabIndex={-1}><Outlet /></main>
      <footer className="workspace-footer"><span>RENT LANKA <span className="footer-dot">/</span> Payment administration</span><span>All dates in Asia/Colombo · Amounts in LKR unless stated</span></footer>
    </div>
  </div>;
}

export default function AdminLayout() {
  return <PaymentProvider><AdminWorkspace /></PaymentProvider>;
}
