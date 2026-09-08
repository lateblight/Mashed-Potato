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

        public PenumbraIpc(IDalamudPluginInterface pluginInterface)
        {
            this.pi = pluginInterface;

            try
            {
                this.redrawAllSub = new RedrawAll(pluginInterface);
            }
            catch (Exception ex)
            {
                Plugin.OutputChatLine($"Failed to initialize Penumbra IPC: {ex.Message}");
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
                // Fixed logging call to use standard Dalamud plugin log framework
                Service.PluginLog.Error($"Error triggering Penumbra RedrawAll: {ex}");
            }
        }

        public void Dispose()
        {
            // Cleanup handled by subscriber wrapper
        }
    }
}