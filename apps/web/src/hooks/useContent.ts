import { useEffect, useState } from 'react'
import { api, mode } from '../lib/api'
import { useAuth } from '../auth/AuthContext'

export function useContent<T>(path: string, demo: T) {
  const { guest } = useAuth()
  const [data, setData] = useState<T>(mode === 'demo' ? demo : demo)
  const [loading, setLoading] = useState(mode === 'staging')
  const [error, setError] = useState<string | null>(null)
  const [revision, setRevision] = useState(0)
  useEffect(() => {
    if (mode === 'demo' || guest) { setData(demo); setLoading(false); setError(null); return }
    let live = true
    setLoading(true)
    api<T>(path).then(result => { if (live) { setData(result.data); setError(null) } })
      .catch((cause: unknown) => { if (live) setError(cause instanceof Error ? cause.message : 'Could not load this content.') })
      .finally(() => { if (live) setLoading(false) })
    return () => { live = false }
  }, [path, revision, guest, demo])
  return { data, loading, error, retry: () => setRevision(value => value + 1) }
}
