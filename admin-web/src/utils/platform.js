import { numberValue, textValue, toDate } from './format.js';
export function imageSource(value) {
  if (typeof value !== 'string') return '';
  try { const url = new URL(value); return url.protocol === 'https:' && !url.username && !url.password ? url.href : ''; } catch { return ''; }
}
export function normalizeUser(id, data = {}) {
  return { id, name: textValue(data.name), email: textValue(data.email), phone: textValue(data.phone), location: textValue(data.location), role: textValue(data.role), isVerified: typeof data.isVerified === 'boolean' ? data.isVerified : null, photoUrl: imageSource(data.photoUrl), createdAt: toDate(data.createdAt) };
}
export function normalizeEquipment(id, data = {}) {
  return { id, ...Object.fromEntries(['name', 'category', 'brand', 'size', 'condition', 'providerId', 'providerName', 'location', 'description', 'status'].map(key => [key, textValue(data[key])])), pricePerDay: numberValue(data.pricePerDay), isAvailable: typeof data.isAvailable === 'boolean' ? data.isAvailable : null, imageUrl: imageSource(data.imageUrl), unavailableDates: Array.isArray(data.unavailableDates) ? data.unavailableDates.filter(v => typeof v === 'string') : [], createdAt: toDate(data.createdAt) };
}
export function normalizeBooking(id, data = {}) {
  return { id, ...Object.fromEntries(['bookingReference', 'equipmentId', 'equipmentName', 'providerId', 'playerId', 'status', 'paymentStatus', 'startDate', 'endDate'].map(key => [key, textValue(data[key])])), totalPayable: numberValue(data.totalPayable) };
}
export function matchesSearch(row, fields, search) {
  const term = search.trim().toLowerCase();
  return !term || fields.some(key => textValue(row[key]).toLowerCase().includes(term));
}
