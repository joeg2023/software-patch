# Update-Software.ps1
# Auto-installs winget if missing, then updates all software

# Run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator."
    exit
}

# Fix TLS issues that block downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Install-Winget {
    Write-Host "🔧 winget not found. Installing now..." -ForegroundColor Yellow
    
    try {
        $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $path = "$env:TEMP\winget.msixbundle"
        
        Write-Host "Downloading winget installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
        
        Write-Host "Installing winget..." -ForegroundColor Cyan
        Add-AppxPackage -Path $path
        
        Remove-Item $path -Force -ErrorAction SilentlyContinue
        
        Write-Host "✅ winget installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install winget: $($_.Exception.Message)"
        Write-Host "Please install 'App Installer' manually from the Microsoft Store" -ForegroundColor Red
        exit
    }
}

# Check if winget is installed
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Install-Winget
}

Write-Host "`n🚀 Starting software updates..." -ForegroundColor Cyan

# Update winget itself
winget upgrade --id Microsoft.AppInstaller -e --silent --accept-source-agreements --accept-package-agreements

# Update all programs
Write-Host "Upgrading all installed software..." -ForegroundColor Green
winget upgrade --all --silent --force --accept-source-agreements --accept-package-agreements --include-unknown

Write-Host "`n✅ All done! Software update process completed." -ForegroundColor Green
