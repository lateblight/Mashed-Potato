// File: MashedPotato/Utils/PenumbraIpc.cs

using System;
using Dalamud.Plugin;
using Dalamud.Plugin.Ipc.Exceptions;
using Penumbra.Api.Enums;
using Penumbra.Api.IpcSubscribers;

namespace MashedPotato.Utils
{
    public sealed class PenumbraIpc : IDisposable
    {
        private readonly IDalamudPluginInterface pi;
        private readonly RedrawAll? redrawAllSub;
        private readonly IDisposable? creatingCharaSub;
        private readonly IDisposable? initializedSub;
        private readonly IDisposable? disposedSub;

        // This flag lets the UI know if Penumbra is actually awake
        public bool ApiAvailable { get; private set; }

        public PenumbraIpc(IDalamudPluginInterface pluginInterface)
        {
            this.pi = pluginInterface;

            try
            {
                this.redrawAllSub = new RedrawAll(pluginInterface);
                this.creatingCharaSub = (IDisposable)CreatingCharacterBase.Subscriber(pluginInterface, Drawer.OnCreatingCharacterBase);

                this.initializedSub = (IDisposable)Initialized.Subscriber(pluginInterface, OnPenumbraInitialized);
                this.disposedSub = (IDisposable)Disposed.Subscriber(pluginInterface, OnPenumbraDisposed);

                this.ApiAvailable = true;
            }
            catch (Exception ex)
            {
                this.ApiAvailable = false;
                Service.PluginLog.Warning($"Penumbra IPC not ready at startup: {ex.Message}");
            }
        }

        private void OnPenumbraInitialized()
        {
            Service.PluginLog.Information("Penumbra IPC initialized signal received.");
            this.ApiAvailable = true;
            Drawer.RefreshAllPlayers();
        }

        private void OnPenumbraDisposed()
        {
            Service.PluginLog.Information("Penumbra IPC disposed signal received.");
            this.ApiAvailable = false;
        }

        public void RedrawAll(RedrawType type)
        {
            if (!this.ApiAvailable) return;

            try
            {
                this.redrawAllSub?.Invoke(type);
            }
            catch (IpcNotReadyError)
            {
                this.ApiAvailable = false;
            }
            catch (Exception ex)
            {
                Service.PluginLog.Error($"Error triggering Penumbra RedrawAll: {ex}");
            }
        }

        public void Dispose()
        {
            this.initializedSub?.Dispose();
            this.disposedSub?.Dispose();
            this.creatingCharaSub?.Dispose();
        }
    }
}