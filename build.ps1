# ==============================================================================
# Mashed Potato Build & Release Automation Script
# Target: .NET 10 / Dalamud API 15
# Maintainer: Lateblight
# ==============================================================================

[CmdletBinding()]
param(
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

# Force absolute path resolution to prevent null path binding errors
$RootPath = $PSScriptRoot
if (-not $RootPath) {
    $RootPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}

$ProjectName = "MashedPotato"
$ProjectDir = Join-Path $RootPath $ProjectName
$CsprojPath = Join-Path $ProjectDir "$ProjectName.csproj"
$JsonPath = Join-Path $ProjectDir "$ProjectName.json"
$RepoJsonPath = Join-Path $RootPath "repo.json"
$StageDir = Join-Path $RootPath "stage"
$LibDir = Join-Path $RootPath "lib"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 🥔 Initialising Mashed Potato Build Sequence..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Ensure local lib directory exists for offline assembly security
if (!(Test-Path $LibDir)) {
    Write-Host "[1/6] Creating local lib directory for offline DLLs..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $LibDir | Out-Null
}

# 2. Parse and Auto-Increment Version across manifests
Write-Host "[2/6] Parsing and bumping project version..." -ForegroundColor Yellow
if (!(Test-Path $CsprojPath)) {
    throw "Could not locate project file at: $CsprojPath"
}

[xml]$csproj = Get-Content $CsprojPath
$propertyGroup = $csproj.Project.PropertyGroup | Select-Object -First 1

$currentVersion = $propertyGroup.Version
if (-not $currentVersion) {
    $currentVersion = "1.4.0.0"
}

# Split version and increment the minor/build patch (e.g., 1.4.0.x)
$verParts = $currentVersion.Split('.')
[int]$patch = $verParts[-1]
$patch++
$verParts[-1] = $patch.ToString()
$newVersion = [string]::Join('.', $verParts)

# Explicitly set version properties
$propertyGroup.Version = $newVersion
if ($propertyGroup.AssemblyVersion) { 
    $propertyGroup.AssemblyVersion = $newVersion 
} else { 
    $propertyGroup.AppendChild($csproj.CreateElement("AssemblyVersion", $csproj.DocumentElement.NamespaceURI)).InnerText = $newVersion 
}
if ($propertyGroup.FileVersion) { 
    $propertyGroup.FileVersion = $newVersion 
} else { 
    $propertyGroup.AppendChild($csproj.CreateElement("FileVersion", $csproj.DocumentElement.NamespaceURI)).InnerText = $newVersion 
}

$csproj.Save($CsprojPath)

# Update Plugin JSON
if (Test-Path $JsonPath) {
    $pluginJson = Get-Content $JsonPath -Raw | ConvertFrom-Json
    $pluginJson.AssemblyVersion = $newVersion
    $pluginJson | ConvertTo-Json -Depth 10 | Set-Content $JsonPath
}

# Update Repo JSON safely
if (Test-Path $RepoJsonPath) {
    $repoJson = Get-Content $RepoJsonPath -Raw | ConvertFrom-Json
    for ($i = 0; $i -lt $repoJson.Count; $i++) {
        if ($repoJson[$i].InternalName -eq $ProjectName) {
            $repoJson[$i].AssemblyVersion = $newVersion
            if ($repoJson[$i].PSObject.Properties['DownloadLink']) {
                $repoJson[$i].DownloadLink = "https://github.com/lateblight/Mashed-Potato/raw/main/latest.zip"
            } elseif ($repoJson[$i].PSObject.Properties['Url']) {
                $repoJson[$i].Url = "https://github.com/lateblight/Mashed-Potato/raw/main/latest.zip"
            }
        }
    }
    $repoJson | ConvertTo-Json -Depth 10 | Set-Content $RepoJsonPath
}

Write-Host "✨ Bumping Version -> $newVersion" -ForegroundColor Green

# 3. Prepare Staging Directories
Write-Host "[3/6] Preparing staging directories..." -ForegroundColor Yellow
if (Test-Path $StageDir) {
    Remove-Item -Recurse -Force $StageDir
}
New-Item -ItemType Directory -Path $StageDir | Out-Null

# 4. Compile Project directly to Staging
Write-Host "[4/6] Compiling .NET 10 project directly to staging folder..." -ForegroundColor Yellow
dotnet publish $CsprojPath -c $Configuration -o $StageDir --nologo

# 5. Scrub Prohibited Core Game Assemblies & Inject Assets
Write-Host "[5/6] Scrubbing prohibited core game assemblies & injecting manifest..." -ForegroundColor Yellow

$prohibited = @("ImGui*.dll", "FFXIVClientStructs*.dll", "Dalamud*.dll", "Interop*.dll")
foreach ($pattern in $prohibited) {
    Get-ChildItem -Path $StageDir -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "   -> Scrubbing prohibited assembly: $($_.Name)" -ForegroundColor Red
        Remove-Item $_.FullName -Force
    }
}

$iconSrc = Join-Path $RootPath "image\icon.png"
if (Test-Path $iconSrc) {
    Copy-Item $iconSrc (Join-Path $StageDir "icon.png")
}

Copy-Item $JsonPath (Join-Path $StageDir "$ProjectName.json")

# 6. Create Flat latest.zip Release Bundle
Write-Host "[6/6] Creating final flat latest.zip..." -ForegroundColor Yellow
$ZipPath = Join-Path $RootPath "latest.zip"
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

Compress-Archive -Path "$StageDir\*" -DestinationPath $ZipPath -Force

Write-Host "==================================================" -ForegroundColor Green
Write-Host " ✅ Build & Auto-Version Complete ($newVersion Ready)!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green