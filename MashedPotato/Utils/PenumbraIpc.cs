// File: ./MashedPotato/Utils/PenumbraIpc.cs

using System;
using Dalamud.Plugin;
using Penumbra.Api.Enums;
using Penumbra.Api.IpcSubscribers;

namespace MashedPotato.Utils
{
    public sealed class PenumbraIpc : IDisposable
    {
        private readonly IDalamudPluginInterface pi;
        private readonly RedrawAll? redrawAllSub;
        private readonly IDisposable? creatingCharaSub;

        public PenumbraIpc(IDalamudPluginInterface pluginInterface)
        {
            this.pi = pluginInterface;

            try
            {
                this.redrawAllSub = new RedrawAll(pluginInterface);
                this.creatingCharaSub = CreatingCharacterBase.Subscriber(pluginInterface, Drawer.OnCreatingCharacterBase);
            }
            catch (Exception ex)
            {
                Service.PluginLog.Error($"Failed to initialize Penumbra IPC: {ex.Message}");
            }
        }

        public void RedrawAll(RedrawType type)
        {
            try
            {
                this.redrawAllSub?.Invoke(type);
            }
            catch (Exception ex)
            {
                Service.PluginLog.Error($"Error triggering Penumbra RedrawAll: {ex}");
            }
        }

        public void Dispose()
        {
            this.creatingCharaSub?.Dispose();
        }
    }
}