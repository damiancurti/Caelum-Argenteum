// Una partida real del código previo: clases de datos iguales a las del lector.
class CA322Token : Inventory { Default { Inventory.MaxAmount 20; } }
class CA322Snapshot : Actor
{
    Array<CaelumAnchoredResident> Bodies;
    Array<int> Healths;
    Array<double> Bases;
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA322Probe : CA282Probe
{
    Array<CaelumAnchoredResident> Followers;
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c322_route")
        {
            Setup();User.SetOrigin((400,0,0),false);
            Class<CaelumAnchoredResident> kinds[]={"CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
            for(int i=0;i<4;i++)
            {
                User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
                let follower=CaelumAnchoredResident(Actor.Spawn(kinds[i],(250-i*50,0,0),NO_REPLACE));
                follower.ChangeTid(322+i);Followers.Push(follower);
            }
        }
        if(e.Name=="c322_snapshot")
        {
            let saved=CA322Snapshot(Actor.Spawn("CA322Snapshot",User.Pos,NO_REPLACE));
            for(int i=0;i<Followers.Size();i++)
            {
                let follower=Followers[i];follower.ReleaseEscortPrisoner(User);
                let token=follower.GiveInventoryType("CA322Token");token.Amount=3+i;
                follower.health=follower.CombatMaximumHealth-100;follower.bInConversation=true;
                saved.Bodies.Push(follower);saved.Healths.Push(follower.health);saved.Bases.Push(follower.CombatBaseSpeed);
            }
            User.player.ConversationNPC=Followers[0];
            Check(saved.Bodies.Size()==4,"legacy native save contains four original released bodies");
        }
        if(e.Name=="c322_done")Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
    }
}
