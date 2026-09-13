// File: MashedPotato/Plugin.cs

using System;
using Dalamud.Plugin;
using Dalamud.Plugin.Services;
using Dalamud.Interface.Windowing;
using MashedPotato.Utils;
using MashedPotato.Windows;

namespace MashedPotato
{
    public sealed class Plugin : IDalamudPlugin
    {
        public string Name => "Mashed Potato";

        private readonly IDalamudPluginInterface pluginInterface;
        private readonly ICommandManager commandManager;
        private readonly WindowSystem windowSystem;

        public Configuration Configuration { get; init; }
        public PenumbraIpc PenumbraApi { get; init; }
        public WhitelistManager WhitelistManager { get; init; }
        public Nameplate NameplateManager { get; init; }
        public Drawer DrawerManager { get; init; }

        public Plugin(
            IDalamudPluginInterface pluginInterface,
            IClientState clientState,
            ICommandManager commandManager,
            IChatGui chatGui,
            IContextMenu contextMenu,
            IPluginLog pluginLog,
            INamePlateGui namePlateGui,
            IObjectTable objectTable)
        {
            this.pluginInterface = pluginInterface;
            this.commandManager = commandManager;

            // Initialise Service locator
            Service.pluginInterface = pluginInterface;
            Service.clientState = clientState;
            Service.commandManager = commandManager;
            Service.chatGui = chatGui;
            Service.contextMenu = contextMenu;
            Service.PluginLog = pluginLog;
            Service.namePlateGui = namePlateGui;
            Service.objectTable = objectTable;
            Service.plugin = this;

            // Load Configuration
            Configuration = pluginInterface.GetPluginConfig() as Configuration ?? new Configuration();
            Configuration.Initialize(pluginInterface);
            Service.configuration = Configuration;

            // Initialise Managers and IPC wrappers
            PenumbraApi = new PenumbraIpc(pluginInterface);
            Service.penumbraApi = PenumbraApi;

            WhitelistManager = new WhitelistManager(Configuration, contextMenu, chatGui);
            Service.whitelistManager = WhitelistManager;

            NameplateManager = new Nameplate();
            Service.nameplate = NameplateManager;

            DrawerManager = new Drawer();
            Service.drawer = DrawerManager;

            // Initialise UI Windows
            windowSystem = new WindowSystem(Name);
            
            var configWindow = new ConfigWindow(this, Configuration);
            Service.configWindow = configWindow;
            windowSystem.AddWindow(configWindow);

            pluginInterface.UiBuilder.Draw += windowSystem.Draw;
            pluginInterface.UiBuilder.OpenConfigUi += () => {
                configWindow.InvokeConfigChanged();
                configWindow.Toggle();
            };

            // Register main UI callback to satisfy Dalamud validation checks
            pluginInterface.UiBuilder.OpenMainUi += () => {
                configWindow.Toggle();
            };

            // Register Commands
            commandManager.AddHandler("/mash", new Dalamud.Game.Command.CommandInfo(OnCommand)
            {
                HelpMessage = "Toggles the Mashed Potato configuration window or toggles the filter on/off ('/mash on' or '/mash off')."
            });
        }

        private void OnCommand(string command, string args)
        {
            if (args.Equals("on", StringComparison.OrdinalIgnoreCase))
            {
                Configuration.enabled = true;
                Configuration.Save();
                Service.chatGui.Print("[Mashed Potato] Filter enabled.");
            }
            else if (args.Equals("off", StringComparison.OrdinalIgnoreCase))
            {
                Configuration.enabled = false;
                Configuration.Save();
                Service.chatGui.Print("[Mashed Potato] Filter disabled.");
            }
            else
            {
                Service.configWindow.Toggle();
            }
        }

        public void Dispose()
        {
            commandManager.RemoveHandler("/mash");
            pluginInterface.UiBuilder.Draw -= windowSystem.Draw;
            pluginInterface.UiBuilder.OpenMainUi -= Service.configWindow.Toggle;
            
            NameplateManager?.Dispose();
            WhitelistManager?.Dispose();
            DrawerManager?.Dispose();
            PenumbraApi?.Dispose();
        }
    }
}