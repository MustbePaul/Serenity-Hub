import { FormEvent, useState } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { mode } from '../lib/api'
import { Button, Field, Notice } from '../components/ui'

export function AuthPage({ kind }: { kind: 'login' | 'register' }) {
  const { login, register } = useAuth()
  const navigate = useNavigate()
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  if (mode === 'demo') return <Navigate to="/" replace />
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setError(''); setBusy(true)
    const data = new FormData(event.currentTarget)
    try {
      if (kind === 'login') await login(String(data.get('email')), String(data.get('password')))
      else await register(String(data.get('name')), String(data.get('email')), String(data.get('password')))
      navigate('/app', { replace: true })
    } catch (cause) { setError(cause instanceof Error ? cause.message : 'Could not continue.') }
    finally { setBusy(false) }
  }
  return <div className="auth-shell"><Link to="/" className="brand"><span className="brand-mark">✦</span><span>serenity<span className="brand-light">hub</span></span></Link><main className="auth-card"><span className="eyebrow">STAGING ACCOUNT</span><h1>{kind === 'login' ? 'Welcome back.' : 'A space to begin.'}</h1><p className="muted">{kind === 'login' ? 'Sign in to your test account.' : 'Create an account on the isolated staging service.'}</p>{error && <Notice tone="error">{error}</Notice>}<form onSubmit={submit}>
    {kind === 'register' && <Field id="name" name="name" label="Name" autoComplete="name" required maxLength={255} />}
    <Field id="email" name="email" label="Email" type="email" autoComplete="email" required />
    <Field id="password" name="password" label="Password" type="password" autoComplete={kind === 'login' ? 'current-password' : 'new-password'} minLength={kind === 'register' ? 8 : undefined} required />
    {kind === 'register' && <label className="check-row"><input type="checkbox" required /><span>I agree to the staging privacy notice and understand this is a test environment.</span></label>}
    <Button type="submit" disabled={busy}>{busy ? 'Please wait…' : kind === 'login' ? 'Sign in' : 'Create test account'}</Button>
  </form><p className="auth-switch">{kind === 'login' ? <>New here? <Link to="/register">Create a test account</Link></> : <>Already registered? <Link to="/login">Sign in</Link></>}</p></main><p className="auth-foot">Serenity Hub is a wellness trial, not an emergency service.</p></div>
}
