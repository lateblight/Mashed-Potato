# File: ProjectDump.ps1

<#
.SYNOPSIS
    Robustly exports the entire Mashed-Potato codebase (including project files) into a single text file.
#>

$ErrorActionPreference = "Stop"

$outputFile = "ProjectDump_Output.txt"
$rootPath = $PSScriptRoot
if ([string]::IsNullOrEmpty($rootPath)) { $rootPath = (Get-Location).Path }
$outputPath = Join-Path $rootPath $outputFile

if (Test-Path $outputPath) { Remove-Item $outputPath -Force }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Generating Bulletproof Project Code Dump" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Find all relevant code, project, and config files using normalised forward-slash paths
$filesToDump = Get-ChildItem -Path $rootPath -Recurse -File | Where-Object { 
    $normalizedPath = $_.FullName.Replace('\', '/')
    $extension = $_.Extension.ToLower()

    # Target text-based project extensions including .csproj
    $isWantedExtension = ($extension -in '.cs', '.ps1', '.json', '.md', '.csproj')

    # Explicitly exclude build directories, hidden folders, and lib folders
    $isForbidden = $normalizedPath -match '/(bin|obj|lib|\.vs|\.git|stage|tools)/'

    # Do not include the output dump file itself
    $isNotOutput = ($_.Name -ne $outputFile)

    return $isWantedExtension -and (-not $isForbidden) -and $isNotOutput
}

foreach ($file in $filesToDump) {
    $relPath = "./" + $file.FullName.Substring($rootPath.Length).TrimStart('\', '/').Replace('\', '/')
    Write-Host "Appending: $relPath" -ForegroundColor DarkGray

    "==================================================" | Out-File -FilePath $outputPath -Append -Encoding UTF8
    "FILE: $relPath" | Out-File -FilePath $outputPath -Append -Encoding UTF8
    "==================================================" | Out-File -FilePath $outputPath -Append -Encoding UTF8
    "" | Out-File -FilePath $outputPath -Append -Encoding UTF8

    Get-Content $file.FullName -Raw | Out-File -FilePath $outputPath -Append -Encoding UTF8
    "" | Out-File -FilePath $outputPath -Append -Encoding UTF8
    "" | Out-File -FilePath $outputPath -Append -Encoding UTF8
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Project Dump Complete! Saved to: $outputFile" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan