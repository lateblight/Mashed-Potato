using System;
using Dalamud.Game.Gui.ContextMenu;
using Dalamud.Game.ClientState.Objects.Types;
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

        // Subscribe to world and party list context menu events.
        this.contextMenu.OnOpenWorldContextMenu += OnOpenContextMenu;
    }

    private void OnOpenContextMenu(IMenuOpenedArgs args)
    {
        // Check if the target is a valid player character in the game world.
        if (args.Target is MenuTargetSelection target && target.Object is IPlayerCharacter player)
        {
            string playerName = player.Name.TextValue;
            if (string.IsNullOrEmpty(playerName)) return;

            bool isWhitelisted = configuration.WhitelistedPlayers.Contains(playerName);
            string menuLabel = isWhitelisted ? "Remove from Mashed Potato Whitelist" : "Add to Mashed Potato Whitelist";

            // Add the custom option to the context menu.
            args.AddMenuItem(new MenuItem
            {
                Name = menuLabel,
                Callback = _ => ToggleWhitelist(playerName)
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
        this.contextMenu.OnOpenWorldContextMenu -= OnOpenContextMenu;
    }
}