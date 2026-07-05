param(
    [switch]$SkipBuild,
    [switch]$Down,
    [switch]$Logs
)

$ErrorActionPreference = "Stop"
$backend = Split-Path -Parent $PSScriptRoot
Set-Location $backend

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created .env from .env.example"
}

$gatewayPort = "8080"
Get-Content ".env" | ForEach-Object {
    if ($_ -match '^\s*GATEWAY_PORT\s*=\s*(\d+)\s*$') {
        $gatewayPort = $matches[1]
    }
}

if ($Down) {
    docker compose down
    exit $LASTEXITCODE
}

if ($Logs) {
    docker compose logs -f --tail 100
    exit $LASTEXITCODE
}

if ($SkipBuild) {
    docker compose up -d
} else {
    docker compose up -d --build
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "docker compose failed"
    exit 1
}

Write-Host ""
Write-Host "Waiting for gateway health..." -ForegroundColor Cyan
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$gatewayPort/actuator/health" -TimeoutSec 3 -ErrorAction Stop
        if ($health.status -eq "UP") {
            $ready = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 5
    }
}

Write-Host ""
Write-Host "=== Vithey Stack ===" -ForegroundColor Green
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
if ($ready) {
    Write-Host "Gateway:  http://localhost:$gatewayPort/actuator/health  [UP]" -ForegroundColor Green
} else {
    Write-Host "Gateway:  still starting — run: docker compose logs -f api-gateway" -ForegroundColor Yellow
}
Write-Host "Eureka:   http://localhost:8761"
Write-Host "RabbitMQ: http://localhost:15672  (guest/guest)"
Write-Host "MinIO:    http://localhost:9001  (minioadmin/minioadmin)"
Write-Host ""
Write-Host "Logs:     .\scripts\start-all.ps1 -Logs"
Write-Host "Stop:     .\scripts\start-all.ps1 -Down"
