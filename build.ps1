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

# 2. Parse and Auto-Increment Version across manifests safely
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

# Split version and increment the minor/build patch
$verParts = $currentVersion.Split('.')
[int]$patch = $verParts[-1]
$patch++
$verParts[-1] = $patch.ToString()
$newVersion = [string]::Join('.', $verParts)

# Explicitly set version properties in .csproj
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

# Update Plugin JSON (MashedPotato.json) preserving all other properties
if (Test-Path $JsonPath) {
    $pluginJson = Get-Content $JsonPath -Raw | ConvertFrom-Json
    $pluginJson.AssemblyVersion = $newVersion
    $pluginJson | ConvertTo-Json -Depth 10 | Set-Content $JsonPath
}

# Update Repo JSON (repo.json) with strict schema and array enforcement
if (Test-Path $RepoJsonPath) {
    $jsonContent = Get-Content $RepoJsonPath -Raw
    $rawRepo = $jsonContent | ConvertFrom-Json
    
    $repoJson = if ($rawRepo -is [System.Array]) { 
        [System.Collections.Generic.List[psobject]]$rawRepo 
    } else { 
        [System.Collections.Generic.List[psobject]]@($rawRepo) 
    }

    $found = $false
    $currentEpoch = [int][double]::Parse((Get-Date -UFormat %s))

    foreach ($entry in $repoJson) {
        if ($entry.InternalName -eq $ProjectName) {
            $found = $true
            $entry.AssemblyVersion = $newVersion

            # Ensure mandatory Dalamud API 15 and full repository metadata properties exist
            $metadata = @{
                'Punchline'           = 'Transforms Lalafells into other races.'
                'DalamudApiLevel'     = 15
                'LoadPriority'        = 0
                'IsHide'              = "False"
                'IsTestingExclusive'  = "False"
                'DownloadCount'       = 0
                'LastUpdate'          = "$currentEpoch"
            }

            foreach ($key in $metadata.Keys) {
                if (-not $entry.PSObject.Properties[$key]) {
                    $entry | Add-Member -NotePropertyName $key -NotePropertyValue $metadata[$key] -Force
                } else {
                    $entry.$key = $metadata[$key]
                }
            }

            $entry.DownloadLinkInstall = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
            $entry.DownloadLinkUpdate = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
            $entry.DownloadLinkTesting = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
        }
    }

    if (-not $found) {
        Write-Host " ⚠️ Warning: MashedPotato entry missing from repo.json. Appending..." -ForegroundColor Yellow
        $newEntry = [PSCustomObject]@{
            "Author"             = "Lateblight, Avaflow, Ars Magna, Kelvin"
            "Name"               = "Mashed Potato"
            "InternalName"       = "MashedPotato"
            "AssemblyVersion"    = $newVersion
            "Punchline"          = "Transforms Lalafells into other races."
            "Description"        = "Tired of ankle-biters? This client-side visual filter swaps Lalafell models for a grown-up race of your choice without touching game servers. Features robust /mash configurations and a right-click in-game whitelist with blazing-fast, targeted character refreshing to instantly exclude specific players without screen flicker. Requires Penumbra."
            "ApplicableVersion"  = "any"
            "DalamudApiLevel"    = 15
            "LoadPriority"       = 0
            "IsHide"             = "False"
            "IsTestingExclusive" = "False"
            "DownloadCount"      = 0
            "LastUpdate"         = "$currentEpoch"
            "RepoUrl"            = "https://github.com/Lateblight/Mashed-Potato"
            "Tags"               = @("lalafell", "penumbra", "model swap", "race swap", "visual filter")
            "IconUrl"            = "https://raw.githubusercontent.com/Lateblight/Mashed-Potato/main/image/icon.png"
            "DownloadLinkInstall"= "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
            "DownloadLinkUpdate" = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
            "DownloadLinkTesting"= "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
        }
        $repoJson.Add($newEntry)
    }

    # CRITICAL: Force serialization wrapper to guarantee root square brackets `[ { ... } ]`
    $finalArray = @($repoJson)
    $jsonOutput = $finalArray | ConvertTo-Json -Depth 10
    if (-not $jsonOutput.TrimStart().StartsWith("[")) {
        $jsonOutput = "[$jsonOutput]"
    }
    $jsonOutput | Set-Content $RepoJsonPath -Encoding UTF8
}

Write-Host "✨ Bumping Version -> $newVersion (Manifests fully synchronised)" -ForegroundColor Green

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
Write-Host "==================================================" -ForegroundColor Cyan