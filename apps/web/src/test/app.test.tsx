import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { cleanup, fireEvent, render, screen, within } from '@testing-library/react'
import { App } from '../App'

beforeEach(() => { window.history.replaceState({}, '', '/'); vi.stubEnv('VITE_TRIAL_MODE', 'demo') })
afterEach(() => { cleanup(); vi.unstubAllEnvs(); vi.restoreAllMocks() })

describe('synthetic browser trial', () => {
  it('shows guest entry and keeps account actions out of demo', () => {
    render(<App />)
    expect(screen.getByRole('heading', { name: /make room for/i })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /review as guest/i })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: /create an account/i })).not.toBeInTheDocument()
  })

  it('navigates top-level pages and browser back without losing guest access', async () => {
    render(<App />)
    fireEvent.click(screen.getByRole('button', { name: /review as guest/i }))
    expect(await screen.findByRole('heading', { name: /welcome to your space/i })).toBeInTheDocument()
    fireEvent.click(within(screen.getByRole('navigation', { name: 'Main navigation' })).getByRole('link', { name: 'Library' }))
    expect(await screen.findByRole('heading', { name: 'Wellness library' })).toBeInTheDocument()
    expect(window.location.pathname).toBe('/app/library')
    window.history.back()
    fireEvent.popState(window)
    expect(await screen.findByRole('heading', { name: /welcome to your space/i })).toBeInTheDocument()
  })

  it('protects a refreshed direct app URL without a guest session', async () => {
    window.history.replaceState({}, '', '/app/care')
    render(<App />)
    expect(await screen.findByRole('heading', { name: /make room for/i })).toBeInTheDocument()
  })

  it('labels fictional care profiles and never calls the API from preview', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch')
    render(<App />)
    fireEvent.click(screen.getByRole('button', { name: /review as guest/i }))
    fireEvent.click(within(screen.getByRole('navigation', { name: 'Main navigation' })).getByRole('link', { name: 'Care' }))
    expect(await screen.findByText('Sample care profile A')).toBeInTheDocument()
    expect(screen.queryByText(/verified professional/i)).not.toBeInTheDocument()
    fireEvent.click(screen.getAllByRole('button', { name: /preview booking flow/i })[0])
    expect(screen.getByRole('dialog')).toHaveTextContent('No appointment was created')
    expect(fetchSpy).not.toHaveBeenCalled()
  })

  it('shows a local mood preview without persisting', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch')
    render(<App />)
    fireEvent.click(screen.getByRole('button', { name: /review as guest/i }))
    fireEvent.click(screen.getByRole('button', { name: 'Good' }))
    fireEvent.click(screen.getByRole('button', { name: /preview check-in/i }))
    expect(await screen.findByText(/nothing was saved to an account/i)).toBeInTheDocument()
    expect(fetchSpy).not.toHaveBeenCalled()
  })

  it('filters demo resources and marks audio without a source unavailable', async () => {
    render(<App />)
    fireEvent.click(screen.getByRole('button', { name: /review as guest/i }))
    fireEvent.click(within(screen.getByRole('navigation', { name: 'Main navigation' })).getByRole('link', { name: 'Library' }))
    fireEvent.click(screen.getByRole('button', { name: 'Audio' }))
    expect(screen.getByRole('heading', { name: 'Sound and stillness' })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'A five-minute reset for a busy mind' })).not.toBeInTheDocument()
    fireEvent.click(screen.getByRole('link', { name: /sound and stillness/i }))
    expect(await screen.findByText(/No licensed audio source is configured/i)).toBeInTheDocument()
  })

  it('keeps guest community and profile actions non-persistent', async () => {
    render(<App />)
    fireEvent.click(screen.getByRole('button', { name: /review as guest/i }))
    fireEvent.click(within(screen.getByRole('navigation', { name: 'Main navigation' })).getByRole('link', { name: 'Serenity Circle' }))
    expect(await screen.findByText(/Posting, reporting and account identities are unavailable/i)).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Post to room' })).not.toBeInTheDocument()
    fireEvent.click(within(screen.getByRole('navigation', { name: 'Account navigation' })).getByRole('link', { name: 'Profile' }))
    expect(await screen.findByText(/do not have a persisted account or profile/i)).toBeInTheDocument()
  })
})
