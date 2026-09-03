<#
.SYNOPSIS
    Bulletproof Automated Build & Flat-Zip Pipeline for Dalamud API 15
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Automated Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/5] Auto-incrementing plugin version..." -ForegroundColor Yellow
$csprojPath = "MashedPotato/MashedPotato.csproj"
$manifestPath = "MashedPotato/MashedPotato.json"
$repoPath = "repo.json"

[xml]$csprojXml = Get-Content $csprojPath
$currentVersion = $csprojXml.Project.PropertyGroup.Version
$versionParts = $currentVersion.Split('.')
if ($versionParts.Length -eq 4) {
    $buildNum = [int]$versionParts[3] + 1
    $newVersion = "$($versionParts[0]).$($versionParts[1]).$($versionParts[2]).$buildNum"
} else {
    $newVersion = "$currentVersion.1"
}
Write-Host "Bumping Version -> $newVersion" -ForegroundColor Green

$csprojXml.Project.PropertyGroup.Version = $newVersion
$csprojXml.Save((Resolve-Path $csprojPath))

if (Test-Path $manifestPath) {
    $manifestJson = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $manifestJson.AssemblyVersion = $newVersion
    $manifestJson | ConvertTo-Json -Depth 10 | Set-Content $manifestPath
}

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

Write-Host "[2/5] Preparing staging directories..." -ForegroundColor Yellow
$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" -ErrorAction SilentlyContinue }

Write-Host "[3/5] Compiling .NET 8 project directly to staging folder..." -ForegroundColor Yellow
Push-Location "MashedPotato"
# The -o flag forces all compiled files directly into our staging folder safely
dotnet publish -c Release -o "stage"
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed. Please ensure you have the .NET 8 SDK installed."
    exit $LASTEXITCODE
}

Write-Host "[4/5] Injecting JSON manifest into package..." -ForegroundColor Yellow
Copy-Item $manifestPath -Destination $stageDir -Force

Write-Host "[5/5] Creating final flat latest.zip..." -ForegroundColor Yellow
$zipPath = "latest.zip"
# Compress-Archive is natively supported and guarantees a flat zip format
Compress-Archive -Path "$stageDir\*" -DestinationPath $zipPath -Force

Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan