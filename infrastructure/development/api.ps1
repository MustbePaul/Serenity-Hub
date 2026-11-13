Set-Location (Join-Path $PSScriptRoot '../../services/api')
if (-not (Test-Path '.env')) {
  Copy-Item '.env.example' '.env'
  if (-not (Test-Path 'database/database.sqlite')) { New-Item -ItemType File 'database/database.sqlite' | Out-Null }
  composer install
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  php artisan key:generate
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  php artisan migrate --seed
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
php artisan serve
