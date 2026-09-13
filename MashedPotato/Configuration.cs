// File: MashedPotato/Configuration.cs

using Dalamud.Configuration;
using Dalamud.Plugin;
using System;
using System.Collections.Generic;

namespace MashedPotato
{
    public class Configuration : IPluginConfiguration
    {
        public int Version { get; set; } = 1;

        public bool enabled = true;
        public bool zoneChange = true;
        public bool nameHQ = true;
        public List<string> WhitelistedPlayers { get; set; } = new();

        [NonSerialized]
        private IDalamudPluginInterface? pluginInterface;

        public void Initialize(IDalamudPluginInterface pluginInterface)
        {
            this.pluginInterface = pluginInterface;
        }

        public void Save()
        {
            this.pluginInterface?.SavePluginConfig(this);
        }
    }
}