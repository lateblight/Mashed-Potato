using Dalamud.Game.ClientState.Objects.Enums;
using Dalamud.Game.Gui.NamePlate;

namespace OopsAllLalafellsSRE.Utils
{
    internal class Nameplate
    {
        public Nameplate()
        {
            Service.namePlateGui.OnNamePlateUpdate += (context, handlers) =>
            {
                // Check if the plugin is enabled and nameplate modifications are active in settings.
                if (!Service.configuration.enabled || !Service.configuration.nameHQ)
                    return;

                foreach (var handler in handlers)
                {
                    if (handler.NamePlateKind == NamePlateKind.PlayerCharacter)
                    {
                        unsafe
                        {
                            if (handler.PlayerCharacter == null) return;

                            string playerName = handler.PlayerCharacter.Name.TextValue;
                            if (string.IsNullOrEmpty(playerName)) continue;

                            // Check if this player is actively transformed by our plugin.
                            bool isTransformed = Drawer.NonNativeID.Contains(playerName);

                            // Check if this player is present on our trusted whitelist.
                            // We use case-insensitive lookup to ensure robust matching.
                            bool isWhitelisted = Service.configuration.WhitelistedPlayers.Contains(playerName);

                            // Only display our indicator symbol if they are transformed AND not whitelisted.
                            if (isTransformed && !isWhitelisted)
                            {
                                // Attach the indicator symbol to the front of their nameplate display.
                                handler.NameParts.Text = $"\uE03C {handler.Name}";
                            }
                        }
                    }
                }
            };
        }

        public void Dispose() { }
    }
}