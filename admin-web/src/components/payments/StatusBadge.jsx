import { formatStatus } from '../../utils/format.js';

export default function StatusBadge({ status }) {
  const tone = ['paid', 'approved', 'completed'].includes(status) ? 'success'
    : ['pay_on_pickup', 'pending'].includes(status) ? 'warning'
      : ['rejected', 'failed'].includes(status) ? 'danger'
        : status === 'refunded' ? 'refund' : 'neutral';
  return <span className={`status-badge status-${tone}`}><span className="status-dot" />{formatStatus(status)}</span>;
}
