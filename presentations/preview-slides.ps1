param(
    [switch]$RenderOnly,
    [switch]$Live
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$rscript = "C:\Program Files\R\R-4.6.1\bin\Rscript.exe"
$rmd = Join-Path $here "Vithey_App_Presentation.Rmd"
$html = Join-Path $here "Vithey_App_Presentation.html"

if (-not (Test-Path $rscript)) {
    Write-Error "R not found. Install with: winget install RProject.R"
}

$libSetup = ".libPaths(c(Sys.getenv('R_LIBS_USER'), .libPaths()))"

if ($Live) {
    Set-Location $here
    & $rscript -e "$libSetup; xaringan::inf_mr('Vithey_App_Presentation.Rmd')"
    exit $LASTEXITCODE
}

Write-Host "Rendering slides..." -ForegroundColor Cyan
& $rscript -e "$libSetup; rmarkdown::render('Vithey_App_Presentation.Rmd', quiet=TRUE)"
if ($LASTEXITCODE -ne 0) { exit 1 }

if ($RenderOnly) {
    Write-Host "Saved: $html" -ForegroundColor Green
    exit 0
}

Write-Host "Opening preview in browser..." -ForegroundColor Green
Write-Host "Tip: Press F for presentation fullscreen (or F11 for browser fullscreen)" -ForegroundColor Yellow
Start-Process $html
