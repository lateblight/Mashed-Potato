# File: ./Hide-Tools.ps1

# Hide-Tools.ps1

<#
    .SYNOPSIS
    Tucks helper scripts away into a local, git-ignored folder to keep the repo clean.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Tidying away utility scripts" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$toolFolder = "tools"

# 1. Create the local tools folder if it doesn't exist
if (-not (Test-Path $toolFolder)) {
    New-Item -ItemType Directory -Path $toolFolder | Out-Null
    Write-Host "[1/3] Created local '$toolFolder' directory." -ForegroundColor Yellow
}

# 2. Drop a local .gitignore inside the tools folder so Git ignores it entirely
$localIgnore = @"
*
!.gitignore
"@
Set-Content -Path "$toolFolder/.gitignore" -Value $localIgnore -Encoding UTF8
Write-Host "[2/3] Added local ignore rules to keep Git blind to this folder." -ForegroundColor Yellow

# 3. Move all the Fix-*, Clean-*, and ProjectDump scripts safely out of the root directory
$scriptsToHide = @(
    "Clean-Repo.ps1",
    "Fix-NuGet.ps1",
    "Fix-Penumbra.ps1",
    "Fix-TheFinalBoss.ps1",
    "Fix-VSCode.ps1",
    "Fix-Workspace.ps1",
    "Fix-Xml.ps1",
    "ProjectDump.ps1",
    "ProjectDump.txt"
)

foreach ($script in $scriptsToHide) {
    if (Test-Path $script) {
        Move-Item $script -Destination "$toolFolder\" -Force
        Write-Host " -> Moved $script into '$toolFolder/'" -ForegroundColor Green
    }
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ All utility scripts safely tucked away!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
