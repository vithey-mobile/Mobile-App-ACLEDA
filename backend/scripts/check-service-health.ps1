# Checks /actuator/health for Vithey backend services (Docker Compose or local).
# Usage: .\check-service-health.ps1 [-BaseHost localhost]

param(
    [string]$BaseHost = "localhost"
)

$ErrorActionPreference = "Stop"

$services = @(
    @{ Name = "eureka-server";        Port = 8761 },
    @{ Name = "config-server";        Port = 8888 },
    @{ Name = "api-gateway";          Port = 8080 },
    @{ Name = "auth-service";         Port = 8081 },
    @{ Name = "user-profile-service"; Port = 8082 },
    @{ Name = "file-service";         Port = 8083 },
    @{ Name = "content-service";      Port = 8084 },
    @{ Name = "career-service";       Port = 8085 },
    @{ Name = "finance-service";      Port = 8086 },
    @{ Name = "chat-service";         Port = 8087 },
    @{ Name = "notification-service"; Port = 8088 },
    @{ Name = "ai-service";           Port = 8089 }
)

$passed = 0
$failed = 0

Write-Host "Vithey service health check ($BaseHost)" -ForegroundColor Cyan
Write-Host ("-" * 50)

foreach ($svc in $services) {
    $url = "http://${BaseHost}:$($svc.Port)/actuator/health"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 5
        if ($response.status -eq "UP") {
            Write-Host "[OK]   $($svc.Name) ($url)" -ForegroundColor Green
            $passed++
        }
        else {
            Write-Host "[FAIL] $($svc.Name) status=$($response.status)" -ForegroundColor Red
            $failed++
        }
    }
    catch {
        Write-Host "[FAIL] $($svc.Name) - $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host ("-" * 50)
Write-Host "Passed: $passed  Failed: $failed"

if ($failed -gt 0) {
    exit 1
}
