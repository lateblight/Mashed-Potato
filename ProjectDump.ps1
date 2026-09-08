# Mashed-Potato/Export-Codebase.ps1

<#
    Pulls together all your human-readable source code into one tidy text file.
    Leaves behind the heavy binaries, compiled junk, and git history.
#>

$outFile = "ProjectDump.txt"
if (Test-Path $outFile) { Remove-Item $outFile -Force }

# Folders we definitely do not want snooping through
$excludeFolders = @('.git', 'bin', 'obj', 'lib', 'dist', '.vs', '.vscode')

# Extensions we actually care about reading
$includeExtensions = @('.cs', '.csproj', '.json', '.ps1', '.md')

Write-Host "Gathering your code files..." -ForegroundColor Cyan

$files = Get-ChildItem -Recurse -File | Where-Object {
    $item = $_
    $skip = $false

    # Check if the file lives in a banned directory
    foreach ($folder in $excludeFolders) {
        if ($item.FullName -match "[\\/]$folder([\\/]|$)") {
            $skip = $true
            break
        }
    }

    # Keep only source code and configs
    if (-not $skip -and ($includeExtensions -contains $item.Extension)) {
        # Skip giant generated lockfiles
        if ($item.Name -eq "packages.lock.json") { return $false }
        return $true
    }
    return $false
}

$stream = [System.IO.StreamWriter]::new($outFile)

foreach ($file in $files) {
    # Keep the path relative so it's clean and easy to read
    $relativePath = Resolve-Path -Relative $file.FullName
    
    $stream.WriteLine("================================================================================")
    $stream.WriteLine("File: $relativePath")
    $stream.WriteLine("================================================================================")
    
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $stream.WriteLine($content)
    $stream.WriteLine("")
    
    Write-Host "Bundled: $relativePath" -ForegroundColor Green
}

$stream.Dispose()

Write-Host "`nAll sorted! Created $outFile." -ForegroundColor Cyan
Write-Host "You can now drop $outFile straight into the chat." -ForegroundColor Yellow