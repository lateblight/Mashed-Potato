// File: MashedPotato/Utils/PenumbraIpc.cs

using System;
using Dalamud.Plugin;
using Penumbra.Api.Enums;

namespace MashedPotato.Utils
{
    public class PenumbraIpc : IDisposable
    {
        private readonly IDalamudPluginInterface pluginInterface;
        public bool ApiAvailable { get; private set; }

        public PenumbraIpc(IDalamudPluginInterface pluginInterface)
        {
            this.pluginInterface = pluginInterface;
            try
            {
                var subscriber = pluginInterface.GetIpcSubscriber<int>("Penumbra.ApiVersion");
                var apiVersion = (int?)subscriber?.GetType().GetMethod("Invoke")?.Invoke(subscriber, null) 
                                 ?? (int?)subscriber?.GetType().GetMethod("InvokeFunc")?.Invoke(subscriber, null) ?? 0;
                
                ApiAvailable = apiVersion >= 3;
            }
            catch
            {
                ApiAvailable = false;
            }
        }

        public void RedrawAll(RedrawType type)
        {
            if (!ApiAvailable) return;
            try
            {
                var redrawSub = pluginInterface.GetIpcSubscriber<object>("Penumbra.RedrawAll");
                redrawSub?.GetType().GetMethod("Invoke")?.Invoke(redrawSub, null);
            }
            catch
            {
                // Suppress transient IPC errors gracefully
            }
        }

        public void Dispose()
        {
            // Cleanup IPC resources
        }
    }
}