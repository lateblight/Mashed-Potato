// File: ./MashedPotato/Utils/Service.cs

// Mashed-Potato/MashedPotato/Utils/Service.cs

using Dalamud.Game.ClientState.Objects;
using Dalamud.IoC;
using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using MashedPotato.Windows;

namespace MashedPotato.Utils
{
    public class Service
    {
        [PluginService] public static IDalamudPluginInterface pluginInterface { get; set; } = null!;
        [PluginService] public static IClientState clientState { get; set; } = null!;
        [PluginService] public static ICommandManager commandManager { get; set; } = null!;
        [PluginService] public static IChatGui chatGui { get; set; } = null!;
        [PluginService] public static IContextMenu contextMenu { get; set; } = null!;
        [PluginService] public static IPluginLog PluginLog { get; private set; } = null!;
        
        // Proper API 15 NamePlate service, none of that obsolete IGameGui rubbish!
        [PluginService] public static INamePlateGui namePlateGui { get; private set; } = null!;

        public static Configuration configuration { get; set; } = null!;
        public static Plugin plugin { get; set; } = null!;
        public static ConfigWindow configWindow { get; set; } = null!;
        
        internal static Drawer drawer { get; set; } = null!;
        internal static Nameplate nameplate { get; set; } = null!;
        internal static PenumbraIpc penumbraApi { get; set; } = null!;
        internal static WhitelistManager whitelistManager { get; set; } = null!;
    }
}
