// File: ./MashedPotato/Windows/ConfigWindow.cs

// Mashed-Potato/MashedPotato/Windows/ConfigWindow.cs

using System;
using System.Numerics;
using Dalamud.Interface.Windowing;
using Dalamud.Interface.Colors;
using Dalamud.Bindings.ImGui;
using MashedPotato.Utils;

namespace MashedPotato.Windows
{
    public class ConfigWindow : Window, IDisposable
    {
        private Configuration configuration;
        
        // The missing event trigger! Without this, the Drawer throws a wobbly.
        public event Action? OnConfigChanged;

        public ConfigWindow(Plugin plugin) : base(
            "Mashed Potato Settings",
            ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoScrollWithMouse | ImGuiWindowFlags.AlwaysAutoResize)
        {
            this.configuration = Service.configuration;
            this.SizeCondition = ImGuiCond.Always;
        }

        public void Dispose() { }

        public override void Draw()
        {
            ImGui.TextColored(ImGuiColors.DalamudYellow, "Welcome to Mashed Potato!");
            ImGui.Text("Configure how you want to transform Lalafells below.");
            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();

            var enabled = configuration.enabled;
            if (ImGui.Checkbox("Enable Plugin", ref enabled))
            {
                configuration.enabled = enabled;
                configuration.Save();
                InvokeConfigChanged();
            }
            if (ImGui.IsItemHovered())
            {
                ImGui.SetTooltip("Turn the Lalafell transformation on or off globally.");
            }

            var stayOn = configuration.stayOn;
            if (ImGui.Checkbox("Keep Enabled Across Area Changes", ref stayOn))
            {
                configuration.stayOn = stayOn;
                configuration.Save();
            }
            if (ImGui.IsItemHovered())
            {
                ImGui.SetTooltip("If unchecked, the plugin will automatically turn off whenever you teleport or change zones.");
            }
            
            var nameHQ = configuration.nameHQ;
            if (ImGui.Checkbox("Show Indicator Icon", ref nameHQ))
            {
                configuration.nameHQ = nameHQ;
                configuration.Save();
                InvokeConfigChanged();
            }
            if (ImGui.IsItemHovered())
            {
                ImGui.SetTooltip("Shows a sneaky little icon next to transformed players so you can spot the fakes.");
            }

            ImGui.Spacing();
            
            // The missing dropdown for selecting our target race
            var selectedRace = configuration.SelectedRace;
            string[] races = { "Hyur", "Elezen", "Lalafell (Why?)", "Miqo'te", "Roegadyn", "Au Ra", "Hrothgar", "Viera" };
            
            // Map the dropdown index to the Constant.Race enum offset
            int raceIndex = selectedRace > 0 ? selectedRace - 1 : 0;
            
            if (ImGui.Combo("Target Race", ref raceIndex, races, races.Length))
            {
                configuration.SelectedRace = raceIndex + 1;
                configuration.Save();
                InvokeConfigChanged();
            }

            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();

            ImGui.TextColored(ImGuiColors.ParsedOrange, "How to use the Whitelist:");
            ImGui.TextWrapped("Want to spare a specific Lalafell friend from being mashed? Right-click them in the game world or chat, and select the Mashed Potato whitelist option to exclude them from transformations.");
            
            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();

            ImGui.TextColored(ImGuiColors.DalamudGrey, "Mashed Potato is brought to you by Lateblight & Team.");
        }

        public void InvokeConfigChanged()
        {
            // Give a shout to anyone listening (like Drawer.cs) that settings have changed
            OnConfigChanged?.Invoke();
        }
    }
}
