# Open GLM terminal helpers — Vithey AI UI pack
# Prints the path of each prompt so you can paste into GLM 5.3 Flash chats.

$root = $PSScriptRoot
Write-Host "=== RUN 00 FIRST (alone) ===" -ForegroundColor Yellow
Write-Host (Join-Path $root "00-shared-mock-layer.md")

Write-Host "`n=== THEN OPEN 5 PARALLEL CHATS ===" -ForegroundColor Cyan
1..5 | ForEach-Object {
  $n = "{0:D2}" -f $_
  Get-ChildItem $root -Filter "$n-*.md" | ForEach-Object {
    Write-Host $_.FullName
  }
}

Write-Host "`nCopy everything BELOW the --- line in each file." -ForegroundColor Green
Write-Host "Read COMMON_CONTEXT.md + README.md first."
