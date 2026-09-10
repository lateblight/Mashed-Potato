# File: ./Deploy-Local.ps1

<#
.SYNOPSIS
    Compiles the plugin and copies it directly into your local Dalamud devPlugins folder for rapid testing.
#>

$ErrorActionPreference = "Stop"

# Since this script will be hidden in the tools folder, we need to step out to the main directory first
Push-Location $PSScriptRoot\..

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Deploying to Local Dalamud" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Run the build script to ensure we have a fresh compile
if (Test-Path "build.ps1") {
    Write-Host "Triggering build.ps1..." -ForegroundColor DarkGray
    ./build.ps1
} else {
    Write-Host "Could not find build.ps1!" -ForegroundColor Red
    Pop-Location
    exit 1
}

# 2. Define the local XIVLauncher plugin folder
$devPluginDir = "$env:APPDATA\XIVLauncher\devPlugins\MashedPotato"

if (-not (Test-Path $devPluginDir)) {
    New-Item -ItemType Directory -Path $devPluginDir | Out-Null
}

# 3. Extract the fresh build directly into the game's dev folder
Write-Host "Extracting latest.zip directly into $devPluginDir..." -ForegroundColor Yellow
Expand-Archive -Path "latest.zip" -DestinationPath $devPluginDir -Force

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Local deployment sorted! Type /xlplugins in-game and check 'Dev Tools'." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

Pop-Location