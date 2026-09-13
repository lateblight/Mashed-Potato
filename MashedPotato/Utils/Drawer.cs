// File: ./MashedPotato/Utils/Drawer.cs

// File: MashedPotato/Utils/Drawer.cs

using System;
using FFXIVClientStructs.FFXIV.Client.Game.Object;

namespace MashedPotato.Utils
{
    public class Drawer : IDisposable
    {
        // Empty constructor: We now rely exclusively on Penumbra IPC events
        public Drawer() { }

        public static unsafe void OnCreatingCharacterBase(nint gameObjectAddress, Guid collectionId, nint modelId, nint customizeDataAddress, nint equipDataAddress)
        {
            if (Service.configuration == null || !Service.configuration.enabled) return;

            var gameObj = (GameObject*)gameObjectAddress;
            if (gameObj == null || gameObj->ObjectKind != ObjectKind.Pc) return;

            var playerName = gameObj->NameString;
            if (!string.IsNullOrEmpty(playerName) && Service.whitelistManager != null && Service.whitelistManager.IsWhitelisted(playerName)) 
                return;

            // Safe unmanaged pointer manipulation completely bypasses the Marshal COM crash risk[cite: 4]
            byte* customize = (byte*)customizeDataAddress;
            if (customize != null)
            {
                if (customize[0] == 3) // Race ID 3 = Lalafell
                {
                    byte targetRace = (byte)Service.configuration.targetRaceId;
                    if (targetRace == 3) return; // Don't mash a potato into a potato!

                    customize[0] = targetRace;
                    
                    // Adjust parameters to ensure the new model renders correctly
                    byte oldTribe = customize[2];
                    customize[2] = (byte)((targetRace * 2) - (oldTribe % 2));
                    customize[3] %= 4; // FaceType
                    customize[1] %= 2; // ModelType
                    
                    if (customize[4] == 0) customize[4] = 1; // Fallback hair
                }
            }
        }

        public void Dispose() { }
    }
}
