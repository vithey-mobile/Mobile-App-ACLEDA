param(
    [switch]$SkipBuild,
    [switch]$Down,
    [switch]$Logs,
    [switch]$InfraOnly,
    [switch]$SkipFlutterEnv
)

$ErrorActionPreference = "Stop"
$backend = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $backend

Set-Location $backend

function Get-LanIpv4 {
    $candidates = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*' -and
            $_.PrefixOrigin -ne 'WellKnown' -and
            $_.InterfaceAlias -notmatch 'WSL|Hyper-V|vEthernet|VirtualBox|Loopback|Docker|Bluetooth|VMware'
        } |
        Sort-Object {
            if ($_.InterfaceAlias -match 'Wi-?Fi|Wireless') { 0 }
            elseif ($_.InterfaceAlias -match 'Ethernet') { 1 }
            else { 2 }
        }, IPAddress)

    if ($candidates.Count -gt 0) {
        return $candidates[0].IPAddress
    }
    return $null
}

function Set-MinioPublicEndpoint {
    $lanIp = Get-LanIpv4
    if (-not $lanIp) {
        $script:MinioPublicEndpoint = "http://localhost:19000"
        $script:LanIp = "localhost"
        Write-Host "No LAN IP detected -- MinIO public URL: $script:MinioPublicEndpoint" -ForegroundColor Yellow
        return
    }

    $script:LanIp = $lanIp
    $script:MinioPublicEndpoint = "http://${lanIp}:19000"
    $env:MINIO_PUBLIC_ENDPOINT = $script:MinioPublicEndpoint

    # Compose interpolates from backend/.env
    $composeEnvPath = Join-Path $backend ".env"
    $line = "MINIO_PUBLIC_ENDPOINT=$script:MinioPublicEndpoint"
    if (Test-Path $composeEnvPath) {
        $content = Get-Content $composeEnvPath -Raw
        if ($content -match '(?m)^MINIO_PUBLIC_ENDPOINT=.*$') {
            $content = [regex]::Replace($content, '(?m)^MINIO_PUBLIC_ENDPOINT=.*$', $line)
        } else {
            if (-not $content.EndsWith("`n")) { $content += "`n" }
            $content += "$line`n"
        }
        Set-Content -Path $composeEnvPath -Value $content -NoNewline
    } else {
        Set-Content -Path $composeEnvPath -Value "$line`n"
    }

    Write-Host "Detected LAN IP: $lanIp" -ForegroundColor Cyan
    Write-Host "MinIO public URL: $script:MinioPublicEndpoint" -ForegroundColor Cyan
}

function Sync-FlutterEnv {
    if ($SkipFlutterEnv) { return }

    $flutterEnv = Join-Path $repoRoot "vithey_app\.env"
    if (-not (Test-Path $flutterEnv)) { return }
    if (-not $script:LanIp -or $script:LanIp -eq "localhost") { return }

    $api = "http://$($script:LanIp):8080/api/v1"
    $ws = "ws://$($script:LanIp):8080/ws"
    $content = Get-Content $flutterEnv -Raw

    if ($content -match '(?m)^API_BASE_URL=.*$') {
        $content = [regex]::Replace($content, '(?m)^API_BASE_URL=.*$', "API_BASE_URL=$api")
    }
    if ($content -match '(?m)^WS_BASE_URL=.*$') {
        $content = [regex]::Replace($content, '(?m)^WS_BASE_URL=.*$', "WS_BASE_URL=$ws")
    }

    Set-Content -Path $flutterEnv -Value $content -NoNewline
    Write-Host "Updated vithey_app/.env -> $api" -ForegroundColor Cyan
}

function Wait-ForHealth {
    param(
        [string]$Url,
        [int]$MaxAttempts = 60,
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
    Write-Host "=== Vithey stack logs (last 80 lines) ===" -ForegroundColor Cyan
    docker compose logs --tail 80
    exit $LASTEXITCODE
}

if ($Down) {
    Write-Host "Stopping Vithey full stack..." -ForegroundColor Yellow
    docker compose down
    exit $LASTEXITCODE
}

Set-MinioPublicEndpoint
Sync-FlutterEnv

if ($InfraOnly) {
    Write-Host "Starting infrastructure only..." -ForegroundColor Green
    Set-Location (Join-Path $backend "infrastructure")
    if ($SkipBuild) {
        docker compose up -d
    } else {
        docker compose up -d --build
    }
    exit $LASTEXITCODE
}

Write-Host "Starting Vithey full stack (infra + all services)..." -ForegroundColor Green
Write-Host "First build can take several minutes." -ForegroundColor DarkGray

if ($SkipBuild) {
    docker compose up -d
} else {
    docker compose up -d --build
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "docker compose up failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Ensure file-service picks up the current LAN MinIO public URL
docker compose up -d --no-deps --force-recreate file-service | Out-Null

# Drop retired Java AI if an old container is still around; keep Python ai_core
docker rm -f vithey-ai-service 2>$null | Out-Null
docker compose up -d ai-core | Out-Null

Write-Host ""
Write-Host "Waiting for Eureka / Config / Gateway..." -ForegroundColor Cyan
$eurekaReady = Wait-ForHealth -Url "http://localhost:8761/actuator/health" -MaxAttempts 36
$configReady = Wait-ForHealth -Url "http://localhost:8888/actuator/health" -MaxAttempts 36
$gatewayReady = Wait-ForHealth -Url "http://localhost:8080/actuator/health" -MaxAttempts 72
$aiCoreReady = $false
for ($i = 0; $i -lt 24; $i++) {
    try {
        $null = Invoke-WebRequest -Uri "http://localhost:8100/health" -TimeoutSec 3 -UseBasicParsing
        $aiCoreReady = $true
        break
    } catch {
        Start-Sleep -Seconds 5
    }
}

Write-Host ""
Write-Host "=== Vithey stack status ===" -ForegroundColor Green
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
if ($eurekaReady) {
    Write-Host "Eureka:   http://localhost:8761  [UP]" -ForegroundColor Green
} else {
    Write-Host "Eureka:   still starting -- docker compose logs eureka-server" -ForegroundColor Yellow
}

if ($configReady) {
    Write-Host "Config:   http://localhost:8888  [UP]" -ForegroundColor Green
} else {
    Write-Host "Config:   still starting -- docker compose logs config-server" -ForegroundColor Yellow
}

if ($gatewayReady) {
    Write-Host "Gateway:  http://localhost:8080/actuator/health  [UP]" -ForegroundColor Green
} else {
    Write-Host "Gateway:  still starting -- docker compose logs api-gateway" -ForegroundColor Yellow
}

if ($aiCoreReady) {
    Write-Host "AI core:  http://localhost:8100/health  [UP]  (chat stub / CV when keyed)" -ForegroundColor Green
} else {
    Write-Host "AI core:  still starting -- docker compose logs ai-core" -ForegroundColor Yellow
}

Write-Host "RabbitMQ: http://localhost:15672  (guest/guest)"
Write-Host "MinIO:    http://localhost:19001  (minioadmin/minioadmin)"
Write-Host "MinIO API public: $script:MinioPublicEndpoint"
Write-Host "Postgres: localhost:15432"
Write-Host "Redis:    localhost:16379"
Write-Host ""
Write-Host "Logs:     .\scripts\start-all.ps1 -Logs"
Write-Host "Stop:     .\scripts\start-all.ps1 -Down"
Write-Host "Infra:    .\scripts\start-all.ps1 -InfraOnly"
