// Prueba aislada de transporte: un único Actor.Inv conserva las existencias.
class CA381ProbeOwner : Actor
{
    Default { +NOBLOCKMAP +NOSECTOR +NOGRAVITY }
}
class CA381ProbeCargo : Inventory
{
    CA381ProbeOwner Box;
    Inventory Contents;
    int Transfers;
    override void PreTravelled()
    {
        Super.PreTravelled();
        if(Box==null)return;
        Box.UnlinkFromWorld();Box.ChangeStatNum(STAT_TRAVELLING);
        for(Inventory i=Box.Inv;i!=null;i=i.Inv)
        {i.UnlinkFromWorld();i.ChangeStatNum(STAT_TRAVELLING);}
        Console.Printf("CA381 PROBE depart");
    }
    override void Travelled()
    {
        Super.Travelled();
        if(Box==null)return;
        Box.ChangeStatNum(STAT_DEFAULT);Box.SetOrigin(Owner.Pos,false);Box.LinkToWorld();
        for(Inventory i=Box.Inv;i!=null;i=i.Inv)
        {i.ChangeStatNum(STAT_INVENTORY);i.LinkToWorld();}
        Transfers++;
        Console.Printf("CA381 PROBE arrived transfers=%d",Transfers);
    }
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
}
class CA381Probe : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca381_probe")
        {
            let token=CA381ProbeCargo(Actor.Spawn("CA381ProbeCargo",u.Pos,NO_REPLACE));
            token.AttachToOwner(u);
            token.Box=CA381ProbeOwner(Actor.Spawn("CA381ProbeOwner",u.Pos,NO_REPLACE));
            token.Contents=Inventory(Actor.Spawn("CaelumCopperCoin",u.Pos,NO_REPLACE));
            token.Contents.Amount=37;token.Contents.AttachToOwner(token.Box);
        }
        if(e.Name=="ca381_verify")
        {
            let token=CA381ProbeCargo(u.FindInventory("CA381ProbeCargo"));
            bool ok=token!=null && token.Box!=null && token.Contents!=null
                && token.Box.Inv==token.Contents && token.Contents.Owner==token.Box
                && token.Contents.Amount==37;
            Console.Printf("CA381 %s native owner, identity and quantity survive map=%s",
                ok ? "PASS" : "FAIL",level.MapName);
        }
    }
}
