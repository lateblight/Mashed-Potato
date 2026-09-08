<#
.SYNOPSIS
    Bulletproof Automated Build & Flat-Zip Pipeline for Mashed-Potato
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Automated Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/5] Auto-incrementing plugin version..." -ForegroundColor Yellow
$csprojPath = "MashedPotato/MashedPotato.csproj"
$manifestPath = "MashedPotato/MashedPotato.json"
$repoPath = "repo.json"

# Read .csproj as plain text to find the version securely via Regex
$csprojContent = Get-Content $csprojPath -Raw
if ($csprojContent -match '<Version>(.*?)</Version>') {
    $currentVersion = $Matches[1]
} else {
    $currentVersion = "1.1.0.0"
}

Write-Host "Current Version detected: $currentVersion" -ForegroundColor DarkGray

# Parse and bump version parts (Major.Minor.Build.Revision)
$versionParts = $currentVersion.Split('.')
if ($versionParts.Length -eq 4) {
    $buildNum = [int]$versionParts[3] + 1
    $newVersion = "$($versionParts[0]).$($versionParts[1]).$($versionParts[2]).$buildNum"
} else {
    $newVersion = "$currentVersion.1"
}
Write-Host "Bumping Version -> $newVersion" -ForegroundColor Green

# Update .csproj text cleanly using Regex replacement
if ($csprojContent -match '<Version>.*?</Version>') {
    $csprojContent = $csprojContent -replace '<Version>.*?</Version>', "<Version>$newVersion</Version>"
} else {
    # If tag doesn't exist, inject it right into the first PropertyGroup
    $csprojContent = $csprojContent -replace '<PropertyGroup>', "<PropertyGroup>`n    <Version>$newVersion</Version>"
}
Set-Content -Path $csprojPath -Value $csprojContent -NoNewline

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

Write-Host "[2/5] Preparing staging directories..." -ForegroundColor Yellow
$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" -ErrorAction SilentlyContinue }

Write-Host "[3/5] Compiling .NET 10 project directly to staging folder..." -ForegroundColor Yellow
Push-Location "MashedPotato"
dotnet publish -c Release -o "stage"
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Error "[Error] Compilation failed."
    exit $LASTEXITCODE
}

Write-Host "[4/5] Injecting JSON manifest into package..." -ForegroundColor Yellow
Copy-Item $manifestPath -Destination $stageDir -Force

Write-Host "[5/5] Creating final flat latest.zip..." -ForegroundColor Yellow
$zipPath = "latest.zip"
Compress-Archive -Path "$stageDir\*" -DestinationPath $zipPath -Force

Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan