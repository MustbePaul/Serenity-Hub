import { BrowserRouter, Navigate, Route, Routes, useLocation } from 'react-router-dom'
import { AuthProvider, useAuth } from './auth/AuthContext'
import { Layout } from './components/Layout'
import { Loading } from './components/ui'
import { mode } from './lib/api'
import { AuthPage } from './pages/AuthPages'
import { Care, Appointments } from './pages/Care'
import { Circle } from './pages/Circle'
import { Dashboard } from './pages/Dashboard'
import { Library } from './pages/Library'
import { Profile, Settings, Help } from './pages/Account'
import { Sessions } from './pages/Sessions'
import { Welcome } from './pages/Welcome'

function Protected({ children }: { children: React.ReactNode }) {
  const { user, guest, loading, error } = useAuth()
  const location = useLocation()
  if (loading) return <div className="route-loading"><Loading /></div>
  if (error && mode === 'staging') return <div className="route-loading" role="alert">{error} <a href="/">Return to welcome</a></div>
  if (!user && !guest) return <Navigate to="/" state={{ from: location.pathname }} replace />
  return children
}

export function App() {
  return <BrowserRouter><AuthProvider><a className="skip-link" href="#main-content">Skip to content</a><Routes>
    <Route path="/" element={<Welcome />} />
    <Route path="/login" element={<AuthPage kind="login" />} />
    <Route path="/register" element={<AuthPage kind="register" />} />
    <Route path="/app" element={<Protected><Layout /></Protected>}>
      <Route index element={<Dashboard />} />
      <Route path="library" element={<Library />} /><Route path="library/:kind/:id" element={<Library />} />
      <Route path="sessions" element={<Sessions />} /><Route path="sessions/:id" element={<Sessions />} />
      <Route path="care" element={<Care />} /><Route path="appointments" element={<Appointments />} />
      <Route path="circle" element={<Circle />} />
      <Route path="profile" element={<Profile />} /><Route path="settings" element={<Settings />} /><Route path="help" element={<Help />} />
    </Route><Route path="*" element={<Navigate to="/" replace />} />
  </Routes></AuthProvider></BrowserRouter>
}
