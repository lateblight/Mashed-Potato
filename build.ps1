# File: ./build.ps1

<#
.SYNOPSIS
    Clean Automated Build & Version Bump Pipeline for Mashed-Potato
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Automated Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/4] Auto-incrementing plugin version..." -ForegroundColor Yellow
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
    ConvertTo-Json -InputObject $repoArray -Depth 10 | Set-Content $repoPath -Encoding UTF8
}

Write-Host "[2/4] Preparing staging directories..." -ForegroundColor Yellow
$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $stageDir | Out-Null

Write-Host "[3/4] Compiling .NET 10 project from solution root..." -ForegroundColor Yellow
dotnet restore Mashed-Potato.sln
dotnet publish MashedPotato/MashedPotato.csproj -c Release -o $stageDir

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed."
    exit $LASTEXITCODE
}

Write-Host "[4/4] Creating final flat latest.zip..." -ForegroundColor Yellow
Copy-Item $manifestPath -Destination "$stageDir/MashedPotato.json" -Force

# Guaranteed flat zip architecture
Get-ChildItem -Path $stageDir | Compress-Archive -DestinationPath "latest.zip" -Force

Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan