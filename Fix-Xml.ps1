# Mashed-Potato/Fix-Xml.ps1

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] Surgically fixing XML files" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$nugetPath = "NuGet.Config"
$csprojPath = "MashedPotato/MashedPotato.csproj"

# Using single quotes directly against the tag prevents any newlines from sneaking in
$nugetContent = '<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    <add key="Dalamud" value="https://dalamud-nuget.goats.dev/v3/index.json" />
  </packageSources>
</configuration>'

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
    <Version>1.1.0.33</Version>
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
    <Reference Include="Penumbra.Api">
      <HintPath>lib\Penumbra.Api.dll</HintPath>
      <Private>false</Private>
    </Reference>
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Luna" Version="1.7.0.12" />
  </ItemGroup>
</Project>'

Set-Content -Path $nugetPath -Value $nugetContent -NoNewline -Encoding UTF8
Set-Content -Path $csprojPath -Value $csprojContent -NoNewline -Encoding UTF8

Write-Host "✅ XML files written perfectly!" -ForegroundColor Green