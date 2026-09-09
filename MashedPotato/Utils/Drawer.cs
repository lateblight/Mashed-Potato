// File: ./MashedPotato/Utils/Drawer.cs

using FFXIVClientStructs.FFXIV.Client.Game.Object;
using Penumbra.Api.Enums;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using static MashedPotato.Utils.Constant;
using MashedPotato;

namespace MashedPotato.Utils
{
    internal class Drawer : IDisposable
    {
        public static HashSet<string> NonNativeID = [];

        public Drawer()
        {
            Service.configWindow.OnConfigChanged += RefreshAllPlayers;
            
            // Subscribe to Penumbra's character base creation event safely
            try
            {
                Penumbra.Api.IpcSubscribers.CreatingCharacterBase.Delegate += OnCreatingCharacterBase;
            }
            catch (Exception ex)
            {
                Plugin.OutputChatLine(s: $"Failed to subscribe to Penumbra CreatingCharacterBase: {ex.Message}");
            }

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

            var gameObj = (GameObject*)gameObjectAddress;
            if (gameObj->ObjectKind != ObjectKind.Pc) return;

            var playerName = gameObj->NameString;

            // WHITELIST CHECK: If your mate is on the list, leave their Lalafell model alone
            if (!string.IsNullOrEmpty(playerName) && Service.configuration.WhitelistedPlayers.Contains(playerName))
                return;

            var customData = Marshal.PtrToStructure<CharaCustomizeData>(customizePtr);
            
            // 3 is the internal game ID for Lalafells
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
            try
            {
                Penumbra.Api.IpcSubscribers.CreatingCharacterBase.Delegate -= OnCreatingCharacterBase;
            }
            catch { }
        }
    }
}
```[cite: 1]

---

### How to Build and Push

Pop open your terminal in the repository root and run your automated build script to compile everything, bump the version, and bundle a fresh `latest.zip`[cite: 1]:

```powershell
./build.ps1