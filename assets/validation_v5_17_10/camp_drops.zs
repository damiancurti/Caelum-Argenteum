// #664: cuatro piezas reales conservan identidad, contenido y reglas nativas.
class CA664CampCamera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA664CampEvents : EventHandler
{
    Array<Inventory> Drops;
    CA664CampCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    double Liters,Temperature,Cooling,Stamp,Boil;
    int Quality,QualityRevision,ThermalRevision;
    bool Submerged,ClockReady;
    void Check(bool okay,String label)
    { if(!okay)Failures++;Console.Printf("CA664 %s %s",okay?"PASS":"FAIL",label); }
    CaelumCompanionHistory GetHistory(Inventory item)
    {
        let special=CaelumSpecialInventoryItem(item);if(special!=null)return special.CompanionHistory;
        let consumable=CaelumConsumableItem(item);if(consumable!=null)return consumable.CompanionHistory;return null;
    }
    Inventory FindOwned(CaelumPlayer user,int index)
    {
        // Recorrido local del inventario, solamente ante eventos de esta prueba.
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            if(!CaelumCampData.IsItem(cursor))continue;let history=GetHistory(cursor);
            if(history!=null && history.Records.Size()==1 && history.Records[0].RefusedStage==index+10)return cursor;
        }
        return null;
    }
    double Weight(Inventory item)
    {
        let special=CaelumSpecialInventoryItem(item);if(special!=null)return special.GetUnitWeight();
        let consumable=CaelumConsumableItem(item);return consumable.GetUnitWeight();
    }
    double CarriedWeight(Inventory item)
    {
        let special=CaelumSpecialInventoryItem(item);if(special!=null)return special.GetCarriedWeight();
        let consumable=CaelumConsumableItem(item);return consumable.GetCarriedWeight();
    }
    double ExpectedWeight(int index)
    {return index%2==0?CaelumCampData.TENT_KG:CaelumCampData.POT_KG+CaelumCampData.POT_LITERS*(index+1)/8.;}
    void Metadata(Inventory item,int index,String label)
    {
        let history=GetHistory(item);
        Check(history!=null && history.Records.Size()==1 && history.Records[0].Loan && history.Records[0].Refused
            && history.Records[0].RefusedStage==index+10,label.." provenance identity");
        Check(!CaelumContainerRules.Boxed(item),label.." location flag");
        Check(CaelumContaminationStack.Eligible(item) && CaelumContaminationStack.Value(item)>0,label.." surface contamination");
    }
    void Snapshot(CaelumCampPot item)
    {
        Liters=item.WaterLiters;Quality=item.WaterQuality;QualityRevision=item.WaterQualityRevision;
        Temperature=item.WaterTemperatureC;ThermalRevision=item.WaterTemperatureRevision;Cooling=item.CoolingSeconds;
        Stamp=item.TemperatureStamp;Submerged=item.WasSubmerged;ClockReady=item.TemperatureClockReady;Boil=item.CampBoilSeconds;
    }
    void Transfer(CaelumCampPot item,String label)
    {
        Check(item.WaterLiters==Liters && item.WaterQuality==Quality && item.WaterQualityRevision==QualityRevision,label.." exact water identity");
        Check(item.WaterTemperatureC==Temperature && item.WaterTemperatureRevision==ThermalRevision
            && item.CoolingSeconds==Cooling && item.TemperatureStamp==Stamp && item.TemperatureClockReady==ClockReady,label.." exact thermal state");
        Check(item.WasSubmerged==Submerged && item.CampBoilSeconds==Boil,label.." immersion and boiling state");
    }
    void Verify()
    {
        Check(Drops.Size()==4,"four independent camp references");let user=CaelumPlayer(players[0].mo);
        for(int index=0;index<Drops.Size();index++)
        {
            let item=Drops[index];String label=String.Format("camp %d",index);
            Check(item!=null,label.." saved reference");if(item==null)continue;
            Check(item.Owner==null && item.Amount==1,label.." independent world ownership");
            bool unique=true;for(int other=0;other<Drops.Size();other++)if(other!=index && Drops[other]==item)unique=false;
            Check(unique && FindOwned(user,index)==null,label.." no duplicate held identity");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale,label.." native collision and scale");
            Check(item.Icon==defaults.Icon && item.sprite==defaults.SpawnState.sprite && item.frame==defaults.SpawnState.frame,label.." original icon and spawn pair");
            Check(abs(item.Pos.Z-item.floorz)<0.01,label.." native floor contact");
            Check(abs(Weight(item)-ExpectedWeight(index))<0.00001,label.." original tare and contents weight");
            Metadata(item,index,label);
            let pot=CaelumCampPot(item);
            if(pot!=null)
            {
                Check(pot.WaterLiters==pot.GetCapacityLiters()*(index+1)/8. && pot.WaterQuality==(index-1)/2
                    && pot.WaterQualityRevision==CaelumWaterQuality.REVISION,label.." separate saved water contents");
                Check(pot.WaterTemperatureRevision==CaelumWaterThermalData.REVISION && pot.WaterTemperatureC==pot.WaterTemperatureC
                    && pot.WaterTemperatureC>-273.15 && pot.CampBoilSeconds==0,label.." valid native thermal state");
            }
        }
        Console.Printf("CA664 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca664_prepare")
        {
            static const class<Inventory> itemClasses[]={ITEM_CLASSES};Array<Inventory> held;
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int index=0;index<4;index++)
            {
                let incoming=Inventory(Actor.Spawn(itemClasses[index%2],(0,0,0),NO_REPLACE));String label=String.Format("camp %d",index);
                let history=new('CaelumCompanionHistory');history.Revision=1;let record=new('CaelumCompanionItemRecord');
                record.Loan=true;record.Refused=true;record.RefusedStage=index+10;history.Records.Push(record);
                let special=CaelumSpecialInventoryItem(incoming);let pot=CaelumCampPot(incoming);
                if(special!=null)special.CompanionHistory=history;else pot.CompanionHistory=history;
                CaelumContaminationStack.Set(incoming,25+index);
                if(pot!=null)
                {
                    pot.WaterLiters=pot.GetCapacityLiters()*(index+1)/8.;pot.WaterQuality=(index-1)/2;
                    pot.WaterQualityRevision=CaelumWaterQuality.REVISION;pot.WaterTemperatureC=50;
                    pot.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;pot.CoolingSeconds=0.25;
                    pot.WasSubmerged=index==3;pot.StampTemperature(user);Snapshot(pot);
                }
                Check(incoming.CallTryPickup(user),label.." native pickup");let owned=FindOwned(user,index);
                Check(owned!=null && owned.Owner==user && owned.Amount==1,label.." distinct native ownership");if(owned==null)continue;
                Metadata(owned,index,label);Check(abs(Weight(owned)-ExpectedWeight(index))<0.00001,label.." carried unit weight");
                CaelumContainerRules.SetBoxed(owned,true);Check(CarriedWeight(owned)==0,label.." existing Box weight rule");
                CaelumContainerRules.SetBoxed(owned,false);Check(abs(CarriedWeight(owned)-ExpectedWeight(index))<0.00001,label.." restored carried weight");
                special=CaelumSpecialInventoryItem(owned);pot=CaelumCampPot(owned);
                if(special!=null)
                {special.LimboQuestUnits=1;Check(special.CreateTossable(1)==null,label.." native quest guard");special.LimboQuestUnits=0;}
                else
                {
                    Transfer(pot,label.." pickup");
                    let brew=CaelumWaterBoilingState(Actor.Spawn('CaelumWaterBoilingState',(0,0,0),NO_REPLACE));brew.AttachToOwner(user);brew.Container=pot;
                    bool wasActive=user.CraftingTaskActive;int oldKind=user.CraftingTaskKind;
                    user.CraftingTaskActive=true;user.CraftingTaskKind=CaelumConstants.CRAFTING_TASK_BOIL;
                    Check(pot.CreateTossable(1)==null,label.." native active boiling guard");
                    user.CraftingTaskActive=wasActive;user.CraftingTaskKind=oldKind;brew.Destroy();
                }
                held.Push(owned);
            }
            Check(held.Size()==4 && held[0]!=held[2] && held[1]!=held[3],"two tents and two pots coexist without merging");
            for(int index=0;index<held.Size();index++)
            {
                String label=String.Format("camp %d",index);let pot=CaelumCampPot(held[index]);if(pot!=null)Snapshot(pot);
                let dropped=Inventory(held[index].CreateTossable(1));Check(dropped!=null,label.." native toss");if(dropped==null)continue;
                Metadata(dropped,index,label);pot=CaelumCampPot(dropped);if(pot!=null)Transfer(pot,label.." toss");
                dropped.SetOrigin(((index%2)*55-27.5,(index/2)*60-30,0),false);Drops.Push(dropped);
            }
            Camera=CA664CampCamera(Actor.Spawn('CA664CampCamera',(0,-180,180),NO_REPLACE));Camera.Angle=90;Camera.Pitch=43;
            players[0].camera=Camera;user.bInvisible=true;let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca664_view")
        {
            if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
            if(hud!=null){if(e.Args[0]==4)hud.HUDFont=Font.GetFont("CaelumMono");else hud.HUDFont=null;}
            if(e.Args[0]==0){Camera.SetOrigin((0,-180,180),false);Camera.Angle=90;Camera.Pitch=43;}
            if(e.Args[0]==1){Camera.SetOrigin((0,-180,50),false);Camera.Angle=90;Camera.Pitch=10;}
            if(e.Args[0]==2){Camera.SetOrigin((180,0,60),false);Camera.Angle=180;Camera.Pitch=14;}
            if(e.Args[0]==3){Camera.SetOrigin((0,-108,35),false);Camera.Angle=90;Camera.Pitch=25;}
            if(e.Args[0]==5){Camera.SetOrigin((0,-53,35),false);Camera.Angle=90;Camera.Pitch=22;}
            if(e.Args[0]==6){Camera.SetOrigin((-55,38,35),false);Camera.Angle=270;Camera.Pitch=22;}
            if(e.Args[0]==7){Camera.SetOrigin((0,180,60),false);Camera.Angle=270;Camera.Pitch=14;}Camera.ClearInterpolation();
        }
        if(e.Name=="ca664_detail" || e.Name=="ca664_next" || e.Name=="ca664_rotate")
        {
            if(Drops.Size()==0)return;
            if(e.Name=="ca664_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca664_next")DetailIndex=(DetailIndex+1)%Drops.Size();
            if(e.Name=="ca664_rotate")DetailAngle=DetailAngle==90?160:DetailAngle==160?270:90;
            if(DetailIndex<0 || DetailIndex>=Drops.Size())return;if(DetailAngle==0)DetailAngle=90;
            static const double extents[]={DETAIL_EXTENTS};static const double heights[]={DETAIL_HEIGHTS};
            let item=Drops[DetailIndex];double distance=max(9.,extents[DetailIndex%2]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[DetailIndex%2]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*0.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;
            players[0].camera=Camera;Camera.ClearInterpolation();
        }
        if(e.Name=="ca664_verify")Verify();
        if(e.Name=="ca664_pickup")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int index=0;index<Drops.Size();index++)
            {
                String label=String.Format("camp %d",index);let pot=CaelumCampPot(Drops[index]);if(pot!=null)Snapshot(pot);
                Check(Drops[index].CallTryPickup(user),label.." repickup");let owned=FindOwned(user,index);
                Check(owned!=null && owned.Amount==1,label.." recovered independent identity");if(owned==null)continue;
                Metadata(owned,index,label);Check(abs(Weight(owned)-ExpectedWeight(index))<0.00001,label.." recovered weight");
                pot=CaelumCampPot(owned);if(pot!=null)Transfer(pot,label.." repickup");
            }
            Check(FindOwned(user,0)!=null && FindOwned(user,1)!=null && FindOwned(user,2)!=null && FindOwned(user,3)!=null,"all four independent items recovered");
            Console.Printf("CA664 COMPLETE failures=%d",Failures);
        }
    }
}
