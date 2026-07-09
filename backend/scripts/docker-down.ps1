$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\infrastructure")

Write-Host "Stopping Vithey infrastructure..." -ForegroundColor Cyan
docker compose down @args
