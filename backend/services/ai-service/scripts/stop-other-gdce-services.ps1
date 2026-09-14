# Stop other GDCE AI services (keep general only)

$ErrorActionPreference = "Continue"

$stopNames = @(
    "orchestrator-service",
    "api-layer",
    "retrieval-service",
    "hs-retrieval-service",
    "qdrant",
    "redis"
)

Write-Host "Stopping GDCE services that are NOT needed for Vithey chatbot..."
Write-Host "Keeping: general-service, qdrant-general, redis-general"
Write-Host ""

foreach ($name in $stopNames) {
    $containers = docker ps -a --format "{{.Names}}" | Select-String -Pattern $name
    foreach ($line in $containers) {
        $container = $line.Line.Trim()
        if ($container -match "general") {
            continue
        }
        Write-Host "Stopping $container"
        docker stop $container 2>$null
    }
}

Write-Host ""
Write-Host "Done. Chatbot needs only:"
Write-Host "  - general-service :8005"
Write-Host "  - qdrant-general"
Write-Host "  - redis-general"
Write-Host "  - vithey-ai-service :8089 (Vithey adapter)"
