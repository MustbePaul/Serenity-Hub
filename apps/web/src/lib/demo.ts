import type { CircleRoom, Home, Media, Resource, Session, Therapist } from './types'

export const demoHome: Home = {
  quote: { text: 'You do not have to solve the whole day at once.', author: 'Serenity Hub demo' },
  affirmation: { text: 'I can take one steady breath and begin again.' },
  latest_mood: null,
  recommended_resource: null,
  upcoming_appointment: null,
}
export const demoResources: Resource[] = [
  { id: 1, title: 'A five-minute reset for a busy mind', slug: 'five-minute-reset', type: 'article', summary: 'A short grounding routine using breath, posture and attention.', body: 'Pause for a moment. Notice where your feet meet the floor. Relax your shoulders if that feels comfortable. Breathe at a pace that is easy for you, and name one thing you can see, hear and feel.', category: { name: 'Stress', slug: 'stress' }, tags: ['grounding'] },
  { id: 2, title: 'A softer evening routine', slug: 'softer-evening-routine', type: 'article', summary: 'Small steps for making space to wind down.', body: 'Choose one small cue that tells your day it is slowing down. You might lower the lights, set aside your phone, or prepare a warm drink. Keep the routine flexible.', category: { name: 'Sleep', slug: 'sleep' }, tags: ['sleep'] },
  { id: 3, title: 'Finding one kind thing today', slug: 'one-kind-thing', type: 'article', summary: 'A gentle reflection prompt for everyday care.', body: 'Ask yourself what would make the next hour a little easier. A glass of water, a stretch or a message to someone you trust can be enough.', category: { name: 'Self-care', slug: 'self-care' }, tags: ['reflection'] },
]
export const demoMedia: Media[] = [
  { id: 101, title: 'Sound and stillness', media_type: 'audio', file_url: '', description: 'Audio playback is available when licensed media is configured on staging.' },
  { id: 102, title: 'A moment with nature', media_type: 'video', file_url: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4', description: 'A short CC0 demonstration video from MDN.' },
]
export const demoSessions: Session[] = [
  { id: 1, title: 'Steady breathing', category: 'breathing', session_type: 'breathing', description: 'A gentle breathing pattern you can pause at any time.', instructions: 'Breathe in, pause briefly, then breathe out. Stop if the exercise feels uncomfortable.', estimated_duration_seconds: 180, inhale_seconds: 4, hold_seconds: 2, exhale_seconds: 6, is_featured: true },
  { id: 2, title: 'Notice the present moment', category: 'grounding', session_type: 'reading', description: 'A brief guided reflection.', instructions: 'Look around and name three things you can see. Notice two sounds. Feel one point of contact with the surface supporting you.', estimated_duration_seconds: 300, is_featured: false },
]
export const demoTherapists: Therapist[] = [
  { id: 1, user: { name: 'Sample care profile A' }, bio: 'Fictional profile for previewing the care journey. No credentials or availability are represented.', location: 'Example location', session_modes: ['online'] },
  { id: 2, user: { name: 'Sample care profile B' }, bio: 'Fictional profile for previewing the care journey. No credentials or availability are represented.', location: 'Example location', session_modes: ['phone'] },
]
export const demoRooms: CircleRoom[] = [
  { id: 1, name: 'A space to check in', slug: 'demo-check-in', description: 'Preview the community layout. Posting is unavailable in demo.' },
  { id: 2, name: 'Small wins', slug: 'demo-wins', description: 'Synthetic room preview with no personal messages.' },
]
