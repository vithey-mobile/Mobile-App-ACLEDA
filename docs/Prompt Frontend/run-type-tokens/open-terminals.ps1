# Open GLM paths — Type + color tokens pack
$root = $PSScriptRoot

Write-Host "=== 1) RUN 00 FIRST ===" -ForegroundColor Yellow
Write-Host (Join-Path $root "00-tokens.md")
Write-Host (Join-Path $root "DESIGN.md")

Write-Host "`n=== 2) THEN 10 PARALLEL MODULE CHATS ===" -ForegroundColor Cyan
1..10 | ForEach-Object {
  $n = "{0:D2}" -f $_
  Get-ChildItem $root -Filter "$n-*.md" | ForEach-Object { Write-Host $_.FullName }
}

Write-Host "`n=== 3) FINALLY 11 SWEEP ===" -ForegroundColor Magenta
Write-Host (Join-Path $root "11-sweep.md")

Write-Host "`nPaste everything BELOW the --- line into each GLM 5.3 Flash chat." -ForegroundColor Green
