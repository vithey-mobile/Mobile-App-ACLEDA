# Start Vithey Profile M demo stack (memory caps + ai_core + map)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$aiEnv = Join-Path (Resolve-Path "..\ai_core") ".env"
if (-not (Test-Path $aiEnv)) {
  Write-Host "Missing ai_core/.env - copy .env.example and set DEEPSEEK_API_KEY" -ForegroundColor Red
  exit 1
}

Write-Host "Starting Vithey DEMO stack (Profile M)..." -ForegroundColor Cyan
docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Demo stack is starting. Check:" -ForegroundColor Green
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.demo.yml ps" -ForegroundColor Green
Write-Host "  Invoke-RestMethod http://localhost:8080/actuator/health" -ForegroundColor Green
Write-Host "  Invoke-RestMethod http://localhost:8100/health" -ForegroundColor Green
Write-Host ""
Write-Host "Docs: DEMO.md" -ForegroundColor DarkGray