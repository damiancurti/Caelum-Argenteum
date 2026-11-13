// #674: tipos/calidades de joyas y la subclase heredada sin cambiar sus reglas.
class CA674JewelryCamera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA674JewelryEvents : EventHandler
{
    Array<CaelumEquipmentItem> Drops;
    Array<int> Ids;
    Array<double> Weights;
    CA674JewelryCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    int Variant(int index){return index<27?index/3:4+(index-27)/3;}
    int Type(int index){int variant=Variant(index);return variant<4?variant:variant-4;}
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA674 %s %s",okay?"PASS":"FAIL",label);}
    void Verify()
    {
        Check(Drops.Size()==42 && Ids.Size()==42 && Weights.Size()==42,"all 27 catalogue qualities and 15 legacy seal variants retained");
        for(int i=0;i<Drops.Size();i++)
        {
            let item=Drops[i];String label=String.Format("jewelry %d",i);int variant=Variant(i);
            Check(item!=null,label.." saved reference");if(item==null)continue;
            Check(item.Owner==null && item.Amount==1,label.." independent world instance");
            Check(item.ItemType==Type(i) && item.Tier==i%3+1 && item.EquipmentKind==(variant<4?CaelumConstants.EQUIPMENT_KIND_AMULET:CaelumConstants.EQUIPMENT_KIND_SEAL),label.." native type, quality and kind");
            Check(item.ItemId==Ids[i] && Ids[i]>0,label.." persistent identity");
            Check(item.EquipmentSize==CaelumConstants.EQUIPMENT_SIZE_M && item.EssenceType==(variant<4?CaelumConstants.ESSENCE_FIRE:Type(i)) && item.Durability==0,label.." original size, essence and durability");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale && Abs(item.Pos.Z-item.floorz)<.01,label.." original collision, scale and floor contact");
            let amulet=CaelumAmuletPickup(item);let seal=CaelumSealPickup(item);
            String icon=amulet!=null?amulet.GetJewelryIconPath():seal.GetJewelryIconPath();
            String spriteName=amulet!=null?amulet.GetJewelrySpriteName():seal.GetJewelrySpriteName();
            Check(item.Icon==TexMan.CheckForTexture(icon,TexMan.Type_MiscPatch) && item.sprite==Actor.GetSpriteIndex(spriteName) && item.frame==0,label.." original tier icon and dynamic world state");
            Check(item.UnitWeight==Weights[i] && item.GetCarriedWeight()==Weights[i],label.." original native weight");
            Check(item.CompanionHistory!=null && item.CompanionHistory.Records.Size()==1 && item.CompanionHistory.Records[0].RefusedStage==i+10,label.." copied provenance");
            Check(!item.InMagicBox && !item.Equipped && item.ItemFlags==0,label.." unequipped world flags");
        }
        Console.Printf("CA674 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca674_prepare")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int i=0;i<42;i++)
            {
                int variant=Variant(i);String label=String.Format("jewelry %d",i);
                class<CaelumEquipmentItem> kind=i>=27?'CA_LimboMagicSeal':variant<4?'CaelumAmuletPickup':'CaelumSealPickup';
                let incoming=CaelumEquipmentItem(Actor.Spawn(kind,(0,0,0),NO_REPLACE));incoming.args[0]=Type(i);incoming.args[1]=i%3+1;
                let history=new('CaelumCompanionHistory');history.Revision=1;let record=new('CaelumCompanionItemRecord');record.RefusedStage=i+10;history.Records.Push(record);incoming.CompanionHistory=history;
                Weights.Push(incoming.PreviewUnitWeight(user));user.DerivedStats.CarryCapacity=10000;
                Check(incoming.CallTryPickup(user),label.." native pickup");
                CaelumEquipmentItem owned=null;
                for(Inventory entry=user.Inv;entry!=null;entry=entry.Inv)
                {let probe=CaelumEquipmentItem(entry);if(probe!=null && probe.CompanionHistory!=null && probe.CompanionHistory.Records.Size()==1 && probe.CompanionHistory.Records[0].RefusedStage==i+10){owned=probe;break;}}
                Check(owned!=null && owned.Amount==1,label.." exact native owned item");if(owned==null)continue;
                Ids.Push(owned.ItemId);Check(owned.ItemId>0,label.." assigned persistent identity");
                owned.InMagicBox=true;Check(owned.GetCarriedWeight()==0,label.." Box excludes carried mass");owned.InMagicBox=false;
                owned.ItemFlags=CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;Check(owned.CreateTossable(1)==null,label.." temporary quest guard");owned.ItemFlags=0;
                let drop=CaelumEquipmentItem(owned.CreateTossable(1));Check(drop!=null,label.." native toss");if(drop==null)continue;
                Check(user.FindNativeEquipmentItemById(Ids[i])==null,label.." exact item leaves inventory");
                drop.SetOrigin(((i%7-3)*32,(i/7-2.5)*38,0),false);Drops.Push(drop);
            }
            Camera=CA674JewelryCamera(Actor.Spawn('CA674JewelryCamera',(0,-240,220),NO_REPLACE));Camera.Angle=90;Camera.Pitch=40;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca674_verify")Verify();
        if(e.Name=="ca674_pickup")
        {
            let user=CaelumPlayer(players[0].mo);
            for(int i=0;i<Drops.Size();i++)
            {
                String label=String.Format("jewelry %d",i);user.DerivedStats.CarryCapacity=10000;
                Check(Drops[i].CallTryPickup(user),label.." native repickup");let owned=user.FindNativeEquipmentItemById(Ids[i]);
                Check(owned!=null && owned.ItemType==Type(i) && owned.Tier==i%3+1 && owned.CompanionHistory!=null && owned.CompanionHistory.Records[0].RefusedStage==i+10,label.." recovered exact metadata");if(owned==null)continue;
                user.EquipmentSelectionItemId=owned.ItemId;user.EquipmentSelectionKind=owned.EquipmentKind;
                user.EquipSelectedNativeEquipment();Check(owned.Equipped && (Variant(i)<4?user.EquippedAmuletItemId:user.EquippedSealItemId)==owned.ItemId,label.." exact native equip");
                user.UnequipSelectedNativeEquipment();Check(!owned.Equipped,label.." native unequip");
                let drop=CaelumEquipmentItem(owned.CreateTossable(1));Check(drop!=null && drop.ItemId==Ids[i] && drop.Tier==i%3+1,label.." second native toss");Drops[i]=drop;
            }
            Check(Drops.Size()==42,"all variants retain separate identity after equip and drop");
            Console.Printf("CA674 COMPLETE failures=%d",Failures);
        }
        if(e.Name=="ca674_view")
        {
            for(int i=0;i<Drops.Size();i++)if(Drops[i]!=null)Drops[i].bInvisible=false;
            players[0].camera=e.Args[0]==4?players[0].mo:Camera;players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=e.Args[0]==4?Font.GetFont("CaelumMono"):null;
            Camera.SetOrigin(e.Args[0]==2?(240,0,100):e.Args[0]==7?(0,240,100):e.Args[0]==1?(0,-240,40):(0,-240,220),false);
            Camera.Angle=e.Args[0]==2?180:e.Args[0]==7?270:90;Camera.Pitch=e.Args[0]==1?5:e.Args[0]==2 || e.Args[0]==7?20:40;Camera.ClearInterpolation();
        }
        if(e.Name=="ca674_detail" || e.Name=="ca674_next" || e.Name=="ca674_rotate")
        {
            if(Drops.Size()!=42)return;
            if(e.Name=="ca674_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca674_next")DetailIndex=(DetailIndex+1)%9;
            if(e.Name=="ca674_rotate")DetailAngle=(DetailAngle+90)%360;
            if(DetailIndex<0 || DetailIndex>=9)return;int selected=DetailIndex*3;
            for(int i=0;i<Drops.Size();i++)Drops[i].bInvisible=i!=selected;
            static const double extents[]={112.0,112.0,112.0,112.0,111.99999999999999,111.99999999999999,111.99999999999999,111.99999999999999,112.00000000000001};static const double heights[]={56.0,56.0,56.0,56.0,55.99999999999999,55.99999999999999,55.99999999999999,55.99999999999999,56.00000000000001};
            let item=Drops[selected];double distance=max(9.,extents[DetailIndex]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[DetailIndex]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*.3),false);Camera.Angle=angle;Camera.Pitch=16.699244;
            players[0].camera=Camera;Camera.ClearInterpolation();
        }
    }
}
