// Fixture compatible con 5.6.5: prepara agua e identidades anteriores a #386.
class CA386Checkpoint : Inventory
{
    int ArmorIds[4],ClothingIds[4];
    double Water[4];
    double TotalWater,Evaporated;
    int StoredId;
    int BookVersion,ClothingCount;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
}
class CA386Legacy : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca386_rollback")
        {
            let saved=CA386Checkpoint(u.FindInventory("CA386Checkpoint"));
            bool ok=saved!=null && saved.ArmorIds[1]>0 && u.EquippedArmorItemId[1]==saved.ArmorIds[1]
                && u.GetPersistentCharacterState(true).RecipeBookVersion==saved.BookVersion;
            Console.Printf("CA386 %s original package and save rollback preserves armor and recipe revision",ok?"PASS":"FAIL");
            return;
        }
        if(e.Name!="ca386_legacy")return;
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier());
        let armor=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",u.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;armor.ArmorSlot=1;
        armor.Tier=1;armor.EquipmentSize=size;armor.Durability=100;armor.UnitWeight=u.ArmorModel.GetWeightFor(1,1,1,size);
        armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;armor.AttachToOwner(u);u.EnsureEquipmentItemId(armor);
        u.ApplyFormalInventorySelection(armor);u.EquipSelectedNativeEquipment();
        let mark=CA386Checkpoint(Actor.Spawn("CA386Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
        let t=CaelumThermalBody.Get(u,true);t.Available=false;u.CurrentThirst=0;t.Hydration=0;t.Exposure=0;
        for(int s=0;s<4;s++){t.BaseWaterKg[s]=0.01;mark.Water[s]=0.01;mark.ArmorIds[s]=u.EquippedArmorItemId[s];}
        armor.ThermalWaterKg=0.02;mark.TotalWater=0.06;mark.Evaporated=t.EvaporatedKg;
        let record=u.GetPersistentCharacterState(true);record.LearnCraftingRecipe(0);
        if(record.RecipeBookVersion>=9)record.LearnCraftingRecipe(136);
        mark.BookVersion=record.RecipeBookVersion;
        Console.Printf("CA386 LEGACY ready book=%d",mark.BookVersion);
    }
}
