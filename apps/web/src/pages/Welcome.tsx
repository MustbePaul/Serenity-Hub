import { ArrowRight, HeartHandshake, Leaf, ShieldCheck } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { mode } from '../lib/api'
import { Button, Notice } from '../components/ui'

export function Welcome() {
  const { enterDemo } = useAuth()
  const navigate = useNavigate()
  const preview = () => { enterDemo(); navigate('/app') }
  return <div className="welcome-shell">
    <header className="welcome-nav"><Link className="brand" to="/"><span className="brand-mark">✦</span><span>serenity<span className="brand-light">hub</span></span></Link><span className="mode-pill">WEB TRIAL · {mode.toUpperCase()}</span></header>
    <main className="welcome-main" id="main-content">
      <div className="welcome-copy"><span className="eyebrow"><Leaf size={15} /> A GENTLER SPACE FOR EVERYDAY WELLNESS</span><h1>Make room for<br/><em>your wellbeing.</em></h1><p className="welcome-lead">A calm place to check in with yourself, explore practical resources, and find a path toward professional support.</p>
        <div className="welcome-actions"><Button onClick={preview}>Review as guest <ArrowRight size={17} /></Button>{mode === 'staging' && <><Link className="button button-secondary" to="/register">Create an account</Link><Link className="text-link" to="/login">Already have an account? Sign in</Link></>}</div>
        {mode === 'demo' && <p className="demo-caption">This preview uses synthetic content. It does not create an account, book care or store personal records.</p>}
      </div>
      <div className="welcome-panel" aria-label="What you can explore"><div className="welcome-panel-top"><span>YOUR SPACE, YOUR PACE</span><span>01 / 03</span></div><div className="welcome-panel-content"><div className="panel-orb"><HeartHandshake size={42} strokeWidth={1.4} /></div><h2>Begin with a moment of calm.</h2><p>Check in with how you feel, then choose a resource or short guided session that fits your day.</p><div className="panel-lines"><span>Daily check-in</span><span>Wellness library</span><span>Guided sessions</span></div></div></div>
    </main>
    <footer className="welcome-footer"><Notice><ShieldCheck size={18} aria-hidden="true" /> Serenity Hub supports wellness and access to care. It does not provide diagnosis, treatment or emergency response. If someone is in immediate danger, contact an appropriate local emergency service or nearest health facility.</Notice></footer>
  </div>
}
