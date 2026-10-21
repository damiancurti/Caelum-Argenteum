// #384: actor y botín exclusivamente de diagnóstico, fuera del paquete del juego.
class CA384Token : Inventory
{
    Default { Inventory.MaxAmount 1; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA384Carrier : CaelumMandinga
{
    bool ProbeReenter, ProbeEntered;
    int ProbeDeaths;
    Default { DropItem "CA384Token", 256, 1; +FRIENDLY -COUNTKILL }
    States
    {
    Spawn: TNT1 A -1; Stop;
    Death: TNT1 A 5; TNT1 A 1 A_CaelumNoBlocking; TNT1 A -1; Stop;
    XDeath: Goto Death;
    }
}
class CA384OwnerReentry : Inventory
{
    int Calls;
    bool Entered;
    override void OwnerDied()
    {
        Calls++;
        if(!Entered){Entered=true;Owner.Die(null,null,0,'None');}
    }
    Default { Inventory.MaxAmount 1; }
}
class CA384Probe : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok,String label)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA384 %s %s",ok?"PASS":"FAIL",label);
    }
    int Tokens()
    {
        int result=0;let it=ThinkerIterator.Create("CA384Token");CA384Token item;
        while((item=CA384Token(it.Next()))!=null)result+=item.Amount;
        return result;
    }
    override void WorldThingDied(WorldEvent e)
    {
        let npc=CA384Carrier(e.Thing);if(npc==null)return;
        npc.ProbeDeaths++;
        if(npc.ProbeReenter && !npc.ProbeEntered)
        {npc.ProbeEntered=true;npc.Die(null,null,0,'None');}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca384_probe_start" && e.Name!="ca384_probe_kill" && e.Name!="ca384_probe_verify")return;
        let user=CaelumPlayer(players[e.Player].mo);
        if(e.Name=="ca384_probe_start")
        {
            user.bInvulnerable=true;user.CreationWizardOpen=false;
            user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            user.GetPersistentCharacterState(true).ProfileCommitted=true;
            let first=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(128,0,0),NO_REPLACE));
            first.ChangeTID(58401);
            let nested=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(0,128,0),NO_REPLACE));
            nested.ChangeTID(58402);nested.ProbeReenter=true;
            let owner=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(-128,0,0),NO_REPLACE));
            owner.ChangeTID(58403);owner.GiveInventoryType("CA384OwnerReentry");
            return;
        }
        if(e.Name=="ca384_probe_kill")
        {
            let first=CA384Carrier(ActorIterator.Create(58401,"CA384Carrier").Next());
            let nested=CA384Carrier(ActorIterator.Create(58402,"CA384Carrier").Next());
            let owner=CA384Carrier(ActorIterator.Create(58403,"CA384Carrier").Next());
            first.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            nested.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            owner.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            Check(first.health<=0 && nested.health<=0,"actual native deaths complete");
            return;
        }
        let first=CA384Carrier(ActorIterator.Create(58401,"CA384Carrier").Next());
        let nested=CA384Carrier(ActorIterator.Create(58402,"CA384Carrier").Next());
        Check(first!=null && nested!=null,"probe corpses retained");
        if(first==null || nested==null)return;
        Console.Printf("CA384 COUNTS initial_tokens=%d first_deaths=%d nested_deaths=%d",Tokens(),first.ProbeDeaths,nested.ProbeDeaths);
        Console.Printf("CA384 BODIES first_solid=%d nested_solid=%d first_pos=%s nested_pos=%s held=%d",first.bSolid,nested.bSolid,String.Format("%f,%f,%f",first.Pos.X,first.Pos.Y,first.Pos.Z),String.Format("%f,%f,%f",nested.Pos.X,nested.Pos.Y,nested.Pos.Z),user.CountInv("CA384Token"));
        Console.Printf("CA384 STATES first_tics=%d nested_tics=%d nested_dead=%d nested_deathstate=%d sleep=%d frozen=%d",first.tics,nested.tics,nested.health<=0,nested.InStateSequence(nested.CurState,nested.FindState("Death")),nested.ForcedSleepTics,nested.bDormant);
        Check(Tokens()==3,"each initial native DropItem produces exactly one item");
        let owner=CA384Carrier(ActorIterator.Create(58403,"CA384Carrier").Next());
        let callback=CA384OwnerReentry(owner.FindInventory("CA384OwnerReentry"));
        Check(callback!=null && callback.Calls==1 && owner.ProbeDeaths==1,"reentrant OwnerDied dispatches once");
        Check(nested.ProbeEntered && nested.ProbeDeaths==1,"reentrant Die dispatches one WorldThingDied");
        int before=Tokens();first.Die(user,user,0,'None');
        Check(first.ProbeDeaths==1,"repeated Die does not redispatch WorldThingDied");
        first.A_CaelumNoBlocking();first.A_CaelumNoBlocking();
        Console.Printf("CA384 COUNTS repeated_tokens=%d first_deaths=%d",Tokens(),first.ProbeDeaths);
        Check(Tokens()==before,"repeated native unblock callback cannot repeat DropItem");
        Console.Printf("CA384 RESULT pass=%d fail=%d",Passed,Failed);
    }
}
