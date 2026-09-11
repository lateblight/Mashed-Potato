// File: ./MashedPotato/Utils/Service.cs

// File: MashedPotato/Utils/Service.cs
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

