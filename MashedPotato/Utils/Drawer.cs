// File: ./MashedPotato/Utils/Drawer.cs

using FFXIVClientStructs.FFXIV.Client.Game.Object;
using Penumbra.Api.Enums;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using static MashedPotato.Utils.Constant;

namespace MashedPotato.Utils
{
    internal class Drawer : IDisposable
    {
        public static HashSet<string> NonNativeID = [];

        public Drawer()
        {
            Service.configWindow.OnConfigChanged += RefreshAllPlayers;
            if (Service.configuration.enabled)
            {
                // Rerouted to silent diagnostic log to prevent boot crashes
                Service.PluginLog.Information("Mashed-Potato starting...");
                RefreshAllPlayers();
            }
        }

        private static void RefreshAllPlayers()
        {
            Service.PluginLog.Information("Refreshing all players");
            NonNativeID.Clear();
            
            // Added safe null-checks (?) to prevent crashes if UI isn't ready
            Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
            Service.namePlateGui?.RequestRedraw();
        }

        public static unsafe void OnCreatingCharacterBase(nint gameObjectAddress, Guid _1, nint _2, nint customizePtr, nint _3)
        {
            if (!Service.configuration.enabled) return;

            var gameObj = (GameObject*)gameObjectAddress;
            if (gameObj->ObjectKind != ObjectKind.Pc) return;

            var playerName = gameObj->NameString;

            if (!string.IsNullOrEmpty(playerName) && Service.configuration.WhitelistedPlayers.Contains(playerName))
                return;

            var customData = Marshal.PtrToStructure<CharaCustomizeData>(customizePtr);
            
            if ((int)customData.Race != 3)
                return;

            if ((int)Service.configuration.SelectedRace == 3 || customData.Race == Race.UNKNOWN)
                return;

            NonNativeID.Add(playerName);
            ChangeRace(customData, customizePtr, (Race)Service.configuration.SelectedRace);
        }

        private static unsafe void ChangeRace(CharaCustomizeData customData, nint customizePtr, Race selectedRace)
        {
            customData.Race = selectedRace;
            customData.Tribe = (byte)(((byte)selectedRace * 2) - (customData.Tribe % 2));
            customData.FaceType %= 4;
            customData.ModelType %= 2;
            customData.HairStyle = (byte)((customData.HairStyle % RaceMappings.RaceHairs[selectedRace]) + 1);
            Marshal.StructureToPtr(customData, customizePtr, true);
        }

        public void Dispose()
        {
            Service.configWindow.OnConfigChanged -= RefreshAllPlayers;
        }
    }
}