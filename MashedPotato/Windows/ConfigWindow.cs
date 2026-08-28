using Dalamud.Bindings.ImGui;
using Dalamud.Interface.Windowing;
using OopsAllLalafellsSRE.Utils;
using System;
using System.Numerics;
using static OopsAllLalafellsSRE.Utils.Constant;

namespace OopsAllLalafellsSRE.Windows;

internal class ConfigWindow : Window
{
    private readonly Configuration configuration;
    private readonly string[] race = ["Lalafell", "Hyur", "Elezen", "Miqo'te", "Roegadyn", "Au Ra", "Hrothgar", "Viera"];
    private int selectedRaceIndex;
    public event Action? OnConfigChanged;

    public ConfigWindow(Plugin plugin) : base(
        "Mashed Potato Configuration",
        ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoScrollbar |
        ImGuiWindowFlags.NoScrollWithMouse)
    {
        Size = new Vector2(300, 175);
        SizeCondition = ImGuiCond.Always;

        configuration = Service.configuration;
        selectedRaceIndex = MapRaceToIndex(configuration.SelectedRace);
    }

    public override void Draw()
    {
        // Select Destination Race
        ImGui.AlignTextToFramePadding();
        ImGui.TextUnformatted("Mash Into:");
        ImGui.SameLine();
        if (ImGui.Combo("###Race", ref selectedRaceIndex, race, race.Length))
        {
            configuration.SelectedRace = MapIndexToRace(selectedRaceIndex);
            configuration.Save();
            OnConfigChanged?.Invoke();
        }

        // Enable Toggle
        bool isEnabled = configuration.enabled;
        if (ImGui.Checkbox("Enable Mashed Potato", ref isEnabled))
        {
            configuration.enabled = isEnabled;
            configuration.Save();
            OnConfigChanged?.Invoke();
        }

        // Stay On Toggle
        bool stayOn = configuration.stayOn;
        if (ImGui.Checkbox("Keep enabled across logins", ref stayOn))
        {
            configuration.stayOn = stayOn;
            configuration.Save();
        }

        ImGui.Separator();

        // Nameplate Indicator Toggle
        bool nameHq = configuration.nameHQ;
        if (ImGui.Checkbox("Show indicator () on mashed Lalafells", ref nameHq))
        {
            configuration.nameHQ = nameHq;
            configuration.Save();
            OnConfigChanged?.Invoke();
        }
    }

    private static Race MapIndexToRace(int index)
    {
        return index switch
        {
            0 => Race.LALAFELL,
            1 => Race.HYUR,
            2 => Race.ELEZEN,
            3 => Race.MIQOTE,
            4 => Race.ROEGADYN,
            5 => Race.AU_RA,
            6 => Race.HROTHGAR,
            7 => Race.VIERA,
            _ => Race.HYUR,
        };
    }

    private static int MapRaceToIndex(Race race)
    {
        return race switch
        {
            Race.LALAFELL => 0,
            Race.HYUR => 1,
            Race.ELEZEN => 2,
            Race.MIQOTE => 3,
            Race.ROEGADYN => 4,
            Race.AU_RA => 5,
            Race.HROTHGAR => 6,
            Race.VIERA => 7,
            _ => 1,
        };
    }

    public void InvokeConfigChanged()
    {
        selectedRaceIndex = MapRaceToIndex(configuration.SelectedRace);
        OnConfigChanged?.Invoke();
    }
}