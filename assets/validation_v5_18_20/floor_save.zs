version "4.14.2"
class FloorHelmetSaveCheck : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent event)
    {
        let p=CaelumPlayer(players[0].mo);
        if (!p || level.MapName!="MAP01") return;
        if (event.Name=='ground933_make')
        {
            let pickup=CaelumArmorPickup(Actor.Spawn('CaelumArmorPickup',p.Pos+(40,0,0),NO_REPLACE));
            if (!pickup) return;
            pickup.args[0]=CaelumConstants.ARMOR_SLOT_HEAD;
            pickup.args[1]=CaelumConstants.ARMOR_TYPE_MEDIUM;
            pickup.args[2]=3;
            int size=pickup.PreviewEquipmentSize(p);
            Actor toucher=p;
            if (!pickup.CallTryPickup(toucher)) return;
            let item=p.FindNativeEquipmentItem(CaelumConstants.EQUIPMENT_KIND_ARMOR,
                CaelumConstants.ARMOR_TYPE_MEDIUM,CaelumConstants.ARMOR_SLOT_HEAD,3,size);
            if (!item) return;
            p.EquipmentSelectionKind=item.EquipmentKind;
            p.EquipmentSelectionItemId=item.ItemId;
            p.EquipmentSelectionArmorType=item.ItemType;
            p.EquipmentSelectionSlot=item.ArmorSlot;
            p.EquipmentSelectionTier=item.Tier;
            p.EquipmentSelectionSize=item.EquipmentSize;
            p.RefreshEquipmentSelectionPreview();
            p.DropSelectedNativeInventoryItem();
        }
        else if (event.Name=='ground933_inspect')
        {
            // Consulta puntual del mapa de prueba al solicitar una lectura.
            let it=ThinkerIterator.Create("CaelumArmorPickup");
            CaelumArmorPickup helmet;
            while ((helmet=CaelumArmorPickup(it.Next()))!=null)
            {
                if (helmet.Owner || !helmet.AcquisitionResolved || helmet.ItemId<=0 ||
                    helmet.ItemType!=CaelumConstants.ARMOR_TYPE_MEDIUM ||
                    helmet.ArmorSlot!=CaelumConstants.ARMOR_SLOT_HEAD || helmet.Tier!=3) continue;
                Console.Printf("FLOORSAVE id=%d tier=%d size=%d durability=%d frame=%d",
                    helmet.ItemId,helmet.Tier,helmet.EquipmentSize,helmet.Durability,helmet.frame);
            }
        }
    }
}
