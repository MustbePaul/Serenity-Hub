import { ArrowLeft, ArrowRight, BookOpen, Headphones, Play, Search, Video } from 'lucide-react'
import { useMemo, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'
import { Empty, Loading, Notice, PageHeader } from '../components/ui'
import { useContent } from '../hooks/useContent'
import { mode } from '../lib/api'
import { demoMedia, demoResources } from '../lib/demo'
import type { Media, Resource } from '../lib/types'

type LibraryItem = { kind: 'article' | 'audio' | 'video'; id: number; title: string; summary: string; category: string; media?: Media; resource?: Resource }
export function Library() {
  const { guest } = useAuth()
  const { kind, id } = useParams()
  const [query, setQuery] = useState('')
  const [filter, setFilter] = useState('all')
  const { data: resources, loading: loadingResources, error: resourceError, retry: retryResources } = useContent<Resource[]>('/resources', demoResources)
  const { data: media, loading: loadingMedia, error: mediaError, retry: retryMedia } = useContent<Media[]>('/media', demoMedia)
  const items = useMemo<LibraryItem[]>(() => [
    ...resources.map(resource => ({ kind: 'article' as const, id: resource.id, title: resource.title, summary: resource.summary, category: resource.category?.name || 'Article', resource })),
    ...media.filter(item => item.media_type === 'audio' || item.media_type === 'video').map(item => ({ kind: item.media_type as 'audio' | 'video', id: item.id, title: item.title, summary: item.description || '', category: item.media_type === 'audio' ? 'Audio' : 'Video', media: item })),
  ], [resources, media])
  const visible = items.filter(item => (filter === 'all' || item.kind === filter) && `${item.title} ${item.summary} ${item.category}`.toLowerCase().includes(query.toLowerCase()))
  const selected = items.find(item => item.kind === kind && item.id === Number(id))
  const loading = loadingResources || loadingMedia
  if (kind && id) return <div className="detail-page"><Link className="back-link" to="/app/library"><ArrowLeft size={17} /> Back to library</Link>{loading ? <Loading /> : selected ? <><span className="eyebrow">{selected.category.toUpperCase()} · {selected.kind.toUpperCase()}</span><h1>{selected.title}</h1><p className="lead muted">{selected.summary}</p><div className="detail-body">{selected.resource?.body ? selected.resource.body.split('\n').map((paragraph, index) => <p key={index}>{paragraph}</p>) : selected.media ? <>{selected.media.file_url ? selected.kind === 'audio' ? <audio controls src={selected.media.file_url} preload="none">Your browser cannot play this audio.</audio> : <video controls src={selected.media.file_url} poster={selected.media.thumbnail_url || undefined} preload="metadata">Your browser cannot play this video.</video> : <Notice>Playback is unavailable in this preview. No licensed audio source is configured.</Notice>}{selected.media.transcript && <details><summary>Transcript</summary><p>{selected.media.transcript}</p></details>}</> : null}</div></> : <Empty title="Resource unavailable">This item may have been removed. Return to the library.</Empty>}</div>
  return <><PageHeader eyebrow="EXPLORE AT YOUR PACE" title="Wellness library" description="Practical reading, listening and viewing for everyday wellbeing." />{(mode === 'demo' || guest) && <Notice>Demo library · Articles are synthetic. The video is a CC0 demonstration; audio without a licensed source is labelled unavailable.</Notice>}{(resourceError || mediaError) && <Notice tone="error">Some resources could not load. {resourceError || mediaError} <button className="inline-action" onClick={() => { retryResources(); retryMedia() }}>Retry</button></Notice>}
    <div className="library-tools"><label className="search-box"><Search size={18} aria-hidden="true" /><span className="sr-only">Search resources</span><input value={query} onChange={event => setQuery(event.target.value)} placeholder="Search resources" /></label><div className="filters" role="group" aria-label="Resource type">{['all', 'article', 'audio', 'video'].map(value => <button key={value} className={filter === value ? 'selected' : ''} aria-pressed={filter === value} onClick={() => setFilter(value)}>{value === 'all' ? 'All resources' : value[0].toUpperCase() + value.slice(1)}</button>)}</div></div>
    {loading ? <Loading /> : visible.length === 0 ? <Empty title="Nothing here yet">Try another search or type. Resources will appear when they are available.</Empty> : <div className="resource-grid">{visible.map(item => <Link key={`${item.kind}-${item.id}`} className="resource-card" to={`/app/library/${item.kind}/${item.id}`}><div className={`resource-art art-${item.kind}`}>{item.kind === 'article' ? <BookOpen size={34} /> : item.kind === 'audio' ? <Headphones size={34} /> : <Video size={34} />}</div><div className="resource-content"><span className="eyebrow">{item.category.toUpperCase()}</span><h2>{item.title}</h2><p className="muted">{item.summary}</p><span className="arrow-link">{item.kind === 'article' ? 'Read article' : item.kind === 'audio' ? 'Listen' : 'Watch'} {item.kind === 'article' ? <ArrowRight size={16} /> : <Play size={16} />}</span></div></Link>)}</div>}
  </>
}
