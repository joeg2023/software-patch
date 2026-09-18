# Update-Software.ps1
# Auto-installs winget if missing, then updates all software.

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Install-Winget {
    Write-Host "winget not found. Installing now..." -ForegroundColor Yellow

    try {
        $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $path = "$env:TEMP\winget.msixbundle"

        Write-Host "Downloading winget installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing

        Write-Host "Installing winget..." -ForegroundColor Cyan
        Add-AppxPackage -Path $path

        Remove-Item $path -Force -ErrorAction SilentlyContinue

        Write-Host "winget installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install winget: $($_.Exception.Message)"
        Write-Host "Please install App Installer manually from the Microsoft Store." -ForegroundColor Red
        exit
    }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Install-Winget
}

Write-Host ""
Write-Host "Starting software updates..." -ForegroundColor Cyan

winget upgrade --id Microsoft.AppInstaller -e --silent --accept-source-agreements --accept-package-agreements

Write-Host "Upgrading all installed software..." -ForegroundColor Green
winget upgrade --all --silent --force --accept-source-agreements --accept-package-agreements --include-unknown

Write-Host ""
Write-Host "All done. Software update process completed." -ForegroundColor Green
