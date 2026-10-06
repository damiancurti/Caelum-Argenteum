// Sonda de observación #116, cargada sólo como complemento de pruebas.
// Los relojes reales no participan de decisiones ni estado del juego.
class CA116Benchmark : EventHandler
{
    int LastSampleTic;
    override void WorldLoaded(WorldEvent e)
    {
        LastSampleTic = -35;
        Console.Printf("CA116 LOAD map=%s tic=%d ms=%.3f", level.MapName, level.time, MSTimeF());
    }
    override void WorldTick()
    {
        if (level.time < LastSampleTic + 35) return;
        LastSampleTic = level.time;
        let port = CaelumPortSiege.Get();
        if (port == null || !port.RosterSealed) return;
        int attackers = 0, defenders = 0;
        for (int i = 0; i < port.Attackers.Size(); i++)
            if (port.Attackers[i].Body != null && port.Attackers[i].Body.health > 0) attackers++;
        for (int i = 0; i < port.Defenders.Size(); i++)
            if (port.Defenders[i] != null && port.Defenders[i].health > 0) defenders++;
        let user = players[0].mo;
        Console.Printf("CA116 SIM tic=%d ms=%.3f roster=%d attackers=%d defenders=%d groups=%d x=%.3f y=%.3f z=%.3f angle=%.3f",
            level.time, MSTimeF(), port.Attackers.Size(), attackers, defenders, port.Groups,
            user.Pos.X, user.Pos.Y, user.Pos.Z, user.Angle);
    }
    ui double LastFrameMS;
    ui int Frames;
    override void RenderOverlay(RenderEvent e)
    {
        double now = MSTimeF();
        Frames++;
        if (LastFrameMS > 0)
            Console.Printf("CA116 FRAME n=%d ms=%.3f interval=%.3f", Frames, now, now - LastFrameMS);
        LastFrameMS = now;
    }
    override bool InputProcess(InputEvent e)
    {
        if (e.Type == InputEvent.Type_KeyDown)
            Console.Printf("CA116 INPUT key=%d ms=%.3f", e.KeyScan, MSTimeF());
        return false;
    }
}
