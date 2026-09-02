<#
.SYNOPSIS
    Automated Build & Packaging Script for Mashed-Potato
.DESCRIPTION
    Compiles the project in Release mode, locates the compiled output inside the publish directory,
    and creates a clean flat-structured latest.zip containing only the raw plugin files.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Build & Flat-Zip Pipeline" -ForegroundColor Cyan
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

# Step 3: Locate the inner publish folder
Write-Host "[3/4] Locating publish output..." -ForegroundColor Yellow
$publishDir = "MashedPotato/bin/Release/publish"

if (!(Test-Path $publishDir)) {
    $publishDir = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "publish" -Recurse | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

# Step 4: Create a clean flat zip directly from the contents inside publish (excluding the folder itself)
if (Test-Path $publishDir) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    # Create temporary staging directory or zip directly from contents
    $tempZipDir = "MashedPotato/bin/Release/zip_temp"
    if (Test-Path $tempZipDir) { Remove-Item -Recurse -Force $tempZipDir }
    New-Item -ItemType Directory -Path $tempZipDir | Out-Null
    
    # Copy all files INSIDE publish directly to temp root
    Copy-Item "$publishDir\*.*" -Destination $tempZipDir -Force
    
    # Create the final zip from the flattened contents
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempZipDir, "latest.zip")
    
    # Clean up temp folder
    Remove-Item -Recurse -Force $tempZipDir
    
    Write-Host "[4/4] Success! Created clean, flat-structured latest.zip in root." -ForegroundColor Green
} else {
    Write-Error "[Error] Could not locate the compiled publish directory to zip."
    exit 1
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build Complete! Ready to commit and push to GitHub." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan