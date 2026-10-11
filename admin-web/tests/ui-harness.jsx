// Isolated UI fixtures. This entry is never imported by the production app.
// Providers below bypass Firebase listeners; these tests never write live data.
import { createRoot } from 'react-dom/client';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { AuthContext } from '../src/context/AuthContext.jsx';
import { PaymentContext } from '../src/context/PaymentContext.jsx';
import { ToastProvider } from '../src/context/ToastContext.jsx';
import { AdminWorkspace } from '../src/components/layout/AdminLayout.jsx';
import ProtectedRoute from '../src/components/common/ProtectedRoute.jsx';
import LoginPage from '../src/pages/LoginPage.jsx';
import DashboardPage from '../src/pages/DashboardPage.jsx';
import PaymentsPage from '../src/pages/PaymentsPage.jsx';
import TransactionsPage from '../src/pages/TransactionsPage.jsx';
import RefundsPage from '../src/pages/RefundsPage.jsx';
import { normalizePayment } from '../src/utils/payments.js';
import { isAdminProfile } from '../src/utils/authorization.js';
import '../src/styles/variables.css';
import '../src/styles/global.css';

const params = new URLSearchParams(window.location.search);
const role = params.get('role') || 'admin';
const profile = { role, name: 'Test Administrator' };
const bookings = {};
const raw = Array.from({ length: 27 }, (_, index) => {
  const number = index + 1;
  const bookingId = `test-booking-${number}`;
  const cash = number % 4 === 0;
  const data = { bookingId, bookingReference: `RL-TEST${String(number).padStart(2, '0')}`,
    playerId: `test-player-${number}`, providerId: 'test-provider', type: 'charge',
    amount: number * 1500, currency: 'LKR', method: cash ? 'cash' : number % 3 ? 'card' : 'online_banking',
    status: cash ? 'pay_on_pickup' : 'paid', transactionId: cash ? '' : `TXN-TEST${String(number).padStart(2, '0')}`,
    createdAt: new Date(Date.now() - index * 86400000) };
  bookings[bookingId] = { ...data, playerName: number === 1 ? 'Test Customer Alpha' : `Test Customer ${number}`,
    providerName: 'Test Provider', equipmentName: 'Test Equipment', status: number === 1 ? 'cancelled' : number === 2 ? 'rejected' : 'accepted',
    paymentStatus: number === 1 ? 'refunded' : data.status, totalPayable: data.amount, paymentMethod: data.method };
  return { id: `test-charge-${number}`, data };
});
raw.push({ id: 'test-booking-1_refund', data: { ...raw[0].data, type: 'refund', status: 'refunded' } });
raw.push({ id: 'test-legacy', data: { type: 'charge', amount: null, createdAt: null } });
const payments = raw.map(({ id, data }) => normalizePayment(id, data, bookings[data.bookingId]));
const refundsByBooking = { 'test-booking-1': [payments.find((payment) => payment.type === 'refund')] };
const state = { payments, bookings, raw, loading: false, error: '', bookingError: '', bookingsLoading: false,
  refundsByBooking, fromCache: false, lastUpdated: new Date(), retry() {} };
const auth = { user: { uid: 'test-admin', email: 'qa@example.invalid' }, profile,
  loading: false, isAdmin: isAdminProfile(profile), retryAuthorization() {},
  error: isAdminProfile(profile) ? '' : 'Access denied. This account is not authorized for the Rent Lanka admin portal.' };

createRoot(document.getElementById('root')).render(
  <MemoryRouter initialEntries={[params.get('page') || '/dashboard']}><ToastProvider><AuthContext.Provider value={auth}><PaymentContext.Provider value={state}>
    <Routes><Route path="/login" element={<LoginPage />} /><Route element={<ProtectedRoute />}><Route element={<AdminWorkspace />}>
      <Route path="/dashboard" element={<DashboardPage />} /><Route path="/payments" element={<PaymentsPage />} />
      <Route path="/transactions" element={<TransactionsPage />} /><Route path="/refunds" element={<RefundsPage />} />
    </Route></Route></Routes>
  </PaymentContext.Provider></AuthContext.Provider></ToastProvider></MemoryRouter>,
);
