/*
 *  ==================================================================
 *   _  _   _    _          _   _                      
 *  | || | | |  (_)        | | | |                     
 *  | || |_| | ___  ___ ___| |_| |__   ___  ___        
 *  | || __| |/ / |/ __/ __| __| '_ \ / _ \/ __|       
 *  | || |_|   <| | (__\__ \ |_| | | |  __/\__ \       
 *  | |_| \__|_|\_\_|\___|___/\__|_| |_|\___||___/       
 *                                                     
 *  [ THEME MANAGER: ARCHITECTURAL AESTHETIC ENFORCEMENT ]
 *  Portable dark-mode elegance for mortals suffering from chronic grey-box 
 *  syndrome. Built with elite 90s cyber-chic and aristocratic spite.
 *  ==================================================================
 */

// File: ./MashedPotato/Windows/ThemeManager.cs

using System.Numerics;
using Dalamud.Bindings.ImGui;

namespace MashedPotato.Windows
{
    public static class ThemeManager
    {
        private static readonly Vector4 ColObsidianBg = new(0.08f, 0.08f, 0.10f, 1.00f);
        private static readonly Vector4 ColPanelDark = new(0.12f, 0.12f, 0.15f, 1.00f);
        private static readonly Vector4 ColAccentAmber = new(1.00f, 0.75f, 0.20f, 1.00f);
        private static readonly Vector4 ColTextBright = new(0.95f, 0.95f, 1.00f, 1.00f);
        private static readonly Vector4 ColTextDim = new(0.55f, 0.55f, 0.60f, 1.00f);

        public static void PushTheme()
        {
            ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 8.0f);
            ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 6.0f);
            ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding, 4.0f);
            ImGui.PushStyleVar(ImGuiStyleVar.PopupRounding, 4.0f);
            ImGui.PushStyleVar(ImGuiStyleVar.ScrollbarRounding, 12.0f);
            ImGui.PushStyleVar(ImGuiStyleVar.TabRounding, 4.0f);

            ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, new Vector2(16, 16));
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, new Vector2(10, 6));
            ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing, new Vector2(10, 10));

            ImGui.PushStyleColor(ImGuiCol.WindowBg, ColObsidianBg);
            ImGui.PushStyleColor(ImGuiCol.ChildBg, ColPanelDark);
            ImGui.PushStyleColor(ImGuiCol.PopupBg, ColPanelDark);
            ImGui.PushStyleColor(ImGuiCol.FrameBg, ColPanelDark);
            ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, new Vector4(0.18f, 0.18f, 0.22f, 1.00f));
            ImGui.PushStyleColor(ImGuiCol.FrameBgActive, new Vector4(0.24f, 0.24f, 0.30f, 1.00f));
            
            ImGui.PushStyleColor(ImGuiCol.Button, new Vector4(0.16f, 0.16f, 0.20f, 1.00f));
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, ColAccentAmber with { W = 0.8f });
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, ColAccentAmber);

            ImGui.PushStyleColor(ImGuiCol.Header, new Vector4(0.18f, 0.18f, 0.22f, 1.00f));
            ImGui.PushStyleColor(ImGuiCol.HeaderHovered, new Vector4(0.24f, 0.24f, 0.30f, 1.00f));
            ImGui.PushStyleColor(ImGuiCol.HeaderActive, ColAccentAmber with { W = 0.5f });

            ImGui.PushStyleColor(ImGuiCol.Text, ColTextBright);
            ImGui.PushStyleColor(ImGuiCol.TextDisabled, ColTextDim);
        }

        public static void PopTheme()
        {
            ImGui.PopStyleColor(14);
            ImGui.PopStyleVar(9);
        }
    }
}