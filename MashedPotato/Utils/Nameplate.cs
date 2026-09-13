// File: MashedPotato/Utils/Nameplate.cs

using System;
using System.Collections.Generic;
using Dalamud.Plugin.Services;
using Dalamud.Game.Gui.NamePlate;
using FFXIVClientStructs.FFXIV.Client.Game.Character;
using ObjectKind = FFXIVClientStructs.FFXIV.Client.Game.Object.ObjectKind;

namespace MashedPotato.Utils
{
    public class Nameplate : IDisposable
    {
        private readonly INamePlateGui.OnPlateUpdateDelegate updateHandler;

        public Nameplate()
        {
            updateHandler = OnNamePlateUpdate;

            if (Service.namePlateGui != null)
            {
                Service.namePlateGui.OnNamePlateUpdate += updateHandler;
            }
        }

        public void Dispose()
        {
            if (Service.namePlateGui != null && updateHandler != null)
            {
                Service.namePlateGui.OnNamePlateUpdate -= updateHandler;
            }
        }

        private unsafe void OnNamePlateUpdate(INamePlateUpdateContext context, IReadOnlyList<INamePlateUpdateHandler> handlers)
        {
            if (!Service.configuration.enabled || !Service.configuration.nameHQ) return;

            foreach (var handler in handlers)
            {
                try
                {
                    var obj = handler.GameObject;
                    if (obj != null && obj.Address != IntPtr.Zero)
                    {
                        // Check the unmanaged GameObject's ObjectKind directly against ObjectKind.Pc
                        // to ensure we only target actual player characters and leave NPCs unmolested.
                        var gameObj = (FFXIVClientStructs.FFXIV.Client.Game.Object.GameObject*)obj.Address;
                        if (gameObj->ObjectKind != ObjectKind.Pc)
                        {
                            continue;
                        }

                        string playerName = handler.GetFieldAsString(NamePlateStringField.Name) ?? string.Empty;
                        if (string.IsNullOrEmpty(playerName))
                        {
                            playerName = obj.Name.TextValue;
                        }

                        if (Service.whitelistManager != null && Service.whitelistManager.IsWhitelisted(playerName))
                        {
                            continue; // Leave our trusted whitelisted ankle-biters alone
                        }

                        // Cast the native object address directly to an unmanaged Character pointer[cite: 3]
                        var character = (Character*)obj.Address;
                        if (character != null)
                        {
                            // Inspect the character's customize data array directly via byte pointer arithmetic.
                            // The very first byte (index 0) represents the playable race ID (3 = Lalafell).
                            byte* customizePtr = (byte*)(&character->DrawData.CustomizeData);
                            if (customizePtr != null && customizePtr[0] == 3)
                            {
                                handler.DisplayTitle = true;
                                handler.Title = "[ * ]";
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    Service.PluginLog?.Debug(ex, "Mashed Potato nameplate update hook encountered an exception.");
                }
            }
        }
    }
}