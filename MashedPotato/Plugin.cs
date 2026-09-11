// File: ./MashedPotato/Plugin.cs

// File: MashedPotato/Plugin.cs
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

