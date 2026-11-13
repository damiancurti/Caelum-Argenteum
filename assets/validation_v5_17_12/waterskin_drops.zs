// #668: raciones nativas; no las convierte en recipientes rellenables.
class CA668WaterRationCamera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA668WaterRationEvents : EventHandler
{
    Array<CaelumConsumableItem> Drops,OwnedStacks;
    CA668WaterRationCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA668 %s %s",okay?"PASS":"FAIL",label);}
    CaelumConsumableItem ExactOwned(Actor user,class<Inventory> type)
    {
        for(Inventory item=user.Inv;item!=null;item=item.Inv)if(item.GetClass()==type)return CaelumConsumableItem(item);
        return null;
    }
    void Metadata(CaelumConsumableItem item,int index,String label)
    {
        let h=item.CompanionHistory;
        Check(h!=null && h.Records.Size()==1 && h.Records[0].Loan && h.Records[0].RefusedStage==index+10,label.." copied provenance");
        Check(CaelumContaminationStack.Value(item)>0,label.." retained contamination");
    }
    void Verify()
    {
        Check(Drops.Size()==2 && OwnedStacks.Size()==2,"both ration classes retained");
        for(int i=0;i<Drops.Size();i++)
        {
            let item=Drops[i];let owned=OwnedStacks[i];String label=String.Format("ration %d",i);
            Check(item!=null && owned!=null,label.." saved references");if(item==null || owned==null)continue;
            Check(item.Owner==null && owned.Owner==players[0].mo,label.." native ownership");
            Check(item.Amount==2 && owned.Amount==3,label.." split quantities");
            Check(item.GetClass()==owned.GetClass() && item.GetConsumableType()==CaelumConstants.CONSUMABLE_WATER_RATION,label.." native ration identity");
            Check(item.GetPowerClassName()=='CaelumThirstRegeneration',label.." original regeneration power");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.GetUnitWeight()==owned.GetUnitWeight(),label.." original unit mass");
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale,label.." native collision and scale");
            Check(item.Icon==defaults.Icon && item.sprite==defaults.SpawnState.sprite && item.frame==defaults.SpawnState.frame,label.." original icon and spawn state");
            Check(abs(item.Pos.Z-item.floorz)<.01,label.." native floor contact");
            Check(!(item is 'CaelumWaterContainer'),label.." consumable remains distinct from refillable containers");
            Metadata(item,i,label.." world");Metadata(owned,i,label.." held");
        }
        Console.Printf("CA668 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca668_prepare")
        {
            static const class<CaelumConsumableItem> kinds[]={ITEM_CLASSES};
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int i=0;i<kinds.Size();i++)
            {
                let item=CaelumConsumableItem(Actor.Spawn(kinds[i],(0,0,0),NO_REPLACE));item.Amount=5;
                let h=new('CaelumCompanionHistory');h.Revision=1;let record=new('CaelumCompanionItemRecord');record.Loan=true;record.RefusedStage=i+10;h.Records.Push(record);item.CompanionHistory=h;
                CaelumContaminationStack.Set(item,25+i);String label=String.Format("ration %d",i);
                Check(item.CallTryPickup(user),label.." native pickup");let owned=ExactOwned(user,kinds[i]);
                Check(owned!=null && owned.Amount==5,label.." owned quantity");if(owned==null)continue;
                Metadata(owned,i,label.." pickup");double weight=owned.GetCarriedWeight();
                owned.InMagicBox=true;Check(owned.GetCarriedWeight()==0 && !owned.Use(false) && owned.Amount==5,label.." Box blocks use and carried mass");
                owned.InMagicBox=false;Check(owned.GetCarriedWeight()==weight,label.." recovered carried mass");
                let dropped=CaelumConsumableItem(owned.CreateTossable(2));Check(dropped!=null,label.." native toss");if(dropped==null)continue;
                dropped.SetOrigin((i*55-27.5,0,0),false);Drops.Push(dropped);OwnedStacks.Push(owned);Metadata(dropped,i,label.." tossed");
            }
            Camera=CA668WaterRationCamera(Actor.Spawn('CA668WaterRationCamera',(0,-180,180),NO_REPLACE));Camera.Angle=90;Camera.Pitch=43;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca668_view")
        {
            for(int i=0;i<Drops.Size();i++)if(Drops[i]!=null)Drops[i].bInvisible=false;
            if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null){if(e.Args[0]==4)hud.HUDFont=Font.GetFont("CaelumMono");else hud.HUDFont=null;}
            if(e.Args[0]==0){Camera.SetOrigin((0,-180,180),false);Camera.Angle=90;Camera.Pitch=43;}
            if(e.Args[0]==1){Camera.SetOrigin((0,-180,50),false);Camera.Angle=90;Camera.Pitch=10;}
            if(e.Args[0]==2){Camera.SetOrigin((180,0,60),false);Camera.Angle=180;Camera.Pitch=14;}
            if(e.Args[0]==3){Camera.SetOrigin((0,-108,35),false);Camera.Angle=90;Camera.Pitch=25;}
            if(e.Args[0]==5){Camera.SetOrigin((0,-53,35),false);Camera.Angle=90;Camera.Pitch=22;}
            if(e.Args[0]==6){Camera.SetOrigin((-55,38,35),false);Camera.Angle=270;Camera.Pitch=22;}
            if(e.Args[0]==7){Camera.SetOrigin((0,180,60),false);Camera.Angle=270;Camera.Pitch=14;}Camera.ClearInterpolation();
        }
        if(e.Name=="ca668_detail" || e.Name=="ca668_next" || e.Name=="ca668_rotate")
        {
            if(Drops.Size()==0)return;
            if(e.Name=="ca668_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca668_next")DetailIndex=(DetailIndex+1)%Drops.Size();
            if(e.Name=="ca668_rotate")DetailAngle=DetailAngle==0?90:DetailAngle==90?160:DetailAngle==160?270:0;
            if(DetailIndex<0 || DetailIndex>=Drops.Size())return;
            for(int i=0;i<Drops.Size();i++)if(Drops[i]!=null)Drops[i].bInvisible=i!=DetailIndex;
            static const double extents[]={DETAIL_EXTENTS};static const double heights[]={DETAIL_HEIGHTS};
            let item=Drops[DetailIndex];double distance=max(9.,extents[DetailIndex%2]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[DetailIndex%2]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;
            players[0].camera=Camera;Camera.ClearInterpolation();
        }

        if(e.Name=="ca668_verify")Verify();
        if(e.Name=="ca668_pickup")
        {
            let user=CaelumPlayer(players[0].mo);user.CurrentThirst=25;
            for(int i=0;i<Drops.Size();i++)
            {
                String label=String.Format("ration %d",i);Check(Drops[i].CallTryPickup(user),label.." native repickup");let owned=OwnedStacks[i];
                Check(owned.Amount==5 && owned.Owner==user,label.." restored native stack");Metadata(owned,i,label.." recovered");
                Check(user.UseInventory(owned) && owned.Amount==4,label.." native use consumes exactly one ration");
                Check(user.FindInventory('CaelumThirstRegeneration')!=null,label.." native thirst power active");
            }
            Console.Printf("CA668 COMPLETE failures=%d",Failures);
        }
        if(e.Name=="ca668_effect")
        {Check(CaelumPlayer(players[0].mo).CurrentThirst>25,"native ration effect restores thirst over time");Console.Printf("CA668 COMPLETE failures=%d",Failures);}
    }
}
