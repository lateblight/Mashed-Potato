// File: ./MashedPotato/Utils/Drawer.cs

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

        internal static void RefreshPlayer(string playerName)
        {
            Service.PluginLog.Information($"Refreshing specific player: {playerName}");
            
            // Remove only this specific player from the transformed cache
            NonNativeID.Remove(playerName);
            
            // Find the player in the object table to get their integer index for Penumbra
            int targetIndex = -1;
            foreach (var obj in Service.objectTable)
            {
                if (obj != null && obj.Name.TextValue == playerName)
                {
                    targetIndex = (int)obj.ObjectIndex;
                    break;
                }
            }
            
            if (targetIndex != -1)
            {
                // Tell Penumbra to redraw just them using their integer index
                Service.penumbraApi?.RedrawPlayer(targetIndex, RedrawType.Redraw);
            }
            else
            {
                // Failsafe: if they aren't found, redraw everyone just in case
                Service.PluginLog.Warning($"Could not find index for {playerName}, falling back to RedrawAll.");
                Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
            }
            
            // Nudge the nameplates to update the sneaky icon status
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