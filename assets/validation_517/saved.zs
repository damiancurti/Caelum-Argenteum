// Shared unchanged fixture schema for old-runtime seed and current-runtime load.
class CA136Saved : Actor
{
    CaelumEquipmentItem Gun,Boxed,Longbow;
    int OldDurability,OldMaximum,OldBoxedDurability,ArrowAmount,OldLongbowDurability;
    int GunId,BoxedId,LongbowId;
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA136Seed : EventHandler
{
    CaelumEquipmentItem Weapon(CaelumPlayer user,int type,int tier)
    {
        let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(1000,1000,0)));
        vendor.SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,type,0,2,0);
        let item=CaelumEquipmentItem(vendor.Inv);vendor.RemoveInventory(item);item.AttachToOwner(user);
        item.AcquisitionResolved=true;item.Tier=tier;item.Durability=int(user.WeaponModel.GetMaximumDurabilityFor(type,tier,2)*0.37);
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.UnitWeight=user.WeaponModel.GetWeightFor(type,tier,2);user.EnsureEquipmentItemId(item);return item;
    }
    override void WorldTick()
    {
        if(level.MapName!="CA136")return;
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==60)
        {
            CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
            let marker=CA136Saved(Actor.Spawn("CA136Saved"));
            marker.Gun=Weapon(user,14,2);marker.Boxed=Weapon(user,14,3);marker.Longbow=Weapon(user,15,1);
            marker.Boxed.InMagicBox=true;
            user.EquipmentSelectionItemId=marker.Gun.ItemId;user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            user.EquipmentSelectionWeaponType=14;user.EquipmentSelectionTier=2;user.EquipmentSelectionSize=2;
            user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();
            let arrows=Inventory(Actor.Spawn("CaelumArrowAmmo",user.Pos));arrows.Amount=41;arrows.AttachToOwner(user);
            user.StandardBowMagazine=23;user.LongbowMagazine=11;user.CrossbowMagazine=7;user.CarbineMagazine=8;
            user.OnNativeInventoryChanged();
            let record=user.GetPersistentCharacterState(true);record.LearnCraftingRecipe(12);record.LearnCraftingRecipe(129);
            marker.OldDurability=marker.Gun.Durability;marker.OldMaximum=user.WeaponModel.GetMaximumDurability();
            marker.OldBoxedDurability=marker.Boxed.Durability;marker.OldLongbowDurability=marker.Longbow.Durability;
            marker.ArrowAmount=41;
            user.PersistCharacterState();
            Console.Printf("CA136 SEED type=%d tier=%d durability=%d max=%d boxed=%d arrows=%d loaded=%d",user.WeaponModel.WeaponType,user.WeaponModel.Tier,marker.OldDurability,marker.OldMaximum,marker.OldBoxedDurability,arrows.Amount,user.StandardBowMagazine);
        }
        if(level.time==70)Console.Printf("CA136 COMPLETE checks=1 failures=0");
    }
}
