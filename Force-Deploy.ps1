$ErrorActionPreference = "Stop"

# Force absolute paths to bypass the Hide-Tools directory confusion
$rootDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($rootDir)) { $rootDir = (Get-Location).Path }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Absolute Path Local Deployment" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$stageDir = Join-Path $rootDir "MashedPotato\stage"
$projectFile = Join-Path $rootDir "MashedPotato\MashedPotato.csproj"
$manifestFile = Join-Path $rootDir "MashedPotato\MashedPotato.json"
$devPluginDir = Join-Path $env:APPDATA "XIVLauncher\devPlugins\MashedPotato"

if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }

Write-Host "[1/2] Compiling Project..." -ForegroundColor Yellow
dotnet publish $projectFile -c Release -o $stageDir

Write-Host "[2/2] Deploying DLL and Manifest to Dev Plugins..." -ForegroundColor Yellow
if (-not (Test-Path $devPluginDir)) { New-Item -ItemType Directory -Path $devPluginDir -Force | Out-Null }

# Clear old junk to ensure a totally clean slate
Remove-Item -Path "$devPluginDir\*" -Recurse -Force -ErrorAction SilentlyContinue

# Target strictly the exact files Dalamud requires (Including the JSON manifest!)
Copy-Item (Join-Path $stageDir "MashedPotato.dll") -Destination $devPluginDir -Force
Copy-Item $manifestFile -Destination $devPluginDir -Force

if (Test-Path (Join-Path $stageDir "MashedPotato.pdb")) {
    Copy-Item (Join-Path $stageDir "MashedPotato.pdb") -Destination $devPluginDir -Force
}

Write-Host "✅ Done! DLL and Manifest are sorted in $devPluginDir" -ForegroundColor Green