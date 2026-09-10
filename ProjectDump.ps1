# File: ProjectDump.ps1

<#
.SYNOPSIS
    Exports the entire Mashed-Potato codebase into a single, structured text file for easy review.
#>

$ErrorActionPreference = "Stop"

$outputFile = "ProjectDump_Output.txt"
if (Test-Path $outputFile) { Remove-Item $outputFile }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Generating Project Code Dump" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Find all relevant code and config files, excluding build artifacts and hidden git folders
$filesToDump = Get-ChildItem -Recurse -File | Where-Object { 
    $_.Extension -match '(.cs|.ps1|.json|.md)$' -and 
    $_.FullName -notmatch '\\(bin|obj|lib|\.vs|\.git|stage|tools)\\' -and
    $_.Name -ne $outputFile
}

foreach ($file in $filesToDump) {
    $relativePath = (Resolve-Path -Relative $file.FullName).Replace('\', '/')
    Write-Host "Appending: $relativePath" -ForegroundColor DarkGray

    # Write a clean separator header for each file
    "==================================================" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "FILE: $relativePath" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "==================================================" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "" | Out-File -FilePath $outputFile -Append -Encoding UTF8

    # Append the actual file content
    Get-Content $file.FullName -Raw | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "" | Out-File -FilePath $outputFile -Append -Encoding UTF8
    "" | Out-File -FilePath $outputFile -Append -Encoding UTF8
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Project Dump Complete! Saved to: $outputFile" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan