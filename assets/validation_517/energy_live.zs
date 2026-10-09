// Real keyboard input on a copied MAP01 checkpoint; normalized safe start only.
class CA136EnergyLive : StaticEventHandler
{
    int Elapsed;
    bool JumpSeen;
    double JumpExpected,StartHP;
    const MODE=0;
    override void WorldLoaded(WorldEvent e) {Elapsed=0;JumpSeen=false;}
    void EquipArmor(CaelumPlayer u,int type)
    {
        for(int slot=0;slot<4;slot++)
        {
            let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(1600,0,0)));
            vendor.SeedEquipment(u,CaelumConstants.EQUIPMENT_KIND_ARMOR,type,slot,CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier()),0);
            let item=CaelumEquipmentItem(vendor.Inv);vendor.RemoveInventory(item);item.AttachToOwner(u);
            item.AcquisitionResolved=true;u.EnsureEquipmentItemId(item);
            u.EquipmentSelectionItemId=item.ItemId;u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;
            u.EquipmentSelectionArmorType=type;u.EquipmentSelectionSlot=slot;u.EquipmentSelectionTier=1;
            u.EquipmentSelectionSize=item.EquipmentSize;
            u.RefreshEquipmentSelectionPreview();u.EquipSelectedNativeEquipment();vendor.Destroy();
        }
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        Elapsed++;let t=CaelumThermalBody.Get(u,true);if(t==null)return;
        if(Elapsed==1)
        {
            u.DebugAttributesAt100=MODE!=0;
            if(MODE==2)u.CharacterProfile.Race=CaelumConstants.RACE_CAELITH;
            if(MODE==3)u.CharacterProfile.Race=CaelumConstants.RACE_GOBLIN;
            u.ApplyCharacterProfile();
            if(MODE<2)EquipArmor(u,CaelumConstants.ARMOR_TYPE_HEAVY);
            if(MODE==2)EquipArmor(u,CaelumConstants.ARMOR_TYPE_LIGHT);
            if(MODE==3)EquipArmor(u,CaelumConstants.ARMOR_TYPE_MAGIC);
            let helper=new("CA136Checks");helper.Equip(u,CaelumConstants.WEAPON_TYPE_GREATSWORD);
            u.SetOrigin((1600,0,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);u.bNOGRAVITY=false;u.bNOTARGET=true;
            u.health=u.CaelumMaximumHealth;u.player.health=u.health;StartHP=u.health;
            u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
            t.Exposure=0;t.ActivityWatts=0;t.ActivityJoules=0;t.ActionJoules=0;t.PendingActivityJoules=0;t.PendingFirearmJoules=0;t.AppliedDamageHP=0;
            for(int slot=0;slot<4;slot++)CaelumThermalBody.SetWater(u,t,slot,0);
            CaelumThermalBody.Refresh(u,t);JumpExpected=t.ReferenceJumpHeat;
            Console.Printf("CA136 ENERGY LIVE setup mode=%d race=%d mass=%.6f area=%.6f jump=%.6f inertia=%.6f resilience=%d acclimation=%.9f",MODE,u.CharacterProfile.Race,t.MovedMassKg,t.SurfaceArea,JumpExpected,t.Inertia,u.Attributes.Resilience,t.AcclimationMultiplier);
        }
        if(!JumpSeen && Elapsed>60 && Elapsed<200 && t.ActionJoules>0)
        {
            JumpSeen=true;
            Console.Printf("CA136 ENERGY JUMP %s actual=%.6f expected=%.6f velocity=%.6f exposure=%.6f",Abs(t.ActionJoules-JumpExpected)<0.00001 ? "PASS" : "FAIL",t.ActionJoules,JumpExpected,u.JumpZ,t.Exposure);
        }
        if(Elapsed%35==0)
            Console.Printf("CA136 ENERGY LIVE sec=%d E=%.6f actionJ=%.6f motionJ=%.6f activity=%.6f air=%.3f hunger=%.3f thirst=%.3f HP=%d thermalHP=%.3f armor=%d,%d,%d,%d",Elapsed/35,t.Exposure,t.ActionJoules,t.ActivityJoules,t.ActivityWatts,u.CurrentAir,u.CurrentHunger,u.CurrentThirst,u.health,t.AppliedDamageHP,u.ArmorModel.ArmorType[0],u.ArmorModel.ArmorType[1],u.ArmorModel.ArmorType[2],u.ArmorModel.ArmorType[3]);
        if(Elapsed==900)
            Console.Printf("CA136 ENERGY LIVE %s mode=%d jumpSeen=%d thermalHP=%.6f meleeJ=%.6f",JumpSeen && t.AppliedDamageHP==0 && t.ActivityWatts==0 && t.ActionJoules>JumpExpected ? "COMPLETE" : "FAIL",MODE,JumpSeen,t.AppliedDamageHP,t.ActionJoules-JumpExpected);
    }
}
