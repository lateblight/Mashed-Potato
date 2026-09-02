using System;
using System.Numerics;
using Dalamud.Interface.Windowing;
using Dalamud.Bindings.ImGui;
using OopsAllLalafellsSRE.Utils;
using MashedPotato;

namespace OopsAllLalafellsSRE.Windows
{
    public class ConfigWindow : Window, IDisposable
    {
        private readonly Plugin plugin;
        public event Action? OnConfigChanged;
        private string inputPlayerName = string.Empty;

        public ConfigWindow(Plugin plugin) : base("Mashed Potato Configuration", ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoResize)
        {
            this.plugin = plugin;
            Size = new Vector2(400, 300);
            SizeCondition = ImGuiCond.FirstUseEver;
        }

        public void InvokeConfigChanged() => OnConfigChanged?.Invoke();

        public override void Draw()
        {
            var config = Service.configuration;

            ImGui.Text("Welcome to Mashed Potato settings!");
            ImGui.Separator();

            bool enabled = config.enabled;
            if (ImGui.Checkbox("Enable Plugin", ref enabled))
            {
                config.enabled = enabled;
                config.Save();
                InvokeConfigChanged();
            }

            bool stayOn = config.stayOn;
            if (ImGui.Checkbox("Keep Enabled Across Area Changes", ref stayOn))
            {
                config.stayOn = stayOn;
                config.Save();
            }

            bool nameHQ = config.nameHQ;
            if (ImGui.Checkbox("Display Indicator Symbol Above Transformed Characters", ref nameHQ))
            {
                config.nameHQ = nameHQ;
                config.Save();
            }

            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Text("Trusted Player Whitelist");
            ImGui.TextWrapped("Players added to this list will never be transformed into other races, keeping them safely as Lalafells.");

            ImGui.SetNextItemWidth(200);
            ImGui.InputText("##WhitelistedPlayerInput", ref inputPlayerName, 64);
            ImGui.SameLine();

            if (ImGui.Button("Add Player"))
            {
                if (!string.IsNullOrWhiteSpace(inputPlayerName))
                {
                    config.WhitelistedPlayers.Add(inputPlayerName.Trim());
                    config.Save();
                    inputPlayerName = string.Empty;
                }
            }

            ImGui.Spacing();
            ImGui.BeginChild("WhitelistedPlayersList", new Vector2(0, 120), true);
            foreach (var player in config.WhitelistedPlayers)
            {
                if (ImGui.Button($"Remove##{player}"))
                {
                    config.WhitelistedPlayers.Remove(player);
                    config.Save();
                    break;
                }
                ImGui.SameLine();
                ImGui.Text(player);
            }
            ImGui.EndChild();
        }

        public void Dispose() { }
    }
}