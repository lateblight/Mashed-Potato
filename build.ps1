# File: ./build.ps1

# File: build.ps1

<#
.SYNOPSIS
    Bulletproof Automated Build, Version Bump, File Header Stamping, & Flat-Zip Pipeline for Mashed-Potato
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Automated Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/6] Stamping file location headers on source files..." -ForegroundColor Yellow
$sourceFiles = Get-ChildItem -Recurse -File | Where-Object { 
    $_.Extension -match '(.cs|.ps1)$' -and $_.FullName -notmatch '\\(bin|obj|lib|\.vs|\.git|tools)\\' 
}

foreach ($file in $sourceFiles) {
    $relativePath = (Resolve-Path -Relative $file.FullName).Replace('\', '/')
    $content = Get-Content $file.FullName -Raw
    
    if ([string]::IsNullOrEmpty($content)) { continue }

    $expectedHeader = "// File: $relativePath"
    if ($file.Extension -eq '.ps1') { $expectedHeader = "# File: $relativePath" }

    if (-not $content.StartsWith($expectedHeader)) {
        Set-Content -Path $file.FullName -Value "$expectedHeader`n`n$content" -Encoding UTF8
        Write-Host " -> Stamped header on: $relativePath" -ForegroundColor DarkGray
    }
}

Write-Host "[2/6] Auto-incrementing plugin version..." -ForegroundColor Yellow
$csprojPath = "MashedPotato/MashedPotato.csproj"
$manifestPath = "MashedPotato/MashedPotato.json"
$repoPath = "repo.json"

$csprojContent = Get-Content $csprojPath -Raw
if ($csprojContent -match '<Version>(.*?)</Version>') {
    $currentVersion = $Matches[1]
} else {
    $currentVersion = "1.2.0.0"
}

Write-Host "Current Version detected: $currentVersion" -ForegroundColor DarkGray

$versionParts = $currentVersion.Split('.')
if ($versionParts.Length -eq 4) {
    $buildNum = [int]$versionParts[3] + 1
    $newVersion = "$($versionParts[0]).$($versionParts[1]).$($versionParts[2]).$buildNum"
} else {
    $newVersion = "$currentVersion.1"
}
Write-Host "Bumping Version -> $newVersion" -ForegroundColor Green

if ($csprojContent -match '<Version>.*?</Version>') {
    $csprojContent = $csprojContent -replace '<Version>.*?</Version>', "<Version>$newVersion</Version>"
} else {
    $csprojContent = $csprojContent -replace '<PropertyGroup>', "<PropertyGroup>`n    <Version>$newVersion</Version>"
}
Set-Content -Path $csprojPath -Value $csprojContent -NoNewline -Encoding UTF8

if (Test-Path $manifestPath) {
    $manifestJson = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $manifestJson.AssemblyVersion = $newVersion
    $manifestJson | ConvertTo-Json -Depth 10 | Set-Content $manifestPath -Encoding UTF8
}

if (Test-Path $repoPath) {
    $repoJson = Get-Content $repoPath -Raw | ConvertFrom-Json
    $repoArray = @($repoJson)
    foreach ($entry in $repoArray) {
        if ($entry.InternalName -eq "MashedPotato") {
            $entry.AssemblyVersion = $newVersion
        }
    }
    # FIX: Removed the malformed `--json` encoding argument causing the Ubuntu runner to crash
    ConvertTo-Json -InputObject $repoArray -Depth 10 | Set-Content $repoPath -Encoding UTF8
}

Write-Host "[3/6] Preparing staging directories..." -ForegroundColor Yellow
$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" -ErrorAction SilentlyContinue }

Write-Host "[4/6] Compiling .NET 10 project directly to staging folder..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release -o "stage"
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed."
    exit $LASTEXITCODE
}

Write-Host "[5/6] Scrubbing prohibited core game assemblies & injecting manifest..." -ForegroundColor Yellow
$prohibited = @("Dalamud*.dll", "Lumina*.dll", "ImGui*.dll", "FFXIVClientStructs*.dll")
foreach ($pattern in $prohibited) {
    Get-ChildItem -Path $stageDir -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
}
Copy-Item $manifestPath -Destination "$stageDir/MashedPotato.json" -Force

Write-Host "[6/6] Creating final flat latest.zip..." -ForegroundColor Yellow
$zipPath = "latest.zip"
Compress-Archive -Path "$stageDir\*" -DestinationPath $zipPath -Force

Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# Triggering final v1.3.0.0 production release
