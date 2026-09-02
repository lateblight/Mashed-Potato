<#
.SYNOPSIS
    Official DalamudPackager-compliant Build Script for Mashed-Potato
.DESCRIPTION
    Cleans old artifacts, compiles the project in Release mode targeting .NET 10,
    and grabs the official DalamudPackager output zip for root distribution.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Official Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Step 1: Clean previous build artifacts
Write-Host "[1/4] Cleaning old build directories..." -ForegroundColor Yellow
if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" }

# Step 2: Compile project via .NET CLI in Release mode
Write-Host "[2/4] Compiling project & triggering DalamudPackager..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Build failed during compilation. Please check code errors above."
    exit $LASTEXITCODE
}

# Step 3: Locate the official packager output zip
Write-Host "[3/4] Locating DalamudPackager output..." -ForegroundColor Yellow
$packedZip = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "latest.zip" -Recurse | Select-Object -First 1

if (-not $packedZip) {
    # Fallback search for any zip in release output
    $packedZip = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "*.zip" -Recurse | Select-Object -First 1
}

if ($packedZip) {
    Copy-Item $packedZip.FullName -Destination "latest.zip" -Force
    Write-Host "[4/4] Success! Copied official package to root as latest.zip." -ForegroundColor Green
} else {
    Write-Error "[Error] Build completed, but DalamudPackager did not output a zip file. Check your csproj package references."
    exit 1
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build Complete! Ready to commit and push to GitHub." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan