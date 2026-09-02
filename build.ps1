<#
.SYNOPSIS
    Foolproof Flat-Zip Build Script for Mashed-Potato
.DESCRIPTION
    Compiles the plugin, isolates only the required release files, 
    and zips them flatly with zero nested folders.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Foolproof Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Step 1: Clean old artifacts
Write-Host "[1/4] Cleaning old directories..." -ForegroundColor Yellow
if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" }

# Step 2: Compile the project
Write-Host "[2/4] Compiling project in Release mode..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed."
    exit $LASTEXITCODE
}

# Step 3: Set up a clean staging folder for flat zipping
Write-Host "[3/4] Staging files for flat packaging..." -ForegroundColor Yellow
$publishDir = "MashedPotato/bin/Release/publish"
$stageDir = "MashedPotato/bin/Release/stage"

if (!(Test-Path $publishDir)) {
    $publishDir = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "publish" -Recurse | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
New-Item -ItemType Directory -Path $stageDir | Out-Null

# Copy ONLY individual files from publish (ignoring any subfolders like 'publish')
Get-ChildItem -Path $publishDir -File | ForEach-Object {
    Copy-Item $_.FullName -Destination $stageDir -Force
}

# Step 4: Compress only the staged files into a clean latest.zip in the root
Write-Host "[4/4] Creating final flat latest.zip..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($stageDir, "latest.zip")

# Clean up staging folder
Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build Complete! Clean flat zip created successfully." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan