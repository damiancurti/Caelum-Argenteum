// Diagnóstico compatible con el paquete anterior; el guardado original se conserva.
class CA410Compatibility : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA410 %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410_oldseed')
        {
            u.CreationWizardOpen=false;u.bInvulnerable=true;
            u.CurrentHunger=0;u.UpdateSurvivalStates();
            u.PersistCharacterState();
            Check(u.GetPersistentCharacterState(false)!=null,"pre-feature character exists");
        }
        else if(e.Name=='ca410_oldload')
        {
            Check(u.GetPersistentCharacterState(false)!=null,"pre-feature character loads without replacement");
            // CURRENT_MIGRATION_CHECKS
        }
        Console.Printf("CA410 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
