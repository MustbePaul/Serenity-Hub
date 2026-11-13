param([ValidateSet('demo','staging')][string]$Mode = 'demo')
Set-Location (Join-Path $PSScriptRoot '../../apps/mobile')
flutter run -d chrome --web-port=3001 --dart-define=TRIAL_MODE=$Mode --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
