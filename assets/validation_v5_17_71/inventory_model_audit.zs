
class CA785InventoryAudit : EventHandler
{
    int Count;
    void Report(Inventory item, String family, int type, int tier, int slot, int essence)
    {
        if(item==null){Console.Printf("CA785 AUDIT_FAIL null %s %d",family,type);return;}
        let state=item.CurState;
        TextureID texture=state.GetSpriteTexture(0,0,(0,0),item.sprite,item.frame);
        Console.Printf("CA785 ROW|%s|%s|%d|%d|%d|%d|%d|%d|%s|%s|%.6f|%.6f|%.6f|%.6f",
            family,item.GetClassName(),type,tier,slot,essence,item.sprite,item.frame,
            TexMan.GetName(texture),TexMan.GetName(item.Icon),item.Scale.X,item.Scale.Y,item.Radius,item.Height);
        Count++; item.Destroy();
    }
    void Equipment(class<CaelumEquipmentItem> kind, String family, int types, int slots)
    {
        for(int type=0;type<types;type++)for(int slot=0;slot<slots;slot++)for(int tier=1;tier<=3;tier++)
        {
            if(family=="clothing" && tier>1)continue;
            if(family=="weapon" && tier>1 && CaelumWeaponModel.IsSingleTierType(type))continue;
            int essenceCount=family=="weapon"?CaelumConstants.ESSENCE_TYPE_COUNT:1;
            for(int essence=0;essence<essenceCount;essence++)
            {
                if(family=="weapon" && !CaelumSupportImplementData.ValidEssence(type,essence))continue;
                let item=CaelumEquipmentItem(Actor.Spawn(kind,(0,0,128),NO_REPLACE));
                item.args[0]=family=="armor"?slot:type;
                item.args[1]=family=="armor"?type:tier;
                item.args[2]=family=="armor"?tier:0;
                item.args[4]=essence+1;
                item.UpdateWorldSprite();
                Report(item,family,item.PreviewItemType(),item.PreviewTier(),item.PreviewArmorSlot(),item.PreviewEssenceType());
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca785_audit")return;
        Count=0;
        Array<String> codes={CODES};
        for(int i=0;i<codes.Size();i++)Console.Printf("CA785 SPRITE|%s|%d",codes[i],Actor.GetSpriteIndex(codes[i]));
        // Censo de clases del paquete: una sola consulta de diagn?stico, sin escaneo de actores vivos.
        static const Name owned[]={PROJECT_NAMES};
        int inventoryClasses=0,visibleDefaults=0;
        for(int i=0;i<AllActorClasses.Size();i++)
        {
            let kind=(class<Inventory>)(AllActorClasses[i]);if(kind==null)continue;
            let item=GetDefaultByType(kind);bool included=false;
            for(int j=0;j<owned.Size();j++)if(item.GetClassName()==owned[j]){included=true;break;}
            if(!included)continue;
            inventoryClasses++;let state=item.SpawnState;
            bool visible=state!=null && state!=GetDefaultByType('Actor').SpawnState && state.sprite!=Actor.GetSpriteIndex('TNT1');
            Console.Printf("CA785 DEFAULT|%s|%d|%d|%d",item.GetClassName(),item.bUndroppable,item.bUntossable,visible);
            if(!item.bUndroppable && !item.bUntossable && visible)
            {visibleDefaults++;Report(Inventory(Actor.Spawn(kind,(0,0,128),NO_REPLACE)),"default",-1,-1,-1,-1);}
        }
        Console.Printf("CA785 CENSUS classes=%d visible=%d",inventoryClasses,visibleDefaults);
        Equipment('CaelumArmorPickup',"armor",CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT,CaelumConstants.ARMOR_SLOT_COUNT);
        Equipment('CaelumShieldPickup',"shield",CaelumConstants.SHIELD_TYPE_COUNT,1);
        Equipment('CaelumAmuletPickup',"amulet",CaelumConstants.AMULET_TYPE_COUNT,1);
        Equipment('CaelumSealPickup',"seal",CaelumConstants.SEAL_TYPE_COUNT,1);
        Equipment('CaelumClothingPickup',"clothing",CaelumClothingData.COUNT,1);
        Equipment('CaelumWeaponPickup',"weapon",CaelumConstants.WEAPON_TYPE_COUNT,1);
        for(int type=0;type<CaelumConstants.MATERIAL_TYPE_COUNT;type++)for(int tier=1;tier<=3;tier++)
        {
            let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',(0,0,128),NO_REPLACE));
            item.args[0]=type;item.args[1]=tier;item.UpdateMaterialVisuals();
            Report(item,"material",item.GetSpecialType(),item.GetSpecialTier(),-1,-1);
        }
        Console.Printf("CA785 AUDIT_COMPLETE rows=%d",Count);
    }
}
