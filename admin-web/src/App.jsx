import { lazy, Suspense } from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext.jsx';
import { ToastProvider } from './context/ToastContext.jsx';
import ErrorBoundary from './components/common/ErrorBoundary.jsx';
import ProtectedRoute from './components/common/ProtectedRoute.jsx';
import AdminLayout from './components/layout/AdminLayout.jsx';
import LoginPage from './pages/LoginPage.jsx';
import { LoadingSkeleton } from './components/common/Feedback.jsx';

const DashboardPage = lazy(() => import('./pages/DashboardPage.jsx'));
const PaymentsPage = lazy(() => import('./pages/PaymentsPage.jsx'));
const PaymentDetailsPage = lazy(() => import('./pages/PaymentDetailsPage.jsx'));
const TransactionsPage = lazy(() => import('./pages/TransactionsPage.jsx'));
const RefundsPage = lazy(() => import('./pages/RefundsPage.jsx'));
const WithdrawalsPage = lazy(() => import('./pages/WithdrawalsPage.jsx'));

const WithdrawalDetailsPage = lazy(() => import('./pages/WithdrawalDetailsPage.jsx'));
const UsersPage = lazy(() => import('./pages/UsersPage.jsx'));
const UserDetailsPage = lazy(() => import('./pages/UserDetailsPage.jsx'));
const EquipmentPage = lazy(() => import('./pages/EquipmentPage.jsx'));
const EquipmentDetailsPage = lazy(() => import('./pages/EquipmentDetailsPage.jsx'));

export default function App() {
  return <ErrorBoundary><BrowserRouter><ToastProvider><AuthProvider><Suspense fallback={<div className="route-loading"><LoadingSkeleton rows={4} /></div>}>
    <Routes><Route path="/login" element={<LoginPage />} /><Route element={<ProtectedRoute />}><Route element={<AdminLayout />}>
      <Route path="/dashboard" element={<DashboardPage />} /><Route path="/payments" element={<PaymentsPage />} />
      <Route path="/payments/:paymentId" element={<PaymentDetailsPage />} /><Route path="/transactions" element={<TransactionsPage />} />
      <Route path="/refunds" element={<RefundsPage />} /><Route path="/withdrawals" element={<WithdrawalsPage />} />
    <Route path="/withdrawals/:withdrawalId" element={<WithdrawalDetailsPage />} /><Route path="/users" element={<UsersPage />} /><Route path="/users/:userId" element={<UserDetailsPage />} /><Route path="/equipment" element={<EquipmentPage />} /><Route path="/equipment/:equipmentId" element={<EquipmentDetailsPage />} /></Route></Route><Route path="*" element={<Navigate to="/dashboard" replace />} /></Routes>
  </Suspense></AuthProvider></ToastProvider></BrowserRouter></ErrorBoundary>;
}
