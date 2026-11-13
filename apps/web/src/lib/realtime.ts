import { broadcastAuth } from './api'

// Reverb uses the Pusher wire protocol. HTTP remains authoritative; events only trigger refetches.
export function subscribeRoom(slug: string, onChange: () => void, onStatus: (status: string) => void): () => void {
  const origin = import.meta.env.VITE_REVERB_URL as string | undefined
  const key = import.meta.env.VITE_REVERB_APP_KEY as string | undefined
  if (!origin || !key) { onStatus('Polling'); return () => {} }
  let closed = false
  let socket: WebSocket | null = null
  let retry: number | undefined
  let attempt = 0
  const channel = `private-community.room.${slug}`
  const connect = () => {
    if (closed) return
    try {
      socket = new WebSocket(`${origin.replace(/\/$/, '')}/app/${encodeURIComponent(key)}?protocol=7&client=serenity-web&version=1.0&flash=false`)
      socket.onopen = () => onStatus('Connecting')
      socket.onmessage = async event => {
        let packet: { event?: string; data?: unknown }
        try { packet = JSON.parse(String(event.data)) } catch { return }
        let data: Record<string, unknown> = {}
        try { data = typeof packet.data === 'string' ? JSON.parse(packet.data) : (packet.data || {}) as Record<string, unknown> } catch { return }
        if (packet.event === 'pusher:connection_established') {
          const socketId = String(data.socket_id || '')
          try {
            const auth = await broadcastAuth(socketId, channel)
            if (!closed && socket?.readyState === WebSocket.OPEN) socket.send(JSON.stringify({ event: 'pusher:subscribe', data: { channel, auth } }))
          } catch { socket?.close() }
        } else if (packet.event === 'pusher_internal:subscription_succeeded') { attempt = 0; onStatus('Live'); onChange() }
        else if (packet.event?.includes('CommunityMessage') || packet.event?.includes('CommunityReaction')) onChange()
      }
      socket.onclose = () => { if (closed) return; onStatus('Polling while reconnecting'); retry = window.setTimeout(connect, Math.min(2000 * 2 ** attempt++, 15000)) }
      socket.onerror = () => socket?.close()
    } catch { onStatus('Polling while reconnecting'); retry = window.setTimeout(connect, Math.min(2000 * 2 ** attempt++, 15000)) }
  }
  connect()
  return () => { closed = true; if (retry) window.clearTimeout(retry); socket?.close() }
}
