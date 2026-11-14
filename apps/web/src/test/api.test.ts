import { afterEach, describe, expect, it, vi } from 'vitest'

afterEach(() => { vi.unstubAllEnvs(); vi.unstubAllGlobals(); vi.resetModules() })

describe('typed API boundary', () => {
  it('refuses all backend operations in demo', async () => {
    vi.stubEnv('VITE_TRIAL_MODE', 'demo')
    const { api } = await import('../lib/api')
    await expect(api('/mood-checkins', { method: 'POST', body: { mood_score: 3 } })).rejects.toThrow(/demo does not connect/i)
  })

  it('uses a same-origin session cookie and CSRF header in staging', async () => {
    vi.stubEnv('VITE_TRIAL_MODE', 'staging')
    const fetchMock = vi.fn()
      .mockResolvedValueOnce({ ok: true, json: async () => ({ csrf_token: 'csrf-test' }) })
      .mockResolvedValueOnce({ ok: true, json: async () => ({ success: true, data: { id: 1 } }) })
    vi.stubGlobal('fetch', fetchMock)
    const { api } = await import('../lib/api')
    await api('/mood-checkins', { method: 'POST', body: { mood_score: 3 } })
    expect(fetchMock).toHaveBeenCalledTimes(2)
    expect(fetchMock.mock.calls[1][0]).toBe('/api/v1/mood-checkins')
    expect(fetchMock.mock.calls[1][1]).toMatchObject({ credentials: 'same-origin', headers: expect.objectContaining({ 'X-CSRF-TOKEN': 'csrf-test' }) })
    expect(fetchMock.mock.calls[1][1].headers.Authorization).toBeUndefined()
  })

  it('surfaces API failures instead of fabricating success', async () => {
    vi.stubEnv('VITE_TRIAL_MODE', 'staging')
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: false, status: 503, json: async () => ({ message: 'Service unavailable' }) }))
    const { api } = await import('../lib/api')
    await expect(api('/therapists')).rejects.toThrow('Service unavailable')
  })
})
