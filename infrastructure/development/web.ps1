param(
  [ValidateSet('demo','staging')][string]$Mode = 'demo',
  [string]$ApiProxyTarget = 'http://127.0.0.1:8000',
  [string]$ReverbUrl = 'ws://127.0.0.1:8080',
  [string]$ReverbAppKey = 'local-serenity-key'
)
Set-Location (Join-Path $PSScriptRoot '../../apps/web')
$env:VITE_TRIAL_MODE = $Mode
$env:VITE_API_PROXY_TARGET = $ApiProxyTarget
$env:VITE_REVERB_URL = $ReverbUrl
$env:VITE_REVERB_APP_KEY = $ReverbAppKey
if (-not (Test-Path node_modules)) { npm install; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
npm run dev
