// #765: cuatro armas de hoja y dos clases de espada de misi?n.
class CA765AxeCamera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA765AxeEvents : EventHandler
{
    Array<CaelumEquipmentItem> Drops;
    Array<int> Ids,Durabilities;
    Array<double> Weights;
    Array<String> Icons;
    CA765AxeCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    static const int Types[]={4,4,4,7,7,7,11,11,11,20};
    static const int Tiers[]={1,2,3,1,2,3,1,2,3,1};
    static const int Frames[]={0,0,0,0,0,0,0,0,0,0};
    static const int Essences[]={0,0,0,0,0,0,0,0,0,0};
    static const String Sprites[]={"CHAT","CHAT","CHAT","CAXE","CAXE","CAXE","CWAX","CWAX","CWAX","CPIK"};
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA765 %s %s",okay?"PASS":"FAIL",label);}
    bool Provenance(CaelumEquipmentItem item,int index)
    {return item!=null && item.CompanionHistory!=null && item.CompanionHistory.Records.Size()==1 && item.CompanionHistory.Records[0].RefusedStage==index+10;}
    CaelumEquipmentItem ExactOwned(CaelumPlayer user,int index)
    {
        for(Inventory entry=user.Inv;entry!=null;entry=entry.Inv)
        {let item=CaelumEquipmentItem(entry);if(Provenance(item,index))return item;}
        return null;
    }
    void Verify()
    {
        static const class<Inventory> kinds[]={'CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup'};
        Check(Drops.Size()==10 && Ids.Size()==10 && Weights.Size()==10,"all ten weapon cases retained");
        if(Drops.Size()!=10 || Ids.Size()!=10 || Weights.Size()!=10)return;
        let user=CaelumPlayer(players[0].mo);
        for(int i=0;i<Drops.Size();i++)
        {
            let item=Drops[i];int kind=i,tier=Tiers[i];String label=String.Format("axe %d",i);
            Check(item!=null,label.." saved reference");if(item==null)continue;
            Check(item.Owner==null && item.Amount==1,label.." original world quantity and ownership");
            Check(item.sprite==Actor.GetSpriteIndex(Sprites[kind]) && item.frame==Frames[i] && TexMan.GetName(item.Icon)==Icons[i] && item.GetClass()==kinds[kind],label.." exact native class, state and original icon");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale && Abs(item.Pos.Z-item.floorz)<.01,label.." original scale, collision and floor contact");
            Check(Provenance(item,i),label.." copied provenance");
            Check(item.ItemType==Types[kind] && item.Tier==tier && item.EssenceType==Essences[kind] && CaelumSupportImplementData.ValidEssence(item.ItemType,item.EssenceType),label.." native type, quality and valid essence");
            Check(item.UnitWeight==Weights[i] && item.GetCarriedWeight()==Weights[i],label.." original weight");
            Check(item.ItemId==Ids[i] && Ids[i]>0 && ExactOwned(user,i)==null,label.." independent saved identity");
            Check(!item.InMagicBox && !item.Equipped && item.ItemFlags==0,label.." original world flags");
            Check(item.Durability==Durabilities[i] && item.EquipmentSize==CaelumConstants.EQUIPMENT_SIZE_M,label.." native durability and size");
        }
        Console.Printf("CA765 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca765_expect_detail")
        {
            bool raised=DetailAngle==0;let item=Drops[DetailIndex*3];
            Check(DetailIndex==e.Args[0] && DetailAngle==e.Args[1] && item.bNOGRAVITY==raised && players[0].camera==Camera && (raised?item.Pos.Z-item.floorz>63:abs(item.Pos.Z-item.floorz)<0.01),"interactive item/angle and raised-view controls");
        }
        if(e.Name=="ca765_prepare")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            static const class<Inventory> kinds[]={'CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup','CaelumWeaponPickup'};
            for(int i=0;i<10;i++)
            {
                int kind=i,tier=Tiers[i];String label=String.Format("axe %d",i);
                let incoming=CaelumEquipmentItem(Actor.Spawn(kinds[kind],(0,0,0),NO_REPLACE));incoming.args[0]=Types[kind];incoming.args[1]=tier;incoming.args[4]=Essences[kind]+1;incoming.Amount=1;
                let history=new('CaelumCompanionHistory');history.Revision=1;let record=new('CaelumCompanionItemRecord');record.RefusedStage=i+10;history.Records.Push(record);incoming.CompanionHistory=history;
                user.DerivedStats.CarryCapacity=10000;Check(incoming.CallTryPickup(user),label.." native pickup");let owned=ExactOwned(user,i);
                Check(owned!=null && owned.Amount==1,label.." exact native ownership");if(owned==null)continue;
                Icons.Push(TexMan.GetName(owned.Icon));Ids.Push(owned.ItemId);Durabilities.Push(owned.Durability);Weights.Push(owned.UnitWeight);
                Check(owned.Equipped && user.ActiveWeaponItemId==owned.ItemId,label.." native automatic pickup equip");
                user.EquipmentSelectionItemId=owned.ItemId;user.EquipmentSelectionKind=owned.EquipmentKind;user.UnequipSelectedNativeEquipment();
                Check(!owned.Equipped,label.." native unequip before toss");
                Check(owned.ItemId>0,label.." assigned persistent identity");owned.InMagicBox=true;Check(owned.GetCarriedWeight()==0,label.." Box excludes carried mass");owned.InMagicBox=false;
                owned.ItemFlags=CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;Check(owned.CreateTossable(1)==null,label.." temporary quest guard");owned.ItemFlags=0;
                let dropped=CaelumEquipmentItem(owned.CreateTossable(1));Check(dropped!=null,label.." native weapon toss");Check(ExactOwned(user,i)==null,label.." exact weapon leaves inventory");
                if(dropped!=null){dropped.SetOrigin(((i%4-1)*48,(i/4)*48,0),false);Drops.Push(dropped);}
            }
            Camera=CA765AxeCamera(Actor.Spawn('CA765AxeCamera',(20,-180,180),NO_REPLACE));Camera.Angle=90;Camera.Pitch=43;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca765_verify")Verify();
        if(e.Name=="ca765_pickup")
        {
            let user=CaelumPlayer(players[0].mo);
            for(int i=0;i<Drops.Size();i++)
            {
                String label=String.Format("axe %d",i);user.DerivedStats.CarryCapacity=10000;Check(Drops[i].CallTryPickup(user),label.." native repickup");
                let owned=user.FindNativeEquipmentItemById(Ids[i]);Check(owned!=null && owned.Tier==Tiers[i] && Provenance(owned,i),label.." recovered exact metadata");if(owned==null)continue;
                user.EquipmentSelectionItemId=owned.ItemId;user.EquipmentSelectionKind=owned.EquipmentKind;user.EquipSelectedNativeEquipment();
                Check(owned.Equipped && user.ActiveWeaponItemId==owned.ItemId && user.WeaponModel.EssenceType==Essences[i],label.." native equip and unchanged essence");
                user.UnequipSelectedNativeEquipment();Check(!owned.Equipped,label.." native unequip");
                let dropped=CaelumEquipmentItem(owned.CreateTossable(1));Check(dropped!=null && dropped.ItemId==Ids[i] && dropped.Tier==Tiers[i],label.." second weapon toss");Drops[i]=dropped;
            }
            Check(Drops.Size()==10,"all weapon representations retained after native use");Console.Printf("CA765 COMPLETE failures=%d",Failures);
        }
        if(e.Name=="ca765_view")
        {
            for(int i=0;i<Drops.Size();i++){Drops[i].bInvisible=false;Drops[i].bNOGRAVITY=false;Drops[i].SetOrigin(((i%4-1)*48,(i/4)*48,0),false);}
            if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null){if(e.Args[0]==4)hud.HUDFont=Font.GetFont("CaelumMono");else hud.HUDFont=null;}
            Camera.SetOrigin(e.Args[0]==2?(180,20,70):e.Args[0]==7?(20,180,70):e.Args[0]==1?(20,-180,30):(20,-180,180),false);
            Camera.Angle=e.Args[0]==2?180:e.Args[0]==7?270:90;Camera.Pitch=e.Args[0]==1?5:e.Args[0]==2 || e.Args[0]==7?20:43;Camera.ClearInterpolation();
        }
        if(e.Name=="ca765_detail" || e.Name=="ca765_next" || e.Name=="ca765_rotate")
        {
            if(Drops.Size()!=10)return;
            if(e.Name=="ca765_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca765_next")DetailIndex=(DetailIndex+1)%4;
            if(e.Name=="ca765_rotate")DetailAngle=DetailAngle==90?160:DetailAngle==160?225:DetailAngle==225?270:DetailAngle==270?0:90;
            if(DetailIndex<0 || DetailIndex>=4)return;
            static const double extents[]={58.00000000000001,50.99999999999999,58.0,102.0};static const double heights[]={29.000000000000004,25.499999999999996,29.0,51.0};
            for(int i=0;i<Drops.Size();i++){Drops[i].bInvisible=i!=DetailIndex*3;Drops[i].bNOGRAVITY=false;Drops[i].Vel=(0,0,0);Drops[i].SetOrigin(((i%4-1)*48,(i/4)*48,0),false);}
            let item=Drops[DetailIndex*3];double distance=max(9.,extents[DetailIndex]*item.Scale.X*1.4);double angle=DetailAngle;
            if(DetailAngle==0){item.bNOGRAVITY=true;item.SetOrigin(item.Pos+(0,0,64),false);}
            vector3 center=item.Pos+(0,0,heights[DetailIndex]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*0.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;
            if(DetailAngle==0){Camera.SetOrigin(center+(0,-distance,-distance*.65),false);Camera.Angle=90;Camera.Pitch=-33.023868;}players[0].camera=Camera;Camera.ClearInterpolation();
        }
    }
}
