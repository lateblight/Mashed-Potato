using System;
using System.Collections.Generic;
using Dalamud.Configuration;
using Dalamud.Plugin;
using OopsAllLalafellsSRE.Utils;

namespace MashedPotato;

[Serializable]
public class Configuration : IPluginConfiguration
{
    public int Version { get; set; } = 1;

    // Core plugin toggles
    public bool enabled { get; set; } = true;
    public bool stayOn { get; set; } = true;
    public bool nameHQ { get; set; } = true;
    public Constant.Race SelectedRace { get; set; } = Constant.Race.HYUR;

    // A collection of trusted player names that bypass any character transformations.
    // Initialised with case-insensitive handling to prevent duplicate confusion.
    public HashSet<string> WhitelistedPlayers { get; set; } = new(StringComparer.OrdinalIgnoreCase);

    [NonSerialized]
    private IDalamudPluginInterface? pluginInterface;

    public void Initialize(IDalamudPluginInterface dalPluginInterface)
    {
        this.pluginInterface = dalPluginInterface;
    }

    public void Save()
    {
        this.pluginInterface!.SavePluginConfig(this);
    }
}