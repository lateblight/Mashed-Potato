// File: ./MashedPotato/Configuration.cs

// File: MashedPotato/Configuration.cs

using Dalamud.Configuration;
using Dalamud.Plugin;
using System;
using System.Collections.Generic;

namespace MashedPotato
{
    [Serializable]
    public class Configuration : IPluginConfiguration
    {
        public int Version { get; set; } = 1;

        // Chuck your whitelisted mates in here so they don't get mashed
        public HashSet<string> WhitelistedPlayers { get; set; } = new(StringComparer.OrdinalIgnoreCase);

        // The target race we are morphing the Lalafells into
        public int SelectedRace { get; set; } = 0;
        
        public bool enabled { get; set; } = true;
        public bool stayOn { get; set; } = false;
        
        // Toggle for the cheeky indicator icon on the nameplate
        public bool nameHQ { get; set; } = true;

        [NonSerialized] private IDalamudPluginInterface? pluginInterface;

        public void Initialize(IDalamudPluginInterface pluginInterface)
        {
            this.pluginInterface = pluginInterface;
        }

        public void Save()
        {
            this.pluginInterface!.SavePluginConfig(this);
        }
    }
}
