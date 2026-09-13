// File: ./MashedPotato/Utils/PenumbraIpc.cs

// File: MashedPotato/Utils/PenumbraIpc.cs

using System;
using Dalamud.Plugin;
using Penumbra.Api.Enums;
using Penumbra.Api.IpcSubscribers;

namespace MashedPotato.Utils
{
    public class PenumbraIpc : IDisposable
    {
        private readonly RedrawAll? redrawAllSub;
        private readonly RedrawObject? redrawObjectSub;
        
        private readonly IDisposable? initializedSub;
        private readonly IDisposable? disposedSub;
        private readonly IDisposable? creatingCharaSub;

        public bool ApiAvailable { get; private set; }

        public PenumbraIpc(IDalamudPluginInterface pi)
        {
            try
            {
                redrawAllSub = new RedrawAll(pi);
                redrawObjectSub = new RedrawObject(pi);

                initializedSub = (IDisposable)Initialized.Subscriber(pi, OnPenumbraInitialized);
                disposedSub = (IDisposable)Disposed.Subscriber(pi, OnPenumbraDisposed);
                creatingCharaSub = (IDisposable)CreatingCharacterBase.Subscriber(pi, Drawer.OnCreatingCharacterBase);

                ApiAvailable = true; 
            }
            catch (Exception ex)
            {
                Service.PluginLog?.Error(ex, "Failed to initialise Penumbra IPC subscribers.");
                ApiAvailable = false;
            }
        }

        private void OnPenumbraInitialized()
        {
            ApiAvailable = true;
            Service.PluginLog?.Information("Penumbra IPC initialized and ready.");
        }

        private void OnPenumbraDisposed()
        {
            ApiAvailable = false;
            Service.PluginLog?.Information("Penumbra IPC disposed.");
        }

        public void RedrawAll()
        {
            if (ApiAvailable && redrawAllSub != null)
            {
                try
                {
                    redrawAllSub.Invoke(RedrawType.Redraw);
                }
                catch (Exception ex)
                {
                    Service.PluginLog?.Debug(ex, "Failed to invoke Penumbra RedrawAll.");
                }
            }
        }

        public void RedrawTarget(string playerName)
        {
            if (!ApiAvailable || redrawObjectSub == null || Service.objectTable == null) return;

            try
            {
                foreach (var obj in Service.objectTable)
                {
                    if (obj != null && obj.Name.TextValue.Equals(playerName, StringComparison.OrdinalIgnoreCase))
                    {
                        // Pass the integer cloakroom ticket instead of the coat itself
                        redrawObjectSub.Invoke((int)obj.ObjectIndex, RedrawType.Redraw);
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                Service.PluginLog?.Debug(ex, $"Failed to invoke Penumbra RedrawObject for {playerName}.");
            }
        }

        public void Dispose()
        {
            initializedSub?.Dispose();
            disposedSub?.Dispose();
            creatingCharaSub?.Dispose();
        }
    }
}
