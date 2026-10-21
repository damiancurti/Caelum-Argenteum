// #384: verificaciones de los campos nuevos y de la migración local.
class CA384CurrentChecks : StaticEventHandler
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
    void Verify(CaelumPlayer user,CA384Checkpoint mark)
    {
        // El inventario viaja; sus punteros al mapa de origen no. Recuperar
        // los cuerpos locales por TID al volver, sin recrearlos ni modificarlos.
        if(mark.Dead==null)mark.Dead=CA384Carrier(ActorIterator.Create(58410,"CA384Carrier").Next());
        if(mark.Living==null)mark.Living=CA384Carrier(ActorIterator.Create(58411,"CA384Carrier").Next());
        if(mark.Pending==null)mark.Pending=CA384SlowCarrier(ActorIterator.Create(58412,"CA384SlowCarrier").Next());
        if(mark.Archived==null)mark.Archived=CA384SlowCarrier(ActorIterator.Create(58413,"CA384SlowCarrier").Next());
        Check(mark.Stage==2,"revised claim checkpoint retained");
        bool present=mark.Dead!=null && mark.Living!=null && mark.Pending!=null && mark.Archived!=null;
        Check(present,"all four map-local bodies retained");if(!present)return;
        Check(mark.Dead.NativeDeathLootRevision==1 && mark.Dead.NativeDeathLootReleased,
            "finished body retains migrated native claim");
        Check(mark.Living.NativeDeathLootReleased && mark.Pending.NativeDeathLootReleased
            && mark.Archived.NativeDeathLootReleased,"all delivered body claims remain spent");
        int before=Tokens();
        mark.Dead.Die(user,user,0,'None');mark.Dead.A_CaelumNoBlocking();
        mark.Living.A_CaelumNoBlocking();mark.Pending.A_CaelumNoBlocking();mark.Archived.A_CaelumNoBlocking();
        Check(Tokens()==before && before==mark.Tokens,"saved or returned corpses cannot duplicate drops");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca384_upgrade" && e.Name!="ca384_verify" && e.Name!="ca384_ice_upgrade")return;
        let user=CaelumPlayer(players[e.Player].mo);
        if(e.Name=="ca384_ice_upgrade")
        {
            let ice=CA384IceCheckpoint(user.FindInventory("CA384IceCheckpoint"));
            Check(ice!=null,"saved native ice checkpoint retained");if(ice==null)return;
            Check(ice.First.CurState==ice.First.FindState("GenericFreezeDeath")
                && ice.Second.CurState==ice.Second.FindState("CaelumFreezeDeathChunks"),
                "old native ice phases map to corresponding guarded phases");
            int expected=ice.SavedTics-(level.time-ice.SavedTime);
            Check(ice.First.tics==expected && ice.Second.tics==expected,
                "ice migration preserves elapsed timer without reinitialization");
            Check(ice.Raised.NativeDeathLootReleased && !ice.First.NativeDeathLootReleased,
                "old raised and first-life ice bodies keep distinct entitlements");
            Console.Printf("CA384 RESULT pass=%d fail=%d",Passed,Failed);return;
        }
        let mark=CA384Checkpoint(user.FindInventory("CA384Checkpoint"));
        Check(mark!=null,"native save checkpoint available");if(mark==null)return;
        if(e.Name=="ca384_upgrade")
        {
            mark.Dead.ChangeTid(58410);mark.Living.ChangeTid(58411);
            mark.Pending.ChangeTid(58412);mark.Archived.ChangeTid(58413);
            mark.Dead.EnsureNativeDeathLootState();mark.Dead.EnsureNativeDeathLootState();
            Check(mark.Dead.NativeDeathLootReleased,"old completed corpse imports spent entitlement");
            mark.Pending.EnsureNativeDeathLootState();
            Check(!mark.Pending.NativeDeathLootReleased,"old dying body keeps pending native delivery");
            mark.Archived.EnsureNativeDeathLootState();
            Check(!mark.Archived.NativeDeathLootReleased,"archive suspension is not mistaken for delivery");
            int before=Tokens();mark.Dead.A_CaelumNoBlocking();
            Check(Tokens()==before,"imported spent claim cannot reroll");
            mark.Pending.A_CaelumNoBlocking();
            let archived=CaelumArchivedCorpse(mark.Archived.FindInventory("CaelumArchivedCorpse"));archived.Resume();
            mark.Archived.A_CaelumNoBlocking();
            Check(Tokens()==before+2,"pending and resumed archive each deliver once");
            mark.Living.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            mark.Living.A_CaelumNoBlocking();
            Check(mark.Living.health<=0 && Tokens()==before+3,"saved living body delivers exactly once on actual death");
            let memory=CaelumRedemptionBody(mark.Dead.GiveInventoryType("CaelumRedemptionBody"));memory.Remember();
            Check(CaelumResurrection.Restore(mark.Dead,mark.Dead.Pos),"native original corpse is resurrected");
            mark.Dead.DamageMobj(user,user,1000000000,'None',DMG_FORCED|DMG_THRUSTLESS);
            mark.Dead.A_CaelumNoBlocking();
            Check(mark.Dead.health<=0 && Tokens()==before+3,"second life dies without replenishing native loot");
            mark.Tokens=Tokens();mark.Stage=2;
        }
        Verify(user,mark);
        Console.Printf("CA384 RESULT pass=%d fail=%d",Passed,Failed);
    }
}
