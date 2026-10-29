class CA411InteriorObstacle : Actor
{Default {Radius 16;Height 80;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA411InteriorChecks : EventHandler
{
    int Passed,Failed;
    CaelumWardrobe Wardrobe;
    vector3 Placed;
    void Check(bool value,String label){if(value)Passed++;else Failed++;Console.Printf("CA411IN %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CombatTimeRemaining=0;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.DerivedStats.CarryCapacity=2000;u.Vel=(0,0,0);
    }
    void Face(CaelumPlayer u,vector3 target,double radius)
    {u.SetOrigin(target-(u.Radius+radius+1,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=15;u.Vel=(0,0,0);}
    void Core(CaelumPlayer u)
    {
        Profile(u);Wardrobe=CaelumWardrobe(ThinkerIterator.Create('CaelumWardrobe').Next());
        Check(Wardrobe!=null,"actual mansion wardrobe exists");if(Wardrobe==null)return;
        vector3 original=Wardrobe.Pos;
        Check(CaelumCampLand.AllowsFurniture(u,original,Wardrobe.Radius),"approved interior footprint permits furniture");
        Check(!CaelumCampLand.Allows(u,original,Wardrobe.Radius),"interior furniture approval does not permit indoor campfires or tents");
        Face(u,original,Wardrobe.Radius);Wardrobe.GrantLawfulTitle(u);CaelumContainerSession.Open(u,Wardrobe);
        let bread=CaelumConsumableItem(u.GiveInventoryType('CaelumBread'));bread.Amount=2;
        CaelumFoodInventory.SetLots(bread,null);CaelumFoodInventory.Prepare(bread).Lots[0].BaseContamination=30;
        Check(CaelumInventoryService.TransferContainerItem(u,Wardrobe,bread,2,true),"ordinary inventory stores original aged food");
        CaelumContainerSession.Get(u).Close();
        u.DerivedStats.CarryCapacity=2000;
        Check(CaelumInventoryService.CarryStorageChest(u,Wardrobe),"same loaded wardrobe can be carried");
        bool found=false;
        // Busqueda diagnostica acotada; la produccion solo comprueba el destino elegido.
        for(int x=-400;x<=-160 && !found;x+=32)for(int y=400;y<=480 && !found;y+=32)
        {
            vector3 candidate=(x,y,136);if((candidate-original).Length()<32)continue;
            Face(u,candidate,Wardrobe.Radius);
            if(u.TestMobjLocation() && Wardrobe.StoragePlacementAllowed(u,candidate)
                && CaelumPlacementGeometry.Fits(u,candidate,Wardrobe.Radius,Wardrobe.Height,Wardrobe))
            {Placed=candidate;found=true;}
        }
        Check(found,"room contains a different clear complete footprint");if(!found)return;
        Check(Wardrobe.TryPlaceStorage(u) && Wardrobe.Cargo==null,"native placement moves the original wardrobe indoors");
        Check(Near(Wardrobe.Pos.X,Placed.X) && Near(Wardrobe.Pos.Y,Placed.Y),"placement uses the checked destination");
        Check(bread.Owner==Wardrobe && bread.Amount==2 && bread.FoodLots.OldestContamination()>=30,"contents and age survive furniture relocation");
        Check(Wardrobe.IsLawfulOwner(u) && Near(Wardrobe.EmptyStorageWeight(),CaelumWardrobeData.EMPTY_KG),"title and physical mass remain unchanged");
        u.DerivedStats.CarryCapacity=2000;
        Check(CaelumInventoryService.CarryStorageChest(u,Wardrobe),"same placed wardrobe is recoverable");
        let obstacle=Actor.Spawn('CA411InteriorObstacle',Placed,NO_REPLACE);
        Check(!Wardrobe.TryPlaceStorage(u) && Wardrobe.Cargo!=null && bread.Owner==Wardrobe,"occupied destination rejects atomically without losing cargo");
        obstacle.Destroy();Check(Wardrobe.TryPlaceStorage(u),"clearing obstruction permits original cargo placement");
        let target=new('CaelumTargetInfo');target.Refresh(u);
        Check(target.Subject==Wardrobe,"moved furniture remains the actual crosshair target");
        int buttons=u.player.cmd.buttons;u.player.cmd.buttons=0;
        Check(Wardrobe.Used(u) && CaelumContainerSession.Get(u).Chest==Wardrobe,"moved original retains ordinary aimed interaction");
        u.player.cmd.buttons=buttons;CaelumContainerSession.Get(u).Close();
        let door=CaelumSlidingDoorLeaf(ThinkerIterator.Create('CaelumSlidingDoorLeaf').Next());
        Check(door!=null && !CaelumPlacementGeometry.Fits(u,door.ClosedPosition,Wardrobe.Radius,Wardrobe.Height),"existing doorway footprint remains protected");
        let cupboard=CaelumKitchenCupboard(ThinkerIterator.Create('CaelumKitchenCupboard').Next());
        Check(cupboard!=null && !cupboard.CanCarryAsStorage(),"approved fixed kitchen installation remains fixed");
        Check(CaelumMansionWardrobe.Prepare(),"repeated mansion installer accepts moved original");
        int count=0;let it=ThinkerIterator.Create('CaelumWardrobe');while(it.Next()!=null)count++;
        Check(count==1,"relocation never duplicates the wardrobe");
        Console.Printf("CA411IN POSITION %.6f %.6f %.6f",Placed.X,Placed.Y,Placed.Z);
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);Wardrobe=CaelumWardrobe(ThinkerIterator.Create('CaelumWardrobe').Next());
        Check(Wardrobe!=null,"saved relocated wardrobe still exists");if(Wardrobe==null)return;
        Check(Near(Wardrobe.Pos.X,Placed.X) && Near(Wardrobe.Pos.Y,Placed.Y) && Near(Wardrobe.Pos.Z,Placed.Z),"save/hub retains chosen interior position");
        let bread=CaelumConsumableItem(Wardrobe.FindInventory('CaelumBread'));CaelumFoodInventory.Reconcile(bread);
        Check(bread!=null && bread.Amount==2 && bread.FoodLots.OldestContamination()>=30,"save/hub retains native contents and accumulated age");
        Check(Wardrobe.IsLawfulOwner(u) && Wardrobe.Cargo==null,"save/hub retains lawful owner and deployed state");
    }
    void CheckProperty(CaelumPlayer u)
    {
        Profile(u);int house=CaelumHouseHubData.HouseForMap(level.MapName);
        Check(house==CaelumPropertyData.CENTRAL_HOUSE,"actual offered house map used");
        let record=CaelumPropertyRules.Find(house,true);vector3 p=(0,0,0);
        Check(!CaelumCampLand.AllowsFurniture(u,p,24),"unacquired home rejects new furniture");
        record.Holder=CaelumLockRules.Character(u,true);record.PaidUntil=CaelumScheduleState.Now(u)+CaelumWorldClock.TicsPerDay();
        Check(CaelumCampLand.AllowsFurniture(u,p,24),"current rent permits furniture");
        record.PaidUntil=CaelumScheduleState.Now(u);
        Check(!CaelumCampLand.AllowsFurniture(u,p,24),"expired rent prevents new placement without confiscation");
        record.Purchased=true;Check(CaelumCampLand.AllowsFurniture(u,p,24),"purchased home retains permission");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',p,NO_REPLACE));chest.EnsureStorage();
        Check(chest.StoragePlacementAllowed(u,p),"ordinary chest shares current property permission");
        record.Purchased=false;
        Check(!chest.StoragePlacementAllowed(u,p),"ordinary chest cannot bypass expired property permission");chest.Destroy();
    }
    void Migration(CaelumPlayer u)
    {
        Profile(u);Wardrobe=CaelumWardrobe(ThinkerIterator.Create('CaelumWardrobe').Next());
        vector3 original=CaelumWardrobeData.Position();
        Check(Wardrobe!=null && Near(Wardrobe.Pos.X,original.X)
            && Near(Wardrobe.Pos.Y,original.Y),"original-version save keeps authored wardrobe position");
        let reading=CaelumRecipeSession.Get(u);
        Check(reading!=null && reading.Book!=null && reading.Book.Owner==reading.StoredSource
            && Near(reading.RemainingSeconds,321.75),"unrelated saved stored-book task remains intact");
        if(Wardrobe!=null)Check(Wardrobe.StoragePlacementAllowed(u,Wardrobe.Pos),"new interior permission applies to existing saved furniture");
    }
    void CityLand(CaelumPlayer u)
    {
        Profile(u);Check(level.MapName=='MAP03',"actual campaign city used for permission checks");
        Check(!CaelumCampLand.AllowsFurniture(u,(0,0,0),24),"urban land receives no blanket interior permission");
        Check(CaelumCampLand.AllowsFurniture(u,(-30000,0,0),24),"approved unowned countryside still permits furniture");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos,NO_REPLACE));chest.EnsureStorage();
        Check(!chest.StoragePlacementAllowed(u,(0,0,0)),"ordinary carried chest also respects city land restriction");
        Check(chest.StoragePlacementAllowed(u,(-30000,0,0)),"same chest can be placed on authorized countryside");chest.Destroy();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca411in_profile'){Profile(u);return;}
        if(e.Name=='ca411in_core')Core(u);
        else if(e.Name=='ca411in_resume')Resume(u);
        else if(e.Name=='ca411in_property')CheckProperty(u);
        else if(e.Name=='ca411in_migration')Migration(u);
        else if(e.Name=='ca411in_city')CityLand(u);
        else return;
        Console.Printf("CA411IN RESULT passed=%d failed=%d",Passed,Failed);
    }
}
