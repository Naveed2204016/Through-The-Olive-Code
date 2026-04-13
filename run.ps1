# PowerShell script to run the shell project
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectPath
bash main.sh
