// El paquete anterior carga el save nuevo sin depender de un esquema añadido.
class CA361Live : StaticEventHandler
{
    int Passes,Failures;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca361_check")return;
        let user=CaelumPlayer(players[0].mo);let port=CaelumPortSiege.Get();
        if(user==null || port==null || !port.SiegeStarted || port.Attackers.Size()==0)
        {Console.Printf("CA282 FAIL rollback missing saved siege");return;}
        user.CurrentAdrenaline=0;user.UpdateHealthStateEffects();
        if(user.CurrentAdrenaline!=0){Console.Printf("CA282 FAIL rollback still forced");return;}
        Console.Printf("CA282 DONE passes=2 failures=0");
    }
}
