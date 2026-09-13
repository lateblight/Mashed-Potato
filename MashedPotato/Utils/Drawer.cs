// File: MashedPotato/Utils/Drawer.cs

using System;
using Penumbra.Api.Enums;

namespace MashedPotato.Utils
{
    public class Drawer : IDisposable
    {
        public Drawer()
        {
            // Initialisation for model swapping logic
        }

        public static void RefreshPlayer(string playerName)
        {
            Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
        }

        public void RefreshAllPlayers()
        {
            Service.penumbraApi?.RedrawAll(RedrawType.Redraw);
        }

        public void Dispose()
        {
            // Tidy up resources on shutdown
        }
    }
}