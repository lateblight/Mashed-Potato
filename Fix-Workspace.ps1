# Mashed-Potato/Fix-Workspace.ps1

<#
    .SYNOPSIS
    Bans the problematic .slnx format, forces a classic .sln, and writes our formatting rules.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Workspace & Formatting Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/3] Binning the troublesome .slnx file..." -ForegroundColor Yellow
$slnxFile = "Mashed-Potato.slnx"
if (Test-Path $slnxFile) {
    Remove-Item $slnxFile -Force
}

$slnFile = "Mashed-Potato.sln"
if (Test-Path $slnFile) {
    Remove-Item $slnFile -Force
}

Write-Host "[2/3] Forcing the classic .sln format so VS Code stops whinging..." -ForegroundColor Yellow
dotnet new sln -n Mashed-Potato | Out-Null

# Just in case the modern SDK spits out an .slnx anyway, we bin it and create a barebones classic .sln
if (Test-Path $slnxFile) {
    Remove-Item $slnxFile -Force
    $classicSln = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "MashedPotato", "MashedPotato\MashedPotato.csproj", "{00000000-0000-0000-0000-000000000000}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{00000000-0000-0000-0000-000000000000}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{00000000-0000-0000-0000-000000000000}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{00000000-0000-0000-0000-000000000000}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{00000000-0000-0000-0000-000000000000}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
"@
    Set-Content -Path $slnFile -Value $classicSln -Encoding UTF8
} else {
    dotnet sln add MashedPotato/MashedPotato.csproj | Out-Null
}
dotnet restore

Write-Host "[3/3] Writing the .editorconfig blueprint..." -ForegroundColor Yellow
$editorConfigPath = ".editorconfig"
$editorConfigContent = @"
# Top-most EditorConfig file for Mashed Potato
root = true

# Catch-all rules for every file in the repo
[*]
indent_style = space
indent_size = 4
end_of_line = crlf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

# Specific rules for our C# scripts
[*.cs]
# Keep our imports tidy at the top
dotnet_sort_system_directives_first = true
dotnet_separate_import_directive_groups = false

# Proper C# brace placement (Allman style)
csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true

# Indentation logic
csharp_indent_case_contents = true
csharp_indent_switch_labels = true
csharp_indent_labels = one_less_than_current
csharp_indent_block_contents = true
csharp_indent_braces = false

# Force 'var' when the type is obvious, otherwise use explicit types
csharp_style_var_for_built_in_types = false:suggestion
csharp_style_var_when_type_is_apparent = true:suggestion
csharp_style_var_elsewhere = false:suggestion
"@

Set-Content -Path $editorConfigPath -Value $editorConfigContent -Encoding UTF8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Classic Solution and .editorconfig created. Restart VS Code!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan