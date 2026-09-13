// File: MashedPotato/Utils/WhitelistManager.cs

using System;
using System.Collections.Generic;
using System.Linq;
using Dalamud.Plugin.Services;

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
                OnWhitelistChanged?.Invoke(playerName);
            }
        }

        public void RemovePlayer(string playerName)
        {
            if (string.IsNullOrWhiteSpace(playerName)) return;
            if (IsWhitelisted(playerName))
            {
                configuration.WhitelistedPlayers.Remove(playerName);
                configuration.Save();
                OnWhitelistChanged?.Invoke(playerName);
            }
        }

        public void Dispose()
        {
            // Clean up context menu hooks
        }
    }
}