// #387: sólo presentación e identidad de los objetos en la escena aislada.
class CA387Checkpoint : Inventory
{
    int ClothingIds[25];
}
class CA387Checks : StaticEventHandler
{
    int Passed,Failed;
    Array<CaelumEquipmentItem> Reacquired;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA387 %s %s",ok?"PASS":"FAIL",label);}
    bool Visual(CaelumEquipmentItem item,int type)
    {
        let tex=TexMan.CheckForTexture(CaelumClothingData.Icon(type),TexMan.Type_MiscPatch);
        return item!=null && tex.IsValid() && item.Icon==tex
            && item.sprite==item.GetSpriteIndex(CaelumClothingData.SpriteName(type)) && item.frame==0;
    }
    void Prepare(CaelumPlayer u)
    {u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();}
    void Suite(CaelumPlayer u)
    {
        Prepare(u);
        for(int type=0;type<25;type++)
        {
            let item=CaelumClothing.Create(u,type,2);item.UpdateWorldSprite();
            Check(Visual(item,type),String.Format("type %d registered sprite and native icon",type));
            u.CraftingSelectionRecipe=CaelumClothingData.FIRST_RECIPE+type;
            Check(u.ResolveCraftingPreviewIconPath()==CaelumClothingData.Icon(type)
                && CaelumIconResolver.ResolveEquipmentPath(CaelumConstants.EQUIPMENT_KIND_CLOTHING,type,-1,1)==CaelumClothingData.Icon(type),
                String.Format("type %d inventory and crafting use same artwork",type));
            item.AttachToOwner(u);u.EnsureEquipmentItemId(item);item.ThermalWaterKg=0.2;
            int id=item.ItemId;double mass=item.UnitWeight;
            let copy=CaelumEquipmentItem(item.CreateTossable(1));
            if(copy!=null)copy.UpdateWorldSprite();
            Check(Visual(copy,type) && copy.ItemId==id && copy.UnitWeight==mass && copy.ThermalWaterKg==0.2,
                String.Format("type %d native drop retains visual and gameplay identity",type));
            Actor receiver=u;
            bool received=copy!=null && copy.TryEquipmentPickup(receiver);
            let acquired=u.FindNativeEquipmentItemById(id);Reacquired.Push(acquired);
            Check(received && acquired!=null && acquired.Icon.IsValid()
                && acquired.ItemId==id,String.Format("type %d native reacquisition retains icon and identity",type));
            if(acquired!=item)item.Destroy();
        }
        // Las piezas sin adquirir resuelven sus args, incluso si falta capacidad.
        double capacity=u.DerivedStats.CarryCapacity;bool box=u.MagicBoxOwned;
        u.DerivedStats.CarryCapacity=0;u.MagicBoxOwned=false;
        for(int n=0;n<2;n++)
        {
            int type=n==0?CaelumClothingData.HC:CaelumClothingData.BS;
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumClothingPickup",u.Pos+(192,0,0),NO_REPLACE));
            item.args[0]=type;item.args[2]=1;item.UpdateWorldSprite();
            Check(item.ItemType==0 && !item.AcquisitionResolved && Visual(item,type),"argument-driven unacquired item is not formal outfit");
            Actor toucher=u;bool acquired=item.TryEquipmentPickup(toucher);item.UpdateWorldSprite();
            Check(!acquired && item.Owner==null && item.ItemId==0 && Visual(item,type),"capacity rejection preserves argument-driven sprite");
            item.Destroy();
        }
        u.DerivedStats.CarryCapacity=capacity;u.MagicBoxOwned=box;u.OnNativeInventoryChanged();
        Console.Printf("CA387 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Settled()
    {
        for(int type=0;type<Reacquired.Size();type++)
        {
            Check(Visual(Reacquired[type],type),String.Format("type %d native ownership tick restores derived presentation",type));
            if(Reacquired[type]!=null)Reacquired[type].Destroy();
        }
        Reacquired.Clear();Console.Printf("CA387 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Saved(CaelumPlayer u,bool setup)
    {
        Prepare(u);let mark=CA387Checkpoint(u.FindInventory("CA387Checkpoint"));
        if(setup)
        {
            u.GrantMagicBoxFromPalomo(false);
            mark=CA387Checkpoint(Actor.Spawn("CA387Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
            for(int type=0;type<25;type++)
            {
                let item=CaelumClothing.Create(u,type,type%5);item.InMagicBox=true;
                item.ThermalWaterKg=0.1;item.AttachToOwner(u);u.EnsureEquipmentItemId(item);
                mark.ClothingIds[type]=item.ItemId;
            }
            u.OnNativeInventoryChanged();return;
        }
        if(mark==null){Check(false,"saved checkpoint exists");return;}
        for(int type=0;type<25;type++)
        {
            let item=u.FindNativeEquipmentItemById(mark.ClothingIds[type]);
            Check(Visual(item,type) && item.InMagicBox && item.ItemType==type
                && item.EquipmentSize==type%5 && item.ThermalWaterKg==0.1,
                String.Format("type %d cached visual rebuilt after save or travel with same wet identity",type));
        }
        Console.Printf("CA387 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Legacy(CaelumPlayer u)
    {
        int count=0;
        for(Inventory it=u.Inv;it!=null;it=it.Inv)
        {
            let item=CaelumEquipmentItem(it);
            if(item==null || item.EquipmentKind!=CaelumConstants.EQUIPMENT_KIND_CLOTHING)continue;
            count++;Check(Visual(item,item.ItemType),"5.6.6 garment automatically receives correct visual");
        }
        Check(count==5,"5.6.6 save retains five original garments");
        Console.Printf("CA387 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Gallery(CaelumPlayer u)
    {
        for(int type=0;type<25;type++)
        {
            let item=CaelumClothing.Create(u,type,2);
            item.SetOrigin((96+(type/5)*64,-192+(type%5)*96,0),false);
        }
        Console.Printf("CA387 READY: 25 prendas en la Caja y 25 copias en el suelo. / All 25 garments ready.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca387_suite")Suite(u);
        if(e.Name=="ca387_settle")Settled();
        if(e.Name=="ca387_save")Saved(u,true);
        if(e.Name=="ca387_verify")Saved(u,false);
        if(e.Name=="ca387_legacy")Legacy(u);
        if(e.Name=="ca387_gallery")Gallery(u);
        if(e.Name=="ca387_camera"){u.SetOrigin((-120,0,160),false);u.bNoGravity=true;u.Angle=0;u.Pitch=30;}
    }
}
