using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using OopsAllLalafellsSRE.Windows;
using MashedPotato;

namespace OopsAllLalafellsSRE.Utils
{
    public class Service
    {
        [PluginService] internal static IDalamudPluginInterface pluginInterface { get; set; } = null!;
        [PluginService] internal static IClientState clientState { get; set; } = null!;
        [PluginService] internal static IChatGui chatGui { get; set; } = null!;
        [PluginService] internal static ICommandManager commandManager { get; set; } = null!;
        [PluginService] internal static IPluginLog pluginLog { get; set; } = null!;
        [PluginService] internal static INamePlateGui namePlateGui { get; set; } = null!;
        [PluginService] internal static IGameInteropProvider gameInteropProvider { get; set; } = null!;

        internal static Configuration configuration { get; set; } = null!;
        internal static Plugin plugin { get; set; } = null!;
        internal static PenumbraIpc penumbraApi { get; set; } = null!;
        internal static ConfigWindow configWindow { get; set; } = null!;
        internal static Drawer drawer { get; set; } = null!;
        internal static Nameplate nameplate { get; set; } = null!;
    }
}