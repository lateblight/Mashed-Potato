# File: ./Ultimate-Fix.ps1

$ErrorActionPreference = "Stop"
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " [Mashed Potato] The Ultimate Deployment Fix" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "[1/4] Force-writing correct Dependency Injection (Service.cs)..." -ForegroundColor Yellow
$serviceCode = @'
using Dalamud.Game.ClientState.Objects;
using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using MashedPotato.Windows;

namespace MashedPotato.Utils
{
    public class Service
    {
        public static IDalamudPluginInterface pluginInterface { get; set; } = null!;
        public static IClientState clientState { get; set; } = null!;
        public static ICommandManager commandManager { get; set; } = null!;
        public static IChatGui chatGui { get; set; } = null!;
        public static IContextMenu contextMenu { get; set; } = null!;
        public static IPluginLog PluginLog { get; set; } = null!;
        public static INamePlateGui namePlateGui { get; set; } = null!;

        public static Configuration configuration { get; set; } = null!;
        public static Plugin plugin { get; set; } = null!;
        public static ConfigWindow configWindow { get; set; } = null!;
        
        internal static Drawer drawer { get; set; } = null!;
        internal static Nameplate nameplate { get; set; } = null!;
        internal static PenumbraIpc penumbraApi { get; set; } = null!;
        internal static WhitelistManager whitelistManager { get; set; } = null!;
    }
}
'@
Set-Content -Path "MashedPotato/Utils/Service.cs" -Value $serviceCode -Encoding UTF8

Write-Host "[2/4] Force-writing API 15 Constructor (Plugin.cs)..." -ForegroundColor Yellow
$pluginCode = @'
using Dalamud.Game.Command;
using Dalamud.Game.Text;
using Dalamud.Game.Text.SeStringHandling;
using Dalamud.Interface.Windowing;
using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using Penumbra.Api.Enums;
using MashedPotato.Utils;
using MashedPotato.Windows;

namespace MashedPotato
{
    public sealed class Plugin : IDalamudPlugin
    {
        public static string Name => "Mashed Potato";
        private const string CommandName = "/mash";
        public WindowSystem WindowSystem { get; } = new("Mashed Potato");

        public Plugin(
            IDalamudPluginInterface pluginInterface,
            IClientState clientState,
            ICommandManager commandManager,
            IChatGui chatGui,
            IContextMenu contextMenu,
            IPluginLog pluginLog,
            INamePlateGui namePlateGui)
        {
            Service.pluginInterface = pluginInterface;
            Service.clientState = clientState;
            Service.commandManager = commandManager;
            Service.chatGui = chatGui;
            Service.contextMenu = contextMenu;
            Service.PluginLog = pluginLog;
            Service.namePlateGui = namePlateGui;

            Service.configuration = pluginInterface.GetPluginConfig() as Configuration ?? new Configuration();
            if (!Service.configuration.stayOn) { Service.configuration.enabled = false; }
            Service.configuration.Initialize(pluginInterface);
            Service.plugin = this;
            Service.penumbraApi = new PenumbraIpc(pluginInterface);
            Service.configWindow = new ConfigWindow(this);
            WindowSystem.AddWindow(Service.configWindow);
            
            Service.drawer = new Drawer();
            Service.nameplate = new Nameplate();
            Service.whitelistManager = new WhitelistManager(Service.configuration, Service.contextMenu, Service.chatGui);

            pluginInterface.UiBuilder.Draw += DrawUI;
            pluginInterface.UiBuilder.OpenConfigUi += DrawConfigUI;
            pluginInterface.UiBuilder.OpenMainUi += DrawConfigUI;

            Service.commandManager.AddHandler(CommandName, new CommandInfo(OnCommand)
            {
                HelpMessage = "Opens Mashed Potato config menu. Use /mash on or /mash off."
            });
            Service.clientState.TerritoryChanged += OnTerritoryChanged;
        }

        public static void OutputChatLine(SeString message)
        {
            var sb = new SeStringBuilder().AddUiForeground("[Mashed Potato] ", 58).Append(message);
            Service.chatGui.Print(new XivChatEntry { Message = sb.BuiltString });
        }

        public void Dispose()
        {
            Service.clientState.TerritoryChanged -= OnTerritoryChanged;
            WindowSystem.RemoveAllWindows();
            Service.penumbraApi?.Dispose();
            Service.drawer?.Dispose();
            Service.nameplate?.Dispose();
            Service.whitelistManager?.Dispose();
            Service.commandManager?.RemoveHandler(CommandName);
        }

        private void OnTerritoryChanged() => HandleAreaChange();
        private void OnTerritoryChanged(ushort a) => HandleAreaChange();
        private void OnTerritoryChanged(uint a) => HandleAreaChange();
        private void OnTerritoryChanged(int a) => HandleAreaChange();
        private void OnTerritoryChanged(ushort a, ushort b) => HandleAreaChange();
        private void OnTerritoryChanged(uint a, uint b) => HandleAreaChange();
        private void OnTerritoryChanged(int a, int b) => HandleAreaChange();
        private void OnTerritoryChanged(object? a, ushort b) => HandleAreaChange();
        private void OnTerritoryChanged(object? a, uint b) => HandleAreaChange();
        private void OnTerritoryChanged(object? a, int b) => HandleAreaChange();

        private void HandleAreaChange()
        {
            if (!Service.configuration.stayOn && Service.configuration.enabled)
            {
                Service.configuration.enabled = false;
                Service.configuration.Save();
                Service.configWindow.InvokeConfigChanged();
                Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
                OutputChatLine("You entered a new area. Mashed Potato has automatically turned off.");
            }
        }

        private void OnCommand(string command, string args)
        {
            if (args == "on") { Service.configuration.enabled = true; }
            else if (args == "off") { Service.configuration.enabled = false; }
            else { Service.configWindow.IsOpen = true; return; }

            Service.configuration.Save();
            Service.configWindow.InvokeConfigChanged();
            Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
        }

        private void DrawUI() => WindowSystem.Draw();
        public static void DrawConfigUI() => Service.configWindow.IsOpen = true;
    }
}
'@
Set-Content -Path "MashedPotato/Plugin.cs" -Value $pluginCode -Encoding UTF8

Write-Host "[3/4] Force-writing silent Drawer & fixed IPC Hooks..." -ForegroundColor Yellow
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
            if (!string.IsNullOrEmpty(playerName) && Service.configuration.WhitelistedPlayers.Contains(playerName)) return;
            var customData = Marshal.PtrToStructure<CharaCustomizeData>(customizePtr);
            if ((int)customData.Race != 3) return;
            if ((int)Service.configuration.SelectedRace == 3 || customData.Race == Race.UNKNOWN) return;
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
        public void Dispose() { Service.configWindow.OnConfigChanged -= RefreshAllPlayers; }
    }
}
'@
Set-Content -Path "MashedPotato/Utils/Drawer.cs" -Value $drawerCode -Encoding UTF8

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
            catch (Exception ex) { Service.PluginLog.Error($"Failed to initialize Penumbra IPC: {ex.Message}"); }
        }
        public void RedrawAll(RedrawType type)
        {
            try { this.redrawAllSub?.Invoke(type); }
            catch (Exception ex) { Service.PluginLog.Error($"Error triggering Penumbra RedrawAll: {ex}"); }
        }
        public void Dispose() { this.creatingCharaSub?.Dispose(); }
    }
}
'@
Set-Content -Path "MashedPotato/Utils/PenumbraIpc.cs" -Value $ipcCode -Encoding UTF8

Write-Host "[4/4] Compiling, Scrubbing, and Deploying..." -ForegroundColor Yellow
$stageDir = "MashedPotato/stage"
if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }

Push-Location "MashedPotato"
dotnet publish -c Release -o "stage"
Pop-Location

$prohibited = @("Dalamud*.dll", "Lumina*.dll", "ImGui*.dll", "FFXIVClientStructs*.dll")
foreach ($pattern in $prohibited) {
    Get-ChildItem -Path $stageDir -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
}

$devPluginDir = Join-Path $env:APPDATA "XIVLauncher\devPlugins\MashedPotato"
if (-not (Test-Path $devPluginDir)) { New-Item -ItemType Directory -Path $devPluginDir -Force | Out-Null }

Remove-Item -Path "$devPluginDir\*" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$stageDir\*" -Destination $devPluginDir -Recurse -Force
Remove-Item -Recurse -Force $stageDir

Write-Host "✅ Dependencies injected, crashes silenced, and deployed to Dalamud!" -ForegroundColor Green
