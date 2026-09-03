<#
.SYNOPSIS
    Robust Automated Build, Version Bump & Dalamud-Compliant Zip Pipeline
.DESCRIPTION
    Automatically increments the patch version, compiles in Release mode, 
    and builds a latest.zip archive with the required InternalName root folder.
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
    $repoArray = @($repoJson)
    
    foreach ($entry in $repoArray) {
        if ($entry.InternalName -eq "MashedPotato") {
            $entry.AssemblyVersion = $newVersion
        }
    }
    
    ConvertTo-Json -InputObject $repoArray -Depth 10 | Set-Content $repoPath
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
                Write-Warning "[Warning] Could not immediately delete latest.zip due to a file lock."
            } else {
                Start-Sleep -Seconds $retryDelay
            }
        }
    }
}

if (Test-Path "MashedPotato/bin") { Remove-Item -Recurse -Force "MashedPotato/bin" }
if (Test-Path "MashedPotato/obj") { Remove-Item -Recurse -Force "MashedPotato/obj" }

# Step 3: Compile the project in Release mode
Write-Host "[3/5] Compiling project via .NET CLI..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed."
    exit $LASTEXITCODE
}

# Step 4: Stage files into the required InternalName folder
Write-Host "[4/5] Staging files into Dalamud-compliant folder structure..." -ForegroundColor Yellow
$publishDir = "MashedPotato/bin/Release/publish"
$stageRootDir = "MashedPotato/bin/Release/stage"
$pluginFolder = "$stageRootDir/MashedPotato" # This folder name MUST exactly match your InternalName

if (!(Test-Path $publishDir)) {
    $publishDir = Get-ChildItem -Path "MashedPotato/bin/Release" -Filter "publish" -Recurse | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if (Test-Path $stageRootDir) { Remove-Item -Recurse -Force $stageRootDir }
New-Item -ItemType Directory -Path $pluginFolder -Force | Out-Null

# Copy all compiled files INTO the MashedPotato subfolder
Get-ChildItem -Path $publishDir -File | ForEach-Object {
    Copy-Item $_.FullName -Destination $pluginFolder -Force
}

# Failsafe: Force overwrite the manifest directly from source to beat aggressive compiler caching
Copy-Item $manifestPath -Destination $pluginFolder -Force

# Step 5: Compress into latest.zip
Write-Host "[5/5] Creating final latest.zip..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = "latest.zip"
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }

# Zip the root stage folder so the "MashedPotato" folder is safely tucked inside the archive
[System.IO.Compression.ZipFile]::CreateFromDirectory($stageRootDir, $zipPath)
Remove-Item -Recurse -Force $stageRootDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan