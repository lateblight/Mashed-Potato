using System;
using Dalamud.Game.Gui.ContextMenu;
using Dalamud.Plugin.Services;

namespace MashedPotato.Utils;

public class WhitelistManager : IDisposable
{
    private readonly Configuration configuration;
    private readonly IContextMenu contextMenu;
    private readonly IChatGui chatGui;

    public WhitelistManager(Configuration configuration, IContextMenu contextMenu, IChatGui chatGui)
    {
        this.configuration = configuration;
        this.contextMenu = contextMenu;
        this.chatGui = chatGui;

        // Subscribe to the menu opened event required by API 15.
        this.contextMenu.OnMenuOpened += OnMenuOpened;
    }

    private void OnMenuOpened(IMenuOpenedArgs args)
    {
        // MenuTargetDefault applies to players clicked in the world, party list, and friends list.
        if (args.Target is MenuTargetDefault target)
        {
            string playerName = target.TargetName;
            
            // Failsafe to ensure a name actually exists
            if (string.IsNullOrEmpty(playerName)) return;

            bool isWhitelisted = configuration.WhitelistedPlayers.Contains(playerName);
            string menuLabel = isWhitelisted ? "Remove from Mashed Potato Whitelist" : "Add to Mashed Potato Whitelist";

            // Add the custom option to the context menu
            args.AddMenuItem(new MenuItem
            {
                Name = menuLabel,
                OnClicked = _ => ToggleWhitelist(playerName)
            });
        }
    }

    private void ToggleWhitelist(string playerName)
    {
        if (configuration.WhitelistedPlayers.Contains(playerName))
        {
            configuration.WhitelistedPlayers.Remove(playerName);
            chatGui.Print($"[Mashed Potato] Removed {playerName} from your whitelist.");
        }
        else
        {
            configuration.WhitelistedPlayers.Add(playerName);
            chatGui.Print($"[Mashed Potato] Added {playerName} to your whitelist.");
        }

        configuration.Save();
    }

    public void Dispose()
    {
        this.contextMenu.OnMenuOpened -= OnMenuOpened;
    }
}