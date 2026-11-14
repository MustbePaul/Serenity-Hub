import { chromium } from 'playwright-core'

const email = process.env.STAGING_SMOKE_EMAIL
const password = process.env.STAGING_SMOKE_PASSWORD
if (!email || !password) throw new Error('Set STAGING_SMOKE_EMAIL and STAGING_SMOKE_PASSWORD for an isolated test account.')
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true })
const page = await browser.newPage({ viewport: { width: 1360, height: 900 } })
let checks = 0
try {
  await page.goto('http://127.0.0.1:3000/')
  await page.getByRole('link', { name: /already have an account/i }).click()
  await page.getByLabel('Email').fill(email)
  await page.getByLabel('Password').fill(password)
  await page.getByRole('button', { name: 'Sign in' }).click()
  await page.getByRole('heading', { name: /hello,/i }).waitFor()
  checks++

  await page.getByRole('button', { name: 'Good', exact: true }).click()
  await page.getByRole('button', { name: 'Save check-in' }).click()
  await page.getByText('Your check-in was saved.').waitFor()
  checks++

  await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'Library' }).click()
  await page.getByRole('heading', { name: 'Wellness library' }).waitFor()
  await page.locator('.resource-card').first().waitFor()
  checks++

  await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'Sessions' }).click()
  await page.locator('.session-row').first().click()
  await page.getByRole('button', { name: 'Start session' }).click()
  await page.getByRole('button', { name: 'Pause' }).waitFor()
  checks++

  await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'Care' }).click()
  await page.getByRole('heading', { name: 'Care directory' }).waitFor()
  const careCard = page.locator('.care-card').first()
  await careCard.waitFor()
  if (await page.getByText('SAMPLE PROFILE · FICTIONAL').count()) throw new Error('Staging displayed synthetic demo care profiles')
  await careCard.getByRole('button', { name: /browse test availability/i }).click()
  await page.getByRole('dialog').waitFor()
  const slot = page.getByLabel('Available test slot')
  await slot.waitFor()
  await slot.selectOption({ index: 1 })
  await page.getByRole('button', { name: 'Book test appointment' }).click()
  await page.getByText(/Test appointment \d+ was saved/i).waitFor()
  checks++
  await page.getByRole('button', { name: 'Close booking' }).click()

  await page.getByRole('navigation', { name: 'Account navigation' }).getByRole('link', { name: 'Appointments' }).click()
  await page.getByRole('heading', { name: 'Appointments' }).waitFor()
  page.once('dialog', dialog => dialog.accept())
  await page.getByRole('button', { name: 'Cancel test booking' }).first().click()
  await page.getByText('Test appointment cancelled.').waitFor()
  checks++

  await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'Serenity Circle' }).click()
  await page.getByRole('heading', { name: 'Serenity Circle' }).waitFor()
  await page.locator('.room-list button').first().click()
  await page.getByLabel(/Write to /).fill(`Staging smoke check ${Date.now()}: a gentle hello.`)
  await page.getByRole('button', { name: 'Post to room' }).click()
  await page.getByText(/Posted to the room|under review/i).waitFor()
  checks++

  await page.getByRole('navigation', { name: 'Account navigation' }).getByRole('link', { name: 'Profile' }).click()
  await page.getByRole('heading', { name: 'Profile', exact: true }).waitFor()
  await page.getByRole('button', { name: 'Sign out' }).click()
  await page.getByRole('button', { name: 'Review as guest' }).waitFor()
  await page.goto('http://127.0.0.1:3000/app')
  await page.getByRole('button', { name: 'Review as guest' }).waitFor()
  checks++
  console.log(`PASS: ${checks} live local staging browser workflows`)
} finally { await browser.close() }
