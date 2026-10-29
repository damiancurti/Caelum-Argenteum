class CA410FixtureChecks : CA410FoodChecks
{
    CaelumKitchenSink Sink;
    CaelumKitchenCupboard Cupboard;
    double SavedWater,SavedStamp;
    void Result(){Console.Printf("CA410K RESULT passed=%d failed=%d",Passed,Failed);}
    void Position(CaelumPlayer u,Actor item,double distance=56)
    {u.SetOrigin(item.Pos+(0,-distance,-item.Pos.Z),false);u.Angle=90;u.Pitch=ATan2(u.ViewHeight-item.Pos.Z-item.Height/2,distance);u.Vel=(0,0,0);}
    void Core(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;u.CurrentThirst=100;u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
        Sink=CaelumKitchenSink(Actor.Spawn('CaelumKitchenSink',(256,128,0),NO_REPLACE));
        Sink.House=CaelumDomesticWaterData.MANSION;Sink.Installed=true;Position(u,Sink);
        let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
        let other=CaelumDomesticWater.Get(0);
        Check(water!=null && other!=null && water!=other,"mansion reserve is separate from city house zero");
        Check(Near(water.Liters,200) && Sink.CanReach(u),"accessible mansion sink starts with finite200L");
        let bottle=CaelumWaterContainer(u.GiveInventoryType('CaelumCanteenLarge'));
        bottle.WaterLiters=0;bottle.WaterQuality=0;bottle.InMagicBox=false;
        double capacity=bottle.GetCapacityLiters();
        Check(Sink.Fill(u,bottle) && Near(bottle.WaterLiters,capacity) && Near(water.Liters,200-capacity),"fill withdraws actual container capacity and retains container");
        Check(Near(other.Liters,200) && CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION)==water && Near(water.Liters,200-capacity),"other household and repeated reserve lookup remain unchanged");
        water.Liters=.25;bottle.WaterLiters=0;
        Check(Sink.Fill(u,bottle) && Near(bottle.WaterLiters,.25) && Near(water.Liters,0),"partial source cannot supply nonexistent water");
        Check(!Sink.Fill(u,bottle),"empty reserve rejects filling");
        CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()/60);
        water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
        Check(Near(water.Liters,1),"one world minute restores one litre");
        bottle.WaterQuality=CaelumWaterQuality.BIOLOGICAL;
        Check(Sink.Fill(u,bottle) && bottle.WaterQuality==CaelumWaterQuality.BIOLOGICAL,"potable addition does not erase existing contamination");
        bottle.InMagicBox=true;Check(!Sink.Fill(u,bottle),"boxed container cannot fill");bottle.InMagicBox=false;
        Check(CaelumDomesticWater.Get(-1)==null && CaelumDomesticWater.Get(160)==null,"unassigned and out-of-range house IDs stay invalid");
        Cupboard=CaelumKitchenCupboard(Actor.Spawn('CaelumKitchenCupboard',(64,128,48),NO_REPLACE));
        Position(u,Cupboard);Cupboard.GrantLawfulTitle(u);CaelumContainerSession.Open(u,Cupboard);
        let session=CaelumContainerSession.Get(u);
        Check(session!=null && session.Chest==Cupboard && Cupboard.ChestOpen,"wall cupboard opens native storage session");
        Check(Cupboard.StorageTier==CaelumContainerRules.SMALL && session.MaximumSlots==10 && Near(session.MaximumWeight,100),"cupboard has ten stacks and100kg capacity");
        Check(Near(Cupboard.EmptyStorageWeight(),CaelumKitchenFixtureData.CUPBOARD_KG) && Near(Cupboard.StorageVisualScale(),1),"cupboard retains own mass and unscaled visual");
        let heavy=u.CreateDetachedMaterialStack(1,1,100001);heavy.AttachToOwner(u);
        Check(!CaelumInventoryService.TransferContainerItem(u,Cupboard,heavy,100001,true) && heavy.Owner==u,"load over100kg is rejected without consuming material");
        Check(CaelumInventoryService.TransferContainerItem(u,Cupboard,heavy,100000,true) && Near(Cupboard.StorageWeight(u),100),"exact100kg contents accepted independently of furniture mass");
        Inventory load=null;for(Inventory item=Cupboard.Inv;item!=null;item=item.Inv)if(Cupboard.IsStorageItem(item)){load=item;break;}
        Check(load!=null && CaelumInventoryService.TransferContainerItem(u,Cupboard,load,100000,false),"full weight load can be withdrawn without loss");
        let bread=CaelumConsumableItem(u.GiveInventoryType('CaelumBread'));bread.Amount=4;
        CaelumFoodInventory.SetLots(bread,null);let lots=CaelumFoodInventory.Prepare(bread);lots.Lots[0].BaseContamination=30;
        Check(CaelumInventoryService.TransferContainerItem(u,Cupboard,bread,4,true),"actual bread transfers to cupboard");
        let stored=CaelumConsumableItem(Cupboard.FindInventory('CaelumBread'));
        Check(stored!=null && stored.Amount==4 && Near(stored.FoodLots.OldestContamination(),30),"stored food quantity and contamination remain exact");
        for(int id=1;id<=9;id++)
        {
            let material=u.CreateDetachedMaterialStack(id,1,1);material.AttachToOwner(u);
            Check(CaelumInventoryService.TransferContainerItem(u,Cupboard,material,1,true),"available cupboard slot accepts real material stack");
        }
        let extra=u.CreateDetachedMaterialStack(10,1,1);extra.AttachToOwner(u);
        Check(!CaelumInventoryService.TransferContainerItem(u,Cupboard,extra,1,true) && extra.Owner==u,"eleventh distinct stack rejected without loss");
        session.Close();Check(!Cupboard.ChestOpen && Cupboard.ChestVisual is 'CaelumKitchenCupboardClosedVisual',"closing restores cupboard model and closed storage");
        let pair=new('CaelumLockIdentity');let padlock=CaelumLockRules.Create(0,u.Pos,pair);padlock.AttachToOwner(u);
        let key=CaelumLockRules.Create(3,u.Pos,pair);key.AttachToOwner(u);CaelumContainerSession.Open(u,Cupboard);
        Check(Cupboard.TogglePadlock(u) && Cupboard.InstalledPadlock==padlock && Cupboard.ChestVisual is 'CaelumKitchenCupboardLockedVisual',"small native padlock locks cupboard with matching model");
        key.InMagicBox=true;CaelumContainerSession.Open(u,Cupboard);Check(session.Chest==null,"inaccessible key cannot open cupboard");
        key.InMagicBox=false;CaelumContainerSession.Open(u,Cupboard);Check(session.Chest==Cupboard,"matching carried key opens cupboard");
        Check(Cupboard.TogglePadlock(u) && padlock.Owner==u,"owner can remove original padlock");session.Close();
        Check(!CaelumInventoryService.CarryStorageChest(u,Cupboard) && Cupboard.Cargo==null,"wall installation cannot enter portable chest path");
        // Remove the private100kg test payload before checking ordinary carry capacity.
        heavy.Destroy();u.RefreshCarriedInventorySummary();
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(400,128,0),NO_REPLACE));Position(u,chest);chest.EnsureStorage();
        Check(chest.CanCarryAsStorage() && Near(chest.EmptyStorageWeight(),100) && chest.StorageVisualClass()=="CaelumStashChestClosedVisual","ordinary chest defaults remain unchanged");
        Check(CaelumInventoryService.CarryStorageChest(u,chest) && chest.Cargo!=null,"ordinary native chest can still be carried");
        water.Liters=17;SavedWater=water.Liters;SavedStamp=water.Stamp;u.CurrentHunger=100;u.CurrentThirst=100;
        Result();
    }
    void Resume(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;u.CurrentThirst=100;
        let water=CaelumDomesticWater.Get(CaelumDomesticWaterData.MANSION);
        double expected=Min(200,SavedWater+(water.Stamp-SavedStamp)/60);
        Check(Sink!=null && Sink.Installed && Sink.House==CaelumDomesticWaterData.MANSION,"sink identity and source persist");
        Check(Near(water.Liters,expected) && water.Liters<200,"save or hub return retains reserve with elapsed refill only");
        Check(Cupboard!=null && Cupboard.StorageSlots()==10 && Cupboard.Cargo==null,"cupboard and contents persist");
        let bread=CaelumConsumableItem(Cupboard.FindInventory('CaelumBread'));CaelumFoodInventory.Reconcile(bread);
        Check(bread!=null && bread.Amount==4 && bread.FoodLots.OldestContamination()>=30,"food age persists in stored native lots");
        Position(u,Cupboard);CaelumContainerSession.Open(u,Cupboard);
        Check(CaelumInventoryService.TransferContainerItem(u,Cupboard,bread,4,false),"saved food can be withdrawn normally");
        CaelumContainerSession.Get(u).Close();Result();
    }
    void Mansion(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;u.CurrentThirst=100;
        Check(CaelumMansionKitchenFixtures.Prepare(),"sink and cupboard fit actual mansion geometry");
        for(int id=0;id<2;id++)
        {
            vector3 p=id==0?CaelumKitchenFixtureData.SinkPosition():CaelumKitchenFixtureData.CupboardPosition();
            let probe=Actor.Spawn('CA410FixtureCamera',p,NO_REPLACE);
            Console.Printf("CA410K GEOMETRY %d floor=%.1f ceiling=%.1f",id,probe.FloorZ,probe.CeilingZ);probe.Destroy();
            let it=BlockThingsIterator.CreateFromPos(p.X,p.Y,p.Z,64,64,false);Actor found=null;int count=0;
            while(it.Next())if((id==0?it.thing is 'CaelumKitchenSink':it.thing is 'CaelumKitchenCupboard') && (it.thing.Pos-p).Length()<1){count++;found=it.thing;}
            Check(count==1 && found!=null,"one fixture at approved-room position");if(found==null)continue;
            Position(u,found,id==0?56:72);
            Check(u.TestMobjLocation(),"fixture approach has clear physical space");
            if(id==0)Check(CaelumKitchenSink(found).CanReach(u) && CaelumDomesticFixture.SourceFor(u)==found,"actual sink reachable through inventory source lookup");
            else {let chest=CaelumKitchenCupboard(found);bool used=chest.Used(u);let session=CaelumContainerSession.Get(u);Check(used && session!=null && session.Chest==chest,"actual aimed Use opens elevated cupboard storage");if(session!=null)session.Close();}
        }
        Check(CaelumMansionKitchenFixtures.Prepare(),"repeat fixture installation is idempotent");
        let camera=Actor.Spawn('CA410FixtureCamera',(1620,176,70),NO_REPLACE);camera.Angle=90;camera.Pitch=8;u.player.camera=camera;Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca410k_core")Core(u);
        else if(e.Name=="ca410k_resume")Resume(u);
        else if(e.Name=="ca410k_away")CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()/2);
        else if(e.Name=="ca410k_mansion")Mansion(u);
        else if(e.Name=="ca410k_locale")
        {
            Check(StringTable.Localize("CA_KITCHEN_SINK",false)=="Fregadero de cocina","Spanish locale resolves kitchen sink");
            Check(StringTable.Localize("CA_KITCHEN_CUPBOARD",false)=="Alacena de cocina","Spanish locale resolves cupboard");Result();
        }
        else if(e.Name=="ca410k_sprites")
        {
            for(int id=0;id<2;id++)
            {
                vector3 pos=id==0?CaelumKitchenFixtureData.SinkPosition():CaelumKitchenFixtureData.CupboardPosition();
                let it=BlockThingsIterator.CreateFromPos(pos.X,pos.Y,pos.Z,64,64,false);
                while(it.Next())if((id==0?it.thing is 'CaelumKitchenSink':it.thing is 'CaelumKitchenCupboard') && (it.thing.Pos-pos).Length()<1)
                {it.thing.bInvisible=true;let chest=CaelumStashChest(it.thing);if(chest!=null && chest.ChestVisual!=null)chest.ChestVisual.bInvisible=true;}
                Actor.Spawn(id==0?'CA410SinkSpriteOnly':'CA410CupboardSpriteOnly',pos,NO_REPLACE);
            }
        }
        else Super.NetworkProcess(e);
    }
}
class CA410FixtureCamera : Actor
{Default {Radius 1;Height 1;+NOBLOCKMAP +NOGRAVITY +NOINTERACTION}States {Spawn:TNT1 A -1;Stop;}}
class CA410SinkSpriteOnly : Actor
{Default {+NOBLOCKMAP +NOGRAVITY +NOINTERACTION}States {Spawn:CDSK A -1;Stop;}}
class CA410CupboardSpriteOnly : Actor
{Default {+NOBLOCKMAP +NOGRAVITY +NOINTERACTION}States {Spawn:CKCB A -1;Stop;}}
