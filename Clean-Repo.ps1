<#
.SYNOPSIS
    Automated Git Cleanup & Repository Sanitizer
#>

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Initializing Git Sanitizer" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/3] Removing compiled binaries from Git tracking..." -ForegroundColor Yellow
# This removes them from Git's memory, but keeps them on your hard drive
git rm -r --cached MashedPotato/bin -q 2>$null
git rm -r --cached MashedPotato/obj -q 2>$null
git rm -r --cached .vs -q 2>$null

Write-Host "[2/3] Writing bulletproof .gitignore..." -ForegroundColor Yellow
$gitignore = @"
# Build results
[Dd]ebug/
[Rr]elease/
x64/
x86/
[Bb]in/
[Oo]bj/

# Visual Studio / VS Code
.vs/
*.user
*.suo

# Automated Pipeline Packages
latest.zip
MashedPotato/stage/
MashedPotato/lib/
"@
Set-Content -Path ".gitignore" -Value $gitignore -Encoding UTF8

Write-Host "[3/3] Committing the cleanup..." -ForegroundColor Yellow
git add .gitignore
git commit -m "chore: sanitize repository and update gitignore"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Git Repository Cleaned Successfully!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan