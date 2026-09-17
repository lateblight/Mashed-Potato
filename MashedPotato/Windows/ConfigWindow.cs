/*
 *  ==================================================================
 *   _  _   _    _          _   _                      
 *  | || | | |  (_)        | | | |                     
 *  | || |_| | ___  ___ ___| |_| |__   ___  ___        
 *  | || __| |/ / |/ __/ __| __| '_ \ / _ \/ __|       
 *  | || |_|   <| | (__\__ \ |_| | | |  __/\__ \       
 *  | |_| \__|_|\_\_|\___|___/\__|_| |_|\___||___/       
 *                                                     
 *  [ CONFIGURATION WINDOW: THE SCALPEL EDITION (v1.5.0.0) ]
 *  All manual spacing and separators eradicated. Relying purely on 
 *  native ItemSpacing for a bespoke, hyper-compact, tailored silhouette.
 *  ==================================================================
 */

// File: ./MashedPotato/Windows/ConfigWindow.cs

using System;
using System.Numerics;
using Dalamud.Interface.Windowing;
using Dalamud.Bindings.ImGui;
using MashedPotato.Utils;

namespace MashedPotato.Windows
{
    public class ConfigWindow : Window, IDisposable
    {
        private readonly Configuration configuration;
        private string inputPlayerName = string.Empty;

        private readonly string[] availableRaces = { "Hyur", "Elezen", "Miqo'te", "Roegadyn", "Au Ra", "Hrothgar", "Viera" };
        private readonly int[] raceIds = { 1, 2, 4, 5, 6, 7, 8 };

        public ConfigWindow(Configuration configuration) : base("Mashed Potato — Settings & Sanctuary")
        {
            this.configuration = configuration;
            
            Size = new Vector2(400, 100);
            SizeCondition = ImGuiCond.FirstUseEver;
            Flags = ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoScrollWithMouse;
        }

        public void Dispose() { }

        public override void Draw()
        {
            ThemeManager.PushTheme();
            try
            {
                // Majestic header with elevated font scale (No top spacing!)
                ImGui.SetWindowFontScale(1.25f);
                ImGui.TextColored(new Vector4(1.00f, 0.75f, 0.20f, 1.00f), "🥔 Mashed Potato");
                ImGui.SetWindowFontScale(1.0f);

                ImGui.TextDisabled("Client-Side Visual Filter & Soul Registry");

                // Unified Tab Bar holding both Operational Parameters and Whitelist Management
                if (ImGui.BeginTabBar("MashedPotatoTabs", ImGuiTabBarFlags.None))
                {
                    // ==========================================================
                    // TAB 1: GENERAL SETTINGS
                    // ==========================================================
                    if (ImGui.BeginTabItem("Settings ⚙️"))
                    {
                        bool enabled = configuration.enabled;
                        if (ImGui.Checkbox("Enable Mashed Potato (Mash up Lalas)", ref enabled))
                        {
                            configuration.enabled = enabled;
                            configuration.Save();
                            Service.penumbraApi?.RedrawAll();
                            Service.namePlateGui?.RequestRedraw();
                        }

                        bool zoneChange = configuration.zoneChange;
                        if (ImGui.Checkbox("Keep enabled when changing zones", ref zoneChange))
                        {
                            configuration.zoneChange = zoneChange;
                            configuration.Save();
                        }

                        bool nameHQ = configuration.nameHQ;
                        if (ImGui.Checkbox("Show indicator on transformed nameplates (*)", ref nameHQ))
                        {
                            configuration.nameHQ = nameHQ;
                            configuration.Save();
                            Service.namePlateGui?.RequestRedraw();
                        }

                        ImGui.Text("Target Race Transformation:");
                        int currentIdx = Array.IndexOf(raceIds, configuration.targetRaceId);
                        if (currentIdx < 0) currentIdx = 2;

                        ImGui.SetNextItemWidth(220f);
                        if (ImGui.Combo("##TargetRaceCombo", ref currentIdx, availableRaces, availableRaces.Length))
                        {
                            configuration.targetRaceId = raceIds[currentIdx];
                            configuration.Save();
                            Service.penumbraApi?.RedrawAll();
                        }

                        ImGui.EndTabItem();
                    }

                    // ==========================================================
                    // TAB 2: TRUSTED WHITELIST (ZERO REDUNDANT SPACING)
                    // ==========================================================
                    if (ImGui.BeginTabItem("Whitelist 🛡️"))
                    {
                        ImGui.TextDisabled("Exempt specific souls from model conversion.");
                        
                        ImGui.Text("Add Player by Exact Name:");
                        ImGui.SetNextItemWidth(260f);
                        ImGui.InputText("##AddPlayerInput", ref inputPlayerName, 64);
                        ImGui.SameLine();
                        if (ImGui.Button("Add", new Vector2(80f, 26f)))
                        {
                            if (!string.IsNullOrWhiteSpace(inputPlayerName))
                            {
                                Service.whitelistManager?.AddPlayer(inputPlayerName.Trim());
                                inputPlayerName = string.Empty;
                            }
                        }

                        // TIGHTENED TIP BOX: Reduced height to 46f so the padding perfectly hugs the single wrapped line.
                        ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, new Vector2(10f, 8f));
                        ImGui.BeginChild("TipBox", new Vector2(360, 46), true, ImGuiWindowFlags.NoScrollbar);
                        {
                            ImGui.PushStyleColor(ImGuiCol.Text, new Vector4(0.85f, 0.70f, 1.00f, 1.00f));
                            ImGui.TextWrapped("💡 Tip: Right-click players in-game, chat, or party lists to add them instantly!");
                            ImGui.PopStyleColor();
                        }
                        ImGui.EndChild();
                        ImGui.PopStyleVar();

                        ImGui.Text("Protected Souls:");

                        // Framed Child Container Box
                        ImGui.BeginChild("WhitelistScrollBox", new Vector2(360, 140), true, ImGuiWindowFlags.None);
                        {
                            if (configuration.WhitelistedPlayers != null && configuration.WhitelistedPlayers.Count > 0)
                            {
                                // TIGHTENED CELL PADDING: Generous left margin (12f) but strict vertical height (6f)
                                ImGui.PushStyleVar(ImGuiStyleVar.CellPadding, new Vector2(12f, 6f));
                                
                                if (ImGui.BeginTable("WhitelistTableNative", 2, ImGuiTableFlags.BordersInnerH | ImGuiTableFlags.RowBg | ImGuiTableFlags.SizingFixedFit | ImGuiTableFlags.PadOuterX))
                                {
                                    ImGui.TableSetupColumn("Name", ImGuiTableColumnFlags.WidthStretch, 230f);
                                    ImGui.TableSetupColumn("Action", ImGuiTableColumnFlags.WidthFixed, 60f);
                                    
                                    ImGui.TableHeadersRow();

                                    foreach (var player in configuration.WhitelistedPlayers.ToArray())
                                    {
                                        ImGui.TableNextRow();
                                        
                                        // Column 0: Character Name safely padded away from the wall
                                        ImGui.TableSetColumnIndex(0);
                                        ImGui.AlignTextToFramePadding();
                                        ImGui.Text(player);

                                        // Column 1: Remove button scaled to fit the column perfectly
                                        ImGui.TableSetColumnIndex(1);
                                        if (ImGui.Button($"Remove##{player}", new Vector2(-1, 24)))
                                        {
                                            Service.whitelistManager?.RemovePlayer(player);
                                        }
                                    }
                                    ImGui.EndTable();
                                }
                                ImGui.PopStyleVar();
                            }
                            else
                            {
                                // Even the empty state gets tightened up naturally!
                                var emptyMsg1 = "No souls currently whitelisted.";
                                ImGui.SetCursorPosX((340f - ImGui.CalcTextSize(emptyMsg1).X) * 0.5f);
                                ImGui.TextDisabled(emptyMsg1);
                                
                                var emptyMsg2 = "Right-click players in-game to add them.";
                                ImGui.SetCursorPosX((340f - ImGui.CalcTextSize(emptyMsg2).X) * 0.5f);
                                ImGui.TextDisabled(emptyMsg2);
                            }
                        }
                        ImGui.EndChild();

                        ImGui.EndTabItem();
                    }

                    ImGui.EndTabBar();
                }

                // Centered Footer Elements anchored perfectly to the dynamic base
                var windowWidth = ImGui.GetWindowWidth();
                var pluginVersion = Service.pluginInterface?.Manifest.AssemblyVersion?.ToString() ?? "1.5.0.0";
                
                var buttonText = "GitHub Repository";
                var buttonSize = new Vector2(160, 26);
                ImGui.SetCursorPosX((windowWidth - buttonSize.X) * 0.5f);
                if (ImGui.Button(buttonText, buttonSize))
                {
                    Dalamud.Utility.Util.OpenLink("https://github.com/Lateblight/Mashed-Potato");
                }

                var footerText = $"Version {pluginVersion} — Maintained by Lateblight.";
                var textWidth = ImGui.CalcTextSize(footerText).X;
                ImGui.SetCursorPosX((windowWidth - textWidth) * 0.5f);
                ImGui.TextDisabled(footerText);
            }
            finally
            {
                ThemeManager.PopTheme();
            }
        }
    }
}