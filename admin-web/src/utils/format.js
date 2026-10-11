export const TIME_ZONE = 'Asia/Colombo';

export function toDate(value) {
  if (value == null || value === '') return null;
  try {
    const date = value instanceof Date ? value
      : typeof value?.toDate === 'function' ? value.toDate()
        : typeof value?.seconds === 'number' ? new Date(value.seconds * 1000)
          : typeof value === 'string' || typeof value === 'number' ? new Date(value) : null;
    return date instanceof Date && Number.isFinite(date.getTime()) ? date : null;
  } catch { return null; }
}

export function dateKey(value) {
  const date = toDate(value);
  if (!date) return '';
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: TIME_ZONE, year: 'numeric', month: '2-digit', day: '2-digit',
  }).formatToParts(date);
  const part = (name) => parts.find((item) => item.type === name)?.value;
  return `${part('year')}-${part('month')}-${part('day')}`;
}

export function formatDate(value, options = {}) {
  const date = toDate(value);
  return date ? new Intl.DateTimeFormat('en-GB', {
    timeZone: TIME_ZONE, day: '2-digit', month: 'short', year: 'numeric', ...options,
  }).format(date) : 'Not recorded';
}

export function formatDateTime(value) {
  return formatDate(value, { hour: '2-digit', minute: '2-digit' });
}

export function numberValue(value) {
  if (typeof value !== 'number' && typeof value !== 'string') return null;
  if (typeof value === 'string' && !value.trim()) return null;
  const number = Number(value);
  return Number.isFinite(number) && number >= 0 ? number : null;
}

export function textValue(value, fallback = '') {
  return typeof value === 'string' || typeof value === 'number' ? String(value).trim() : fallback;
}

export function formatCurrency(amount, currency = 'LKR', compact = false) {
  if (amount == null || !Number.isFinite(amount)) return 'Not recorded';
  const number = new Intl.NumberFormat('en-LK', {
    minimumFractionDigits: compact ? 0 : 2, maximumFractionDigits: 2,
    ...(compact && Math.abs(amount) >= 1000000 ? { notation: 'compact' } : {}),
  }).format(amount);
  return `${currency === 'LKR' ? 'Rs.' : currency || 'Currency unknown'} ${number}`;
}

export function formatStatus(status) {
  const known = { paid: 'Paid', pay_on_pickup: 'Pay on Pickup', refunded: 'Refunded', unknown: 'Unknown',
    pending: 'Pending', approved: 'Approved', completed: 'Completed', rejected: 'Rejected', cancelled: 'Cancelled' };
  return known[status] || (textValue(status) ? textValue(status).replaceAll('_', ' ') : 'Unknown');
}

export function formatMethod(method) {
  return { card: 'Card', online_banking: 'Online Banking', cash: 'Cash on Pickup' }[method] || textValue(method) || 'Unknown';
}

export function shortId(value) {
  const text = textValue(value);
  return text.length > 16 ? `${text.slice(0, 8)}…${text.slice(-5)}` : text || 'Not recorded';
}
