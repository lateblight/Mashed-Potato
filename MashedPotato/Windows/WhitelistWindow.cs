/*
 *  ==================================================================
 *   _  _   _    _          _   _                      
 *  | || | | |  (_)        | | | |                     
 *  | || |_| | ___  ___ ___| |_| |__   ___  ___        
 *  | || __| |/ / |/ __/ __| __| '_ \ / _ \/ __|       
 *  | || |_|   <| | (__\__ \ |_| | | |  __/\__ \       
 *  | |_| \__|_|\_\_|\___|___/\__|_| |_|\___||___/       
 *                                                     
 *  [ WHITELIST WINDOW: THE SANCTUARY OF TRUSTED SOULS ]
 *  Enclosed in an obsidian framed child container with a disciplined 
 *  scrollbar. Because uncontained lists are the hallmark of chaos.
 *  ==================================================================
 */

// File: ./MashedPotato/Windows/WhitelistWindow.cs

using System.Numerics;
using Dalamud.Interface.Windowing;
using Dalamud.Bindings.ImGui;
using MashedPotato.Utils;

namespace MashedPotato.Windows
{
    public class WhitelistWindow : Window
    {
        private readonly Configuration configuration;
        private string inputPlayerName = string.Empty;

        public WhitelistWindow(Configuration configuration) : base("Mashed Potato — Whitelist")
        {
            this.configuration = configuration;
            
            Size = new Vector2(460, 420);
            SizeCondition = ImGuiCond.FirstUseEver;
            Flags = ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.AlwaysAutoResize;
        }

        public override void Draw()
        {
            ThemeManager.PushTheme();
            try
            {
                ImGui.Spacing();
                
                // Majestic header with elevated font scale
                ImGui.SetWindowFontScale(1.25f);
                ImGui.TextColored(new Vector4(0.4f, 0.8f, 1f, 1f), "🛡️ Trusted Whitelist");
                ImGui.SetWindowFontScale(1.0f);

                ImGui.TextDisabled("Exempt specific souls from model conversion.");
                ImGui.Spacing();
                ImGui.Separator();
                ImGui.Spacing();

                ImGui.Text("Add Player by Exact Name:");
                ImGui.SetNextItemWidth(310f);
                ImGui.InputText("##AddPlayerInput", ref inputPlayerName, 64);
                ImGui.SameLine();
                if (ImGui.Button("Add", new Vector2(90f, 26f)))
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

                ImGui.Text("Protected Souls:");
                ImGui.Spacing();

                // Framed Child Container Box with an internal scrollbar
                // This keeps the outer window compact and elegant while handling infinite growth!
                ImGui.BeginChild("WhitelistScrollBox", new Vector2(0, 220), true, ImGuiWindowFlags.None);
                {
                    if (configuration.WhitelistedPlayers != null && configuration.WhitelistedPlayers.Count > 0)
                    {
                        if (ImGui.BeginTable("WhitelistTable", 2, ImGuiTableFlags.BordersInnerH | ImGuiTableFlags.RowBg))
                        {
                            ImGui.TableSetupColumn("Character Name", ImGuiTableColumnFlags.WidthStretch);
                            ImGui.TableSetupColumn("Actions", ImGuiTableColumnFlags.WidthFixed, 90f);
                            ImGui.TableHeadersRow();

                            foreach (var player in configuration.WhitelistedPlayers.ToArray())
                            {
                                ImGui.TableNextRow();
                                ImGui.TableSetColumnIndex(0);
                                ImGui.AlignTextToFramePadding();
                                ImGui.Text(player);

                                ImGui.TableSetColumnIndex(1);
                                if (ImGui.Button($"Remove##{player}", new Vector2(-1, 24)))
                                {
                                    Service.whitelistManager?.RemovePlayer(player);
                                }
                            }
                            ImGui.EndTable();
                        }
                    }
                    else
                    {
                        ImGui.Spacing();
                        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize("No souls currently whitelisted.").X) * 0.5f);
                        ImGui.TextDisabled("No souls currently whitelisted.");
                        ImGui.Spacing();
                        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize("Right-click players in-game to add them.").X) * 0.5f);
                        ImGui.TextDisabled("Right-click players in-game to add them.");
                    }
                }
                ImGui.EndChild();

                ImGui.Spacing();
            }
            finally
            {
                ThemeManager.PopTheme();
            }
        }
    }
}