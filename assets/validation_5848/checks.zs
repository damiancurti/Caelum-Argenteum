class CA502VesselProof : Inventory
{
    Array<CaelumConsumableItem> Items;
    CaelumDiningSetItem Set;
    CaelumPortableDiningTable Table;
    CaelumWaterContainer Nested;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502VesselChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA502V %s %s",yes?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.0000001;}
    Name Kind(int i)
    {
        switch(i){case 0:return 'CaelumBottleSmall';case 1:return 'CaelumBottleNormal';case 2:return 'CaelumBottleLarge';
        case 3:return 'CaelumCanteenSmall';case 4:return 'CaelumCanteenNormal';case 5:return 'CaelumCanteenLarge';
        case 6:return 'CaelumMateGourd';case 7:return 'CaelumMateSilver';case 8:return 'CaelumMateGold';}
        return 'CaelumCampPot';
    }
    CaelumConsumableItem Vessel(CaelumPlayer u,int i)
    {let item=CaelumConsumableItem(Actor.Spawn(Kind(i),u.Pos+(256,128,0)));item.AttachToOwner(u);return item;}
    CaelumThermalState Climate(bool submerged=false)
    {
        let t=new('CaelumThermalState');t.Initialize();t.Available=true;t.BodyMassKg=80;t.SurfaceArea=2;
        for(int i=0;i<4;i++){t.Coverage[i]=.25;if(submerged){t.SubmergedCoverage[i]=.25;t.DirtyWaterCoverage[i]=.25;}}
        return t;
    }
    void Catalogue(CaelumPlayer u)
    {
        for(int i=0;i<10;i++)
        {
            let item=Vessel(u,i);double area=CaelumVesselSurfaceData.Area(item);
            Check(area>0 && CaelumContaminationStack.Eligible(item),"vessel has approved physical geometry");
            Console.Printf("CA502V AREA kind=%d m2=%.12f",i,area);
            let water=CaelumWaterContainer(item);let mate=CaelumMateItem(item);
            if(water!=null){water.WaterLiters=water.GetCapacityLiters();water.WaterQuality=CaelumWaterQuality.CHEMICAL;water.WaterTemperatureC=75;water.WaterTemperatureRevision=1;}
            if(mate!=null){mate.WaterLiters=CaelumMateData.WaterCapacity(mate.Variant());mate.YerbaLoaded=true;mate.UsesRemaining=13;}
            CaelumContaminationStorage.Set(item,37);
            Check(Near(CaelumVesselSurfaceData.Area(item),area),"filling cannot change exterior area");
            let frame=new('CaelumContaminationExposure');frame.Capture(u,Climate());
            let illness=new('CaelumFoodIllness');frame.Advance(illness,80,20);
            Check(Near(CaelumContaminationStorage.Value(item),37),"forecast does not mutate native vessel");
            frame.Commit(u);
            double expected=CaelumContaminationRules.AfterContact(37,80,area,20);
            Check(Near(CaelumContaminationStorage.Value(item),expected),"carried vessel receives its own exterior exposure");
            Check(water==null || (water.WaterQuality==CaelumWaterQuality.CHEMICAL && Near(water.WaterLiters,water.GetCapacityLiters())),"exterior exposure does not rewrite water contents");
            item.InMagicBox=true;frame.Capture(u,Climate());frame.Advance(illness,100,100);frame.Commit(u);
            Check(Near(CaelumContaminationStorage.Value(item),expected),"Box protects vessel exterior");
            item.InMagicBox=false;
            let copy=CaelumConsumableItem(item.CreateTossable(1));
            Check(copy!=null && Near(CaelumContaminationStorage.Value(copy),expected),"native toss preserves exterior concentration");
            if(copy!=null)
            {
                Actor owner=u;Check(copy.CallTryPickup(owner),"native pickup returns original vessel contents");
                let restored=CaelumConsumableItem(u.FindInventory(Kind(i)));
                Check(restored!=null && Near(CaelumContaminationStorage.Value(restored),expected),"native pickup preserves exterior concentration");
                let restoredWater=CaelumWaterContainer(restored);let restoredMate=CaelumMateItem(restored);
                Check((restoredWater==null || (restoredWater.WaterQuality==CaelumWaterQuality.CHEMICAL && Near(restoredWater.WaterLiters,restoredWater.GetCapacityLiters())))
                    && (restoredMate==null || (restoredMate.YerbaLoaded && restoredMate.UsesRemaining==13)),"native transfer preserves water and mate charges");
                if(restored!=null)restored.Destroy();
            }
            if(item!=null && !item.bDestroyed)item.Destroy();
        }
    }
    void Storage(CaelumPlayer u)
    {
        let item=Vessel(u,0);CaelumContaminationStorage.Set(item,72);
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(64,0,0)));
        chest.args[4]=3;chest.EnsureStorage();chest.GrantLawfulTitle(u);CaelumContainerSession.Open(u,chest);u.DerivedStats.CarryCapacity=10000;
        Check(CaelumInventoryService.TransferContainerItem(u,chest,item,1,true) && item.Owner==chest,"coffer keeps original water vessel identity");
        CaelumContainerSession.Get(u).Close();let node=CaelumContaminationStack.Clock(item);node.Sync();
        Check(node.HistoryArea==0 && Near(CaelumContaminationStorage.Value(item),72),"closed coffer shields dirty vessel");
        CaelumContainerSession.Open(u,chest);
        Check(CaelumInventoryService.TransferContainerItem(u,chest,item,1,false) && item.Owner==u,"coffer returns original vessel");
        Check(Near(CaelumContaminationStorage.Value(item),72),"coffer round trip does not clean exterior");
        CaelumContainerSession.Get(u).Close();item.Destroy();chest.Destroy();
    }
    void Immersion(CaelumPlayer u)
    {
        let item=Vessel(u,0);let water=CaelumWaterContainer(item);water.WaterLiters=1;water.WaterQuality=CaelumWaterQuality.POTABLE;
        CaelumContaminationStorage.Set(item,20);let f=new('CaelumContaminationExposure');let illness=new('CaelumFoodIllness');
        f.Capture(u,Climate(true));f.Advance(illness,0,60);f.Commit(u);
        Check(Near(CaelumContaminationStorage.Value(item),CaelumContaminationRules.AfterContact(20,100,CaelumVesselSurfaceData.Area(item),60)),"dirty immersion exposes submerged vessel exterior");
        Check(water.WaterQuality==CaelumWaterQuality.POTABLE,"external immersion leaves saved water-quality rules intact");
        item.Destroy();
    }
    void Camp(CaelumPlayer u)
    {
        u.SetOrigin((64,128,0),false);u.Vel=(0,0,0);u.Angle=0;u.DerivedStats.CarryCapacity=10000;
        let fire=CaelumCampFire(Actor.Spawn('CaelumCampFire',(112,128,0)));fire.Title=CaelumLockRules.Character(u,true);fire.Prepare();
        let pot=CaelumCampPot(Vessel(u,9));pot.WaterLiters=2;pot.WaterQuality=CaelumWaterQuality.SALT;
        CaelumContaminationStorage.Set(pot,42);
        Console.Printf("CA502V CAMP manage=%d fits=%d pos=%g,%g,%g floor=%g frozen=%d",fire.CanManage(u),CaelumPlacementGeometry.Fits(u,fire.Pos,fire.Radius,CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_HEIGHT_M+CaelumCampData.PotDepth()+CaelumCampData.POT_WALL_M),fire),fire.Pos.X,fire.Pos.Y,fire.Pos.Z,fire.FloorZ,u.isFrozen());
        Check(fire.MountPot(u,pot) && fire.Pot==pot && pot.Owner==fire,"mount keeps native pot and trivet");
        let node=CaelumContaminationStack.Clock(pot);node.Sync();
        Check(node.HistoryReady && Near(node.HistoryArea,CaelumVesselSurfaceData.Area(pot)),"mounted pot follows camp location exposure");
        Check(Near(CaelumContaminationStorage.Value(pot),42) && pot.WaterQuality==CaelumWaterQuality.SALT,"mount preserves exterior dirt and water quality");
        Check(fire.TakePot(u) && pot.Owner==u && fire.Pot==null,"unmount returns original pot");
        Check(!node.HistoryReady && Near(CaelumContaminationStorage.Value(pot),42),"unmount hands exposure to player once");
        pot.Destroy();fire.Destroy();
    }
    void Seed(CaelumPlayer u)
    {
        CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        let proof=CA502VesselProof(u.GiveInventoryType('CA502VesselProof'));
        for(int i=0;i<10;i++){let item=Vessel(u,i);CaelumContaminationStorage.Set(item,42+i);item.InMagicBox=true;proof.Items.Push(item);}
        Check(proof.Items.Size()==10,"save seeds ten original vessels");
    }
    void PackedSeed(CaelumPlayer u)
    {
        CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        let proof=CA502VesselProof(u.GiveInventoryType('CA502VesselProof'));
        let set=CaelumDiningSetItem(Actor.Spawn('CaelumSmallDiningSetItem',u.Pos));set.AttachToOwner(u);
        let table=CaelumPortableDiningTable(Actor.Spawn('CaelumPortableSmallTable',u.Pos+(256,0,0)));
        set.Table=table;table.PackedItem=set;set.InMagicBox=true;
        let item=CaelumWaterContainer(Vessel(u,0));u.RemoveInventory(item);item.AttachToOwner(table);table.Items[0]=item;
        item.WaterLiters=.5;item.WaterQuality=CaelumWaterQuality.SALT;CaelumContaminationStorage.Set(item,37);
        set.Park();
        proof.Set=set;proof.Table=table;proof.Nested=item;
        Check(item.Owner==table && set.Owner==u && table.bNoBlockmap && table.bNoSector,"packed travel seeds parked native nested vessel");
    }
    void PackedResume(CaelumPlayer u)
    {
        let proof=CA502VesselProof(u.FindInventory('CA502VesselProof'));
        Check(proof!=null && proof.Nested!=null && proof.Table!=null && proof.Set!=null,"nested travel restores original objects");
        if(proof==null || proof.Nested==null)return;
        Check(proof.Nested.Owner==proof.Table && proof.Set.Owner==u && proof.Table.Items[0]==proof.Nested,"nested travel retains native ownership links");
        Check(Near(CaelumContaminationStorage.Value(proof.Nested),37) && Near(proof.Nested.WaterLiters,.5)
            && proof.Nested.WaterQuality==CaelumWaterQuality.SALT,"nested travel preserves exterior and contents");
        Check(CaelumContaminationStorage.IsShielded(proof.Nested),"nested travel retains inherited Box protection");
    }
    void Packed(CaelumPlayer u)
    {
        let set=CaelumDiningSetItem(Actor.Spawn('CaelumSmallDiningSetItem',u.Pos));set.AttachToOwner(u);
        let table=CaelumPortableDiningTable(Actor.Spawn('CaelumPortableSmallTable',u.Pos+(256,0,0)));
        set.Table=table;table.PackedItem=set;
        let item=Vessel(u,0);u.RemoveInventory(item);item.AttachToOwner(table);table.Items[0]=item;
        CaelumContaminationStorage.Set(item,20);let f=new('CaelumContaminationExposure');let illness=new('CaelumFoodIllness');
        f.Capture(u,Climate(true));f.Advance(illness,0,60);f.Commit(u);
        double expected=CaelumContaminationRules.AfterContact(20,100,CaelumVesselSurfaceData.Area(item),60);
        Check(Near(CaelumContaminationStorage.Value(item),expected),"carried dining contents follow actual carrier immersion");
        Check(CaelumContaminationStack.Carrier(item)==u && item.Owner==table,"nested vessel preserves original ownership");
        set.InMagicBox=true;f.Capture(u,Climate());f.Advance(illness,100,600);f.Commit(u);
        Check(CaelumContaminationStorage.IsShielded(item) && Near(CaelumContaminationStorage.Value(item),expected),"boxing dining set shields its native vessel contents");
        item.Destroy();table.Items[0]=null;table.Destroy();set.Destroy();
    }
    void Contact(CaelumPlayer u)
    {
        let item=Vessel(u,0);CaelumContaminationStorage.Set(item,80);
        let record=new('CaelumContaminationState');record.Ensure();record.Concentration=20;
        let first=CaelumContaminationCombat.ActorPoint(item);let second=CaelumContaminationCombat.ModelPoint(record);
        double area=CaelumVesselSurfaceData.Area(item);
        CaelumContaminationCombat.Transfer(first,second,100,10);
        Check(Near(record.Concentration,CaelumContaminationRules.AfterContact(20,80,area,10)),"native contact endpoint caps area to real vessel exterior");
        Check(Near(CaelumContaminationStorage.Value(item),80),"vessel contact source retains concentration");
        item.Destroy();
        let material=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos+(256,0,0)));
        material.args[0]=20;material.Amount=100;material.AttachToOwner(u);material.UpdateMaterialVisuals();
        CaelumContaminationStorage.Set(material,20);let lots=CaelumContaminationStack.Prepare(material);
        lots.Lots[0].Units=50;lots.Add(50,80,CaelumFoodInventory.Stamp(material));record.Concentration=40;
        first=CaelumContaminationCombat.ActorPoint(material);area=100*CaelumStackSurfaceData.UnitArea(material);
        CaelumContaminationCombat.Transfer(first,second,area,10);lots=CaelumContaminationStack.Prepare(material);
        Check(lots.Lots.Size()==2 && lots.Units()==100,"modeled contact cannot flatten heterogeneous lots");
        Check(Near(lots.Contamination(0),CaelumContaminationRules.AfterContact(20,40,area/100,10)) && Near(lots.Contamination(1),80),"only lower-concentration source units receive contact");
        Check(Near(record.Concentration,CaelumContaminationRules.AfterContact(40,80,area/2,10)),"modeled receiver uses original higher-source fraction");
        material.Destroy();
    }
    void Resume(CaelumPlayer u,bool prior=false)
    {
        let proof=CA502VesselProof(u.FindInventory('CA502VesselProof'));
        Check(proof!=null && proof.Items.Size()==(prior?3:10),"native saved vessel registry restored");if(proof==null)return;
        for(int i=0;i<proof.Items.Size();i++)
        {
            let item=proof.Items[i];Check(item!=null && item.Owner==u && item.Amount==1,"saved native vessel identity retained");
            Check(item!=null && Near(CaelumContaminationStorage.Value(item),prior?37:42+i),"saved contamination adopted without reset");
            Check(item!=null && CaelumContaminationStack.Prepare(item).Units()==1,"vessel migration reconciles exactly once");
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;Passed=Failed=0;
        if(e.Name=="ca502v_catalogue")Catalogue(u);
        else if(e.Name=="ca502v_storage")Storage(u);
        else if(e.Name=="ca502v_immersion")Immersion(u);
        else if(e.Name=="ca502v_camp")Camp(u);
        else if(e.Name=="ca502v_packed")Packed(u);
        else if(e.Name=="ca502v_contact")Contact(u);
        else if(e.Name=="ca502v_seed")Seed(u);
        else if(e.Name=="ca502v_packedseed")PackedSeed(u);
        else if(e.Name=="ca502v_packedresume")PackedResume(u);
        else if(e.Name=="ca502v_resume")Resume(u);
        else if(e.Name=="ca502v_upgrade")Resume(u,true);
        else if(e.Name=="ca502v_away"){Level.ChangeLevel("CVS502B",0,CHANGELEVEL_NOINTERMISSION);return;}
        else if(e.Name=="ca502v_home"){Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;}
        else return;
        Console.Printf("CA502V RESULT passed=%d failed=%d",Passed,Failed);
    }
}
