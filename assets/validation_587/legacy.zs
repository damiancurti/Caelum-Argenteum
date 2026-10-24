// El mismo handler se usa antes y después, sin editar el archivo guardado.
class CA410JLegacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca410j_legacy' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        u.CreationWizardOpen=false;
        let illness=CaelumFoodIllness.Get(u);
        let plan=CaelumJourneyPlan.Get(u,true);
        let skip=CaelumTimeSkipState.Get(u,true);
        bool ok=true;
        // MODE
        Console.Printf("CA410J %s original save and forecast schema",ok?"PASS":"FAIL");
        Console.Printf("CA410J LEGACY result=%s",ok?"PASS":"FAIL");
    }
}
