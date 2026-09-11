# File: Deploy-Local.ps1
$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Local Development Deployment" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$rootDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($rootDir)) { $rootDir = (Get-Location).Path }

$stageDir = Join-Path $rootDir "MashedPotato\stage"
$projectFile = Join-Path $rootDir "MashedPotato\MashedPotato.csproj"
$manifestFile = Join-Path $rootDir "MashedPotato\MashedPotato.json"
$devPluginDir = Join-Path $env:APPDATA "XIVLauncher\devPlugins\MashedPotato"

Write-Host "[1/4] Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore $projectFile

Write-Host "[2/4] Compiling .NET 10 project to staging..." -ForegroundColor Yellow
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
dotnet publish $projectFile -c Release -o $stageDir --no-restore

Write-Host "[3/4] Scrubbing prohibited core game assemblies..." -ForegroundColor Yellow
$prohibited = @("Dalamud*.dll", "Lumina*.dll", "ImGui*.dll", "FFXIVClientStructs*.dll")
foreach ($pattern in $prohibited) {
    Get-ChildItem -Path $stageDir -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
}
Copy-Item $manifestFile -Destination "$stageDir/MashedPotato.json" -Force

Write-Host "[4/4] Deploying straight to Dalamud dev plugins..." -ForegroundColor Yellow
if (-not (Test-Path $devPluginDir)) { New-Item -ItemType Directory -Path $devPluginDir -Force | Out-Null }

Remove-Item -Path "$devPluginDir\*" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$stageDir\*" -Destination $devPluginDir -Recurse -Force
Remove-Item -Recurse -Force $stageDir

Write-Host "✅ Smashed it! Restored, compiled, and deployed straight to Dalamud." -ForegroundColor Green