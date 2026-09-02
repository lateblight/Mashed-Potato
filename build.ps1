<#
.SYNOPSIS
    Automated Build & Packaging Script for Mashed-Potato
.DESCRIPTION
    Cleans previous build artifacts, compiles the C# project in Release mode,
    packages the Dalamud plugin asset bundle, and copies the final latest.zip to the repository root.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Build & Packaging Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Step 1: Clean previous build artifacts
Write-Host "[1/4] Cleaning old build directories..." -ForegroundColor Yellow
if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" }

# Step 2: Compile project via .NET CLI (pointing directly to the inner project folder)
Write-Host "[2/4] Compiling project in Release configuration..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Build failed during compilation. Please check code errors above."
    exit $LASTEXITCODE
}

# Step 3: Locate and extract/relocate the generated plugin zip
Write-Host "[3/4] Locating package output..." -ForegroundColor Yellow
$packedZip = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "*.zip" -Recurse | Select-Object -First 1

if ($packedZip) {
    Copy-Item $packedZip.FullName -Destination "latest.zip" -Force
    Write-Host "[4/4] Success! Copied $($packedZip.Name) to root as latest.zip." -ForegroundColor Green
} else {
    Write-Error "[Error] Build completed, but the Dalamud packager zip file could not be found."
    exit 1
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build Complete! Ready to commit and push to GitHub." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan