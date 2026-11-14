import type { ApiEnvelope, User } from './types'

export const mode = import.meta.env.VITE_TRIAL_MODE === 'staging' ? 'staging' : 'demo'
let csrfToken: string | null = null

export class ApiError extends Error {
  constructor(message: string, public status: number) { super(message); this.name = 'ApiError' }
}

async function readError(response: Response): Promise<never> {
  const body = await response.json().catch(() => ({})) as { message?: string; errors?: Record<string, string[]> }
  const first = body.errors && Object.values(body.errors).flat()[0]
  throw new ApiError(first || body.message || `Request failed (${response.status})`, response.status)
}

export async function ensureCsrf(): Promise<string> {
  if (csrfToken) return csrfToken
  const response = await fetch('/web/csrf', { credentials: 'same-origin', headers: { Accept: 'application/json' } })
  if (!response.ok) return readError(response)
  const body = await response.json() as { csrf_token: string }
  csrfToken = body.csrf_token
  return csrfToken
}

export async function browserAuth(path: 'login' | 'register' | 'logout', payload: object = {}): Promise<{ user?: User }> {
  if (mode === 'demo') throw new ApiError('Accounts are unavailable in the synthetic demo.', 403)
  const token = await ensureCsrf()
  const response = await fetch(`/web/${path}`, {
    method: 'POST', credentials: 'same-origin',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': token },
    body: JSON.stringify(payload),
  })
  if (!response.ok) return readError(response)
  csrfToken = null // Laravel rotates the session on login, registration and logout.
  return response.json()
}

export async function browserMe(): Promise<User | null> {
  if (mode === 'demo') return null
  const response = await fetch('/web/me', { credentials: 'same-origin', headers: { Accept: 'application/json' } })
  if (response.status === 401) return null
  if (!response.ok) return readError(response)
  return (await response.json() as { user: User }).user
}

export async function api<T>(path: string, options: { method?: 'GET' | 'POST' | 'PATCH' | 'DELETE'; body?: object } = {}): Promise<ApiEnvelope<T>> {
  if (mode === 'demo') throw new ApiError('The demo does not connect to personal records.', 403)
  const method = options.method || 'GET'
  const headers: Record<string, string> = { Accept: 'application/json' }
  if (method !== 'GET') {
    headers['Content-Type'] = 'application/json'
    headers['X-CSRF-TOKEN'] = await ensureCsrf()
  }
  const response = await fetch(`/api/v1${path}`, {
    method, credentials: 'same-origin', headers,
    body: options.body ? JSON.stringify(options.body) : undefined,
  })
  if (!response.ok) return readError(response)
  return response.json() as Promise<ApiEnvelope<T>>
}

export async function broadcastAuth(socketId: string, channelName: string): Promise<string> {
  const token = await ensureCsrf()
  const response = await fetch('/api/v1/community/broadcasting/auth', {
    method: 'POST', credentials: 'same-origin',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json', 'X-CSRF-TOKEN': token },
    body: JSON.stringify({ socket_id: socketId, channel_name: channelName }),
  })
  if (!response.ok) return readError(response)
  return (await response.json() as { auth: string }).auth
}

export function clearSessionMemory() { csrfToken = null }
