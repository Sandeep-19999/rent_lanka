import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth.js';
import { LoadingSpinner } from './Feedback.jsx';

export default function ProtectedRoute() {
  const { loading, isAdmin } = useAuth();
  const location = useLocation();
  if (loading) return <div className="auth-loading"><LoadingSpinner label="Verifying administrator access…" /></div>;
  if (!isAdmin) return <Navigate to="/login" replace state={{ from: location.pathname + location.search }} />;
  return <Outlet />;
}
