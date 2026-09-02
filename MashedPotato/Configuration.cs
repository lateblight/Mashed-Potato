using System;
using System.Collections.Generic;
using Dalamud.Configuration;
using Dalamud.Plugin;

namespace MashedPotato;

[Serializable]
public class Configuration : IPluginConfiguration
{
    public int Version { get; set; } = 1;

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