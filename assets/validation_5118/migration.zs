class CA164Migration : StaticEventHandler
{
    int Age,FirstCount,StaffId,BolasId,LoadedHealth;
    bool Loaded;
    void Check(bool ok,String label){Console.Printf("CA164 %s migration %s",ok?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame){Loaded=true;Age=0;LoadedHealth=players[0].mo.health;}}
    override void WorldTick()
    {
        if(!Loaded)return;Age++;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let audit=CA164Audit(u.FindInventory("CA164Audit"));if(audit==null)return;
        let r=u.GetPersistentCharacterState(true);
        if(Age==80)
        {
            Check(r.QuestStage[0]==audit.QuestStage,"stage retained without replay");
            Console.Printf("CA164 HEALTH actual=%d expected=%d maximum=%d stored=%d",u.health,audit.HealthBefore,u.CaelumMaximumHealth,r.StoredHealth);
            Check(LoadedHealth==audit.HealthBefore && u.health<u.CaelumMaximumHealth,"load retains health; natural recovery remains below full");
            for(int i=0;i<audit.Count;i++)
            {
                let e=u.FindNativeEquipmentItemById(audit.Ids[i]);
                Check(e!=null && e.EquipmentKind==audit.Kinds[i] && e.ItemType==audit.Types[i] && e.EquipmentSize==audit.Sizes[i] && e.Durability==audit.Wear[i] && e.InMagicBox==audit.Boxed[i] && !e.IsLimboTemporary(),"exact old equipment identity size wear location and ownership");
            }
            if(audit.Deck!=null)Check(audit.Deck==u.FindInventory("CaelumTarotDeck"),"no second legacy deck");
            else Check(u.FindInventory("CaelumTarotDeck")==null,"no gift before Argento starts");
            if(audit.Box!=null)Check(audit.Box==CaelumMagicBox.EnsureOwned(u),"no second legacy Box");
            else Check(!u.MagicBoxOwned,"no premature Box");
            if(audit.Mode>=2)Check(r.MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]==111 && r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]==222 && r.MainM00ArmorChosen && r.MainM00SealChoice==0 && r.MainM00ShieldChoice==0,"partial choices and issued allowance preserved");
            Check(r.MainM00LoadoutRevision==2 && r.MainM00GiftsRevision==1 && !r.MainM00BullResetPending,"revision markers and retired retry");
            StaffId=r.MainM00UtilityStaffId;BolasId=r.MainM00BolasId;
            Check((audit.Mode>0)==(StaffId>0) && (audit.Mode>=3)==(BolasId>0),"new gifts follow recorded branch starts");
            FirstCount=0;for(Inventory c=u.Inv;c!=null;c=c.Inv)if(c is "CaelumEquipmentItem")FirstCount++;
            CaelumMainM00MagicTrial.ReturnLoans(u);CaelumMainM00RonnieTrial.ReturnLoan(u);
        }
        if(Age==150)
        {
            int count=0;for(Inventory c=u.Inv;c!=null;c=c.Inv)if(c is "CaelumEquipmentItem")count++;
            Check(count==FirstCount && StaffId==r.MainM00UtilityStaffId && BolasId==r.MainM00BolasId,"repeated updates and compatibility returns preserve items without duplicates");
            Console.Printf("CA164 MIGRATION_DONE mode=%d",audit.Mode);
        }
    }
}
