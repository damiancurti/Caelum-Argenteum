// #251: diagnóstico del contrato nativo, sin implementar la habilidad.
class CA251NativeFlightA : PowerFlight {}
class CA251NativeFlightB : PowerFlight {}

class CA251FlightProbe : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok, String label)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA251 %s %s",ok?"PASS":"FAIL",label);
    }
    override void UiTick()
    {if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c251_flight")return;
        let user=CaelumPlayer(players[e.Player].mo);
        if(user==null)return;
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.ApplyCharacterProfile();user.bInvulnerable=true;
        user.SetOrigin((0,0,128),false);user.Vel=(0,0,0);
        for(int order=0;order<2;order++)
        {
            let first=PowerFlight(user.GiveInventoryType("CA251NativeFlightA"));
            let second=PowerFlight(user.GiveInventoryType("CA251NativeFlightB"));
            Check(first!=null && second!=null && first!=second && user.bFly && user.bNoGravity,
                "native flight grants two independent inventory instances");
            PowerFlight removed=order==0?first:second;
            PowerFlight survivor=order==0?second:first;
            removed.Destroy();
            Check(survivor.Owner==user && survivor.EffectTics>0 && !user.bFly && !user.bNoGravity,
                "native removal clears shared flags despite the surviving flight");
            survivor.InitEffect();
            Check(user.bFly && user.bNoGravity,
                "surviving native flight can restore its owned flags");
            survivor.Destroy();
            Check(!user.bFly && !user.bNoGravity,
                "last native flight removal restores ordinary gravity");
        }
        Console.Printf("CA251 DONE failures=%d passes=%d FLIGHT_API_ONLY",Failed,Passed);
    }
}
