import type { ButtonHTMLAttributes, ReactNode } from 'react'

export function Button({ children, className = '', variant = 'primary', ...props }: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: 'primary' | 'secondary' | 'quiet' }) {
  return <button className={`button button-${variant} ${className}`} {...props}>{children}</button>
}
export function Card({ children, className = '' }: { children: ReactNode; className?: string }) { return <div className={`card ${className}`}>{children}</div> }
export function PageHeader({ eyebrow, title, description, action }: { eyebrow?: string; title: string; description?: string; action?: ReactNode }) {
  return <header className="page-header"><div>{eyebrow && <span className="eyebrow">{eyebrow}</span>}<h1>{title}</h1>{description && <p className="muted lead">{description}</p>}</div>{action}</header>
}
export function Notice({ children, tone = 'info' }: { children: ReactNode; tone?: 'info' | 'warning' | 'error' }) { return <div className={`notice notice-${tone}`} role={tone === 'error' ? 'alert' : 'note'}>{children}</div> }
export function Empty({ title, children }: { title: string; children?: ReactNode }) { return <div className="empty"><h2>{title}</h2>{children && <p>{children}</p>}</div> }
export function Loading() { return <div className="loading" role="status" aria-live="polite">Loading Serenity Hub…</div> }
export function Field({ label, id, ...props }: React.InputHTMLAttributes<HTMLInputElement> & { label: string; id: string }) { return <label className="field" htmlFor={id}><span>{label}</span><input id={id} {...props} /></label> }
