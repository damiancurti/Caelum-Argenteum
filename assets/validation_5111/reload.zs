class CA156Reload : StaticEventHandler
{
    int Elapsed;
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);
        let s=u==null?null:CaelumTimeSkipState.Get(u);
        bool valid=s!=null && !s.Open && !s.Active && !s.ConfirmPending && s.Completed;
        Console.Printf("CA156 %s reload keeps panel closed",valid?"PASS":"FAIL");
        Console.Printf("CA156 %s reload keeps completed crafting",u!=null && !u.CraftingTaskActive?"PASS":"FAIL");
    }
}
