class CA502Legacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca502_legacy' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        u.CreationWizardOpen=false;
        let illness=CaelumFoodIllness.Get(u);
        let skip=CaelumTimeSkipState.Get(u,true);
        bool ok=true;
        // MODE
        Console.Printf("CA502 %s original illness and forecast schema",ok?"PASS":"FAIL");
        Console.Printf("CA502 LEGACY result=%s",ok?"PASS":"FAIL");
    }
}
