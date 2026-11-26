// #775: la armadura y la poción conservan identidades separadas al cambiar de versión.
class CA775Camera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA775Events : EventHandler
{
    Array<CaelumEquipmentItem> Drops;
    Array<int> Ids,Durabilities;
    Array<double> Weights;
    Array<String> Icons;
    CaelumConsumableItem Potion;
    CA775Camera Camera;
    int Failures;
    static const int Types[]={2,2,2,2,2,2,2,2,2,2,2,2,0,1,3};
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA775 %s %s",okay?"PASS":"FAIL",label);}
    int Slot(int i){return i<12?i/3:1;}
    int Quality(int i){return i<12?i%3+1:1;}
    void Select(CaelumPlayer user,CaelumEquipmentItem item)
    {user.EquipmentSelectionItemId=item.ItemId;user.EquipmentSelectionKind=item.EquipmentKind;}
    String SpriteFor(int i,bool candidate)
    {
        if(i>=12)return i==12?"CAMA":i==13?"CALI":"CAHV";
        return Slot(i)==0?"CHMD":Slot(i)==1?(candidate?"CMAR":"CAMD"):Slot(i)==2?"CGMD":"CBMD";
    }
    void Verify(bool candidate)
    {
        Check(Drops.Size()==15 && Ids.Size()==15 && Durabilities.Size()==15 && Weights.Size()==15 && Icons.Size()==15,"all fifteen armor cases retained");
        if(Drops.Size()!=15)return;
        let user=CaelumPlayer(players[0].mo);
        for(int i=0;i<15;i++)
        {
            let item=Drops[i];String label=String.Format("armor %d",i);Check(item!=null,label.." saved world reference");if(item==null)continue;
            String expected=SpriteFor(i,candidate);let state=item.CurState;TextureID texture=state.GetSpriteTexture(0,0,(0,0),item.sprite,item.frame);
            Check(item.sprite==Actor.GetSpriteIndex(expected) && item.frame==0 && TexMan.GetName(texture)==expected.."A0",label.." exact world texture");
            Check(item.Owner==null && item.Amount==1 && item.ItemId==Ids[i] && Ids[i]>0 && user.FindNativeEquipmentItemById(Ids[i])==null,label.." independent world identity");
            Check(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR && item.ItemType==Types[i] && item.ArmorSlot==Slot(i) && item.Tier==Quality(i),label.." unchanged equipment type slot tier");
            Check(item.Durability==Durabilities[i] && item.UnitWeight==Weights[i] && item.GetCarriedWeight()==Weights[i] && TexMan.GetName(item.Icon)==Icons[i],label.." unchanged durability mass and icon");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale && abs(item.Pos.Z-item.floorz)<.01,label.." unchanged collision scale and floor");
            Check(!item.Equipped && !item.InMagicBox && item.ItemFlags==0,label.." unchanged world flags");
        }
        Check(Potion!=null && Potion.GetClass()=='CaelumAnimaPotionMedium' && Potion.Owner==null && Potion.Amount==2,"potion world identity and quantity");
        if(Potion!=null)
        {
            Check(Potion.sprite==Actor.GetSpriteIndex("CAMD") && Potion.frame==0 && TexMan.GetName(Potion.Icon)=="graphics/caelum/icons/potions/anima_medium.png","unchanged potion sprite and icon");
            let remaining=user.FindInventory('CaelumAnimaPotionMedium');Check(remaining!=null && remaining.Amount==3,"potion split stack retained");
        }
        Console.Printf("CA775 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca775_prepare")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.DerivedStats.CarryCapacity=10000;user.SetOrigin((-300,-300,0),false);
            for(int i=0;i<15;i++)
            {
                let incoming=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',(0,0,0),NO_REPLACE));incoming.args[0]=Slot(i);incoming.args[1]=Types[i];incoming.args[2]=Quality(i);
                Check(incoming.CallTryPickup(user),String.Format("armor %d native pickup",i));
                let owned=CaelumEquipmentItem(user.Inv);
                // Buscar la pieza por tipo, ranura y calidad evita depender del orden de inventario.
                owned=null;
                for(Inventory p=user.Inv;p!=null;p=p.Inv)
                {let a=CaelumEquipmentItem(p);if(a!=null && a.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR && a.ItemType==Types[i] && a.ArmorSlot==Slot(i) && a.Tier==Quality(i)){owned=a;break;}}
                Check(owned!=null,String.Format("armor %d native ownership",i));if(owned==null)continue;
                Ids.Push(owned.ItemId);Durabilities.Push(owned.Durability);Weights.Push(owned.UnitWeight);Icons.Push(TexMan.GetName(owned.Icon));
                Select(user,owned);user.UnequipSelectedNativeEquipment();
                let dropped=CaelumEquipmentItem(owned.CreateTossable(1));Check(dropped!=null,String.Format("armor %d native toss",i));if(dropped!=null){dropped.SetOrigin(((i%5-2)*60,(i/5)*60,0),false);Drops.Push(dropped);}
            }
            let potion=CaelumConsumableItem(Actor.Spawn('CaelumAnimaPotionMedium',(0,0,0),NO_REPLACE));potion.Amount=5;Check(potion.CallTryPickup(user),"potion native pickup");
            let stack=CaelumConsumableItem(user.FindInventory('CaelumAnimaPotionMedium'));Check(stack!=null && stack.Amount==5,"potion native stack");
            if(stack!=null){Potion=CaelumConsumableItem(stack.CreateTossable(2));Check(Potion!=null,"potion native toss");if(Potion!=null)Potion.SetOrigin((22,0,0),false);}
            Camera=CA775Camera(Actor.Spawn('CA775Camera',(0,-70,42),NO_REPLACE));Camera.Angle=90;Camera.Pitch=22;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca775_verify")Verify(e.Args[0]!=0);
        if(e.Name=="ca775_view")
        {
            for(int i=0;i<Drops.Size();i++){Drops[i].bInvisible=i!=3;Drops[i].SetOrigin(i==3?(-22,0,0):((i%5-2)*60,(i/5)*60,0),false);}
            if(Potion!=null)Potion.SetOrigin((22,0,0),false);
            players[0].camera=Camera;Camera.ClearInterpolation();
        }
        if(e.Name=="ca775_repick")
        {
            let user=CaelumPlayer(players[0].mo);user.DerivedStats.CarryCapacity=10000;
            for(int i=0;i<Drops.Size();i++)
            {
                Check(Drops[i].CallTryPickup(user),String.Format("armor %d native repickup",i));let owned=user.FindNativeEquipmentItemById(Ids[i]);Check(owned!=null,String.Format("armor %d same identity",i));if(owned==null)continue;
                Select(user,owned);user.EquipSelectedNativeEquipment();Check(owned.Equipped,String.Format("armor %d native equip",i));user.UnequipSelectedNativeEquipment();Check(!owned.Equipped,String.Format("armor %d native unequip",i));
                Drops[i]=CaelumEquipmentItem(owned.CreateTossable(1));Check(Drops[i]!=null && Drops[i].ItemId==Ids[i],String.Format("armor %d same identity after second toss",i));
                if(Drops[i]!=null)Drops[i].SetOrigin(((i%5-2)*60,(i/5)*60,0),false);
            }
            Console.Printf("CA775 COMPLETE failures=%d",Failures);
        }
    }
}
