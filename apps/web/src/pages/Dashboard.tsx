import { ArrowRight, BookOpen, HeartHandshake, MessagesSquare, Sparkles } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { Button, Card, Loading, Notice, PageHeader } from '../components/ui'
import { useContent } from '../hooks/useContent'
import { api, mode } from '../lib/api'
import { demoHome } from '../lib/demo'
import type { Home } from '../lib/types'
import { useState } from 'react'

const moods = [{ score: 1, label: 'Very low' }, { score: 2, label: 'Low' }, { score: 3, label: 'Okay' }, { score: 4, label: 'Good' }, { score: 5, label: 'Very good' }]
export function Dashboard() {
  const { user, guest } = useAuth()
  const { data, loading, error, retry } = useContent<Home>('/home', demoHome)
  const [mood, setMood] = useState<number | null>(null)
  const [saved, setSaved] = useState('')
  const [saving, setSaving] = useState(false)
  async function saveMood() {
    if (!mood) return
    if (mode === 'demo' || guest) { setSaved('Demo check-in selected. Nothing was saved to an account.'); return }
    setSaving(true); setSaved('')
    try { await api('/mood-checkins', { method: 'POST', body: { mood_score: mood } }); setSaved('Your check-in was saved.'); retry() }
    catch (cause) { setSaved(cause instanceof Error ? cause.message : 'Could not save your check-in.') }
    finally { setSaving(false) }
  }
  return <><PageHeader eyebrow="A MOMENT FOR YOU" title={user ? `Hello, ${user.name.split(' ')[0]}.` : 'Welcome to your space.'} description="Take the next step at your own pace." />
    {(mode === 'demo' || guest) && <Notice>Demo preview · Content is synthetic. Check-ins and progress are not stored.</Notice>}
    {error && <Notice tone="error">Home data is unavailable: {error} <button className="inline-action" onClick={retry}>Retry</button></Notice>}
    {loading ? <Loading /> : <div className="dashboard-grid"><Card className="mood-card"><div className="section-top"><span className="eyebrow">TODAY'S CHECK-IN</span><span className="subtle">01</span></div><h2>How are you feeling?</h2><p className="muted">There is no right answer. Choose what fits this moment.</p><div className="mood-options" role="group" aria-label="Choose your mood">{moods.map(item => <button key={item.score} className={`mood-option ${mood === item.score ? 'selected' : ''}`} aria-label={item.label} aria-pressed={mood === item.score} onClick={() => setMood(item.score)}><span className="mood-dot">{['◔','◕','●','✦','☀'][item.score - 1]}</span><span>{item.label}</span></button>)}</div><div className="card-footer"><Button onClick={saveMood} disabled={!mood || saving}>{saving ? 'Saving…' : mode === 'demo' || guest ? 'Preview check-in' : 'Save check-in'}</Button>{data.latest_mood && <span className="muted">Last: {data.latest_mood.label}</span>}</div>{saved && <p role="status" className="action-feedback">{saved}</p>}</Card>
      <Card className="affirmation-card"><span className="eyebrow">A THOUGHT FOR TODAY</span><div className="quote-mark">“</div><blockquote>{data.affirmation?.text || data.quote?.text || 'A quiet moment can be a good place to start.'}</blockquote><span className="muted">{data.quote?.author || 'Serenity Hub'}</span></Card>
      <Card className="feature-card"><span className="icon-circle"><Sparkles size={23} /></span><h2>Continue with a short session</h2><p className="muted">Try a guided breathing or grounding exercise when you have a few minutes.</p><Link className="arrow-link" to="/app/sessions">Explore sessions <ArrowRight size={17} /></Link></Card>
      <Card className="feature-card"><span className="icon-circle"><BookOpen size={23} /></span><h2>Explore the library</h2><p className="muted">Browse practical articles and available audio or video resources.</p><Link className="arrow-link" to="/app/library">Open library <ArrowRight size={17} /></Link></Card></div>}
    <section className="home-shortcuts"><Link to="/app/circle"><MessagesSquare size={22} /><span><strong>Serenity Circle</strong><small>A moderated space for peer support</small></span><ArrowRight size={18} /></Link><Link to="/app/care"><HeartHandshake size={22} /><span><strong>Access to care</strong><small>Browse the directory and appointment options</small></span><ArrowRight size={18} /></Link></section>
  </>
}
