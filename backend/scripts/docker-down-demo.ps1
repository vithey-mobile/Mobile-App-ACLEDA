# Stop Vithey Profile M demo stack (base + demo overlay)
# Pass -v to also remove volumes (wipes DBs - use for Flyway checksum recovery)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Stopping Vithey DEMO stack (Profile M)..." -ForegroundColor Cyan
docker compose -f docker-compose.yml -f docker-compose.demo.yml down @args

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Demo stack stopped." -ForegroundColor Green