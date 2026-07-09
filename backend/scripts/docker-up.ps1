# Start infrastructure only (Postgres, Redis, RabbitMQ, MinIO, Eureka, Config)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\infrastructure")

Write-Host "Starting Vithey infrastructure..." -ForegroundColor Cyan
docker compose up -d

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Infrastructure is up. Build services from their folders, e.g.:" -ForegroundColor Green
Write-Host "  cd services\auth-service" -ForegroundColor Green
Write-Host "  docker compose up -d --build" -ForegroundColor Green
Write-Host ""
Write-Host "Or: ..\scripts\docker-build-service.ps1 auth-service -Up" -ForegroundColor Green
