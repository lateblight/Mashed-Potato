# File: Fix-NuGet.ps1

<#
.SYNOPSIS
    Clears out the local cache and does a proper clean restore.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Exorcising the NuGet Ghosts" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/2] Scrubbing out the corrupted local NuGet caches..." -ForegroundColor Yellow
dotnet nuget locals all --clear

Write-Host "[2/2] Forcing a clean package restore..." -ForegroundColor Yellow
dotnet restore

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Packages restored cleanly! VS Code should stop whinging now." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan