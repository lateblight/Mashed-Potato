// File: MashedPotato/Utils/Drawer.cs

using FFXIVClientStructs.FFXIV.Client.Game.Object;
using Penumbra.Api.Enums;
using System;
using System.Collections.Generic;
using static MashedPotato.Utils.Constant;

namespace MashedPotato.Utils
{
    internal class Drawer : IDisposable
    {
        public static HashSet<string> NonNativeID = new();

        public Drawer()
        {
            Service.configWindow.OnConfigChanged += RefreshAllPlayers;
            if (Service.configuration.enabled)
            {
                Service.PluginLog.Information("Mashed-Potato loaded quietly.");
                RefreshAllPlayers();
            }
        }

        internal static void RefreshAllPlayers()
        {
            Service.PluginLog.Information("Refreshing all players");
            NonNativeID.Clear();
            Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
            Service.namePlateGui?.RequestRedraw();
        }

        public static unsafe void OnCreatingCharacterBase(nint gameObjectAddress, Guid _1, nint _2, nint customizePtr, nint _3)
        {
            try
            {
                if (!Service.configuration.enabled) return;

                if (gameObjectAddress == IntPtr.Zero || customizePtr == IntPtr.Zero) return;

                var gameObj = (GameObject*)gameObjectAddress;
                if (gameObj == null) return;
                if (gameObj->ObjectKind != ObjectKind.Pc) return;

                var playerName = gameObj->NameString;
                if (string.IsNullOrEmpty(playerName)) return;

                if (Service.configuration.WhitelistedPlayers.Contains(playerName))
                    return;

                var customData = (CharaCustomizeData*)customizePtr;

                if ((int)customData->Race != 3)
                    return;

                if ((int)Service.configuration.SelectedRace == 3 || customData->Race == Race.UNKNOWN)
                    return;

                NonNativeID.Add(playerName);
                ChangeRace(customData, (Race)Service.configuration.SelectedRace);
            }
            catch (Exception ex)
            {
                Service.PluginLog.Error(ex, "Caught exception in OnCreatingCharacterBase hook.");
            }
        }

        private static unsafe void ChangeRace(CharaCustomizeData* customData, Race selectedRace)
        {
            customData->Race = selectedRace;
            customData->Tribe = (byte)(((byte)selectedRace * 2) - (customData->Tribe % 2));
            customData->FaceType %= 4;
            customData->ModelType %= 2;
            customData->HairStyle = (byte)((customData->HairStyle % RaceMappings.RaceHairs[selectedRace]) + 1);
        }

        public void Dispose()
        {
            Service.configWindow.OnConfigChanged -= RefreshAllPlayers;
        }
    }
}