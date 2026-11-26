// #702: escudos nativos, cinco talles, identidad persistente y arte inspeccionable.
class CA702ShieldCamera : Actor
{
    Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA702ShieldEvents : EventHandler
{
    Array<CaelumEquipmentItem> Drops;
    Array<int> Ids;
    Array<double> Weights;
    CA702ShieldCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    int Type(int i){return i/(3*CaelumConstants.EQUIPMENT_SIZE_COUNT);}
    int Size(int i){return i%CaelumConstants.EQUIPMENT_SIZE_COUNT;}
    int Tier(int i){return (i/CaelumConstants.EQUIPMENT_SIZE_COUNT)%3+1;}
    String Sprite(int i){static const String names[]={"CBUC","CSHK","CSHT","CSHM"};return names[Type(i)];}
    int Count(){return 4*3*CaelumConstants.EQUIPMENT_SIZE_COUNT;}
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA702 %s %s",okay?"PASS":"FAIL",label);}
    void Restore()
    {
        for(int i=0;i<Drops.Size();i++)
        {Drops[i].SetOrigin(((i/5-5.5)*40,(i%5-2)*36,0),false);Drops[i].bNOGRAVITY=false;Drops[i].Vel=(0,0,0);Drops[i].bInvisible=false;}
    }
    void Detail(int index,int angle)
    {
        if(index<0 || index>=4 || Drops.Size()!=Count())return;
        Restore();DetailIndex=index;DetailAngle=angle;
        static const double extents[]={DETAIL_EXTENTS};static const double heights[]={DETAIL_HEIGHTS};
        int selected=index*3*CaelumConstants.EQUIPMENT_SIZE_COUNT+CaelumConstants.EQUIPMENT_SIZE_M;
        for(int i=0;i<Drops.Size();i++)Drops[i].bInvisible=i!=selected;
        let item=Drops[selected];double distance=max(9.,extents[index]*item.Scale.X*1.4);
        if(angle==0){item.SetOrigin(item.Pos+(0,0,64),false);item.bNOGRAVITY=true;}
        vector3 center=item.Pos+(0,0,heights[index]*item.Scale.Y);
        if(angle==0){Camera.SetOrigin(center+(0,-distance,-distance*.65),false);Camera.Angle=90;Camera.Pitch=-33.023868;}
        else {Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;}
        players[0].camera=Camera;Camera.ClearInterpolation();
        let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
    }
    void Verify()
    {
        Check(Drops.Size()==Count() && Ids.Size()==Count() && Weights.Size()==Count(),"four shield types and three tiers in all native sizes");
        for(int i=0;i<Drops.Size();i++)
        {
            let item=Drops[i];String label=String.Format("shield %d",i);
            Check(item!=null && item.GetClass()=='CaelumShieldPickup',label.." saved native class");
            if(item==null)continue;
            Check(item.Owner==null && item.Amount==1,label.." independent world instance");
            Check(item.ItemType==Type(i) && item.Tier==Tier(i) && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD,label.." original type, slot and kind");
            Check(item.EquipmentSize==Size(i),label.." original native size");
            Check(item.ItemId==Ids[i] && Ids[i]>0,label.." persistent unique identity");
            Check(item.Durability==100-i && abs(item.ThermalWaterKg-.001*(i+1))<.000001,label.." existing wear and water retained");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale && abs(item.Pos.Z-item.floorz)<.01,label.." unchanged collision, scale and floor contact");
            Check(item.sprite==Actor.GetSpriteIndex(Sprite(i)) && item.frame==0 && item.Icon==defaults.Icon,label.." original icon and dynamic sprite");
            Check(item.UnitWeight==Weights[i] && abs(item.GetCarriedWeight()-Weights[i]-item.ThermalWaterKg)<.000001,label.." native dry and wet mass");
            Check(item.CompanionHistory!=null && item.CompanionHistory.Records.Size()==1 && item.CompanionHistory.Records[0].RefusedStage==i+10,label.." provenance survives copy and save");
            Check(!item.Equipped && !item.InMagicBox && item.ItemFlags==0,label.." unequipped world flags");
            Check(item.SizePolicy==CaelumEquipmentRules.FIXED_SIZE && item.AcquisitionResolved,label.." fixed acquired size retained");
        }
        Console.Printf("CA702 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca702_prepare")
        {
            if(Drops.Size()!=0)return;
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int i=0;i<Count();i++)
            {
                String label=String.Format("shield %d",i);
                let incoming=CaelumEquipmentItem(Actor.Spawn('CaelumShieldPickup',(0,0,0),NO_REPLACE));incoming.args[0]=Type(i);incoming.args[1]=Tier(i);incoming.args[2]=Size(i)+1;incoming.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
                let history=new('CaelumCompanionHistory');history.Revision=1;let record=new('CaelumCompanionItemRecord');record.RefusedStage=i+10;history.Records.Push(record);incoming.CompanionHistory=history;
                Weights.Push(incoming.PreviewUnitWeight(user));user.DerivedStats.CarryCapacity=10000;
                Check(incoming.CallTryPickup(user),label.." native pickup");
                CaelumEquipmentItem owned=null;
                for(Inventory entry=user.Inv;entry!=null;entry=entry.Inv)
                {let probe=CaelumEquipmentItem(entry);if(probe!=null && probe.CompanionHistory!=null && probe.CompanionHistory.Records.Size()==1 && probe.CompanionHistory.Records[0].RefusedStage==i+10){owned=probe;break;}}
                Check(owned!=null && owned.Amount==1,label.." exact acquired instance");if(owned==null)continue;
                owned.Durability=100-i;owned.ThermalWaterKg=.001*(i+1);
                Ids.Push(owned.ItemId);Check(owned.ItemId>0,label.." assigned persistent identity");
                owned.InMagicBox=true;Check(owned.GetCarriedWeight()==0,label.." Box excludes wet carried mass");owned.InMagicBox=false;
                owned.ItemFlags=CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;Check(owned.CreateTossable(1)==null,label.." temporary quest drop guard");owned.ItemFlags=0;
                let drop=CaelumEquipmentItem(owned.CreateTossable(1));Check(drop!=null,label.." native toss");if(drop==null)continue;
                Check(user.FindNativeEquipmentItemById(Ids[i])==null,label.." exact instance leaves inventory");
                drop.SetOrigin(((i/5-5.5)*40,(i%5-2)*36,0),false);Drops.Push(drop);
            }
            Camera=CA702ShieldCamera(Actor.Spawn('CA702ShieldCamera',(0,-350,280),NO_REPLACE));Camera.Angle=90;Camera.Pitch=38;
            players[0].camera=Camera;user.bInvisible=true;let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca702_verify")Verify();
        if(e.Name=="ca702_pickup")
        {
            let user=CaelumPlayer(players[0].mo);
            for(int i=0;i<Drops.Size();i++)
            {
                String label=String.Format("shield %d",i);user.DerivedStats.CarryCapacity=10000;
                Check(Drops[i].CallTryPickup(user),label.." native repickup");
                let owned=user.FindNativeEquipmentItemById(Ids[i]);
                Check(owned!=null && owned.ItemType==Type(i) && owned.Tier==Tier(i) && owned.EquipmentSize==Size(i) && owned.Durability==100-i && abs(owned.ThermalWaterKg-.001*(i+1))<.000001,label.." recovered exact worn and wet metadata");if(owned==null)continue;
                user.EquipmentSelectionItemId=owned.ItemId;user.EquipmentSelectionKind=owned.EquipmentKind;user.RefreshEquipmentSelectionPreview();
                bool fits=CaelumEquipmentRules.IsSizeCompatible(Size(i),user.CharacterProfile.GetSizeTier());
                Check(user.EquipmentSelectionSizeCompatible==fits,label.." native selection size eligibility");
                user.EquipSelectedNativeEquipment();
                Check(fits ? owned.Equipped && user.EquippedShieldItemId==owned.ItemId : !owned.Equipped && user.LastEquipmentAction==CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE,label.." native equip or incompatible-size refusal");
                double water=owned.ThermalWaterKg;
                Check(water>=0 && water<=.001*(i+1)+.000001,label.." no water created by native equip");
                if(fits)user.UnequipSelectedNativeEquipment();
                Check(!owned.Equipped && user.EquippedShieldItemId!=owned.ItemId,label.." native unequip");
                water=owned.ThermalWaterKg;
                let drop=CaelumEquipmentItem(owned.CreateTossable(1));
                Check(drop!=null && drop.ItemId==Ids[i] && drop.Tier==Tier(i) && drop.EquipmentSize==Size(i) && drop.Durability==100-i && abs(drop.ThermalWaterKg-water)<.000001,label.." second toss retains identity, size, wear and water");
                Check(user.FindNativeEquipmentItemById(Ids[i])==null,label.." no duplicate owned instance");Drops[i]=drop;
            }
            Check(Drops.Size()==Count(),"all native shield sizes remain independent");Console.Printf("CA702 COMPLETE failures=%d",Failures);
        }
        if(e.Name=="ca702_view")
        {
            Restore();if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;
            players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null){if(e.Args[0]==4)hud.HUDFont=Font.GetFont("CaelumMono");else hud.HUDFont=null;}
            if(e.Args[0]==2){Camera.SetOrigin((350,0,280),false);Camera.Angle=180;Camera.Pitch=33;}
            else if(e.Args[0]==7){Camera.SetOrigin((0,350,280),false);Camera.Angle=270;Camera.Pitch=33;}
            else {Camera.SetOrigin((0,-350,280),false);Camera.Angle=90;Camera.Pitch=38;}
            Camera.ClearInterpolation();
        }
        if(e.Name=="ca702_detail")Detail(e.Args[0],e.Args[1]);
        if(e.Name=="ca702_next")Detail((DetailIndex+1)%4,90);
        if(e.Name=="ca702_rotate")Detail(DetailIndex,DetailAngle==90?160:DetailAngle==160?225:DetailAngle==225?270:DetailAngle==270?0:90);
    }
}
