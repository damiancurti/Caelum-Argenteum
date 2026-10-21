// #384: tipos estables de prueba que también compilan con 5.5.8a.
class CA384SlowCarrier : CA384Carrier
{
    States
    {
    Death: TNT1 A 350; TNT1 A 1 A_CaelumNoBlocking; TNT1 A -1; Stop;
    XDeath: Goto Death;
    }
}
class CA384Checkpoint : Inventory
{
    CA384Carrier Dead, Living;
    CA384SlowCarrier Pending, Archived;
    int Stage, Tokens;
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA384SaveChecks : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA384 %s %s",ok?"PASS":"FAIL",label);}
    int Tokens()
    {
        int count=0;let it=ThinkerIterator.Create("CA384Token");CA384Token item;
        while((item=CA384Token(it.Next()))!=null)count+=item.Amount;
        return count;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca384_save_spawn" && e.Name!="ca384_save_kill"
            && e.Name!="ca384_save_snapshot" && e.Name!="ca384_original_verify")return;
        let user=CaelumPlayer(players[e.Player].mo);
        let mark=CA384Checkpoint(user.FindInventory("CA384Checkpoint"));
        if(e.Name=="ca384_save_spawn")
        {
            user.bInvulnerable=true;user.CreationWizardOpen=false;
            user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            user.GetPersistentCharacterState(true).ProfileCommitted=true;
            mark=CA384Checkpoint(user.GiveInventoryType("CA384Checkpoint"));
            mark.Dead=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(128,0,0),NO_REPLACE));
            mark.Living=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(-128,0,0),NO_REPLACE));
            mark.Pending=CA384SlowCarrier(Actor.Spawn("CA384SlowCarrier",user.Pos+(0,128,0),NO_REPLACE));
            mark.Archived=CA384SlowCarrier(Actor.Spawn("CA384SlowCarrier",user.Pos+(0,-128,0),NO_REPLACE));
            return;
        }
        if(mark==null){Check(false,"saved checkpoint present");return;}
        if(e.Name=="ca384_save_kill")
        {
            mark.Dead.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            mark.Pending.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            mark.Archived.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            return;
        }
        if(e.Name=="ca384_save_snapshot")
        {
            let archived=CaelumArchivedCorpse(mark.Archived.GiveInventoryType("CaelumArchivedCorpse"));
            archived.Suspend();mark.Tokens=Tokens();mark.Stage=1;
        }
        Check(mark.Stage==1,"original checkpoint stage retained");
        Check(mark.Dead.health<=0 && !mark.Dead.bSolid,"finished corpse remains nonblocking");
        Check(mark.Living.health>0 && mark.Living.bSolid,"living carrier retains its first entitlement");
        Check(mark.Pending.health<=0 && mark.Pending.bSolid,"dying carrier has not reached NoBlocking");
        let archived=CaelumArchivedCorpse(mark.Archived.FindInventory("CaelumArchivedCorpse"));
        Check(archived!=null && archived.Suspended && archived.WasSolid && !mark.Archived.bSolid,
            "archived dying carrier retains original solid flag");
        Check(Tokens()==1 && mark.Tokens==1,"original save has exactly one delivered native token");
        Console.Printf("CA384 RESULT pass=%d fail=%d",Passed,Failed);
    }
}
