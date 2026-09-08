# Mashed-Potato/Fix-TheFinalBoss.ps1

<#
    .SYNOPSIS
    Surgically removes the dodgy NuGet dependency and fetches Luna.dll locally.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] The Final Boss: Offline Luna.dll" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$libFolder = "MashedPotato/lib"
$penumbraSource = "$env:APPDATA\XIVLauncher\installedPlugins\Penumbra"

Write-Host "[1/4] Hunting for Luna.dll in your local game files..." -ForegroundColor Yellow
if (Test-Path $penumbraSource) {
    # Grab the Luna library directly from Penumbra's installation
    $lunaDll = Get-ChildItem -Path $penumbraSource -Filter "Luna.dll" -Recurse | Select-Object -First 1
    if ($lunaDll) {
        Copy-Item $lunaDll.FullName -Destination "$libFolder\Luna.dll" -Force
        Write-Host " -> Success: Nabbed Luna.dll and chucked it in the lib folder!" -ForegroundColor Green
    } else {
        Write-Host " -> Error: Found Penumbra, but Luna.dll has gone walkabout." -ForegroundColor Red
    }
} else {
    Write-Host " -> Error: Couldn't locate Penumbra in your installed plugins." -ForegroundColor Red
}

Write-Host "[2/4] Rewriting NuGet.Config to remove the dead feed..." -ForegroundColor Yellow
$rootNugetPath = "NuGet.Config"
$nugetContent = '<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
  </packageSources>
</configuration>'
Set-Content -Path $rootNugetPath -Value $nugetContent -NoNewline -Encoding UTF8

Write-Host "[3/4] Rewriting .csproj to use 100% offline libraries..." -ForegroundColor Yellow
$csprojPath = "MashedPotato/MashedPotato.csproj"
$csprojContent = '<?xml version="1.0" encoding="utf-8"?>
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0-windows</TargetFramework>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <ProduceReferenceAssembly>false</ProduceReferenceAssembly>
    <AppendTargetFrameworkToOutputPath>false</AppendTargetFrameworkToOutputPath>
    <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
    <Version>1.1.0.35</Version>
  </PropertyGroup>

  <PropertyGroup>
    <DalamudLibPath>$(appdata)\XIVLauncher\addon\Hooks\dev\</DalamudLibPath>
  </PropertyGroup>

  <ItemGroup>
    <Reference Include="Dalamud">
      <HintPath>$(DalamudLibPath)Dalamud.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Dalamud.Bindings.ImGui">
      <HintPath>$(DalamudLibPath)Dalamud.Bindings.ImGui.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Lumina">
      <HintPath>$(DalamudLibPath)Lumina.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Lumina.Excel">
      <HintPath>$(DalamudLibPath)Lumina.Excel.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="FFXIVClientStructs">
      <HintPath>$(DalamudLibPath)FFXIVClientStructs.dll</HintPath>
      <Private>false</Private>
    </Reference>
    
    <!-- Pure offline references. No NuGet feeds required for these! -->
    <Reference Include="Penumbra.Api">
      <HintPath>lib\Penumbra.Api.dll</HintPath>
      <Private>false</Private>
    </Reference>
    <Reference Include="Luna">
      <HintPath>lib\Luna.dll</HintPath>
      <Private>false</Private>
    </Reference>
  </ItemGroup>
</Project>'
Set-Content -Path $csprojPath -Value $csprojContent -NoNewline -Encoding UTF8

Write-Host "[4/4] Binning the jams and restoring..." -ForegroundColor Yellow
$rubbishBins = @(".vs", "MashedPotato/obj", "MashedPotato/bin")
foreach ($bin in $rubbishBins) {
    if (Test-Path $bin) { Remove-Item -Recurse -Force $bin }
}
dotnet restore

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ✅ Fully offline and ready! Run ./build.ps1 now." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan