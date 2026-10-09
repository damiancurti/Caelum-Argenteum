// Timed native blocking on a copied checkpoint; no ongoing resource refill.
class CA136EnergyBlock : StaticEventHandler
{
    const HIGH=0;
    int Elapsed;
    bool ActivePassed;
    double Expected;
    override void WorldLoaded(WorldEvent e){Elapsed=0;ActivePassed=false;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;Elapsed++;
        let t=CaelumThermalBody.Get(u,true);if(t==null)return;
        if(Elapsed==1)
        {
            u.DebugAttributesAt100=HIGH==1;u.ApplyCharacterProfile();
            let helper=new("CA136Checks");helper.Equip(u,CaelumConstants.WEAPON_TYPE_DAGGER);
            let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(1600,0,0)));
            vendor.SeedEquipment(u,CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_KITE,0,CaelumConstants.EQUIPMENT_SIZE_M,0);
            let item=CaelumEquipmentItem(vendor.Inv);vendor.RemoveInventory(item);item.AttachToOwner(u);
            item.AcquisitionResolved=true;u.EnsureEquipmentItemId(item);
            u.EquipmentSelectionItemId=item.ItemId;u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;
            u.EquipmentSelectionShieldType=CaelumConstants.SHIELD_TYPE_KITE;
            u.EquipmentSelectionTier=1;u.EquipmentSelectionSize=item.EquipmentSize;
            u.RefreshEquipmentSelectionPreview();u.EquipSelectedNativeEquipment();vendor.Destroy();
            u.SetOrigin((1600,0,0),false);u.Vel=(0,0,0);u.bNOTARGET=true;
            u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
            t.Exposure=0;t.ActivityWatts=0;t.ActivityJoules=0;t.PendingActivityJoules=0;t.PendingFirearmJoules=0;t.AppliedDamageHP=0;
            for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(u,t,slot,0);
            CaelumThermalBody.Refresh(u,t);Expected=t.MovedMassKg*u.GetActiveBlockWeight()*0.2943;
            Console.Printf("CA136 ENERGY BLOCK setup high=%d mass=%.9f held=%.9f expected=%.9f",HIGH,t.MovedMassKg,u.GetActiveBlockWeight(),Expected);
        }
        if(Elapsed==70)u.ToggleCombatBlockMode();
        if(Elapsed==210)
        {
            ActivePassed=u.DebugShieldBlocking && Expected>0 && Abs(t.ActivityWatts-Expected)<0.000001;
            Console.Printf("CA136 ENERGY BLOCK ACTIVE %s actual=%.9f expected=%.9f",ActivePassed ? "PASS" : "FAIL",t.ActivityWatts,Expected);
            u.CancelCombatBlockMode();
        }
        if(Elapsed==280)
            Console.Printf("CA136 ENERGY BLOCK %s high=%d activity=%.9f E=%.9f thermalHP=%.9f",ActivePassed && t.ActivityWatts==0 && t.AppliedDamageHP==0 ? "COMPLETE" : "FAIL",HIGH,t.ActivityWatts,t.Exposure,t.AppliedDamageHP);
    }
}
