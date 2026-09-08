<#
.SYNOPSIS
    Automated Local Library Fetcher & Offline .csproj Injector
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Initializing Local API Fetcher" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$libFolder = "MashedPotato/lib"
$penumbraSource = "$env:APPDATA\XIVLauncher\installedPlugins\Penumbra"

Write-Host "[1/3] Setting up local lib environment..." -ForegroundColor Yellow
if (-not (Test-Path $libFolder)) {
    New-Item -ItemType Directory -Path $libFolder | Out-Null
}

Write-Host "[2/3] Hunting for Penumbra.Api in your FFXIV installation..." -ForegroundColor Yellow
if (Test-Path $penumbraSource) {
    $apiDll = Get-ChildItem -Path $penumbraSource -Filter "Penumbra.Api.dll" -Recurse | Select-Object -First 1
    if ($apiDll) {
        Copy-Item $apiDll.FullName -Destination "$libFolder\Penumbra.Api.dll" -Force
        Write-Host " -> Success: Copied Penumbra.Api.dll to local lib folder!" -ForegroundColor Green
    } else {
        Write-Host " -> Error: Found Penumbra folder, but no API dll inside." -ForegroundColor Red
    }
} else {
    Write-Host " -> Error: Could not find Penumbra in your installed plugins." -ForegroundColor Red
}

Write-Host "[3/3] Writing 100% Offline .csproj file..." -ForegroundColor Yellow
$csprojPath = "MashedPotato/MashedPotato.csproj"
$csprojContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0-windows</TargetFramework>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <ProduceReferenceAssembly>false</ProduceReferenceAssembly>
    <AppendTargetFrameworkToOutputPath>false</AppendTargetFrameworkToOutputPath>
    <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
    <Version>1.1.0.29</Version>
  </PropertyGroup>

  <PropertyGroup>
    <DalamudLibPath>`$(appdata)\XIVLauncher\addon\Hooks\dev\</DalamudLibPath>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="Dalamud">
      <HintPath>`$(DalamudLibPath)Dalamud.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Dalamud.Bindings.ImGui">
      <HintPath>`$(DalamudLibPath)Dalamud.Bindings.ImGui.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Lumina">
      <HintPath>`$(DalamudLibPath)Lumina.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Lumina.Excel">
      <HintPath>`$(DalamudLibPath)Lumina.Excel.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="FFXIVClientStructs">
      <HintPath>`$(DalamudLibPath)FFXIVClientStructs.dll</HintPath>
      <Private>false</Private>
    </Reference>
    
    <!-- 100% Offline Local Fallback for Penumbra -->
    <Reference Include="Penumbra.Api">
      <HintPath>lib\Penumbra.Api.dll</HintPath>
      <Private>false</Private>
    </Reference>
  </ItemGroup>
</Project>
"@
Set-Content -Path $csprojPath -Value $csprojContent -Encoding utf8

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Offline Environment Ready! Run ./build.ps1 next." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan