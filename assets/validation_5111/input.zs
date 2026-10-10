class CA156Input : StaticEventHandler
{
    int Elapsed;
    override void OnRegister(){SetOrder(-1000);}
    override bool InputProcess(InputEvent e)
    {
        if(e.Type==InputEvent.Type_KeyDown || e.Type==InputEvent.Type_KeyUp)
            Console.Printf("CA156 RAW type=%d scan=%d char=%d string=%s",e.Type,e.KeyScan,e.KeyChar,e.KeyString);
        return false;
    }
    override void NetworkProcess(ConsoleEvent e)
    {Console.Printf("CA156 NET %s",e.Name);}
    override void RenderOverlay(RenderEvent e)
    {if(level.Time%70==0)Console.Printf("CA156 UI menu=%d console=%d journal=%d",menuactive,ConsoleState,CVar.GetCVar("ca_journal_open",players[consoleplayer]).GetBool());}
    override void WorldTick()
    {
        Elapsed++;if(Elapsed%35!=0)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let s=CaelumTimeSkipState.Get(u);if(s==null)return;
        let input=CaelumJournalInput(StaticEventHandler.Find("CaelumJournalInput"));
        Console.Printf("CA156 STATE tic=%d open=%d active=%d pending=%d done=%d task=%d remaining=%.6f target=%d/%d now=%d/%d inputUI=%d reason=%s",
            Elapsed,s.Open,s.Active,s.ConfirmPending,s.Completed,u.CraftingTaskActive,u.CraftingTaskRemainingSeconds,
            s.TargetDay,s.TargetTics,CaelumTimeSkipState.NowDay(u),CaelumTimeSkipState.NowTics(u),input!=null && input.IsUiProcessor,s.LastReason);
    }
}
