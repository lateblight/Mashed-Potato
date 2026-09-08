# Mashed-Potato/Fix-VSCode.ps1

<#
    .SYNOPSIS
    Slaps the VS Code C# Dev Kit awake by giving it a proper Solution file.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Fixing VS Code's Tantrum" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Chuck the local caches in the bin to clear the slate
$rubbishBins = @(".vs", "MashedPotato/obj", "MashedPotato/bin")
foreach ($bin in $rubbishBins) {
    if (Test-Path $bin) {
        Remove-Item -Recurse -Force $bin
        Write-Host "Chucked $bin in the bin." -ForegroundColor Yellow
    }
}

# 2. Nuke any existing solution file so we start fresh
$slnFile = "Mashed-Potato.sln"
if (Test-Path $slnFile) {
    Remove-Item $slnFile -Force
    Write-Host "Swept away the old Solution file." -ForegroundColor Yellow
}

# 3. Create a brand new shiny Solution file
Write-Host "Drafting a proper Solution index card for the librarian..." -ForegroundColor Cyan
dotnet new sln -n Mashed-Potato | Out-Null

# 4. Link our project to the new Solution so VS Code knows where to look
Write-Host "Linking MashedPotato.csproj to the new Solution..." -ForegroundColor Cyan
dotnet sln add MashedPotato/MashedPotato.csproj | Out-Null

# 5. One last restore to lock it all in
Write-Host "Doing a final package restore to satisfy the compiler..." -ForegroundColor Cyan
dotnet restore

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Sorted! Please completely close and reopen VS Code." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan