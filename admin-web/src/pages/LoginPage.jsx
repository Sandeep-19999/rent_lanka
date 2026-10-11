import { useState } from 'react';
import { ArrowRight, ArrowUpRight, Eye, EyeOff, Layers3, LockKeyhole, Mail, ShieldCheck } from 'lucide-react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth.js';
import { login, logout } from '../services/authService.js';
import { configurationError } from '../services/firebase.js';
import { errorMessage } from '../utils/errors.js';
import { safeReturnPath } from '../utils/authorization.js';
import Brand from '../components/layout/Brand.jsx';
import { LoadingSpinner } from '../components/common/Feedback.jsx';

export default function LoginPage() {
  const { isAdmin, loading, error: authorizationError, user, retryAuthorization } = useAuth();
  const location = useLocation();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [show, setShow] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  if (isAdmin && !loading) return <Navigate to={safeReturnPath(location.state?.from)} replace />;
  async function submit(event) {
    event.preventDefault(); setBusy(true); setError('');
    try { await login(email, password); retryAuthorization(); } catch (failure) { setError(errorMessage(failure, 'Unable to sign in. Please try again.')); }
    finally { setBusy(false); }
  }
  return <main className="login-page"><div className="login-brand"><Brand /><span className="login-top-label"><ShieldCheck size={15} />Administrator access</span></div>
    <div className="login-grid"><section className="login-intro"><p className="eyebrow">THE FINANCIAL WORKSPACE</p><h1>Every payment.<br /><span>A clearer picture.</span></h1>
      <p className="login-lead">One workspace for the payments behind every rental. Review transactions, track refunds, and keep your team informed.</p>
      <div className="login-feature"><span><Layers3 size={20} /></span><div><strong>Connected to Rent Lanka</strong><p>The same booking and payment records your mobile app uses.</p></div></div>
      <div className="login-feature"><span><ShieldCheck size={20} /></span><div><strong>Access for administrators</strong><p>Sign in with your authorized Rent Lanka account.</p></div></div>
      <div className="login-wordmark" aria-hidden="true">RENT<span>LANKA</span><ArrowUpRight size={47} /></div>
    </section><section className="login-card glass"><div className="login-card-icon"><LockKeyhole size={23} /></div><p className="eyebrow">ADMIN PORTAL</p><h2>Welcome back</h2><p className="muted">Sign in to your payment workspace.</p>
      <form onSubmit={submit}><label htmlFor="email">Username or email address</label><div className="input-with-icon"><Mail size={17} /><input id="email" type="text" autoComplete="username" autoCapitalize="none" spellCheck={false} placeholder="Enter your username or email" required value={email} onChange={(event) => setEmail(event.target.value)} disabled={busy || loading} /></div>
        <label htmlFor="password">Password</label><div className="input-with-icon"><LockKeyhole size={17} /><input id="password" type={show ? 'text' : 'password'} autoComplete="current-password" placeholder="Enter your password" required value={password} onChange={(event) => setPassword(event.target.value)} disabled={busy || loading} />
          <button type="button" className="icon-button password-toggle" aria-label={show ? 'Hide password' : 'Show password'} aria-pressed={show} onClick={() => setShow((value) => !value)}>{show ? <EyeOff size={18} /> : <Eye size={18} />}</button></div>
        {(error || authorizationError || configurationError) && <div className="form-error" role="alert">{error || authorizationError || configurationError}</div>}
        <button className="button primary login-submit" type="submit" disabled={busy || loading || !!configurationError}>{busy || loading ? <LoadingSpinner label={loading ? 'Verifying access…' : 'Signing in…'} /> : <>Sign in to workspace<ArrowRight size={18} /></>}</button>
      </form>
      {user && !isAdmin && !loading && <button className="text-button" onClick={async () => { try { await logout(); setError(''); } catch (failure) { setError(errorMessage(failure)); } }}>Sign out of {user.email}</button>}
      <div className="login-card-footer"><ShieldCheck size={16} /><p>Need access? Contact your project administrator to authorize your account.</p></div>
    </section></div><footer className="login-footer"><span>© {new Date().getFullYear()} Rent Lanka</span><span>Sports equipment rental & exchange</span></footer>
  </main>;
}
