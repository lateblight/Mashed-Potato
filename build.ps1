$ErrorActionPreference = "Stop"
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Starting Clean Build Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$newVersion = "1.2.0.30"
Write-Host "Forcing Version -> $newVersion" -ForegroundColor Green

$csprojPath = "MashedPotato/MashedPotato.csproj"
$csprojContent = Get-Content $csprojPath -Raw
if ($csprojContent -match '<Version>.*?</Version>') {
    $csprojContent = $csprojContent -replace '<Version>.*?</Version>', "<Version>$newVersion</Version>"
} else {
    $csprojContent = $csprojContent -replace '<PropertyGroup>', "<PropertyGroup>`n    <Version>$newVersion</Version>"
}
Set-Content -Path $csprojPath -Value $csprojContent -NoNewline -Encoding UTF8

$manifestPath = "MashedPotato/MashedPotato.json"
$repoPath = "repo.json"

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

$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
if (Test-Path "latest.zip") { Remove-Item -Force "latest.zip" }
New-Item -ItemType Directory -Path $stageDir | Out-Null

dotnet restore Mashed-Potato.sln
dotnet publish MashedPotato/MashedPotato.csproj -c Release -o $stageDir

Copy-Item $manifestPath -Destination "$stageDir/MashedPotato.json" -Force

# BULLETPROOF ZIP PATHING: Lock onto the absolute root directory
$rootDir = (Get-Location).Path
$zipDest = Join-Path $rootDir "latest.zip"

Push-Location $stageDir
Compress-Archive -Path "*" -DestinationPath $zipDest -Force
Pop-Location

Remove-Item -Recurse -Force $stageDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Build Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
