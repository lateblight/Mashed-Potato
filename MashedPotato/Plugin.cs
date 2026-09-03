using Dalamud.Game.Command;
using Dalamud.Game.Text;
using Dalamud.Game.Text.SeStringHandling;
using Dalamud.Interface.Windowing;
using Dalamud.Plugin;
using OopsAllLalafellsSRE.Utils;
using OopsAllLalafellsSRE.Windows;
using Penumbra.Api.Enums;
using MashedPotato; 
using MashedPotato.Utils;

namespace OopsAllLalafellsSRE
{
    public sealed class Plugin : IDalamudPlugin
    {
        public static string Name => "Mashed Potato";
        private const string CommandName = "/mash";
        public WindowSystem WindowSystem { get; } = new("Mashed Potato");

        public Plugin(IDalamudPluginInterface pluginInterface)
        {
            // This line asks Dalamud to populate all the [PluginService] tools in Service.cs
            pluginInterface.Create<Service>();

            Service.pluginInterface = pluginInterface;
            Service.configuration = pluginInterface.GetPluginConfig() as Configuration ?? new Configuration();

            // We do a quick check on startup just in case
            if (!Service.configuration.stayOn)
            {
                Service.configuration.enabled = false;
            }

            Service.configuration.Initialize(pluginInterface);
            Service.plugin = this;
            Service.penumbraApi = new PenumbraIpc(pluginInterface);
            Service.configWindow = new ConfigWindow(this);
            WindowSystem.AddWindow(Service.configWindow);
            
            // Reassured the compiler these won't be null
            Service.drawer = pluginInterface.Create<Drawer>()!;
            Service.nameplate = pluginInterface.Create<Nameplate>()!;
            
            // Initialised the right-click whitelist integration
            Service.whitelistManager = new WhitelistManager(Service.configuration, Service.contextMenu, Service.chatGui);

            pluginInterface.UiBuilder.Draw += DrawUI;
            pluginInterface.UiBuilder.OpenConfigUi += DrawConfigUI;
            pluginInterface.UiBuilder.OpenMainUi += DrawConfigUI;

            Service.commandManager.AddHandler(CommandName, new CommandInfo(OnCommand)
            {
                HelpMessage = "Opens Mashed Potato config menu. Use /mash on or /mash off."
            });

            // EVENT HOOK: Listen for when the player changes areas (loading screens)
            Service.clientState.TerritoryChanged += OnTerritoryChanged;
        }

        public static void OutputChatLine(SeString message)
        {
            var sb = new SeStringBuilder().AddUiForeground("[Mashed Potato] ", 58).Append(message);
            Service.chatGui.Print(new XivChatEntry { Message = sb.BuiltString });
        }

        public void Dispose()
        {
            // Clean up our event hook so it doesn't cause memory leaks when the plugin is disabled
            Service.clientState.TerritoryChanged -= OnTerritoryChanged;

            WindowSystem.RemoveAllWindows();
            Service.penumbraApi?.Dispose();
            Service.drawer?.Dispose();
            Service.nameplate?.Dispose();
            Service.whitelistManager?.Dispose();
            Service.commandManager?.RemoveHandler(CommandName);
        }

        // ==============================================================================
        // THE MASTER KEYRING: METHOD OVERLOADING
        // Dalamud API 15 changed the hidden signature for TerritoryChanged.
        // By providing all reasonable data combinations below, the C# compiler will 
        // automatically select the exact fit and route it to our HandleAreaChange logic!
        // ==============================================================================
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

        // The actual logic that runs when the player passes through a loading screen
        private void HandleAreaChange()
        {
            // If the player has "Keep Enabled Across Area Changes" turned OFF, and the plugin is currently ON...
            if (!Service.configuration.stayOn && Service.configuration.enabled)
            {
                // Turn it off!
                Service.configuration.enabled = false;
                Service.configuration.Save();
                
                // Tell the UI menu to update its checkbox so it matches our new state
                Service.configWindow.InvokeConfigChanged();
                
                // Ask Penumbra to redraw everyone back to their normal, non-Lalafell selves
                Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
                
                // Leave a friendly little note in the chat so the player knows what happened
                OutputChatLine("You entered a new area. Mashed Potato has automatically turned off.");
            }
        }

        private void OnCommand(string command, string args)
        {
            if (args == "on")
            {
                Service.configuration.enabled = true;
                Service.configuration.Save();
                Service.configWindow.InvokeConfigChanged();
                Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
                return;
            }

            if (args == "off")
            {
                Service.configuration.enabled = false;
                Service.configuration.Save();
                Service.configWindow.InvokeConfigChanged();
                Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
                return;
            }

            Service.configWindow.IsOpen = true;
        }

        private void DrawUI() => WindowSystem.Draw();
        public static void DrawConfigUI() => Service.configWindow.IsOpen = true;
    }
}