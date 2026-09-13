// File: ./MashedPotato/Windows/ConfigWindow.cs

// File: MashedPotato/Windows/ConfigWindow.cs

using System;
using System.Numerics;
using Dalamud.Interface.Windowing;
using Dalamud.Bindings.ImGui;
using MashedPotato.Utils;

namespace MashedPotato.Windows
{
    public class ConfigWindow : Window, IDisposable
    {
        private readonly Plugin plugin;
        private readonly Configuration configuration;
        private string inputPlayerName = string.Empty;

        private readonly string[] availableRaces = { "Hyur", "Elezen", "Miqo'te", "Roegadyn", "Au Ra", "Hrothgar", "Viera" };
        private readonly int[] raceIds = { 1, 2, 4, 5, 6, 7, 8 };

        public ConfigWindow(Plugin plugin, Configuration configuration) : base("Mashed Potato Configuration")
        {
            this.plugin = plugin;
            this.configuration = configuration;
            
            Size = new Vector2(520, 420);
            SizeCondition = ImGuiCond.FirstUseEver;
        }

        public void Dispose()
        {
            // Clean up window resources if necessary
        }

        public void InvokeConfigChanged()
        {
            // Placeholder for configuration update callbacks
        }

        public override void Draw()
        {
            if (ImGui.BeginTabBar("MashedPotatoTabs"))
            {
                if (ImGui.BeginTabItem("General Settings"))
                {
                    ImGui.TextColored(new Vector4(1f, 0.84f, 0f, 1f), "Welcome to Mashed Potato! *");
                    ImGui.Text("Configure how you want to transform Lalafells below.");
                    ImGui.Spacing();

                    bool enabled = configuration.enabled;
                    if (ImGui.Checkbox("Enable Mashed Potato (Mash up Lalas)", ref enabled))
                    {
                        configuration.enabled = enabled;
                        configuration.Save();
                        Service.penumbraApi?.RedrawAll();
                    }

                    bool zoneChange = configuration.zoneChange;
                    if (ImGui.Checkbox("Keep enabled when changing zones", ref zoneChange))
                    {
                        configuration.zoneChange = zoneChange;
                        configuration.Save();
                    }

                    bool nameHQ = configuration.nameHQ;
                    if (ImGui.Checkbox("Show indicator on nameplates (*)", ref nameHQ))
                    {
                        configuration.nameHQ = nameHQ;
                        configuration.Save();
                    }

                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();

                    ImGui.Text("Target Race Transformation:");
                    int currentIdx = Array.IndexOf(raceIds, configuration.targetRaceId);
                    if (currentIdx < 0) currentIdx = 2;

                    ImGui.SetNextItemWidth(200f);
                    if (ImGui.Combo("##TargetRaceCombo", ref currentIdx, availableRaces, availableRaces.Length))
                    {
                        configuration.targetRaceId = raceIds[currentIdx];
                        configuration.Save();
                        Service.penumbraApi?.RedrawAll();
                    }

                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();

                    var pluginVersion = Service.pluginInterface?.Manifest.AssemblyVersion?.ToString() ?? "1.4.0.3";
                    
                    // The UI string cleanly incorporates the version alongside the Lateblight attribution[cite: 1]
                    ImGui.TextDisabled($"Mashed Potato v{pluginVersion} is brought to you by Lateblight.");
                    
                    if (ImGui.Button("GitHub Repo"))
                    {
                        Dalamud.Utility.Util.OpenLink("https://github.com/Lateblight/Mashed-Potato");
                    }

                    ImGui.EndTabItem();
                }

                if (ImGui.BeginTabItem("Whitelist Management"))
                {
                    ImGui.TextColored(new Vector4(0.4f, 0.8f, 1f, 1f), "Trusted Friends Whitelist");
                    ImGui.TextWrapped("Exempt specific players from model conversion so they appear normally on your screen.");
                    ImGui.Spacing();

                    ImGui.Text("Add Player by Exact Name:");
                    ImGui.SetNextItemWidth(320f);
                    ImGui.InputText("##AddPlayerInput", ref inputPlayerName, 64);
                    ImGui.SameLine();
                    if (ImGui.Button("Add to Whitelist", new Vector2(110f, 0f)))
                    {
                        if (!string.IsNullOrWhiteSpace(inputPlayerName))
                        {
                            Service.whitelistManager?.AddPlayer(inputPlayerName.Trim());
                            inputPlayerName = string.Empty;
                        }
                    }

                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();

                    ImGui.Text("Currently Whitelisted Players:");
                    ImGui.Spacing();

                    if (configuration.WhitelistedPlayers != null && configuration.WhitelistedPlayers.Count > 0)
                    {
                        if (ImGui.BeginTable("WhitelistTable", 2, ImGuiTableFlags.BordersInnerH | ImGuiTableFlags.RowBg | ImGuiTableFlags.ScrollY, new Vector2(0, 190)))
                        {
                            ImGui.TableSetupColumn("Character Name", ImGuiTableColumnFlags.WidthStretch);
                            ImGui.TableSetupColumn("Actions", ImGuiTableColumnFlags.WidthFixed, 110f);
                            ImGui.TableHeadersRow();

                            foreach (var player in configuration.WhitelistedPlayers.ToArray())
                            {
                                ImGui.TableNextRow();
                                ImGui.TableSetColumnIndex(0);
                                ImGui.AlignTextToFramePadding();
                                ImGui.Text(player);

                                ImGui.TableSetColumnIndex(1);
                                if (ImGui.Button($"Remove##{player}", new Vector2(-1, 0)))
                                {
                                    Service.whitelistManager?.RemovePlayer(player);
                                }
                            }
                            ImGui.EndTable();
                        }
                    }
                    else
                    {
                        ImGui.TextDisabled("No players currently whitelisted.");
                        ImGui.Spacing();
                        ImGui.TextDisabled("Tip: You can also right-click players in the game world, chat, or party list to add them.");
                    }

                    ImGui.EndTabItem();
                }

                ImGui.EndTabBar();
            }
        }
    }
}
