# Vithey Microservices Dev Runner - Windows PowerShell Launcher
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
python "$scriptDir\backend\scripts\dev-cli.py" @args
