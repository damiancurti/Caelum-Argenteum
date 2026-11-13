// #666: piezas nuevas sueltas; las referencias a muebles colocados no se duplican.
class CA666FurnitureCamera : Actor
{
    Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA666FurnitureEvents : EventHandler
{
    Array<Inventory> Drops;
    CA666FurnitureCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA666 %s %s",okay?"PASS":"FAIL",label);}
    CaelumStorageFurnitureItem FindOwned(CaelumPlayer user,int index)
    {
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumStorageFurnitureItem(cursor);if(item==null)continue;
            let history=item.CompanionHistory;
            if(history!=null && history.Records.Size()==1 && history.Records[0].RefusedStage==index+10)return item;
        }
        return null;
    }
    double ExpectedWeight(int index)
    {int v=index%17;return v<2?CaelumStorageFurnitureData.Mass(v):CaelumRestFurnitureData.Mass(v-2);}
    void Metadata(Inventory reference,int index,String label)
    {
        let item=CaelumStorageFurnitureItem(reference);let history=item.CompanionHistory;
        Check(history!=null && history.Records.Size()==1 && history.Records[0].Loan && history.Records[0].Refused
            && history.Records[0].RefusedStage==index+10,label.." independent provenance");
        Check(!item.InMagicBox && abs(CaelumContaminationStorage.Value(item)-(25+index))<0.00001,label.." exact surface contamination and location");
    }
    void BodyGuard(CaelumStorageFurnitureItem reference,String label)
    {
        let item=CaelumRestFurnitureItem(reference);if(item==null)return;
        // La biblioteca se convierte en CaelumChestCargo al colocarla, no guarda Body.
        if(item is 'CaelumBookcaseItem'){Check(!item.HasBody(),label.." unplaced bookcase remains separate from storage cargo");return;}
        let dining=CaelumDiningSetItem(item);let decor=CaelumDecorItem(item);let sofa=CaelumSofaItem(item);let desk=CaelumDeskItem(item);
        let body=Actor.Spawn(CaelumRestFurnitureData.BodyClass(item.Variant()),(180,180,0),NO_REPLACE);
        if(dining!=null)dining.Table=CaelumPortableDiningTable(body);
        else if(decor!=null)decor.Decoration=CaelumDecorBody(body);
        else if(sofa!=null)sofa.Sofa=CaelumSofa(body);
        else if(desk!=null)desk.Desk=CaelumPortableReadingDesk(body);
        else item.Body=CaelumRestFurniture(body);
        Check(body!=null && item.HasBody() && item.CreateTossable(1)==null,label.." native linked body prevents duplicate drop");
        if(dining!=null)dining.Table=null;else if(decor!=null)decor.Decoration=null;else if(sofa!=null)sofa.Sofa=null;else if(desk!=null)desk.Desk=null;else item.Body=null;
        if(body!=null)body.Destroy();
    }
    void DiningLayout()
    {
        static const double expected[]={DINING_TRANSFORMS};int offset=0;
        Check(abs(GetDefaultByType('CaelumPlayer').Radius-16)<0.000001,"source player radius agrees with native seat clearance");
        for(int kind=0;kind<4;kind++)
        {
            let table=CaelumPortableDiningTable(Actor.Spawn(CaelumDiningSetData.BodyClass(kind),(0,0,0),NO_REPLACE));
            table.Angle=0;Check(table.ConfigureParts(),String.Format("dining %d original parts configured",kind));
            for(int seat=0;seat<table.SeatCount();seat++)
            {
                vector3 point=table.SeatPosition(seat);let chair=table.Chairs[seat];
                Check(chair!=null && abs(point.X-expected[offset])<0.00001 && abs(point.Y-expected[offset+1])<0.00001
                    && abs(point.Z-expected[offset+2])<0.00001 && abs(table.SeatAngle(seat)-expected[offset+3])<0.00001
                    && (chair.Pos-point).Length()<0.00001 && chair.GetClass()==table.ChairClass(),String.Format("dining %d seat %d original transform and chair class",kind,seat));
                offset+=4;
            }
            table.Destroy();
        }
    }
    void Verify()
    {
        Check(Drops.Size()==34,"two independent copies of all seventeen classes");let user=CaelumPlayer(players[0].mo);
        for(int index=0;index<Drops.Size();index++)
        {
            let item=CaelumStorageFurnitureItem(Drops[index]);String label=String.Format("furniture %d",index);
            Check(item!=null,label.." saved reference");if(item==null)continue;
            Check(item.Owner==null && item.Amount==1,label.." independent world ownership");
            bool unique=true;for(int other=0;other<Drops.Size();other++)if(other!=index && Drops[other]==item)unique=false;
            Check(unique && FindOwned(user,index)==null,label.." no duplicate held identity");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale,label.." original collision and scale");
            Check(item.Icon==defaults.Icon && item.sprite==defaults.SpawnState.sprite && item.frame==defaults.SpawnState.frame,label.." original icon and spawn pair");
            Check(abs(item.Pos.Z-item.floorz)<0.01,label.." native floor contact");
            Check(abs(item.GetUnitWeight()-ExpectedWeight(index))<0.00001,label.." original furniture weight");Metadata(item,index,label);
        }
        Console.Printf("CA666 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca666_prepare")
        {
            static const class<Inventory> itemClasses[]={ITEM_CLASSES};Array<CaelumStorageFurnitureItem> held;
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            DiningLayout();
            for(int index=0;index<34;index++)
            {
                let incoming=CaelumStorageFurnitureItem(Actor.Spawn(itemClasses[index%17],(0,0,0),NO_REPLACE));String label=String.Format("furniture %d",index);
                let history=new('CaelumCompanionHistory');history.Revision=1;let record=new('CaelumCompanionItemRecord');
                record.Loan=true;record.Refused=true;record.RefusedStage=index+10;history.Records.Push(record);incoming.CompanionHistory=history;
                CaelumContaminationStorage.Set(incoming,25+index);user.DerivedStats.CarryCapacity=10000;
                Check(incoming.CallTryPickup(user),label.." native pickup");let owned=FindOwned(user,index);
                Check(owned!=null && owned.Owner==user && owned.Amount==1,label.." independent native ownership");if(owned==null)continue;
                Metadata(owned,index,label);Check(abs(owned.GetUnitWeight()-ExpectedWeight(index))<0.00001,label.." original carried weight");
                CaelumContainerRules.SetBoxed(owned,true);Check(owned.GetCarriedWeight()==0,label.." native Box weight rule");
                CaelumContainerRules.SetBoxed(owned,false);Check(abs(owned.GetCarriedWeight()-ExpectedWeight(index))<0.00001,label.." restored carried weight");
                owned.LimboQuestUnits=1;Check(owned.CreateTossable(1)==null,label.." native quest guard");owned.LimboQuestUnits=0;
                BodyGuard(owned,label);held.Push(owned);
            }
            bool unique=held.Size()==34;for(int i=0;i<held.Size();i++)for(int j=0;j<i;j++)if(held[i]==held[j])unique=false;
            Check(unique,"all independent copies coexist without merging");
            for(int index=0;index<held.Size();index++)
            {
                String label=String.Format("furniture %d",index);let dropped=Inventory(held[index].CreateTossable(1));
                Check(dropped!=null,label.." native toss");if(dropped==null)continue;Metadata(dropped,index,label);
                dropped.SetOrigin(((index%6-2.5)*35,(index/6-2.5)*35,0),false);Drops.Push(dropped);
            }
            Camera=CA666FurnitureCamera(Actor.Spawn('CA666FurnitureCamera',(0,-180,180),NO_REPLACE));Camera.Angle=90;Camera.Pitch=43;
            players[0].camera=Camera;user.bInvisible=true;let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca666_view")
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
        if(e.Name=="ca666_detail" || e.Name=="ca666_next" || e.Name=="ca666_rotate")
        {
            if(Drops.Size()==0)return;
            if(e.Name=="ca666_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca666_next")DetailIndex=(DetailIndex+1)%Drops.Size();
            if(e.Name=="ca666_rotate")DetailAngle=DetailAngle==0?90:DetailAngle==90?160:DetailAngle==160?270:0;
            if(DetailIndex<0 || DetailIndex>=Drops.Size())return;
            for(int i=0;i<Drops.Size();i++)if(Drops[i]!=null)Drops[i].bInvisible=i!=DetailIndex;
            static const double extents[]={DETAIL_EXTENTS};static const double heights[]={DETAIL_HEIGHTS};
            let item=Drops[DetailIndex];double distance=max(9.,extents[DetailIndex%17]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[DetailIndex%17]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;
            players[0].camera=Camera;Camera.ClearInterpolation();
        }
        if(e.Name=="ca666_verify")Verify();
        if(e.Name=="ca666_pickup")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;bool allRecovered=true;
            for(int index=0;index<Drops.Size();index++)
            {
                String label=String.Format("furniture %d",index);user.DerivedStats.CarryCapacity=10000;
                Check(Drops[index].CallTryPickup(user),label.." repickup");let owned=FindOwned(user,index);
                Check(owned!=null && owned.Amount==1,label.." recovered independent identity");if(owned==null){allRecovered=false;continue;}
                Metadata(owned,index,label);Check(abs(owned.GetUnitWeight()-ExpectedWeight(index))<0.00001,label.." recovered original weight");
            }
            Check(allRecovered,"all independent furniture identities recovered");Console.Printf("CA666 COMPLETE failures=%d",Failures);
        }
    }
}
