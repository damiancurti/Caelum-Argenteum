// #384: conserva fases nativas antiguas de hielo sin copiar su implementación.
class CA384IceCheckpoint : Inventory
{
    CA384Carrier First,Second,Raised;
    int SavedTime,SavedTics;
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA384IceChecks : StaticEventHandler
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
        if(e.Name!="ca384_ice_spawn" && e.Name!="ca384_ice_normal"
            && e.Name!="ca384_ice_freeze" && e.Name!="ca384_ice_force"
            && e.Name!="ca384_ice_verify")return;
        let user=CaelumPlayer(players[e.Player].mo);
        let mark=CA384IceCheckpoint(user.FindInventory("CA384IceCheckpoint"));
        if(e.Name=="ca384_ice_spawn")
        {
            user.bInvulnerable=true;user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
            user.ApplyCharacterProfile();user.GetPersistentCharacterState(true).ProfileCommitted=true;
            mark=CA384IceCheckpoint(user.GiveInventoryType("CA384IceCheckpoint"));
            mark.First=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(128,0,0),NO_REPLACE));
            mark.Second=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(0,128,0),NO_REPLACE));
            mark.Raised=CA384Carrier(Actor.Spawn("CA384Carrier",user.Pos+(-128,0,0),NO_REPLACE));
            return;
        }
        if(mark==null){Check(false,"ice checkpoint available");return;}
        if(e.Name=="ca384_ice_normal")
        {mark.Raised.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);return;}
        if(e.Name=="ca384_ice_freeze")
        {
            Check(Tokens()==1,"normal first life delivers one token before ice test");
            let memory=CaelumRedemptionBody(mark.Raised.GiveInventoryType("CaelumRedemptionBody"));memory.Remember();
            Check(CaelumResurrection.Restore(mark.Raised,mark.Raised.Pos),"ice test resurrects the exact original body");
            mark.First.DamageMobj(user,user,1000000000,'Ice',DMG_FORCED|DMG_THRUSTLESS);
            mark.Second.DamageMobj(user,user,1000000000,'Ice',DMG_FORCED|DMG_THRUSTLESS);
            mark.Raised.DamageMobj(user,user,1000000000,'Ice',DMG_FORCED|DMG_THRUSTLESS);
            Check(mark.First.bIceCorpse && mark.Second.bIceCorpse && mark.Raised.bIceCorpse,
                "actual Ice damage selects native freeze states");
            mark.Second.SetState(mark.Second.FindState("GenericFreezeDeath").NextState,true);
            mark.First.tics=mark.Second.tics=mark.Raised.tics=200;
            mark.First.Vel=mark.Second.Vel=mark.Raised.Vel=(0,0,0);
            mark.SavedTime=level.time;mark.SavedTics=200;
            Check(Tokens()==1,"frozen saved bodies have not prematurely dropped loot");
        }
        if(e.Name=="ca384_ice_force")
        {
            mark.First.Vel=mark.Second.Vel=mark.Raised.Vel=(0,0,0);
            mark.First.bShattering=mark.Second.bShattering=mark.Raised.bShattering=true;
            mark.First.tics=mark.Second.tics=mark.Raised.tics=1;
            return;
        }
        if(e.Name=="ca384_ice_verify")
        {
            Check(mark.First==null && mark.Second==null && mark.Raised==null,"native ice chunks retire original corpses");
            Check(Tokens()==3,"first ice deaths deliver once and raised ice death cannot duplicate loot");
            int chunks=0;let it=ThinkerIterator.Create("IceChunk");while(it.Next()!=null)chunks++;
            Check(chunks>0,"native visual ice chunks still exist");
        }
        Console.Printf("CA384 RESULT pass=%d fail=%d",Passed,Failed);
    }
}
