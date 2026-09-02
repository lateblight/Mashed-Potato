<#
.SYNOPSIS
    Robust Automated Build, Version Bump & Flat-Zip Pipeline for Mashed-Potato
.DESCRIPTION
    Automatically increments the patch version across all manifests, handles file locks,
    compiles in Release mode, and builds a flat latest.zip archive.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Automated Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Step 1: Automatically Bump the Version Number across all files
Write-Host "[1/5] Auto-incrementing plugin version..." -ForegroundColor Yellow
$csprojPath = "MashedPotato/MashedPotato.csproj"
$manifestPath = "MashedPotato/MashedPotato.json"
$repoPath = "repo.json"

[xml]$csprojXml = Get-Content $csprojPath
$currentVersion = $csprojXml.Project.PropertyGroup.Version
Write-Host "Current Version detected: $currentVersion" -ForegroundColor DarkGray

# Parse version parts (e.g., 1.0.0.12 -> Major.Minor.Build.Revision)
$versionParts = $currentVersion.Split('.')
if ($versionParts.Length -eq 4) {
    $buildNum = [int]$versionParts[3] + 1
    $newVersion = "$($versionParts[0]).$($versionParts[1]).$($versionParts[2]).$buildNum"
} else {
    $newVersion = "$currentVersion.1"
}
Write-Host "New Bumping Version -> $newVersion" -ForegroundColor Green

# Update MashedPotato.csproj
$csprojXml.Project.PropertyGroup.Version = $newVersion
$csprojXml.Save((Resolve-Path $csprojPath))

# Update MashedPotato.json manifest
if (Test-Path $manifestPath) {
    $manifestJson = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $manifestJson.AssemblyVersion = $newVersion
    $manifestJson | ConvertTo-Json -Depth 10 | Set-Content $manifestPath
}

# Update repo.json manifest
if (Test-Path $repoPath) {
    $repoJson = Get-Content $repoPath -Raw | ConvertFrom-Json
    foreach ($entry in $repoJson) {
        if ($entry.InternalName -eq "MashedPotato") {
            $entry.AssemblyVersion = $newVersion
        }
    }
    $repoJson | ConvertTo-Json -Depth 10 | Set-Content $repoPath
}

# Step 2: Clean old build artifacts with lock-retry safety
Write-Host "[2/5] Cleaning old directories and releasing file locks..." -ForegroundColor Yellow
$maxRetries = 3
$retryDelay = 1

if (Test-Path "latest.zip") {
    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Set-ItemProperty -Path "latest.zip" -Name IsReadOnly -Value $false
            Remove-Item -Force "latest.zip" -ErrorAction Stop
            break
        } catch {
            if ($i -eq $maxRetries) {
                Write-Warning "[Warning] Could immediately delete latest.zip due to a file lock. Attempting overwrite..."
            } else {
                Start-Sleep -Seconds $retryDelay
            }
        }
    }
}

if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }

# Step 3: Compile the project in Release mode
Write-Host "[3/5] Compiling project via .NET CLI..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed."
    exit $LASTEXITCODE
}

# Step 4: Stage and flatten files for zip package
Write-Host "[4/5] Staging files for flat packaging..." -ForegroundColor Yellow
$publishDir = "MashedPotato/bin/Release/publish"
$stageDir = "MashedPotato/bin/Release/stage"

if (!(Test-Path $publishDir)) {
    $publishDir = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "publish" -Recurse | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
New-Item -ItemType Directory -Path $stageDir | Out-Null

Get-ChildItem -Path $publishDir -File | ForEach-Object {
    Copy-Item $_.FullName -Destination $stageDir -Force
}

# Step 5: Compress into root latest.zip (using safe overwrite)
Write-Host "[5/5] Creating final flat latest.zip..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = "latest.zip"
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
[System.IO.Compression.ZipFile]::CreateFromDirectory($stageDir, $zipPath)
Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan