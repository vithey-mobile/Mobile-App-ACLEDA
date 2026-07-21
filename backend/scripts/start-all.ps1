param(
    [switch]$SkipBuild,
    [switch]$Down,
    [switch]$Logs
)

$ErrorActionPreference = "Stop"
$backend = Split-Path -Parent $PSScriptRoot

$composeFolders = @(
    "infrastructure",
    "services/auth-service",
    "services/user-profile-service",
    "services/file-service",
    "services/content-service",
    "services/career-service",
    "services/finance-service",
    "services/chat-service",
    "services/notification-service",
    "services/ai-service",
    "services/api-gateway"
)

function Invoke-ComposeInFolder {
    param(
        [string]$RelativeFolder,
        [ValidateSet("up", "down")]
        [string]$Action,
        [int]$MaxAttempts = 3
    )

    $folderPath = Join-Path $backend $RelativeFolder
    $composeFile = Join-Path $folderPath "docker-compose.yml"
    if (-not (Test-Path $composeFile)) {
        Write-Host "Skipping $RelativeFolder (no docker-compose.yml)" -ForegroundColor DarkGray
        return $true
    }

    Push-Location $folderPath
    try {
        # Compose loads .env.example via env_file; no local .env copy needed
        $attempts = if ($Action -eq "up") { $MaxAttempts } else { 1 }
        for ($attempt = 1; $attempt -le $attempts; $attempt++) {
            $prevEap = $ErrorActionPreference
            $ErrorActionPreference = "Continue"
            if ($Action -eq "up") {
                if ($SkipBuild) {
                    docker compose up -d
                } else {
                    docker compose up -d --build
                }
            } else {
                docker compose down
            }
            $composeExit = $LASTEXITCODE
            $ErrorActionPreference = $prevEap

            if ($composeExit -eq 0) {
                return $true
            }

            if ($attempt -lt $attempts) {
                Write-Host "Retry $attempt/$attempts failed for $RelativeFolder; waiting 15s..." -ForegroundColor Yellow
                Start-Sleep -Seconds 15
            }
        }

        Write-Host "docker compose $Action failed in $RelativeFolder after $attempts attempt(s)" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

function Wait-ForHealth {
    param(
        [string]$Url,
        [int]$MaxAttempts = 30,
        [int]$DelaySeconds = 5
    )

    for ($i = 0; $i -lt $MaxAttempts; $i++) {
        try {
            $health = Invoke-RestMethod -Uri $Url -TimeoutSec 3 -ErrorAction Stop
            if ($health.status -eq "UP") {
                return $true
            }
        } catch {
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    return $false
}

if ($Logs) {
    foreach ($folder in $composeFolders) {
        $folderPath = Join-Path $backend $folder
        $composeFile = Join-Path $folderPath "docker-compose.yml"
        if (-not (Test-Path $composeFile)) { continue }

        Write-Host ""
        Write-Host "=== $folder ===" -ForegroundColor Cyan
        Push-Location $folderPath
        docker compose logs --tail 50
        Pop-Location
    }
    exit 0
}

if ($Down) {
    for ($i = $composeFolders.Length - 1; $i -ge 0; $i--) {
        $folder = $composeFolders[$i]
        Write-Host "Stopping $folder..." -ForegroundColor Yellow
        Invoke-ComposeInFolder -RelativeFolder $folder -Action down
    }
    exit 0
}

Write-Host "Ensuring optional external networks exist..." -ForegroundColor DarkGray
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
docker network inspect gdce-network 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    docker network create gdce-network | Out-Null
}
$ErrorActionPreference = $prevEap

Write-Host "Starting infrastructure..." -ForegroundColor Green
$failedFolders = @()
if (-not (Invoke-ComposeInFolder -RelativeFolder "infrastructure" -Action up)) {
    $failedFolders += "infrastructure"
}

Write-Host "Waiting for Eureka and Config Server..." -ForegroundColor Cyan
$infraReady = (Wait-ForHealth -Url "http://localhost:8761/actuator/health") -and (Wait-ForHealth -Url "http://localhost:8888/actuator/health")
if (-not $infraReady) {
    Write-Warning "Infrastructure may still be starting. Continuing with services..."
}

$domainServices = $composeFolders | Where-Object {
    $_ -ne "infrastructure" -and $_ -ne "services/api-gateway"
}

foreach ($folder in $domainServices) {
    Write-Host "Starting $folder..." -ForegroundColor Green
    if (-not (Invoke-ComposeInFolder -RelativeFolder $folder -Action up)) {
        $failedFolders += $folder
    }
}

Write-Host "Starting api-gateway..." -ForegroundColor Green
if (-not (Invoke-ComposeInFolder -RelativeFolder "services/api-gateway" -Action up)) {
    $failedFolders += "services/api-gateway"
}
$gatewayPort = "8080"
$apiGatewayEnv = Join-Path $backend "services/api-gateway/.env.example"
if (Test-Path $apiGatewayEnv) {
    Get-Content $apiGatewayEnv | ForEach-Object {
        if ($_ -match '^\s*SERVER_PORT\s*=\s*(\d+)\s*$') {
            $gatewayPort = $matches[1]
        }
    }
}

Write-Host ""
Write-Host "Waiting for gateway health..." -ForegroundColor Cyan
$gatewayReady = Wait-ForHealth -Url "http://localhost:$gatewayPort/actuator/health" -MaxAttempts 60

Write-Host ""
Write-Host "=== Vithey Stack (per-folder) ===" -ForegroundColor Green
foreach ($folder in $composeFolders) {
    $folderPath = Join-Path $backend $folder
    $composeFile = Join-Path $folderPath "docker-compose.yml"
    if (-not (Test-Path $composeFile)) { continue }

    Write-Host ""
    Write-Host "--- $folder ---" -ForegroundColor Cyan
    Push-Location $folderPath
    docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    Pop-Location
}

Write-Host ""
if ($gatewayReady) {
    Write-Host "Gateway:  http://localhost:$gatewayPort/actuator/health  [UP]" -ForegroundColor Green
} else {
    Write-Host "Gateway:  still starting - check services/api-gateway logs" -ForegroundColor Yellow
}
Write-Host "Eureka:   http://localhost:8761"
Write-Host "RabbitMQ: http://localhost:15672  (guest/guest)"
Write-Host "MinIO:    http://localhost:9001  (minioadmin/minioadmin)"
Write-Host ""
Write-Host "Logs:     .\scripts\start-all.ps1 -Logs"
Write-Host "Stop:     .\scripts\start-all.ps1 -Down"

if ($failedFolders.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed folders:" -ForegroundColor Red
    foreach ($folder in $failedFolders) {
        Write-Host "  - $folder" -ForegroundColor Red
    }
    exit 1
}