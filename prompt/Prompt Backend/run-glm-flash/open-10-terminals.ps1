# Opens 10 Windows Terminal tabs — one GLM prompt file each.
# Run from this folder, or: powershell -File .\open-10-terminals.ps1

$ErrorActionPreference = "Stop"
$pack = $PSScriptRoot
$repo = (Resolve-Path (Join-Path $pack "..\..\..")).Path

$tabs = @(
  @{ n = "01-auth";          f = "01-auth-service.md" }
  @{ n = "02-profile";       f = "02-user-profile-service.md" }
  @{ n = "03-file";          f = "03-file-service.md" }
  @{ n = "04-content";       f = "04-content-service.md" }
  @{ n = "05-career";        f = "05-career-service.md" }
  @{ n = "06-finance";       f = "06-finance-service.md" }
  @{ n = "07-chat";          f = "07-chat-service.md" }
  @{ n = "08-notification";  f = "08-notification-service.md" }
  @{ n = "09-ai";            f = "09-ai-service.md" }
  @{ n = "10-map";           f = "10-map-service.md" }
)

if (-not (Get-Command wt -ErrorAction SilentlyContinue)) {
  Write-Host "Windows Terminal (wt) not found. Open 10 Cursor Agent chats and paste each file instead."
  $tabs | ForEach-Object { Write-Host ("  {0}  {1}" -f $_.n, (Join-Path $pack $_.f)) }
  exit 0
}

$wtArgs = @("-d", $repo)
$first = $true
foreach ($t in $tabs) {
  $path = Join-Path $pack $t.f
  $cmd = @"
Write-Host 'GLM terminal $($t.n)' -ForegroundColor Cyan
Write-Host 'Copy EVERYTHING below the --- line in this file into a NEW GLM / Cursor Agent chat:'
Write-Host '$path' -ForegroundColor Yellow
Write-Host ''
Get-Content -LiteralPath '$path'
"@
  if ($first) {
    $wtArgs += @("new-tab", "--title", $t.n, "-d", $repo, "powershell", "-NoExit", "-Command", $cmd)
    $first = $false
  } else {
    $wtArgs += @(";", "new-tab", "--title", $t.n, "-d", $repo, "powershell", "-NoExit", "-Command", $cmd)
  }
}

Start-Process -FilePath "wt" -ArgumentList $wtArgs
Write-Host "Opened 10 Windows Terminal tabs. Paste each printed prompt into its own GLM chat."
