/*
 *  ==================================================================
 *   _  _   _    _          _   _                      
 *  | || | | |  (_)        | | | |                     
 *  | || |_| | ___  ___ ___| |_| |__   ___  ___        
 *  | || __| |/ / |/ __/ __| __| '_ \ / _ \/ __|       
 *  | || |_|   <| | (__\__ \ |_| | | |  __/\__ \       
 *  | |_| \__|_|\_\_|\___|___/\__|_| |_|\___||___/       
 *                                                     
 *  [ SERVICE LOCATOR: THE CENTRAL NERVOUS SYSTEM ]
 *  Unified, streamlined, and blissfully free of architectural clutter.
 *  ==================================================================
 */

// File: ./MashedPotato/Utils/Service.cs

using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using MashedPotato.Windows;

namespace MashedPotato.Utils
{
    public static class Service
    {
        public static IDalamudPluginInterface? pluginInterface { get; set; }
        public static IClientState? clientState { get; set; }
        public static ICommandManager? commandManager { get; set; }
        public static IChatGui? chatGui { get; set; }
        public static IContextMenu? contextMenu { get; set; }
        public static IPluginLog? PluginLog { get; set; }
        public static INamePlateGui? namePlateGui { get; set; }
        public static IObjectTable? objectTable { get; set; }
        public static IFramework? framework { get; set; }

        public static Plugin? plugin { get; set; }
        public static Configuration? configuration { get; set; }
        public static PenumbraIpc? penumbraApi { get; set; }
        public static WhitelistManager? whitelistManager { get; set; }
        public static Nameplate? nameplate { get; set; }
        public static Drawer? drawer { get; set; }
        public static ConfigWindow? configWindow { get; set; }
    }
}