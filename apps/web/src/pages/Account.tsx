import { CalendarDays, CircleHelp, LockKeyhole, LogOut, Settings as SettingsIcon, UserRound } from 'lucide-react'
import { FormEvent, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { Button, Card, Field, Loading, Notice, PageHeader } from '../components/ui'
import { useContent } from '../hooks/useContent'
import { api, mode } from '../lib/api'
import type { SupportContact, User } from '../lib/types'

const emptyContacts: SupportContact[] = []

export function Profile() {
  const { user, guest, logout, updateUser } = useAuth()
  const navigate = useNavigate()
  const [name, setName] = useState(user?.name || '')
  const [feedback, setFeedback] = useState('')
  const [busy, setBusy] = useState(false)
  async function save(event: FormEvent) { event.preventDefault(); if (!user) return; setBusy(true); setFeedback(''); try { const result = await api<User>('/profile', { method: 'PATCH', body: { name } }); updateUser(result.data); setFeedback('Profile saved to your staging account.') } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not save profile.') } finally { setBusy(false) } }
  async function signOut() { try { await logout(); navigate('/', { replace: true }) } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not sign out.') } }
  const preview = mode === 'demo' || guest
  return <><PageHeader eyebrow="YOUR ACCOUNT" title="Profile" description={preview ? 'A preview of the account area.' : 'Your staging account details and preferences.'} />{feedback && <Notice>{feedback}</Notice>}{preview ? <Notice>Guest preview · You do not have a persisted account or profile. Personal information entered here is not saved.</Notice> : null}<div className="account-grid"><Card className="profile-summary"><div className="profile-avatar"><UserRound size={34} /></div><span className="eyebrow">{preview ? 'GUEST PREVIEW' : 'STAGING TEST ACCOUNT'}</span><h2>{preview ? 'Guest visitor' : user?.name}</h2><p className="muted">{preview ? 'Explore the demo without personal records.' : user?.email}</p>{preview ? <Link to="/" className="button button-secondary">Return to welcome</Link> : <Button variant="secondary" onClick={signOut}><LogOut size={17} /> Sign out</Button>}</Card><div className="account-actions"><Link to="/app/appointments"><CalendarDays size={21} /><span><strong>Appointments</strong><small>{preview ? 'See how booking works' : 'Review your test bookings'}</small></span></Link><Link to="/app/settings"><SettingsIcon size={21} /><span><strong>Settings & privacy</strong><small>Understand browser data and account controls</small></span></Link><Link to="/app/help"><CircleHelp size={21} /><span><strong>Help & safety</strong><small>Support and urgent-care guidance</small></span></Link></div></div>{!preview && <Card className="profile-edit"><h2>Edit profile</h2><p className="muted">Your name is stored on the staging service.</p><form onSubmit={save}><Field id="profile-name" label="Name" value={name} onChange={event => setName(event.target.value)} required maxLength={255} /><Button type="submit" disabled={busy || !name.trim()}>{busy ? 'Saving…' : 'Save profile'}</Button></form></Card>}</>
}
export function Settings() {
  const { user, guest } = useAuth()
  const preview = mode === 'demo' || guest
  return <><PageHeader eyebrow="ACCOUNT CONTROL" title="Settings & privacy" description="Clear information about what this browser trial stores." /><div className="settings-grid"><Card><LockKeyhole size={24} /><h2>Session privacy</h2><p>{preview ? 'Demo state is held in memory for this browser tab. It has no account data.' : 'Your account uses an HttpOnly Laravel session cookie. No bearer token is saved in browser storage.'}</p><p className="muted">{preview ? 'Refreshing the page returns to the welcome screen.' : 'Sign out when using a shared device. Session expiry is controlled by the staging API.'}</p></Card><Card><SettingsIcon size={24} /><h2>Preferences</h2><p>Notification, biometric, language and appearance controls are not available in this trial.</p><p className="muted">They will only be enabled after their behavior is implemented and tested.</p></Card><Card><UserRound size={24} /><h2>Account data</h2><p>{user ? 'Profile, mood, appointment and community actions are stored by the isolated staging Laravel service.' : 'Demo interactions are synthetic and do not access personal records.'}</p><Link className="arrow-link" to="/app/profile">Open profile</Link></Card></div></>
}
export function Help() {
  const { guest } = useAuth()
  const preview = mode === 'demo' || guest
  const { data: contacts, loading, error } = useContent<SupportContact[]>('/support-contacts', emptyContacts)
  const verified = contacts.filter(contact => contact.country_code.toUpperCase() !== 'ZZ' && !contact.service_name.toUpperCase().includes('DEMO ONLY'))
  const [subject, setSubject] = useState('')
  const [message, setMessage] = useState('')
  const [feedback, setFeedback] = useState('')
  async function send(event: FormEvent) { event.preventDefault(); if (preview) return; try { await api('/support-tickets', { method: 'POST', body: { subject, message } }); setFeedback('Your staging support request was saved.'); setSubject(''); setMessage('') } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not send support request.') } }
  return <><PageHeader eyebrow="HELP & SAFETY" title="Support when you need it" description="Practical guidance and clear limits for this wellness trial." /><Notice tone="warning">Serenity Hub does not provide emergency response, diagnosis or medical treatment. If someone is in immediate danger, contact an appropriate local emergency service or go to the nearest health facility.</Notice><div className="settings-grid"><Card><h2>Crisis contacts</h2>{loading ? <Loading /> : error ? <p>Support contacts are unavailable: {error}</p> : verified.length === 0 ? <p>No verified local contacts are available in this trial. We do not display placeholder numbers as real services.</p> : verified.map(contact => <p key={contact.id}><strong>{contact.service_name}</strong> · {contact.country_name}{contact.phone_number && <> · <a href={`tel:${contact.phone_number}`}>{contact.phone_number}</a></>}</p>)}</Card><Card><h2>About this trial</h2><p>{preview ? 'This is a synthetic demonstration. No support request is sent.' : 'This staging environment is for testing with isolated accounts and records.'}</p><p className="muted">Do not include urgent or highly sensitive information in a test support request.</p></Card></div>{!preview && <Card className="support-form"><h2>Contact test support</h2><form onSubmit={send}><Field id="support-subject" label="Subject" value={subject} onChange={event => setSubject(event.target.value)} required /><label className="field"><span>Message</span><textarea value={message} onChange={event => setMessage(event.target.value)} minLength={10} required /></label><Button type="submit">Send test request</Button></form>{feedback && <p role="status">{feedback}</p>}</Card>}</>
}
