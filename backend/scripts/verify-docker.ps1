# Verify Vithey Docker stack
$ErrorActionPreference = "Continue"

$infra = @(
    "vithey-eureka-server",
    "vithey-config-server",
    "vithey-postgres",
    "vithey-redis",
    "vithey-rabbitmq",
    "vithey-minio"
)

$services = @(
    "vithey-auth-service",
    "vithey-user-profile-service",
    "vithey-file-service",
    "vithey-content-service",
    "vithey-career-service",
    "vithey-finance-service",
    "vithey-chat-service",
    "vithey-notification-service",
    "vithey-api-gateway",
    "vithey-ai-service"
)

$gdce = @(
    "general-service",
    "qdrant-general",
    "redis-general"
)

function Test-ContainerRunning($name) {
    $state = docker inspect -f "{{.State.Status}}" $name 2>$null
    if ($state -eq "running") {
        Write-Host "[OK]   $name" -ForegroundColor Green
        return $true
    }
    Write-Host "[FAIL] $name (status: $state)" -ForegroundColor Red
    return $false
}

function Test-Http($label, $url, $pattern) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($resp.Content -match $pattern -or $resp.StatusCode -eq 200) {
            Write-Host "[OK]   $label" -ForegroundColor Green
            return $true
        }
        Write-Host "[FAIL] $label (unexpected response)" -ForegroundColor Red
        return $false
    } catch {
        Write-Host "[FAIL] $label ($($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n=== Infrastructure ===" -ForegroundColor Cyan
$ok = 0
foreach ($c in $infra) { if (Test-ContainerRunning $c) { $ok++ } }

Write-Host "`n=== Microservices ===" -ForegroundColor Cyan
foreach ($c in $services) { if (Test-ContainerRunning $c) { $ok++ } }

Write-Host "`n=== GDCE General (chatbot) ===" -ForegroundColor Cyan
foreach ($c in $gdce) { if (Test-ContainerRunning $c) { $ok++ } }

Write-Host "`n=== Health endpoints ===" -ForegroundColor Cyan
$healthOk = 0
if (Test-Http "Eureka" "http://localhost:8761/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "Gateway" "http://localhost:8080/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "Auth" "http://localhost:8081/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "AI service" "http://localhost:8089/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "General" "http://localhost:8005/health" "status|healthy|UP") { $healthOk++ }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$total = $infra.Count + $services.Count + $gdce.Count
Write-Host "Containers running: check output above ($total expected)"
Write-Host "Health checks passed: $healthOk / 5"
Write-Host ""

if ($healthOk -eq 5) {
    Write-Host "Stack looks healthy." -ForegroundColor Green
    exit 0
}

Write-Host "Some checks failed. See DOCKER-VERIFY.md for fixes." -ForegroundColor Yellow
exit 1
