import { BookOpen, CalendarDays, CircleHelp, HeartHandshake, Home, Menu, MessagesSquare, Settings, Sparkles, UserRound, X } from 'lucide-react'
import { useState } from 'react'
import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { mode } from '../lib/api'

const primary = [
  { to: '/app', label: 'Home', icon: Home, end: true },
  { to: '/app/library', label: 'Library', icon: BookOpen },
  { to: '/app/sessions', label: 'Sessions', icon: Sparkles },
  { to: '/app/care', label: 'Care', icon: HeartHandshake },
  { to: '/app/circle', label: 'Serenity Circle', icon: MessagesSquare },
]
const secondary = [
  { to: '/app/appointments', label: 'Appointments', icon: CalendarDays },
  { to: '/app/profile', label: 'Profile', icon: UserRound },
  { to: '/app/settings', label: 'Settings', icon: Settings },
  { to: '/app/help', label: 'Help & safety', icon: CircleHelp },
]

export function Layout() {
  const [open, setOpen] = useState(false)
  const location = useLocation()
  const { user, guest } = useAuth()
  const links = (items: typeof primary) => items.map(({ to, label, icon: Icon, end }) => <NavLink key={to} to={to} end={end} onClick={() => setOpen(false)} className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}><Icon size={19} aria-hidden="true" /><span>{label}</span></NavLink>)
  return <div className="app-frame">
    {open && <button className="nav-scrim" aria-label="Close navigation" onClick={() => setOpen(false)} />}
    <aside className={`sidebar ${open ? 'open' : ''}`} aria-label="Main navigation">
      <div className="sidebar-top"><NavLink to="/app" className="brand" onClick={() => setOpen(false)}><span className="brand-mark">✦</span><span>serenity<span className="brand-light">hub</span></span></NavLink><button className="icon-button close-nav" aria-label="Close navigation" onClick={() => setOpen(false)}><X size={20} /></button></div>
      <div className="sidebar-label">YOUR SPACE</div><nav aria-label="Main navigation">{links(primary)}</nav>
      <div className="sidebar-label secondary-label">ACCOUNT & SUPPORT</div><nav aria-label="Account navigation">{links(secondary)}</nav>
      <div className="sidebar-bottom"><span className="small-dot" /> {mode === 'demo' || guest ? 'Synthetic demo' : 'Staging trial'}<p>Wellness support, at your pace.</p></div>
    </aside>
    <div className="app-main">
      <header className="topbar"><button className="icon-button mobile-menu" aria-label="Open navigation" onClick={() => setOpen(true)}><Menu size={22} /></button><span className="topbar-route">{location.pathname === '/app' ? 'Your space' : location.pathname.split('/').pop()?.replace('-', ' ')}</span><div className="topbar-right"><span className="mode-pill">{mode === 'demo' || guest ? 'DEMO' : 'STAGING'}</span><NavLink className="avatar" to="/app/profile" aria-label="Open profile">{user?.name?.charAt(0).toUpperCase() || 'G'}</NavLink></div></header>
      <main id="main-content" className="page-content"><Outlet /></main>
    </div>
    <nav className="bottom-nav" aria-label="Mobile navigation">{primary.slice(0, 4).map(({ to, label, icon: Icon, end }) => <NavLink key={to} to={to} end={end} className={({ isActive }) => isActive ? 'active' : ''}><Icon size={20} aria-hidden="true" /><span>{label}</span></NavLink>)}</nav>
  </div>
}
