import { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react';
import { CheckCircle2, CircleAlert, X } from 'lucide-react';

const ToastContext = createContext(null);
export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);
  const timers = useRef(new Set());
  const dismiss = useCallback((id) => setToasts((items) => items.filter((item) => item.id !== id)), []);
  const notify = useCallback((message, type = 'success') => {
    const id = crypto.randomUUID();
    setToasts((items) => [...items.slice(-3), { id, message, type }]);
    const timer = setTimeout(() => { dismiss(id); timers.current.delete(timer); }, 6000);
    timers.current.add(timer);
  }, [dismiss]);
  useEffect(() => () => timers.current.forEach(clearTimeout), []);
  return <ToastContext.Provider value={notify}>{children}
    <div className="toast-stack" aria-label="Notifications">{toasts.map((toast) =>
      <div key={toast.id} className={`toast toast-${toast.type}`} role={toast.type === 'error' ? 'alert' : 'status'}>
        {toast.type === 'error' ? <CircleAlert size={19} /> : <CheckCircle2 size={19} />}
        <span>{toast.message}</span><button className="icon-button" aria-label="Dismiss notification" onClick={() => dismiss(toast.id)}><X size={16} /></button>
      </div>)}</div>
  </ToastContext.Provider>;
}
export function useToast() { return useContext(ToastContext); }
