// File: MashedPotato/Windows/ConfigWindow.cs

using System;
using Dalamud.Interface.Windowing;
using Dalamud.Interface.Colors;
using Dalamud.Bindings.ImGui;
using MashedPotato.Utils;

namespace MashedPotato.Windows
{
    public class ConfigWindow : Window, IDisposable
    {
        private Configuration configuration;
        
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
            // Penumbra Status Warning
            if (!Service.penumbraApi.ApiAvailable)
            {
                ImGui.TextColored(ImGuiColors.DalamudRed, "⚠️ WARNING: Penumbra is not connected!");
                ImGui.TextWrapped("Mashed Potato requires Penumbra to be installed and enabled. The fryer is offline until Penumbra is loaded.");
                ImGui.Spacing();
                ImGui.Separator();
                ImGui.Spacing();
            }

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
            
            var selectedRace = configuration.SelectedRace;
            string[] races = { "Hyur", "Elezen", "Lalafell (Why?)", "Miqo'te", "Roegadyn", "Au Ra", "Hrothgar", "Viera" };
            
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
            OnConfigChanged?.Invoke();
        }
    }
}