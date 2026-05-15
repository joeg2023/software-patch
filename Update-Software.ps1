# Update-Software.ps1
# PowerShell script to update installed programs using winget

# Run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit
}

Write-Host "Checking for updates..." -ForegroundColor Cyan

# Update winget itself if needed
winget upgrade --id Microsoft.AppInstaller -e --silent --accept-source-agreements --accept-package-agreements

# Upgrade all packages
Write-Host "Upgrading all installed software..." -ForegroundColor Green
winget upgrade --all --silent --force --accept-source-agreements --accept-package-agreements --include-unknown

Write-Host "Software update complete!" -ForegroundColor Green