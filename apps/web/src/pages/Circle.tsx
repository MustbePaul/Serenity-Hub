import { Flag, Heart, MessageCircle, Shield, UserX } from 'lucide-react'
import { FormEvent, useCallback, useEffect, useState } from 'react'
import { useAuth } from '../auth/AuthContext'
import { Button, Card, Empty, Loading, Notice, PageHeader } from '../components/ui'
import { api, mode } from '../lib/api'
import { demoRooms } from '../lib/demo'
import { subscribeRoom } from '../lib/realtime'
import type { CircleMessage, CirclePostResult, CircleRoom } from '../lib/types'

const reasons = ['harassment', 'bullying', 'hate', 'spam', 'self_harm_concern', 'privacy_or_personal_information', 'misinformation_or_harmful_advice', 'other']
export function Circle() {
  const { guest } = useAuth()
  const preview = mode === 'demo' || guest
  const [rooms, setRooms] = useState<CircleRoom[]>(preview ? demoRooms : [])
  const [room, setRoom] = useState<CircleRoom | null>(null)
  const [messages, setMessages] = useState<CircleMessage[]>([])
  const [replies, setReplies] = useState<Record<number, CircleMessage[]>>({})
  const [body, setBody] = useState('')
  const [replyBody, setReplyBody] = useState<Record<number, string>>({})
  const [openReplies, setOpenReplies] = useState<number | null>(null)
  const [status, setStatus] = useState('Polling')
  const [error, setError] = useState('')
  const [feedback, setFeedback] = useState('')
  const [loading, setLoading] = useState(!preview)
  const [busy, setBusy] = useState(false)
  useEffect(() => { if (preview) { setRooms(demoRooms); setLoading(false); return } let active = true; api<CircleRoom[]>('/community/rooms').then(result => { if (active) setRooms(result.data) }).catch(cause => { if (active) setError(String(cause.message)) }).finally(() => { if (active) setLoading(false) }); return () => { active = false } }, [preview])
  const refresh = useCallback(async (slug: string, silent = false) => {
    if (preview) return
    try { const result = await api<CircleMessage[]>(`/community/rooms/${encodeURIComponent(slug)}/messages`); setMessages(result.data); if (!silent) setError('') }
    catch (cause) { if (!silent) setError(cause instanceof Error ? cause.message : 'Could not load messages.') }
  }, [preview])
  useEffect(() => {
    if (!room || preview) return
    const slug = room.slug
    void refresh(slug)
    const timer = window.setInterval(() => { void refresh(slug, true) }, 15000)
    const stop = subscribeRoom(slug, () => { void refresh(slug, true) }, setStatus)
    return () => { window.clearInterval(timer); stop() }
  }, [room, preview, refresh])
  async function submit(event: FormEvent) { event.preventDefault(); if (!room || preview || !body.trim()) return; setBusy(true); setFeedback(''); try { const result = await api<CirclePostResult>(`/community/rooms/${room.slug}/messages`, { method: 'POST', body: { body: body.trim() } }); setBody(''); setFeedback(result.data.safety?.supportive_notice || (result.data.safety?.requires_review ? 'Your post is under review.' : 'Posted to the room.')); await refresh(room.slug) } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not post.') } finally { setBusy(false) } }
  async function loadReplies(id: number) { if (preview) return; try { const result = await api<CircleMessage[]>(`/community/messages/${id}/replies`); setReplies(current => ({ ...current, [id]: result.data })); setOpenReplies(openReplies === id ? null : id) } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not load replies.') } }
  async function sendReply(id: number) { const text = replyBody[id]?.trim(); if (!text || preview) return; try { await api(`/community/messages/${id}/replies`, { method: 'POST', body: { body: text } }); setReplyBody(current => ({ ...current, [id]: '' })); const result = await api<CircleMessage[]>(`/community/messages/${id}/replies`); setReplies(current => ({ ...current, [id]: result.data })); if (room) await refresh(room.slug) } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not reply.') } }
  async function react(message: CircleMessage) { if (preview) return; try { if (message.my_reactions.includes('support')) await api(`/community/messages/${message.id}/reactions/support`, { method: 'DELETE' }); else await api(`/community/messages/${message.id}/reactions`, { method: 'POST', body: { reaction: 'support' } }); if (room) await refresh(room.slug) } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not react.') } }
  async function report(id: number) { if (preview) return; const reason = window.prompt(`Report reason: ${reasons.join(', ')}`, 'other'); if (!reason) return; if (!reasons.includes(reason)) { setFeedback('Choose a listed report reason.'); return } try { await api(`/community/messages/${id}/report`, { method: 'POST', body: { reason } }); setFeedback('Report sent to moderators.') } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not report.') } }
  async function block(code: string) { if (preview || !window.confirm('Block this anonymous identity?')) return; try { await api(`/community/identities/${encodeURIComponent(code)}/block`, { method: 'POST' }); if (room) await refresh(room.slug); setFeedback('Identity blocked.') } catch (cause) { setFeedback(cause instanceof Error ? cause.message : 'Could not block identity.') } }
  return <><PageHeader eyebrow="PEER SUPPORT" title="Serenity Circle" description="A moderated space to share and listen with an anonymous community identity." />{preview ? <Notice>Demo preview · Rooms are synthetic. Posting, reporting and account identities are unavailable.</Notice> : <Notice><Shield size={18} /> Your account name is not shown in room posts. Moderators can review reports; avoid sharing private details.</Notice>}{error && <Notice tone="error">{error}</Notice>}{feedback && <Notice>{feedback}</Notice>}{loading ? <Loading /> : <div className="circle-layout"><aside className="room-list"><h2>Rooms</h2>{rooms.map(item => <button key={item.id} className={room?.id === item.id ? 'selected' : ''} onClick={() => { setRoom(item); setMessages([]); setOpenReplies(null) }}><strong>{item.name}</strong><small>{item.description}</small></button>)}</aside><section className="message-panel">{!room ? <Empty title="Choose a room">Find a space that feels right for you.</Empty> : <><header className="message-header"><div><h2>{room.name}</h2><p className="muted">{room.description}</p></div><span className="status-pill">{preview ? 'Preview' : status}</span></header>{preview ? <Empty title="A preview of the space">There are no real posts in demo. Sign in to an isolated staging account to test the community workflow.</Empty> : <><div className="message-list">{messages.length === 0 ? <Empty title="No posts yet">Start a supportive conversation if you wish.</Empty> : messages.map(message => <Card key={message.id} className="message-card"><div className="message-author"><span className="anonymous-avatar">✦</span><strong>{message.anonymous_identity.display_name}</strong><time>{new Date(message.created_at).toLocaleString()}</time></div><p>{message.body || 'This post is unavailable.'}</p><div className="message-actions"><button aria-pressed={message.my_reactions.includes('support')} onClick={() => react(message)}><Heart size={15} /> Support {message.reactions.support || 0}</button><button onClick={() => loadReplies(message.id)}><MessageCircle size={15} /> Replies {message.reply_count}</button>{!message.is_mine && <><button onClick={() => report(message.id)}><Flag size={15} /> Report</button><button onClick={() => block(message.anonymous_identity.id)}><UserX size={15} /> Block</button></>}</div>{openReplies === message.id && <div className="reply-list">{(replies[message.id] || []).map(reply => <p key={reply.id}><strong>{reply.anonymous_identity.display_name}</strong> {reply.body}</p>)}<label className="field"><span>Write a supportive reply</span><textarea value={replyBody[message.id] || ''} onChange={event => setReplyBody(current => ({ ...current, [message.id]: event.target.value }))} maxLength={2000} /></label><Button variant="secondary" disabled={!replyBody[message.id]?.trim()} onClick={() => sendReply(message.id)}>Reply</Button></div>}</Card>)}</div><form className="composer" onSubmit={submit}><label className="field"><span>Write to {room.name}</span><textarea value={body} onChange={event => setBody(event.target.value)} maxLength={2000} placeholder="Share with care. Avoid personal information." /></label><Button type="submit" disabled={!body.trim() || busy}>{busy ? 'Posting…' : 'Post to room'}</Button></form></>}</>}</section></div>}</>
}
