import { chromium } from 'playwright-core'
import { mkdir } from 'node:fs/promises'
import { resolve } from 'node:path'

const executablePath = process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe'
const browser = await chromium.launch({ executablePath, headless: true })
const output = resolve('../../docs/testing/screenshots')
await mkdir(output, { recursive: true })
const base = 'http://127.0.0.1:3000'
let checks = 0
try {
  for (const [name, width, height] of [['desktop', 1440, 900], ['tablet', 800, 900], ['mobile', 390, 844]]) {
    const context = await browser.newContext({ viewport: { width, height }, reducedMotion: 'reduce' })
    const page = await context.newPage()
    let apiCalls = 0
    page.on('request', request => { if (request.url().includes('/api/v1/') || request.url().includes('/web/')) apiCalls++ })
    await page.goto(base)
    await page.getByRole('button', { name: /review as guest/i }).waitFor()
    await page.screenshot({ path: resolve(output, `react-welcome-${name}.png`), fullPage: true })
    await page.getByRole('button', { name: /review as guest/i }).click()
    await page.getByRole('heading', { name: /welcome to your space/i }).waitFor()
    await page.screenshot({ path: resolve(output, `react-home-${name}.png`), fullPage: true })
    const nav = width <= 650 ? page.getByRole('navigation', { name: 'Mobile navigation' }) : width <= 900 ? null : page.getByRole('navigation', { name: 'Main navigation' })
    if (nav) await nav.getByRole('link', { name: 'Care' }).click()
    else { await page.getByRole('button', { name: 'Open navigation' }).click(); await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'Care' }).click() }
    await page.getByText('Sample care profile A').waitFor()
    if (await page.getByText('Verified professional').count()) throw new Error(`${name}: fictional profile claims verification`)
    await page.getByRole('button', { name: /preview booking flow/i }).first().click()
    await page.getByText(/No appointment was created/i).waitFor()
    await page.getByRole('button', { name: 'Close booking' }).click()
    await page.screenshot({ path: resolve(output, `react-care-${name}.png`), fullPage: true })
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth + 1)
    if (overflow) throw new Error(`${name}: horizontal overflow`)
    if (apiCalls) throw new Error(`${name}: demo made ${apiCalls} backend calls`)
    if (await page.evaluate(() => localStorage.length > 0)) throw new Error(`${name}: localStorage is not empty`)
    await page.reload()
    await page.getByRole('button', { name: /review as guest/i }).waitFor()
    checks += 7
    await context.close()
  }
  console.log(`PASS: ${checks} browser checks across desktop, tablet and mobile`)
} finally { await browser.close() }
