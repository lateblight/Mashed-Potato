// File: ./MashedPotato/Utils/Nameplate.cs

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
            // Cache the configuration locally so the compiler's null-state analysis is fully satisfied
            var config = Service.configuration;
            if (config == null || !config.enabled || !config.nameHQ) return;

            foreach (var handler in handlers)
            {
                try
                {
                    var obj = handler.GameObject;
                    if (obj != null && obj.Address != IntPtr.Zero)
                    {
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
                            continue; 
                        }

                        var character = (Character*)obj.Address;
                        if (character != null)
                        {
                            byte* customizePtr = (byte*)(&character->DrawData.CustomizeData);
                            if (customizePtr != null && customizePtr[0] == 3)
                            {
                                handler.DisplayTitle = true;
                                handler.Title = "*";
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
