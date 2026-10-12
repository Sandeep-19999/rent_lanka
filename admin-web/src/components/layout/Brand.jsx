import { Activity } from 'lucide-react';

export default function Brand({ compact = false }) {
  return <div className={`brand ${compact ? 'brand-compact' : ''}`}><span className="brand-mark"><Activity size={24} strokeWidth={2.5} /></span>
    <span className="brand-copy"><strong>RENT <span>LANKA</span></strong><small>ADMIN PORTAL</small></span></div>;
}
