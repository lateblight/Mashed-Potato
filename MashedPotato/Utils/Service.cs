// File: MashedPotato/Utils/Service.cs

using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using MashedPotato.Windows;

namespace MashedPotato.Utils
{
    public static class Service
    {
        public static IDalamudPluginInterface pluginInterface { get; set; } = null!;
        public static IClientState clientState { get; set; } = null!;
        public static ICommandManager commandManager { get; set; } = null!;
        public static IChatGui chatGui { get; set; } = null!;
        public static IContextMenu contextMenu { get; set; } = null!;
        public static IPluginLog PluginLog { get; set; } = null!;
        public static INamePlateGui namePlateGui { get; set; } = null!;
        public static IObjectTable objectTable { get; set; } = null!;
        
        public static Configuration configuration { get; set; } = null!;
        public static Plugin plugin { get; set; } = null!;
        public static PenumbraIpc penumbraApi { get; set; } = null!;
        public static ConfigWindow configWindow { get; set; } = null!;
        public static Drawer drawer { get; set; } = null!;
        public static Nameplate nameplate { get; set; } = null!;
        public static WhitelistManager whitelistManager { get; set; } = null!;
    }
}