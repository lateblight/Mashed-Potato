<#
.SYNOPSIS
    Automated Build & Packaging Script for Mashed-Potato
.DESCRIPTION
    Cleans old artifacts, compiles the project in Release mode targeting .NET 10,
    and creates a clean flat-structured latest.zip for Dalamud installation.
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

# Step 2: Compile project via .NET CLI
Write-Host "[2/4] Compiling project in Release configuration..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Build failed during compilation. Please check code errors above."
    exit $LASTEXITCODE
}

# Step 3: Package the publish output directly into a clean flat zip
Write-Host "[3/4] Creating clean plugin zip package..." -ForegroundColor Yellow
$publishDir = "MashedPotato/bin/Release/publish"

if (!(Test-Path $publishDir)) {
    # Fallback path check if target differs
    $publishDir = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "publish" -Recurse | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if (Test-Path $publishDir) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($publishDir, "latest.zip")
    Write-Host "[4/4] Success! Created flat-structured latest.zip in root." -ForegroundColor Green
} else {
    Write-Error "[Error] Could not locate the compiled publish directory to zip."
    exit 1
}

Write-Host "==================================================s" -ForegroundColor Cyan
Write-Host " Build Complete! Ready to commit and push to GitHub." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan