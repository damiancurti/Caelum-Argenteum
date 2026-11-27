// Base anterior exacta: comprueba migración sin referenciar campos nuevos.
class CA460Probe : CA283Probe
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca460_setup'){Setup();User.CurrentHunger=User.CurrentThirst=100;return;}
        if(e.Name=='ca460_legacy_check')
        {
            User=CaelumDomingoPilotPlayer(players[0].mo);Ready=true;
            Check(User!=null,"legacy player restored");
            Check(CaelumRestState.IsActive(User),"legacy rest remains active");
            Check(User.PilotBody!=null,"legacy visual owner restored");
            CaelumRestState.Cancel(User);
            Check(!CaelumRestState.IsActive(User),"legacy controls released");Audit();
            return;
        }
        if(e.Name=='ca460_done'){Console.Printf("CA460 RESULT passed=%d failed=%d",Passed,Failed);return;}
        Super.NetworkProcess(e);
    }
}
