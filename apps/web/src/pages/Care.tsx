import { ArrowRight, CalendarDays, MapPin, ShieldAlert } from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { Button, Card, Empty, Loading, Notice, PageHeader } from '../components/ui'
import { useContent } from '../hooks/useContent'
import { api, mode } from '../lib/api'
import { demoTherapists } from '../lib/demo'
import type { Appointment, Slot, Therapist } from '../lib/types'

const emptyAppointments: Appointment[] = []

export function Care() {
  const { guest, user } = useAuth()
  const preview = mode === 'demo' || guest
  const { data, loading, error, retry } = useContent<Therapist[]>('/therapists', demoTherapists)
  const [selected, setSelected] = useState<Therapist | null>(null)
  const [slots, setSlots] = useState<Slot[]>([])
  const [slotId, setSlotId] = useState<number | null>(null)
  const [modeChoice, setModeChoice] = useState('online')
  const [busy, setBusy] = useState(false)
  const [feedback, setFeedback] = useState('')
  async function openBooking(therapist: Therapist) {
    setSelected(therapist); setSlots([]); setSlotId(null); setFeedback('')
    if (preview) return
    try { const response = await api<Slot[]>(`/therapists/${therapist.id}/availability`); setSlots(response.data) }
    catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Availability is unavailable.') }
  }
  async function book() {
    if (!selected || !slotId || preview || !user) return
    setBusy(true); setFeedback('')
    try { const result = await api<Appointment>('/appointments', { method: 'POST', body: { therapist_id: selected.id, availability_slot_id: slotId, mode: modeChoice } }); setFeedback(`Test appointment ${result.data.id} was saved. View it in Appointments.`); setSlots([]) }
    catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Booking failed.') }
    finally { setBusy(false) }
  }
  return <><PageHeader eyebrow="ACCESS TO CARE" title="Care directory" description="Explore care options and understand the steps before requesting a session." action={!preview ? <Link className="button button-secondary" to="/app/appointments">My appointments</Link> : undefined} />
    <Notice tone="warning"><ShieldAlert size={18} /> {preview ? 'Sample profiles are fictional and show no real credentials or availability. Booking previews do not create appointments.' : 'Staging directory and appointments are for testing. Provider credentials and availability require independent verification before public use.'}</Notice>
    {error && <Notice tone="error">The directory is unavailable: {error} <button className="inline-action" onClick={retry}>Retry</button></Notice>}
    {loading ? <Loading /> : data.length === 0 ? <Empty title="No care profiles available">The directory has no approved test profiles right now.</Empty> : <div className="care-grid">{data.map(therapist => <Card key={therapist.id} className="care-card"><div className="care-avatar"><span aria-hidden="true">✦</span></div><span className="eyebrow">{preview ? 'SAMPLE PROFILE · FICTIONAL' : 'STAGING TEST PROFILE'}</span><h2>{therapist.user?.name || 'Care profile'}</h2><p className="muted">{therapist.bio || 'Information has not been provided.'}</p><div className="care-meta"><span><MapPin size={15} /> {therapist.location || 'Location unavailable'}</span><span>{therapist.specialties?.map(item => item.name).join(', ') || 'Specialty information unavailable'}</span></div><Button variant="secondary" onClick={() => openBooking(therapist)}>{preview ? 'Preview booking flow' : 'Browse test availability'} <ArrowRight size={16} /></Button></Card>)}</div>}
    {selected && <div className="modal-backdrop" role="presentation" onMouseDown={event => { if (event.target === event.currentTarget) setSelected(null) }}><section className="dialog" role="dialog" aria-modal="true" aria-labelledby="booking-title"><button className="dialog-close" aria-label="Close booking" onClick={() => setSelected(null)}>×</button><span className="eyebrow">{preview ? 'NON-PERSISTING PREVIEW' : 'STAGING BOOKING'}</span><h2 id="booking-title">{preview ? 'How booking would work' : `Availability for ${selected.user?.name}`}</h2>{preview ? <><p>This fictional profile has no real appointment slots. In staging, an authenticated test user can choose an available slot and submit a booking to the Laravel API.</p><Notice>No appointment was created. No one will contact you from this preview.</Notice><Button onClick={() => setSelected(null)}>Close preview</Button></> : <>{slots.length === 0 && !feedback && <p>No test slots are currently available.</p>}{slots.length > 0 && <><label className="field"><span>Available test slot</span><select value={slotId || ''} onChange={event => setSlotId(Number(event.target.value))}><option value="">Choose a time</option>{slots.map(slot => <option key={slot.id} value={slot.id}>{new Date(slot.starts_at).toLocaleString()}</option>)}</select></label><label className="field"><span>Session mode</span><select value={modeChoice} onChange={event => setModeChoice(event.target.value)}>{(selected.session_modes || ['online']).map(value => <option key={value} value={value}>{value.replace('_', ' ')}</option>)}</select></label><Button onClick={book} disabled={!slotId || busy}>{busy ? 'Submitting…' : 'Book test appointment'}</Button></>}{feedback && <p role="status" className="action-feedback">{feedback}</p>}</>}</section></div>}
  </>
}

export function Appointments() {
  const { guest } = useAuth()
  const preview = mode === 'demo' || guest
  const { data, loading, error, retry } = useContent<Appointment[]>('/appointments', emptyAppointments)
  const [feedback, setFeedback] = useState('')
  async function cancel(id: number) {
    if (preview || !window.confirm('Cancel this test appointment?')) return
    try { await api(`/appointments/${id}/cancel`, { method: 'PATCH', body: {} }); setFeedback('Test appointment cancelled.'); retry() }
    catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not cancel the appointment.') }
  }
  return <><PageHeader eyebrow="YOUR CARE" title="Appointments" description="Review the status of your staging test appointments." />{preview && <Notice>Guest review has no appointment records. Use staging with a test account to exercise persisted booking.</Notice>}{error && <Notice tone="error">Appointments could not load: {error} <button className="inline-action" onClick={retry}>Retry</button></Notice>}{feedback && <Notice>{feedback}</Notice>}{loading ? <Loading /> : data.length === 0 ? <Empty title="No appointments yet">Browse the care directory to see how booking works.</Empty> : <div className="session-list">{data.map(item => <Card key={item.id} className="appointment-row"><CalendarDays size={22} /><div><strong>{item.therapist?.user?.name || 'Care appointment'}</strong><p>{new Date(item.scheduled_start).toLocaleString()} · {item.mode.replace('_', ' ')} · {item.status}</p></div>{!preview && ['confirmed', 'pending', 'rescheduled'].includes(item.status) && <Button variant="quiet" onClick={() => cancel(item.id)}>Cancel test booking</Button>}</Card>)}</div>}</>
}
