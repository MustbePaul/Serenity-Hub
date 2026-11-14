import { createContext, useContext, useEffect, useMemo, useState } from 'react'
import type { ReactNode } from 'react'
import { browserAuth, browserMe, clearSessionMemory, mode } from '../lib/api'
import type { User } from '../lib/types'

type AuthState = { user: User | null; guest: boolean; loading: boolean; error: string | null; enterDemo: () => void; login: (email: string, password: string) => Promise<void>; register: (name: string, email: string, password: string) => Promise<void>; logout: () => Promise<void>; updateUser: (user: User) => void }
const AuthContext = createContext<AuthState | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [guest, setGuest] = useState(false)
  const [loading, setLoading] = useState(mode === 'staging')
  const [error, setError] = useState<string | null>(null)
  useEffect(() => {
    if (mode === 'staging') browserMe().then(setUser).catch(() => setError('Could not check your session. Please retry.')).finally(() => setLoading(false))
  }, [])
  const value = useMemo<AuthState>(() => ({
    user, guest, loading, error,
    enterDemo: () => { setUser(null); setGuest(true); setError(null); clearSessionMemory() },
    login: async (email, password) => { const result = await browserAuth('login', { email, password }); setGuest(false); setUser(result.user || null); setError(null) },
    register: async (name, email, password) => { const result = await browserAuth('register', { name, email, password, privacy_consent: true }); setGuest(false); setUser(result.user || null); setError(null) },
    logout: async () => { if (user) await browserAuth('logout'); clearSessionMemory(); setUser(null); setGuest(false) },
    updateUser: setUser,
  }), [user, guest, loading, error])
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('AuthProvider is missing')
  return context
}
