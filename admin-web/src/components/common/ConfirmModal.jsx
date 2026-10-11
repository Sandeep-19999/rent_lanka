import { useEffect, useId, useRef } from 'react';
import { X } from 'lucide-react';
import { LoadingSpinner } from './Feedback.jsx';

export default function ConfirmModal({ open, title, description, children, busy, onCancel, onConfirm, confirmLabel = 'Confirm', busyLabel = 'Recording refund…', disabled = false }) {
  const dialog = useRef(null);
  const heading = useId();
  const content = useId();
  useEffect(() => {
    const element = dialog.current;
    if (!open) return;
    const previousFocus = document.activeElement;
    if (!element.open) element.showModal();
    return () => { element.close(); previousFocus?.focus(); };
  }, [open]);
  if (!open) return null;
  return <dialog ref={dialog} className="confirm-dialog" aria-labelledby={heading} aria-describedby={content}
    onCancel={(event) => { event.preventDefault(); if (!busy) onCancel(); }}>
    <div className="modal-header"><h2 id={heading}>{title}</h2><button className="icon-button" onClick={onCancel} disabled={busy} aria-label="Close dialog"><X size={20} /></button></div>
    <p id={content} className="muted">{description}</p>
    {children}
    <div className="modal-actions"><button autoFocus className="button secondary" onClick={onCancel} disabled={busy}>Cancel</button>
      <button className="button primary" onClick={onConfirm} disabled={busy || disabled}>{busy ? <LoadingSpinner label={busyLabel} /> : confirmLabel}</button></div>
  </dialog>;
}
