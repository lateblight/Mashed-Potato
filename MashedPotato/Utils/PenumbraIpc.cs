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
        
        // Stored as an IDisposable because Subscriber is a method, not a class type.
        private readonly IDisposable? creatingCharaSub;

        public PenumbraIpc(IDalamudPluginInterface pluginInterface)
        {
            this.pi = pluginInterface;

            try
            {
                this.redrawAllSub = new RedrawAll(pluginInterface);
                
                // Call the static method directly and box the result into our IDisposable field.
                this.creatingCharaSub = (IDisposable)CreatingCharacterBase.Subscriber(pluginInterface, Drawer.OnCreatingCharacterBase);
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