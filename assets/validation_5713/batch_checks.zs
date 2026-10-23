// Diagnóstico aislado: los números de esta prueba no definen recetas del juego.
class CA471BatchHolder : Inventory
{
    CaelumFermentationBatch Batch;
    double StartStamp;
    Default
    {
        Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA471BatchChecks : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok, String label)
    {
        if (ok) Passed++; else Failed++;
        Console.Printf("CA471B %s %s", ok ? "PASS" : "FAIL", label);
    }
    void Result()
    { Console.Printf("CA471B RESULT passed=%d failed=%d map=%s", Passed, Failed, level.MapName); }
    void Seed(CaelumPlayer user)
    {
        let holder = CA471BatchHolder(user.GiveInventoryType("CA471BatchHolder"));
        holder.Batch = new("CaelumFermentationBatch");
        let batch = holder.Batch;
        let clock = CaelumWorldClock.Get(user, true);
        holder.StartStamp = CaelumThermalRuntime.Stamp(clock);
        double now = holder.StartStamp;
        Check(!batch.Occupied && !batch.Ready(now), "empty before first use");
        Check(!batch.Withdraw(1, now), "empty withdrawal rejected");
        Check(!batch.Begin(0, 1, 1, 1000, 3403, 3600, now), "above barrel capacity rejected");
        Check(!batch.Begin(0, 1, 1, 0, 1, 3600, now), "zero output rejected");
        Check(!batch.Begin(0, 1, 1, 1000, 0, 3600, now), "zero volume rejected");
        Check(!batch.Begin(0, 1, 1, 1000, 1, 0, now), "zero duration rejected");
        Check(!batch.Occupied, "invalid starts preserve empty barrel");
        Check(batch.Begin(0, 1, 1, 1000, 3402, 3600, now), "full approved capacity accepted");
        Check(!batch.Begin(0, 1, 1, 1000, 1, 3600, now), "occupied barrel rejects second batch");
        Check(batch.RemainingUnits == 1000 && batch.WorkingLiters == 3402, "failed second start preserves first batch");
        batch.Clear();
        Check(!batch.Occupied && batch.RemainingUnits == 0, "cancel discards mixture");
        Check(batch.Begin(0, 1, 1, 1000, 1, 3600, now), "partial barrel fill accepted");
        Check(!batch.Withdraw(1, now + 3599), "unfinished batch cannot be withdrawn");
        Check(batch.SecondsLeft(now - 100) == 3600, "backward timestamp cannot extend duration");
        Check(batch.SecondsLeft(now + 900) == 2700, "absolute clock reduces remaining duration");
        Check(batch.Revision == CaelumFermentationBatch.SCHEMA_REVISION, "versioned additive state");
        Result();
    }
    void Resume(CaelumPlayer user)
    {
        let holder = CA471BatchHolder(user.FindInventory("CA471BatchHolder"));
        Check(holder != null && holder.Batch != null, "batch object survives native persistence");
        if (holder == null || holder.Batch == null) { Result(); return; }
        let batch = holder.Batch;
        Check(batch.Occupied && batch.RemainingUnits == 1000 && batch.WorkingLiters == 1,
            "saved partial fill retains units and occupancy");
        Check(batch.StartedAt == holder.StartStamp && batch.ReadyAt == holder.StartStamp + 3600,
            "save and travel preserve original deadline");
        let clock = CaelumWorldClock.Get(user, true);
        clock.AdvanceTics(CaelumWorldClock.TicsPerHour());
        double now = CaelumThermalRuntime.Stamp(clock);
        Check(batch.Ready(now) && batch.SecondsLeft(now) == 0,
            "world time skip completes batch without ticking a station");
        Check(!batch.Withdraw(0, now) && !batch.Withdraw(-1, now) && !batch.Withdraw(1001, now),
            "invalid withdrawal cannot mutate inventory quantity");
        Check(batch.Withdraw(375, now), "partial collection accepted after completion");
        Check(batch.Occupied && batch.RemainingUnits == 625 && batch.OriginalUnits == 1000,
            "partial collection retains occupied barrel and exact remainder");
        Check(!batch.Begin(0, 1, 1, 1000, 1, 3600, now), "ready remainder blocks another batch");
        Check(batch.Withdraw(625, now), "final remainder can be collected");
        Check(!batch.Occupied && batch.RemainingUnits == 0 && !batch.Withdraw(1, now),
            "empty barrel cannot duplicate delivered output");
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user = CaelumPlayer(players[e.Player].mo);
        if (user == null) return;
        if (e.Name == "ca471b_seed") Seed(user);
        if (e.Name == "ca471b_resume") Resume(user);
        if (e.Name == "ca471b_go")
            level.ChangeLevel("CABAT2", 0, CHANGELEVEL_NOINTERMISSION);
        if (e.Name == "ca471b_arrived")
        {
            Check(level.MapName == "CABAT2", "native transition reaches destination");
            Resume(user);
        }
    }
}
