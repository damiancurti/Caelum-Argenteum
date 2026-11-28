version "4.14.2"
class HelmetTransaction : StaticEventHandler
{
    int sample,phase,nextTic,identity,life,size;
    CaelumArmorPickup floorItem;

    void Fail(String stage)
    {
        Console.Printf("HELMETFAIL sample=%d stage=%s",sample,stage);
        sample=12;
    }
    static void SelectHelmet(CaelumPlayer p,CaelumEquipmentItem item)
    {
        p.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;
        p.EquipmentSelectionItemId=item.ItemId;
        p.EquipmentSelectionArmorType=item.ItemType;
        p.EquipmentSelectionSlot=item.ArmorSlot;
        p.EquipmentSelectionTier=item.Tier;
        p.EquipmentSelectionSize=item.EquipmentSize;
        p.RefreshEquipmentSelectionPreview();
    }
    override void WorldTick()
    {
        let p=CaelumPlayer(players[0].mo);
        if(!p || !p.CharacterProfile || !p.ArmorModel || level.time<100 || level.time<nextTic || sample>=12)return;
        int kind=sample/3, tier=sample%3+1;
        Actor toucher=p;
        if(phase==0)
        {
            floorItem=CaelumArmorPickup(Actor.Spawn('CaelumArmorPickup',p.Pos+(80,0,0),NO_REPLACE));
            if(!floorItem){Fail("spawn");return;}
            floorItem.args[0]=CaelumConstants.ARMOR_SLOT_HEAD;floorItem.args[1]=kind;floorItem.args[2]=tier;
            size=floorItem.PreviewEquipmentSize(p);
            phase=1;nextTic=level.time+3;return;
        }
        if(phase==1)
        {
            if(floorItem.frame!=tier || floorItem.PreviewTier()!=tier || !floorItem.CallTryPickup(toucher))
            {Fail("map pickup");return;}
            let item=p.FindNativeEquipmentItem(CaelumConstants.EQUIPMENT_KIND_ARMOR,kind,0,tier,size);
            if(!item){Fail("first inventory identity");return;}
            identity=item.ItemId;life=item.Durability;
            SelectHelmet(p,item);p.EquipSelectedNativeEquipment();p.UpdateWorldCarbineVisual();
            if(p.EquippedArmorItemId[0]!=identity || p.WornVisualKeys[2]!=1+kind+(tier-1)*4)
            {Fail("equip");return;}
            p.DropSelectedNativeInventoryItem();
            if(p.LastEquipmentAction!=CaelumConstants.EQUIPMENT_ACTION_DROPPED){Fail("inventory drop");return;}
            floorItem=null;phase=2;nextTic=level.time+42;return;
        }
        // Solo en este mapa de prueba: una consulta por transacción identifica
        // la copia que acaba de crear el inventario, incluso si no usa blockmap.
        let it=ThinkerIterator.Create("CaelumArmorPickup");
        CaelumArmorPickup found;
        while((found=CaelumArmorPickup(it.Next()))!=null)
            if(!found.Owner && found.ItemId==identity){floorItem=found;break;}
        if(!floorItem || floorItem.frame!=tier || floorItem.PreviewTier()!=tier || floorItem.PreviewItemType()!=kind
            || floorItem.EquipmentSize!=size || floorItem.Durability!=life){Fail("dropped identity or frame");return;}
        if(!floorItem.CallTryPickup(toucher)){Fail("second pickup");return;}
        let item=p.FindNativeEquipmentItemById(identity);
        if(!item || item.Tier!=tier || item.ItemType!=kind || item.Durability!=life || item.EquipmentSize!=size)
        {Fail("recovered inventory");return;}
        SelectHelmet(p,item);p.EquipSelectedNativeEquipment();p.UpdateWorldCarbineVisual();
        if(p.WornVisualKeys[2]!=1+kind+(tier-1)*4){Fail("equip after drop");return;}
        Console.Printf("HELMETROUND kind=%d tier=%d item=%d",kind,tier,identity);
        p.UnequipSelectedNativeEquipment();
        item=p.FindNativeEquipmentItemById(identity);
        if(item)item.Destroy();
        floorItem=null;phase=0;sample++;nextTic=level.time+3;
    }
}
