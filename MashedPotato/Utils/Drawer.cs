using FFXIVClientStructs.FFXIV.Client.Game.Object;
using Penumbra.Api.Enums;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using static OopsAllLalafellsSRE.Utils.Constant;

namespace OopsAllLalafellsSRE.Utils
{
    internal class Drawer : IDisposable
    {
        public static HashSet<string> NonNativeID = [];

        public Drawer()
        {
            Service.configWindow.OnConfigChanged += RefreshAllPlayers;
            if (Service.configuration.enabled)
            {
                Plugin.OutputChatLine("Mashed-Potato starting...");
                RefreshAllPlayers();
            }
        }

        private static void RefreshAllPlayers()
        {
            Plugin.OutputChatLine("Refreshing all players");
            NonNativeID.Clear();
            Service.penumbraApi.RedrawAll(RedrawType.Redraw);
            Service.namePlateGui.RequestRedraw();
        }

        public static unsafe void OnCreatingCharacterBase(nint gameObjectAddress, Guid _1, nint _2, nint customizePtr, nint _3)
        {
            if (!Service.configuration.enabled) return;

            // return if not player character
            var gameObj = (GameObject*)gameObjectAddress;
            if (gameObj->ObjectKind != ObjectKind.Pc) return;

            var playerName = gameObj->NameString;

            // WHITELIST CHECK: If the player is on your whitelist, ignore them and keep them as a Lalafell
            if (!string.IsNullOrEmpty(playerName) && Service.configuration.WhitelistedNames.Contains(playerName))
                return;

            var customData = Marshal.PtrToStructure<CharaCustomizeData>(customizePtr);
            
            // 3 is the internal game ID for Lalafells. 
            // If the character loading in is NOT a 3, we stop the code here and let them stay normal.
            if ((int)customData.Race != 3)
                return;

            // FAILSAFE: 
            // If they ARE a Lalafell, but you accidentally selected Lalafell in the plugin menu 
            // as the race you want to change them into, we stop here so the game doesn't do unnecessary work.
            if ((int)Service.configuration.SelectedRace == 3 || customData.Race == Race.UNKNOWN)
                return;

            // If they made it past the checks above, they are a Lalafell! Change them!
            NonNativeID.Add(playerName);
            ChangeRace(customData, customizePtr, Service.configuration.SelectedRace);
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