// File: ./MashedPotato/Utils/Nameplate.cs

using Dalamud.Game.ClientState.Objects.Enums;
using Dalamud.Game.Gui.NamePlate;

namespace MashedPotato.Utils
{
    internal class Nameplate
    {
        public Nameplate()
        {
            Service.namePlateGui.OnNamePlateUpdate += (context, handlers) =>
            {
                if (!Service.configuration.enabled || !Service.configuration.nameHQ)
                    return;

                foreach (var handler in handlers)
                {
                    if (handler.NamePlateKind == NamePlateKind.PlayerCharacter)
                    {
                        unsafe
                        {
                            if (handler.PlayerCharacter == null) continue;

                            string playerName = handler.PlayerCharacter.Name.TextValue;
                            if (string.IsNullOrEmpty(playerName)) continue;

                            bool isTransformed = Drawer.NonNativeID.Contains(playerName);
                            bool isWhitelisted = Service.configuration.WhitelistedPlayers.Contains(playerName);

                            if (isTransformed && !isWhitelisted)
                            {
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