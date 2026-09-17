<#
 *  ==================================================================
 *   _  _   _    _          _   _                      
 *  | || | | |  (_)        | | | |                     |
 *  | || |_| | ___  ___ ___| |_| |__   ___  ___        |
 *  | || __| |/ / |/ __/ __| __| '_ \ / _ \/ __|       |
 *  | || |_|   <| | (__\__ \ |_| | | |  __/\__ \       |
 *  |  _| \__|_|\_\_|\___|___/\__|_| |_|\___||___/       |
 *                                                     
 *  [ THE IMMORTAL BUILD & AUTO-BUMP ENGINE ]
 *  Elegantly increments patch versions, enforces split manifests, 
 *  and banishes git ghosts into the shadow realm.
 *  ==================================================================
#>

[CmdletBinding()]
param(
    [string]$ExplicitVersion = ""
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
$ZipPath = Join-Path $RootPath "latest.zip"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " 🥔 INITIALISING MASHED POTATO ETERNAL BUILD PIPELINE... " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

try {
    # ------------------------------------------------------------------
    # 1. ENSURE LOCAL LIB DIRECTORY FOR OFFLINE ASSEMBLY SECURITY
    # ------------------------------------------------------------------
    if (!(Test-Path $LibDir)) {
        Write-Host "[*] Creating local lib directory for offline DLLs..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $LibDir | Out-Null
    }

    if (!(Test-Path $CsprojPath)) {
        throw "Could not locate project file at: $CsprojPath"
    }

    # ------------------------------------------------------------------
    # 2. PARSE & AUTO-INCREMENT VERSION ACROSS MANIFESTS SAFELY
    # ------------------------------------------------------------------
    Write-Host "[*] Parsing current project version..." -ForegroundColor DarkGray
    [xml]$csproj = Get-Content $CsprojPath
    $propertyGroup = $csproj.Project.PropertyGroup | Select-Object -First 1

    $currentVersion = $propertyGroup.Version
    if (-not $currentVersion) {
        $currentVersion = "1.5.0.0"
    }

    # Determine whether to use explicit override or auto-increment the patch
    if ($ExplicitVersion -ne "") {
        $newVersion = $ExplicitVersion
        Write-Host "[*] Using explicit target version: $newVersion" -ForegroundColor Cyan
    } else {
        $verParts = $currentVersion.Split('.')
        [int]$patch = $verParts[-1]
        $patch++
        $verParts[-1] = $patch.ToString()
        $newVersion = [string]::Join('.', $verParts)
        Write-Host "[*] Auto-incrementing patch version: $currentVersion -> $newVersion" -ForegroundColor Green
    }

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
    Write-Host "[OK] MashedPotato.csproj elevated to v$newVersion." -ForegroundColor Green

    # ------------------------------------------------------------------
    # 3. UPDATE THE PLUGIN MANIFEST (Strictly Object - NO AsArray)
    # ------------------------------------------------------------------
    if (Test-Path $JsonPath) {
        Write-Host "[*] Tailoring plugin manifest ($JsonPath)..." -ForegroundColor DarkGray
        $pluginJson = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $pluginJson.AssemblyVersion = $newVersion
        # Serialised strictly as a standard single object to satisfy DalamudPackager
        $pluginJson | ConvertTo-Json -Depth 10 | Set-Content $JsonPath -Encoding UTF8
        Write-Host "[OK] MashedPotato.json updated successfully." -ForegroundColor Green
    } else {
        throw "Could not locate plugin JSON at: $JsonPath"
    }

    # ------------------------------------------------------------------
    # 4. UPDATE THE REPOSITORY FEED (Strictly Array - MUST use AsArray)
    # ------------------------------------------------------------------
    if (Test-Path $RepoJsonPath) {
        Write-Host "[*] Stamping repository feed ($RepoJsonPath)..." -ForegroundColor DarkGray
        $jsonContent = Get-Content $RepoJsonPath -Raw
        $rawRepo = $jsonContent | ConvertFrom-Json
        
        $repoJson = if ($rawRepo -is [System.Array]) { 
            [System.Collections.Generic.List[psobject]]$rawRepo 
        } else { 
            [System.Collections.Generic.List[psobject]]@($rawRepo) 
        }

        $found = $false
        $currentEpoch = [int64][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

        foreach ($entry in $repoJson) {
            if ($entry.InternalName -eq $ProjectName) {
                $found = $true
                $entry.AssemblyVersion = $newVersion
                $entry.LastUpdate = "$currentEpoch"
                $entry.DownloadLinkInstall = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
                $entry.DownloadLinkUpdate = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
                $entry.DownloadLinkTesting = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
            }
        }

        if (-not $found) {
            Write-Host " ⚠️ Warning: MashedPotato entry missing from repo.json. Appending..." -ForegroundColor Yellow
            $newEntry = [PSCustomObject]@{
                "Author"              = "Lateblight"
                "Name"                = "Mashed Potato"
                "InternalName"        = "MashedPotato"
                "AssemblyVersion"     = $newVersion
                "Punchline"           = "Transforms Lalafells into other races."
                "Description"         = "Tired of ankle-biters? This client-side visual filter swaps Lalafell models for a grown-up race of your choice without touching game servers. Features robust /mash configurations and a right-click in-game whitelist with blazing-fast, targeted character refreshing to instantly exclude specific players without screen flicker. Requires Penumbra."
                "ApplicableVersion"   = "any"
                "DalamudApiLevel"     = 15
                "LoadPriority"        = 0
                "IsHide"              = "False"
                "IsTestingExclusive"  = "False"
                "DownloadCount"       = 0
                "LastUpdate"          = "$currentEpoch"
                "RepoUrl"             = "https://github.com/Lateblight/Mashed-Potato"
                "Tags"                = @("lalafell", "penumbra", "model swap", "race swap", "visual filter")
                "IconUrl"             = "https://raw.githubusercontent.com/Lateblight/Mashed-Potato/main/image/icon.png"
                "DownloadLinkInstall" = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
                "DownloadLinkUpdate"  = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
                "DownloadLinkTesting" = "https://github.com/Lateblight/Mashed-Potato/raw/main/latest.zip"
            }
            $repoJson.Add($newEntry)
        }

        # Serialised strictly as a root JSON array using -AsArray
        $repoJson | ConvertTo-Json -Depth 10 -AsArray | Set-Content $RepoJsonPath -Encoding UTF8
        Write-Host "[OK] repo.json updated with epoch timestamp and v$newVersion." -ForegroundColor Green
    } else {
        throw "Could not locate repo.json at: $RepoJsonPath"
    }

    # ------------------------------------------------------------------
    # 5. PREPARE STAGING & COMPILE .NET 10 PROJECT
    # ------------------------------------------------------------------
    Write-Host "[*] Preparing staging directories..." -ForegroundColor Yellow
    if (Test-Path $StageDir) {
        Remove-Item -Recurse -Force $StageDir
    }
    New-Item -ItemType Directory -Path $StageDir | Out-Null

    Write-Host "[*] Compiling .NET 10 project directly to staging folder..." -ForegroundColor Cyan
    dotnet publish $CsprojPath -c Release -o $StageDir --nologo

    # ------------------------------------------------------------------
    # 6. SCRUB PROHIBITED CORE GAME ASSEMBLIES & INJECT ASSETS
    # ------------------------------------------------------------------
    Write-Host "[*] Scrubbing prohibited core game assemblies & injecting assets..." -ForegroundColor Yellow

    $prohibited = @("ImGui*.dll", "FFXIVClientStructs*.dll", "Dalamud*.dll", "Interop*.dll")
    foreach ($pattern in $prohibited) {
        Get-ChildItem -Path $StageDir -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "    -> Scrubbing prohibited assembly: $($_.Name)" -ForegroundColor Red
            Remove-Item $_.FullName -Force
        }
    }

    $iconSrc = Join-Path $RootPath "image\icon.png"
    if (Test-Path $iconSrc) {
        Copy-Item $iconSrc (Join-Path $StageDir "icon.png")
    }

    Copy-Item $JsonPath (Join-Path $StageDir "$ProjectName.json")

    # ------------------------------------------------------------------
    # 7. CREATE FLAT latest.zip RELEASE BUNDLE
    # ------------------------------------------------------------------
    Write-Host "[*] Creating final flat latest.zip..." -ForegroundColor Yellow
    if (Test-Path $ZipPath) {
        Remove-Item $ZipPath -Force
    }
    Compress-Archive -Path "$StageDir\*" -DestinationPath $ZipPath -Force

    # ------------------------------------------------------------------
    # 8. PURGE GHOST ARTEFACTS & PUBLISH TO GITHUB
    # ------------------------------------------------------------------
    Write-Host "[*] Purging untracked build artefacts from git index..." -ForegroundColor DarkGray
    git rm -r --cached stage/ 2>$null
    git rm -r --cached MashedPotato/bin/ 2>$null
    git rm -r --cached MashedPotato/obj/ 2>$null

    Write-Host "[*] Staging architectural masterworks for GitHub..." -ForegroundColor Cyan
    git add .
    git commit -m "🚀 Release v${newVersion}: Auto-incremented patch build with absolute geometric harmony"

    Write-Host "[*] Pushing version $newVersion to GitHub origin..." -ForegroundColor Magenta
    git push origin main --force-with-lease

    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "   ✨ v$newVersion SUCCESSFULLY PUBLISHED TO GITHUB! ✨" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "---- Start errors" -ForegroundColor Red
    Write-Host "Mashed Potato Build Pipeline Encountered a Fatal Exception:" -ForegroundColor Yellow
    Write-Host "Error Message:             $($_.Exception.Message)" -ForegroundColor White
    Write-Host "Script Line Number:        $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor White
    Write-Host "Fully Qualified Error ID:  $($_.FullyQualifiedErrorId)" -ForegroundColor White
    Write-Host "Stack Trace:" -ForegroundColor DarkGray
    foreach ($line in ($_.ScriptStackTrace -split "`n")) {
        Write-Host "  $line" -ForegroundColor DarkGray
    }
    Write-Host "---- End errors." -ForegroundColor Red
    Write-Host ""
    exit 1
}