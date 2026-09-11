# File: ./Fix-TheFinalBoss.ps1

$ErrorActionPreference = "Stop"
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] The Final Boss Fix" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/3] Force-writing correct C# files..." -ForegroundColor Yellow
$drawerPath = "MashedPotato/Utils/Drawer.cs"
$drawerCode = @'
using FFXIVClientStructs.FFXIV.Client.Game.Object;
using Penumbra.Api.Enums;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using static MashedPotato.Utils.Constant;

namespace MashedPotato.Utils
{
    internal class Drawer : IDisposable
    {
        public static HashSet<string> NonNativeID = new();

        public Drawer()
        {
            Service.configWindow.OnConfigChanged += RefreshAllPlayers;
            if (Service.configuration.enabled)
            {
                Service.PluginLog.Information("Mashed-Potato loaded quietly.");
                RefreshAllPlayers();
            }
        }

        private static void RefreshAllPlayers()
        {
            Service.PluginLog.Information("Refreshing all players");
            NonNativeID.Clear();
            Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
            Service.namePlateGui?.RequestRedraw();
        }

        public static unsafe void OnCreatingCharacterBase(nint gameObjectAddress, Guid _1, nint _2, nint customizePtr, nint _3)
        {
            if (!Service.configuration.enabled) return;

            var gameObj = (GameObject*)gameObjectAddress;
            if (gameObj->ObjectKind != ObjectKind.Pc) return;

            var playerName = gameObj->NameString;

            if (!string.IsNullOrEmpty(playerName) && Service.configuration.WhitelistedPlayers.Contains(playerName))
                return;

            var customData = Marshal.PtrToStructure<CharaCustomizeData>(customizePtr);
            
            if ((int)customData.Race != 3)
                return;

            if ((int)Service.configuration.SelectedRace == 3 || customData.Race == Race.UNKNOWN)
                return;

            NonNativeID.Add(playerName);
            ChangeRace(customData, customizePtr, (Race)Service.configuration.SelectedRace);
        }

        private static unsafe void ChangeRace(CharaCustomizeData customData, nint customizePtr, Race selectedRace)
        {
            customData.Race = selectedRace;
            customData.Tribe = (byte)(((byte)selectedRace * 2) - (customData.Tribe % 2));
            customData.FaceType %= 4;
            customData.ModelType %= 2;
            customData.HairStyle = (byte)((customData.HairStyle % RaceMappings.RaceHairs[selectedRace]) + 1);
            Marshal.StructureToPtr(customData, customizePtr, true);
        }

        public void Dispose()
        {
            Service.configWindow.OnConfigChanged -= RefreshAllPlayers;
        }
    }
}
'@
Set-Content -Path $drawerPath -Value $drawerCode -Encoding UTF8

$ipcPath = "MashedPotato/Utils/PenumbraIpc.cs"
$ipcCode = @'
using System;
using Dalamud.Plugin;
using Penumbra.Api.Enums;
using Penumbra.Api.IpcSubscribers;

namespace MashedPotato.Utils
{
    public sealed class PenumbraIpc : IDisposable
    {
        private readonly IDalamudPluginInterface pi;
        private readonly RedrawAll? redrawAllSub;
        private readonly IDisposable? creatingCharaSub;

        public PenumbraIpc(IDalamudPluginInterface pluginInterface)
        {
            this.pi = pluginInterface;

            try
            {
                this.redrawAllSub = new RedrawAll(pluginInterface);
                this.creatingCharaSub = (IDisposable)CreatingCharacterBase.Subscriber(pluginInterface, Drawer.OnCreatingCharacterBase);
            }
            catch (Exception ex)
            {
                Service.PluginLog.Error($"Failed to initialize Penumbra IPC: {ex.Message}");
            }
        }

        public void RedrawAll(RedrawType type)
        {
            try
            {
                this.redrawAllSub?.Invoke(type);
            }
            catch (Exception ex)
            {
                Service.PluginLog.Error($"Error triggering Penumbra RedrawAll: {ex}");
            }
        }

        public void Dispose()
        {
            this.creatingCharaSub?.Dispose();
        }
    }
}
'@
Set-Content -Path $ipcPath -Value $ipcCode -Encoding UTF8

Write-Host "[2/3] Compiling and scrubbing..." -ForegroundColor Yellow
$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }

Push-Location "MashedPotato"
dotnet publish -c Release -o "stage"
Pop-Location

$prohibited = @("Dalamud*.dll", "Lumina*.dll", "ImGui*.dll", "FFXIVClientStructs*.dll")
foreach ($pattern in $prohibited) {
    Get-ChildItem -Path $stageDir -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
}
Copy-Item "MashedPotato/MashedPotato.json" -Destination "$stageDir/MashedPotato.json" -Force

Write-Host "[3/3] Deploying to Dev Plugins..." -ForegroundColor Yellow
$devPluginDir = Join-Path $env:APPDATA "XIVLauncher\devPlugins\MashedPotato"
if (-not (Test-Path $devPluginDir)) { New-Item -ItemType Directory -Path $devPluginDir -Force | Out-Null }

Remove-Item -Path "$devPluginDir\*" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$stageDir\*" -Destination $devPluginDir -Recurse -Force
Remove-Item -Recurse -Force $stageDir

Write-Host "✅ The Final Boss defeated! Deployed to Dalamud." -ForegroundColor Green
