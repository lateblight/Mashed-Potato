using Dalamud.Configuration;
using Dalamud.Plugin;
using System;
using System.Collections.Generic;
using static OopsAllLalafellsSRE.Utils.Constant;

namespace OopsAllLalafellsSRE
{
    [Serializable]
    public class Configuration : IPluginConfiguration
    {
        public int Version { get; set; } = 0;
        public Race SelectedRace { get; set; } = Race.LALAFELL;
        public bool enabled { get; set; } = false;
        public bool stayOn { get; set; } = false;
        public bool nameHQ { get; set; } = true;

        // Whitelist collection for character names to be ignored by the swap
        public HashSet<string> WhitelistedNames { get; set; } = new(StringComparer.OrdinalIgnoreCase);

        // the below exist just to make saving less cumbersome
        [NonSerialized]
        private IDalamudPluginInterface? pluginInterface;

        public void Initialize(IDalamudPluginInterface pluginInterface)
        {
            this.pluginInterface = pluginInterface;
        }

        public void Save()
        {
            pluginInterface!.SavePluginConfig(this);
        }
    }
}