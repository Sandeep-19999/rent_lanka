import { formatDateTime } from './format.js';

export function csvCell(value) {
  let text = value == null ? '' : String(value);
  // Prevent formula execution when exports are opened in spreadsheet software.
  if (/^\s*[=+\-@]|^[\t\r\n]/.test(text)) text = `'${text}`;
  return `"${text.replaceAll('"', '""')}"`;
}

export function paymentsCsv(rows) {
  const headings = ['Payment ID', 'Transaction ID', 'Type', 'Booking Reference', 'Booking ID', 'Customer',
    'Provider', 'Method', 'Amount', 'Currency', 'Status', 'Date (Asia/Colombo)'];
  return [headings, ...rows.map((row) => [row.id, row.transactionId, row.type, row.bookingReference, row.bookingId,
    row.playerName || row.playerId, row.providerName || row.providerId, row.method, row.amount,
    row.currency, row.status, row.createdAt ? formatDateTime(row.createdAt) : ''])]
    .map((cells) => cells.map(csvCell).join(',')).join('\r\n');
}

export function downloadCsv(contents, filename) {
  const blob = new Blob(['\uFEFF', contents], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = filename;
  document.body.append(anchor);
  anchor.click();
  anchor.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
