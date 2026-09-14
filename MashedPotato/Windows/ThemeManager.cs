// File: MashedPotato/Windows/ThemeManager.cs
using System.Numerics;
using Dalamud.Bindings.ImGui;

namespace MashedPotato.Windows
{
    public static class ThemeManager
    {
        // Define a consistent colour palette for your suite of plugins
        public static readonly Vector4 BackgroundDark = new(0.12f, 0.12f, 0.15f, 1.00f);
        public static readonly Vector4 PanelBackground = new(0.16f, 0.16f, 0.20f, 1.00f);
        public static readonly Vector4 AccentGold = new(1.00f, 0.75f, 0.20f, 1.00f);
        public static readonly Vector4 AccentHover = new(1.00f, 0.85f, 0.40f, 1.00f);
        public static readonly Vector4 TextPrimary = new(0.90f, 0.90f, 0.95f, 1.00f);
        public static readonly Vector4 TextMuted = new(0.60f, 0.60f, 0.65f, 1.00f);

        public static void ApplyCustomStyle()
        {
            var style = ImGui.GetStyle();

            // Smooth out the harsh default corners
            style.WindowRounding = 6.0f;
            style.ChildRounding = 4.0f;
            style.FrameRounding = 4.0f;
            style.PopupRounding = 4.0f;
            style.ScrollbarRounding = 9.0f;
            style.TabRounding = 4.0f;

            // Comfortable padding
            style.WindowPadding = new Vector2(12, 12);
            style.FramePadding = new Vector2(8, 4);
            style.ItemSpacing = new Vector2(8, 8);

            // Apply custom colour scheme safely
            var colors = style.Colors;
            colors[(int)ImGuiCol.WindowBg] = BackgroundDark;
            colors[(int)ImGuiCol.ChildBg] = PanelBackground;
            colors[(int)ImGuiCol.PopupBg] = PanelBackground;
            colors[(int)ImGuiCol.FrameBg] = PanelBackground;
            colors[(int)ImGuiCol.FrameBgHovered] = new Vector4(0.22f, 0.22f, 0.28f, 1.00f);
            colors[(int)ImGuiCol.FrameBgActive] = new Vector4(0.28f, 0.28f, 0.36f, 1.00f);
            
            // Buttons & Interactive Accents
            colors[(int)ImGuiCol.Button] = new Vector4(0.20f, 0.20f, 0.26f, 1.00f);
            colors[(int)ImGuiCol.ButtonHovered] = AccentGold with { W = 0.8f };
            colors[(int)ImGuiCol.ButtonActive] = AccentGold;

            // Headers & Tabs
            colors[(int)ImGuiCol.Header] = new Vector4(0.22f, 0.22f, 0.28f, 1.00f);
            colors[(int)ImGuiCol.HeaderHovered] = new Vector4(0.28f, 0.28f, 0.36f, 1.00f);
            colors[(int)ImGuiCol.HeaderActive] = AccentGold with { W = 0.5f };

            // Text
            colors[(int)ImGuiCol.Text] = TextPrimary;
            colors[(int)ImGuiCol.TextDisabled] = TextMuted;
        }
    }
}