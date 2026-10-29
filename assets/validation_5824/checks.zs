class CA410WardrobeChecks : EventHandler
{
    CaelumStashChest Wardrobe;
    int Passed,Failed;
    bool Manual;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA410W %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CombatTimeRemaining=0;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.DerivedStats.CarryCapacity=2000;u.Vel=(0,0,0);
    }
    void Position(CaelumPlayer u)
    {
        u.SetOrigin(Wardrobe.Pos+(0,-72,0),false);u.FindFloorCeiling();u.Vel=(0,0,0);
        u.Angle=90;u.Pitch=ATan2(u.ViewHeight-Wardrobe.Height/2,72);u.player.camera=u;
    }
    void Find()
    {Wardrobe=CaelumStashChest(ThinkerIterator.Create('CaelumWardrobe').Next());}
    void Mansion(CaelumPlayer u)
    {
        Profile(u);Find();Check(Wardrobe!=null,"mansion installs wardrobe through normal controller");
        if(Wardrobe==null)
        {
            vector3 p=CaelumWardrobeData.Position();let around=BlockThingsIterator.CreateFromPos(p.X,p.Y,p.Z,96,96,false);
            while(around.Next())Console.Printf("CA410W NEIGHBOR %s %.1f %.1f %.1f solid=%d",around.thing.GetClassName(),around.thing.Pos.X,around.thing.Pos.Y,around.thing.Pos.Z,around.thing.bSolid);
            return;
        }
        Check(Wardrobe.TestMobjLocation() && Near(Wardrobe.FloorZ,Wardrobe.Pos.Z),"actual wardrobe footprint is supported and clear");
        Check(Near(Wardrobe.Height,CaelumWardrobeData.HEIGHT) && Near(Wardrobe.Radius,CaelumWardrobeData.RADIUS),"wardrobe uses its own physical envelope");
        Position(u);Check(u.TestMobjLocation() && Wardrobe.CanReachStorage(u),"ordinary player reaches wardrobe from clear floor");
        int buttons=u.player.cmd.buttons;u.player.cmd.buttons=BT_USE;
        Check(Wardrobe.Used(u),"aimed native Use opens wardrobe");u.player.cmd.buttons=buttons;
        let session=CaelumContainerSession.Get(u);
        Check(session!=null && session.Chest==Wardrobe && Wardrobe.ChestOpen,"actual storage session belongs to wardrobe");
        if(session!=null)session.Close();
        Check(CaelumMansionWardrobe.Prepare(),"repeated installer retains existing wardrobe");
        int count=0;let all=ThinkerIterator.Create('CaelumWardrobe');while(all.Next()!=null)count++;
        Check(count==1,"installation does not duplicate wardrobe");
        Check(CaelumMansionBathrooms.Find()!=null && CaelumMansionBathrooms.Prepare(),"all accepted bathroom fixtures remain installed");
        for(int id=101;id<=106;id++)Check(CaelumDiningWorld.Find(id)!=null,"accepted dining table retained");
        for(int id=101;id<=104;id++)Check(CaelumRestFurnitureTrial.Find(id)!=null,"accepted bedroom bed retained");
    }
    void Core(CaelumPlayer u)
    {
        Profile(u);Check(Wardrobe!=null,"prepared native wardrobe exists");if(Wardrobe==null)return;Position(u);
        Wardrobe.GrantLawfulTitle(u);CaelumContainerSession.Open(u,Wardrobe);let session=CaelumContainerSession.Get(u);
        Check(session!=null && session.Chest==Wardrobe,"native wardrobe storage opens");if(session==null)return;
        Check(session.MaximumSlots==25 && Near(session.MaximumWeight,1000),"approved25 stacks and1000kg contents");
        Check(Near(Wardrobe.EmptyStorageWeight(),CaelumWardrobeData.EMPTY_KG) && Near(Wardrobe.StorageVisualScale(),1),"calculated physical mass and unscaled model");
        Check(Wardrobe.ChestVisual is 'CaelumWardrobeOpenVisual',"open wardrobe uses own model");
        let heavy=u.CreateDetachedMaterialStack(1,1,1000001);heavy.AttachToOwner(u);
        Check(!CaelumInventoryService.TransferContainerItem(u,Wardrobe,heavy,1000001,true) && heavy.Owner==u,"over1000kg rejected without mutation");
        Check(CaelumInventoryService.TransferContainerItem(u,Wardrobe,heavy,1000000,true) && Near(Wardrobe.StorageWeight(u),1000),"exact1000kg accepted without counting furniture mass");
        heavy.Destroy();
        Inventory load=null;for(Inventory item=Wardrobe.Inv;item!=null;item=item.Inv)if(Wardrobe.IsStorageItem(item)){load=item;break;}
        u.DerivedStats.CarryCapacity=2000;
        Check(load!=null && CaelumInventoryService.TransferContainerItem(u,Wardrobe,load,1000000,false),"native full load withdraws without loss");
        if(load!=null && load.Owner==u)load.Destroy();
        let bread=CaelumConsumableItem(u.GiveInventoryType('CaelumBread'));bread.Amount=2;
        CaelumFoodInventory.SetLots(bread,null);let lots=CaelumFoodInventory.Prepare(bread);lots.Lots[0].BaseContamination=30;
        Check(CaelumInventoryService.TransferContainerItem(u,Wardrobe,bread,2,true),"food transfers through native inventory");
        for(int id=1;id<=24;id++)
        {
            let item=u.CreateDetachedMaterialStack(id,1,1);item.AttachToOwner(u);
            Check(CaelumInventoryService.TransferContainerItem(u,Wardrobe,item,1,true),"available wardrobe slot accepts a distinct stack");
        }
        let extra=u.CreateDetachedMaterialStack(25,1,1);extra.AttachToOwner(u);
        Check(Wardrobe.StorageSlots()==25 && !CaelumInventoryService.TransferContainerItem(u,Wardrobe,extra,1,true) && extra.Owner==u,"twenty-sixth stack rejected without loss");
        let stored=CaelumConsumableItem(Wardrobe.FindInventory('CaelumBread'));
        Check(stored!=null && stored.Amount==2 && Near(stored.FoodLots.OldestContamination(),30),"storage retains food lot contamination");
        session.Close();Check(Wardrobe.ChestVisual is 'CaelumWardrobeClosedVisual',"closed wardrobe uses own model");
        let pair=new('CaelumLockIdentity');let padlock=CaelumLockRules.Create(1,u.Pos,pair);padlock.AttachToOwner(u);
        let key=CaelumLockRules.Create(4,u.Pos,pair);key.AttachToOwner(u);CaelumContainerSession.Open(u,Wardrobe);
        Check(Wardrobe.TogglePadlock(u) && Wardrobe.InstalledPadlock==padlock && Wardrobe.ChestVisual is 'CaelumWardrobeLockedVisual',"matching medium native padlock installs and changes model");
        key.InMagicBox=true;CaelumContainerSession.Open(u,Wardrobe);Check(session.Chest==null,"boxed key cannot open locked wardrobe");
        key.InMagicBox=false;CaelumContainerSession.Open(u,Wardrobe);Check(session.Chest==Wardrobe,"matching carried key opens wardrobe");
        Check(Wardrobe.TogglePadlock(u) && padlock.Owner==u,"owner retrieves original padlock");session.Close();
        u.DerivedStats.CarryCapacity=1;
        Check(!CaelumInventoryService.CarryStorageChest(u,Wardrobe) && Wardrobe.Cargo==null,"insufficient carrying capacity rejects heavy wardrobe");
        u.DerivedStats.CarryCapacity=2000;double weight=Wardrobe.TotalStorageWeight(u);
        Check(CaelumInventoryService.CarryStorageChest(u,Wardrobe) && Wardrobe.Cargo!=null,"native cargo carries the same full wardrobe");
        Check(Near(Wardrobe.Cargo.CarriedWeight(u),weight) && Wardrobe.StorageSlots()==25,"carried weight includes original furniture and contents");
        u.FillFormalInventoryRow(0,Wardrobe.Cargo);
        Check(u.FormalInventoryRowType[0]==CaelumWardrobeData.DISPLAY_TYPE && Wardrobe.StorageTier==CaelumContainerRules.MEDIUM,"display identity is separate from capacity tier");
        Check(CaelumContainerRules.NameKey(Wardrobe.StorageDisplayType())=="CA_FURNITURE_WARDROBE","inventory name identifies wardrobe");
        u.SetOrigin((128,64,0),false);u.Angle=90;
        Check(!Wardrobe.TryPlaceStorage(u) && Wardrobe.Cargo!=null && Wardrobe.StorageSlots()==25,"land without placement permission retains carried wardrobe");
        Check(Wardrobe.ChestVisual==null && Near(Wardrobe.Height,CaelumWardrobeData.HEIGHT),"denied placement keeps hidden cargo and physical dimensions");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(-128,128,0),NO_REPLACE));
        chest.EnsureStorage();
        Check(chest.StorageDisplayType()==CaelumContainerRules.MEDIUM && Near(chest.EmptyStorageWeight(),100),"ordinary chest name tier and weight unchanged");
    }
    void Seed(CaelumPlayer u,bool carried)
    {
        Profile(u);Find();Check(Wardrobe!=null,"save uses actual mansion wardrobe");if(Wardrobe==null)return;
        Position(u);Wardrobe.GrantLawfulTitle(u);CaelumContainerSession.Open(u,Wardrobe);
        let bread=CaelumConsumableItem(u.GiveInventoryType('CaelumBread'));bread.Amount=2;
        CaelumFoodInventory.SetLots(bread,null);CaelumFoodInventory.Prepare(bread).Lots[0].BaseContamination=30;
        Check(CaelumInventoryService.TransferContainerItem(u,Wardrobe,bread,2,true),"save stores two actual food portions");
        CaelumContainerSession.Get(u).Close();
        u.DerivedStats.CarryCapacity=2000;
        if(carried)Check(CaelumInventoryService.CarryStorageChest(u,Wardrobe),"save carries same wardrobe through native cargo");
    }
    void Resume(CaelumPlayer u,bool carried)
    {
        Profile(u);
        if(carried)
        {
            Wardrobe=null;
            for(Inventory item=u.Inv;item!=null;item=item.Inv)
            {let cargo=CaelumChestCargo(item);if(cargo!=null && cargo.Chest is 'CaelumWardrobe'){Wardrobe=cargo.Chest;break;}}
        }
        Check(Wardrobe!=null && Wardrobe is 'CaelumWardrobe',"restored saved wardrobe retains native class and identity");if(Wardrobe==null)return;
        let bread=CaelumConsumableItem(Wardrobe.FindInventory('CaelumBread'));CaelumFoodInventory.Reconcile(bread);
        Check(bread!=null && bread.Amount==2 && bread.FoodLots.OldestContamination()>=30,"restored food quantity and age survive");
        Check(Near(Wardrobe.EmptyStorageWeight(),CaelumWardrobeData.EMPTY_KG) && Near(Wardrobe.Height,CaelumWardrobeData.HEIGHT),"restored wardrobe keeps mass and dimensions");
        Check(carried?(Wardrobe.Cargo!=null && Wardrobe.Cargo.Owner==u):Wardrobe.Cargo==null,"restored cargo ownership matches saved state");
        if(level.MapName=="MAP01")
        {int count=0;let all=ThinkerIterator.Create('CaelumWardrobe');while(all.Next()!=null)count++;Check(count==1,"return does not install a duplicate moved wardrobe");}
    }
    void LegacyResume(CaelumPlayer u)
    {
        Profile(u);Check(Wardrobe!=null && Wardrobe.GetClassName()=="CaelumStashChest","previous native chest retains its class");
        if(Wardrobe!=null)
        {
            let bread=Wardrobe.FindInventory('CaelumBread');
            Check(bread!=null && bread.Amount==2,"previous chest contents preserved");
            Check(Wardrobe.StorageTier==CaelumContainerRules.MEDIUM && Near(Wardrobe.EmptyStorageWeight(),100),"previous chest mass and capacity unchanged");
        }
        Mansion(u);
    }
    void Placement(CaelumPlayer u)
    {
        Profile(u);Find();Check(Wardrobe!=null,"placement uses installed wardrobe");if(Wardrobe==null)return;
        Position(u);Check(CaelumInventoryService.CarryStorageChest(u,Wardrobe),"actual mansion wardrobe becomes cargo");
        u.SetOrigin((900,-1000,0),false);u.FindFloorCeiling();u.Vel=(0,0,0);u.Angle=0;
        Check(Wardrobe.StoragePlacementAllowed(u,u.Pos+(u.Radius+Wardrobe.Radius+1,0,0)),"mansion garden grants furniture placement");
        Check(Wardrobe.TryPlaceStorage(u) && Wardrobe.Cargo==null,"permitted garden restores native wardrobe body");
        Check(Wardrobe.TestMobjLocation() && Wardrobe.ChestVisual is 'CaelumWardrobeClosedVisual',"placed wardrobe has clear collision and correct visual");
    }
    void View(CaelumPlayer u,int mode)
    {
        Profile(u);Find();Check(Wardrobe!=null,"view requires installed wardrobe");if(Wardrobe==null)return;
        Position(u);Manual=true;
        if(mode==1){CaelumContainerSession.Open(u,Wardrobe);CaelumContainerSession.Get(u).Chest=null;}
        else if(mode==2){CaelumContainerSession.Get(u,true).Close();let lock=CaelumLockRules.Create(1,u.Pos,new('CaelumLockIdentity'));lock.AttachToOwner(Wardrobe);Wardrobe.InstalledPadlock=lock;Wardrobe.RefreshChestVisual();}
        else if(mode==3)
        {
            Check(CaelumInventoryService.CarryStorageChest(u,Wardrobe),"inventory view carries real wardrobe");
            u.EquipmentMenuOpen=false;u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        }
        Check(u.TestMobjLocation(),"author viewpoint has clear footprint");
        Console.Printf("CA410W INPUT wardrobe ready; native Use, inventory and storage controls; diagnostic carry capacity2000kg");
    }
    override void WorldTick()
    {
        if(!Manual)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {let u=CaelumPlayer(players[i].mo);if(u!=null)u.DerivedStats.CarryCapacity=2000;}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410w_profile')Profile(u);
        else if(e.Name=='ca410w_prepare'){Profile(u);Wardrobe=CaelumStashChest(Actor.Spawn('CaelumWardrobe',(64,128,0),NO_REPLACE));}
        else if(e.Name=='ca410w_es')
        {
            Check(StringTable.Localize("CA_FURNITURE_WARDROBE",false)=="Armario","Spanish wardrobe name resolves");
            Check(StringTable.Localize("CA_TARGET_CARRY_WARDROBE",false)=="{bind:+speed} + {bind:+use}: recoger armario","Spanish carry action resolves");
        }
        else if(e.Name=='ca410w_mansion')Mansion(u);
        else if(e.Name=='ca410w_core')Core(u);
        else if(e.Name=='ca410w_seed')Seed(u,e.Args[0]!=0);
        else if(e.Name=='ca410w_resume')Resume(u,e.Args[0]!=0);
        else if(e.Name=='ca410w_legacyresume')LegacyResume(u);
        else if(e.Name=='ca410w_placement')Placement(u);
        else if(e.Name=='ca410w_view')View(u,e.Args[0]);
        else return;
        Console.Printf("CA410W RESULT passed=%d failed=%d",Passed,Failed);
    }
}
