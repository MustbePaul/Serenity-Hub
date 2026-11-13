import { ArrowLeft, ArrowRight, BookOpen, Clock3, Wind } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { Button, Card, Empty, Loading, Notice, PageHeader } from '../components/ui'
import { useContent } from '../hooks/useContent'
import { mode } from '../lib/api'
import { demoSessions } from '../lib/demo'
import type { Session } from '../lib/types'

function SessionExercise({ session }: { session: Session }) {
  const [running, setRunning] = useState(false)
  const [remaining, setRemaining] = useState(session.estimated_duration_seconds || 180)
  useEffect(() => { if (!running || remaining <= 0) return; const timer = window.setInterval(() => setRemaining(value => Math.max(value - 1, 0)), 1000); return () => window.clearInterval(timer) }, [running, remaining])
  const breathing = session.session_type === 'breathing' || session.category === 'breathing'
  return <Card className="exercise-card"><span className="eyebrow">{breathing ? 'BREATHING EXERCISE' : 'GUIDED READING'}</span><h2>{running ? remaining > 0 ? 'Take this moment at your own pace' : 'Session complete' : 'Ready when you are'}</h2><p>{session.instructions || session.transcript || 'Choose a comfortable position and begin when ready.'}</p>{breathing && <div className="breath-pattern"><span>Inhale {session.inhale_seconds || 4}s</span><span>Hold {session.hold_seconds || 0}s</span><span>Exhale {session.exhale_seconds || 6}s</span></div>}<p className="timer" aria-live="off">{Math.floor(remaining / 60)}:{String(remaining % 60).padStart(2, '0')}</p><div className="exercise-actions"><Button onClick={() => setRunning(value => !value)} disabled={remaining === 0}>{running ? 'Pause' : 'Start session'}</Button><Button variant="secondary" onClick={() => { setRunning(false); setRemaining(session.estimated_duration_seconds || 180) }}>Reset</Button></div><p className="muted small">Stop whenever the exercise does not feel helpful. The timer is local to this browser tab.</p></Card>
}
export function Sessions() {
  const { guest } = useAuth()
  const { id } = useParams()
  const [filter, setFilter] = useState('all')
  const { data, loading, error, retry } = useContent<Session[]>('/wellness-sessions', demoSessions)
  if (id) { const session = data.find(item => item.id === Number(id)); return <div className="detail-page"><Link className="back-link" to="/app/sessions"><ArrowLeft size={17} /> Back to sessions</Link>{loading ? <Loading /> : session ? <><span className="eyebrow">{session.category.toUpperCase()} · {Math.ceil((session.estimated_duration_seconds || 0) / 60)} MIN</span><h1>{session.title}</h1><p className="lead muted">{session.description}</p><SessionExercise key={session.id} session={session} /></> : <Empty title="Session unavailable">Choose another session from the list.</Empty>}</div> }
  const categories = ['all', ...new Set(data.map(item => item.category))]
  const visible = data.filter(item => filter === 'all' || item.category === filter)
  return <><PageHeader eyebrow="A PAUSE FOR YOUR DAY" title="Guided sessions" description="Short exercises and reflections you can start and stop whenever you like." />{(mode === 'demo' || guest) && <Notice>Demo sessions are synthetic. Timer progress is local and is not saved to an account.</Notice>}{error && <Notice tone="error">Sessions could not load: {error} <button className="inline-action" onClick={retry}>Retry</button></Notice>}<div className="filters" role="group" aria-label="Session category">{categories.map(value => <button key={value} className={filter === value ? 'selected' : ''} aria-pressed={filter === value} onClick={() => setFilter(value)}>{value === 'all' ? 'All sessions' : value}</button>)}</div>{loading ? <Loading /> : visible.length === 0 ? <Empty title="No sessions available">Try another category.</Empty> : <div className="session-list">{visible.map(item => <Link className="session-row" to={`/app/sessions/${item.id}`} key={item.id}><span className="session-icon">{item.session_type === 'breathing' || item.category === 'breathing' ? <Wind size={25} /> : <BookOpen size={25} />}</span><span className="session-main"><span className="eyebrow">{item.category.toUpperCase()} {item.is_featured && '· FEATURED'}</span><strong>{item.title}</strong><small>{item.description}</small></span><span className="session-duration"><Clock3 size={15} /> {Math.ceil((item.estimated_duration_seconds || 0) / 60)} min</span><ArrowRight size={18} /></Link>)}</div>}</>
}
