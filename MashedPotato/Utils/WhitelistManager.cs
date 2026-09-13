// File: ./MashedPotato/Utils/WhitelistManager.cs

// File: MashedPotato/Utils/WhitelistManager.cs

using System;
using System.Collections.Generic;
using System.Linq;
using Dalamud.Plugin.Services;
using Dalamud.Game.Gui.ContextMenu;

namespace MashedPotato.Utils
{
    public class WhitelistManager : IDisposable
    {
        private readonly Configuration configuration;
        private readonly IContextMenu contextMenu;
        private readonly IChatGui chatGui;

        public event Action<string>? OnWhitelistChanged;

        public WhitelistManager(Configuration configuration, IContextMenu contextMenu, IChatGui chatGui)
        {
            this.configuration = configuration;
            this.contextMenu = contextMenu;
            this.chatGui = chatGui;

            this.contextMenu.OnMenuOpened += OnContextMenuOpened;
        }

        private void OnContextMenuOpened(IMenuOpenedArgs args)
        {
            if (args.Target is MenuTargetDefault target)
            {
                var playerName = target.TargetName;
                
                if (string.IsNullOrWhiteSpace(playerName)) return;

                bool isWhitelisted = IsWhitelisted(playerName);
                string menuName = isWhitelisted ? "Remove from Mashed Potato Whitelist" : "Add to Mashed Potato Whitelist";

                args.AddMenuItem(new MenuItem
                {
                    Name = menuName,
                    OnClicked = _ => 
                    {
                        if (isWhitelisted)
                            RemovePlayer(playerName);
                        else
                            AddPlayer(playerName);
                    }
                });
            }
        }

        public bool IsWhitelisted(string playerName)
        {
            if (string.IsNullOrWhiteSpace(playerName)) return false;
            return configuration.WhitelistedPlayers != null &&
                   configuration.WhitelistedPlayers.Contains(playerName, StringComparer.OrdinalIgnoreCase);
        }

        public void AddPlayer(string playerName)
        {
            if (string.IsNullOrWhiteSpace(playerName)) return;
            if (!IsWhitelisted(playerName))
            {
                configuration.WhitelistedPlayers.Add(playerName);
                configuration.Save();
                chatGui.Print($"[Mashed Potato] Added {playerName} to the whitelist.");
                OnWhitelistChanged?.Invoke(playerName);
                
                // Trigger a targeted redraw so ONLY this player updates[cite: 2]
                Service.penumbraApi?.RedrawTarget(playerName);
            }
        }

        public void RemovePlayer(string playerName)
        {
            if (string.IsNullOrWhiteSpace(playerName)) return;
            if (IsWhitelisted(playerName))
            {
                configuration.WhitelistedPlayers.Remove(playerName);
                configuration.Save();
                chatGui.Print($"[Mashed Potato] Removed {playerName} from the whitelist.");
                OnWhitelistChanged?.Invoke(playerName);
                
                // Trigger a targeted redraw so ONLY this player updates[cite: 2]
                Service.penumbraApi?.RedrawTarget(playerName);
            }
        }

        public void Dispose()
        {
            if (this.contextMenu != null)
            {
                this.contextMenu.OnMenuOpened -= OnContextMenuOpened;
            }
        }
    }
}
