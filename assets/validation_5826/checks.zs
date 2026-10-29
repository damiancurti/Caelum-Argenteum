class CA410ReadingChecks : EventHandler
{
    int Passed,Failed;
    CaelumReadingShelf Shelf;
    CaelumReadingDesk Desk;
    CaelumBookcaseStorage Store;
    CaelumRecipeBook Book;
    double SavedRemaining;
    void Check(bool value,String label){if(value)Passed++;else Failed++;Console.Printf("CA410RD %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CombatTimeRemaining=0;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.DerivedStats.CarryCapacity=2000;u.Vel=(0,0,0);
    }
    bool Find(CaelumPlayer u)
    {
        Profile(u);Shelf=CaelumReadingShelf(ThinkerIterator.Create('CaelumReadingShelf').Next());
        Desk=CaelumReadingDesk(ThinkerIterator.Create('CaelumReadingDesk').Next());
        Check(Shelf!=null && Desk!=null,"mansion installs original shelf and adjacent desk");
        if(Shelf==null || Desk==null)return false;
        Store=Shelf.GetStorage();return Store!=null;
    }
    void AtShelf(CaelumPlayer u){u.SetOrigin(Shelf.Pos+(-64,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=10;u.Vel=(0,0,0);}
    void AtDesk(CaelumPlayer u){u.SetOrigin(Desk.Pos+(-64,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=20;u.Vel=(0,0,0);}
    CaelumRecipeBook MakeBook(Actor owner,int slot)
    {let book=CaelumRecipeBook(Actor.Spawn('CaelumRecipeBook',owner.Pos,NO_REPLACE));book.Sheets[slot]=true;book.AttachToOwner(owner);return book;}
    void Core(CaelumPlayer u)
    {
        if(!Find(u))return;AtShelf(u);
        Check(Near(Shelf.Pos.X,368) && Near(Shelf.Pos.Y,-576),"accepted shelf location retained");
        Check(Desk.TestMobjLocation() && u.TestMobjLocation(),"full desk envelope and shelf approach fit");
        Check(Store.StorageSlotLimit()==25 && Near(Store.StorageWeightLimit(),100),"approved independent25-stack100kg limits");
        Check(Store.Inv==null || Store.StorageSlots()==0,"migration creates no physical books");
        let original=Shelf.GetStorage();Check(original==Store,"repeated binding preserves actual native owner");
        Book=MakeBook(u,0);CaelumContainerSession.Open(u,Store);
        Check(CaelumInventoryService.TransferContainerItem(u,Store,Book,1,true),"ordinary storage deposits original book");
        Check(Book.Owner==Store && Book.Sheets[0],"native identity and pages preserved");
        Check(CaelumNotifications.Describe(u,Book,0,true)==StringTable.Localize("CA_KEY_ITEM_RECIPE_BOOK",false),"actual book label is not the historical shared-ID sleeping bag");
        let bag=CaelumSleepingBag(Actor.Spawn('CaelumSleepingBag',u.Pos,NO_REPLACE));
        Check(CaelumNotifications.Describe(u,bag,0,true)==StringTable.Localize("CA_SLEEPING_BAG_NAME",false),"shared-ID sleeping bag keeps its own label");bag.Destroy();
        CaelumContainerSession.Get(u).Close();AtDesk(u);
        Check(u.TestMobjLocation() && CaelumStoredReading.Adjacent(Desk,Shelf),"desk approach and96-unit shelf rule");
        Check(CaelumRecipeSession.OpenLibrary(u,Desk),"ordinary library opens without a carried recipe book");
        let reading=CaelumRecipeSession.Get(u);
        Check(reading.BrowsingLibrary && reading.LibraryBooks.Size()==1 && reading.LibraryBooks[0]==Book,"picker lists only stored original");
        Check(reading.Start() && !reading.BrowsingLibrary && reading.Book==Book,"picker selects actual stored book");
        Check(reading.Start() && reading.Active && reading.Anchor==Desk,"real recipe starts at desk");
        Check(CaelumRecipeSession.Working(u) && Book.Owner==Store,"reading never withdraws book");
        double before=reading.RemainingSeconds;reading.Advance();
        Check(Near(before-reading.RemainingSeconds,1.0/TICRATE),"existing reading clock retained");
        before=reading.RemainingSeconds;reading.Open=false;reading.Advance();
        Check(Near(before,reading.RemainingSeconds),"closing menu pauses without losing progress");
        Check(CaelumRecipeSession.OpenLibrary(u,Desk) && reading.Open && reading.Active
            && Near(before,reading.RemainingSeconds),"desk reopens the same unfinished task");
        vector3 originalDesk=Desk.Pos;Desk.SetOrigin(Shelf.Pos+(0,97,0),false);
        Check(!CaelumStoredReading.Adjacent(Desk,Shelf),"97units rejected without adding furniture radii");
        before=reading.RemainingSeconds;reading.Advance();Check(Near(before,reading.RemainingSeconds),"lost adjacency pauses reading");
        Desk.SetOrigin(originalDesk,false);AtDesk(u);
        let pair=new('CaelumLockIdentity');let lock=CaelumLockRules.Create(CaelumContainerRules.MEDIUM,Store.Pos,pair);
        lock.AttachToOwner(Store);Store.InstalledPadlock=lock;Store.PadlockReleased=false;
        Check(!CaelumStoredReading.Access(u,Desk,Store),"locked shelf requires its actual paired key");
        before=reading.RemainingSeconds;reading.Advance();Check(Near(before,reading.RemainingSeconds),"relocking never grants remote reading");
        let key=CaelumLockRules.Create(CaelumContainerRules.MEDIUM+3,u.Pos,pair);key.AttachToOwner(u);
        Check(CaelumStoredReading.Access(u,Desk,Store),"actual paired key grants access");
        reading.RemainingSeconds=0;reading.Complete();
        Check(!reading.Active && u.GetPersistentCharacterState(false).KnowsCraftingRecipe(0,1),"existing recipe learning completes");
        Check(Book.Owner==Store && Book.Sheets[0] && u.FindInventory('CaelumRecipeBook')==null,"learning neither transfers nor duplicates pages");
        Check(reading.Start(),"stored recipe can be reread");
        int reread=u.GetPersistentCharacterState(false).RecipeRereadings[0];reading.RemainingSeconds=0;reading.Complete();
        Check(u.GetPersistentCharacterState(false).RecipeRereadings[0]==reread+1,"rereading keeps existing progression");
        key.Destroy();Store.InstalledPadlock=null;lock.Destroy();
        reading.Active=false;reading.Open=false;AtShelf(u);CaelumContainerSession.Open(u,Store);
        Check(CaelumInventoryService.TransferContainerItem(u,Store,Book,1,false),"ordinary retrieval returns same physical book");
        Check(Book.Owner==u && Book.Sheets[0],"retrieved page identity intact");
        CaelumContainerSession.Get(u).Close();AtDesk(u);
        Check(CaelumRecipeSession.OpenBook(u,Book) && reading.Start(),"carried-book reading remains functional at new desk");
        reading.Active=false;reading.Open=false;
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(0,0,0),NO_REPLACE));chest.EnsureStorage();
        Check(chest.StorageSlotLimit()==25 && Near(chest.StorageWeightLimit(),1000),"ordinary medium chest limits unchanged");chest.Destroy();
        Check(CaelumStoredReading.Prepare(),"idempotent desk setup");
        int count=0;let it=ThinkerIterator.Create('CaelumReadingDesk');while(it.Next()!=null)count++;
        Check(count==1,"no duplicated desk");
    }
    void Limits(CaelumPlayer u)
    {
        if(!Find(u))return;AtShelf(u);CaelumContainerSession.Open(u,Store);
        for(int i=0;i<25;i++)MakeBook(Store,i);
        let extra=MakeBook(u,27);
        Check(Store.StorageSlots()==25,"25 distinct physical books occupy 25 stacks");
        Check(!CaelumInventoryService.TransferContainerItem(u,Store,extra,1,true)
            && extra.Owner==u && Store.StorageSlots()==25,"26th stack rejected without removing its pages");
        let session=CaelumContainerSession.Get(u);session.Refresh();
        Check(session.MaximumSlots==25 && Near(session.MaximumWeight,100),"ordinary storage menu reports bookcase limits");
        for(Inventory item=Store.Inv;item!=null;){let next=item.Inv;item.Destroy();item=next;}
        extra.Destroy();
        let wood=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos,NO_REPLACE));
        wood.args[0]=CaelumConstants.MATERIAL_WOOD;wood.args[1]=1;wood.Amount=100001;wood.AttachToOwner(u);
        Check(Near(CaelumContainerRules.Weight(u,wood),100.001),"actual material weight supplies capacity boundary");
        Check(CaelumInventoryService.TransferContainerItem(u,Store,wood,100000,true),"exact100kg content deposit succeeds");
        Check(Near(Store.StorageWeight(u),100) && wood.Owner==u && wood.Amount==1,"partial transfer conserves remaining gram");
        Check(!CaelumInventoryService.TransferContainerItem(u,Store,wood,1,true),"same-stack excess gram rejected");
        Check(Near(Store.StorageWeight(u),100) && wood.Amount==1,"overweight rejection conserves all mass");
        Check(!CaelumInventoryService.CarryStorageChest(u,Store),"hidden storage component cannot become portable cargo");
        session.Close();
    }
    void AccessChecks(CaelumPlayer u)
    {
        if(!Find(u))return;AtDesk(u);Book=MakeBook(Store,0);let other=MakeBook(Store,3);let carried=MakeBook(u,6);
        CaelumRecipeSession.OpenLibrary(u,Desk);let reading=CaelumRecipeSession.Get(u);
        Check(reading.LibraryBooks.Size()==2,"picker excludes carried book and includes both stored originals");
        vector3 pos=Desk.Pos;Desk.SetOrigin(Shelf.Pos+(0,96,0),false);AtDesk(u);
        Check(CaelumStoredReading.Adjacent(Desk,Shelf),"96-unit inclusive boundary retains line of sight");
        Desk.SetOrigin(pos,false);AtDesk(u);
        CaelumRecipeSession.OpenStoredBook(u,Book,Desk);reading.Start();double before=reading.RemainingSeconds;
        u.SetOrigin((0,0,0),false);reading.Advance();
        Check(!CaelumStoredReading.Access(u,Desk,Store) && Near(before,reading.RemainingSeconds),"leaving desk pauses the actual task");
        AtDesk(u);Book.Owner.RemoveInventory(Book);Book.AttachToOwner(u);reading.Advance();
        Check(!reading.Active && !reading.Open && Book.Owner==u,"another withdrawal invalidates the source without duplicating book");
        carried.Destroy();Book.Destroy();
        Check(CaelumRecipeSession.OpenStoredBook(u,other,Desk) && reading.Start(),"second independently stored book can be read");
        Check(other.Sheets[3] && !other.Sheets[0],"book contents never merged by the picker");
        other.Destroy();reading.Advance();
        Check(!reading.Active && !reading.Open,"destroyed book cannot complete learning");
        AtDesk(u);CaelumRecipeSession.OpenLibrary(u,Desk);
        Check(reading.LibraryBooks.Size()==0 && !reading.Start(),"empty accessible bookcase does not grant recipes");
    }
    void Seed(CaelumPlayer u)
    {
        if(!Find(u))return;AtDesk(u);Book=MakeBook(Store,0);
        Check(CaelumRecipeSession.OpenStoredBook(u,Book,Desk),"seed stored reading");
        let reading=CaelumRecipeSession.Get(u);Check(reading.Start(),"seed actual reading task");
        reading.RemainingSeconds=321.75;reading.Open=false;SavedRemaining=reading.RemainingSeconds;
    }
    void Resume(CaelumPlayer u,bool hub)
    {
        if(!Find(u))return;Book=CaelumRecipeBook(Store.FindInventory('CaelumRecipeBook'));AtDesk(u);
        Check(Book!=null && Book.Owner==Store && Book.Sheets[0],"saved native book and pages remain in same shelf");
        let reading=CaelumRecipeSession.Get(u);
        if(hub)Check(reading!=null && reading.Book==null && reading.StoredSource==null && !reading.Active,"hub travel releases map-local reading references");
        else Check(reading!=null && reading.Book==Book && reading.StoredSource==Store && Near(reading.RemainingSeconds,321.75),"saved partial reading resumes exact progress");
        if(hub)
        {
            Check(Store.Readings.Size()==1,"absent reader progress remains with stored original");
            Check(CaelumRecipeSession.OpenStoredBook(u,Book,Desk) && reading.Active
                && Near(reading.RemainingSeconds,321.75) && Store.Readings.Size()==0,"return restores same reader progress exactly once");
        }
    }
    void View(CaelumPlayer u,int kind)
    {
        if(!Find(u))return;Book=MakeBook(Store,0);AtDesk(u);
        if(kind==1)CaelumRecipeSession.OpenLibrary(u,Desk);
        if(kind==2){AtShelf(u);CaelumContainerSession.Open(u,Store);}
    }
    void Migration(CaelumPlayer u)
    {
        if(!Find(u))return;
        let carried=CaelumRecipeBook(u.FindInventory('CaelumRecipeBook'));
        let reading=CaelumRecipeSession.Get(u);
        Check(carried!=null && carried.Sheets[0] && carried.Owner==u,"old carried book and pages migrate unchanged");
        Check(Store.StorageSlots()==0 && Shelf.LibraryRevision==CaelumStoredReadingData.REVISION,"old shelf receives one empty native storage owner");
        Check(reading!=null && reading.Book==carried && reading.StoredSource==null && reading.Active
            && Near(reading.RemainingSeconds,77.125),"legacy personal reading retains partial task");
        int count=0;let it=ThinkerIterator.Create('CaelumReadingDesk');while(it.Next()!=null)count++;
        Check(count==1,"legacy mansion adds exactly one desk");
    }
    void InputCheck(CaelumPlayer u,int phase)
    {
        let r=CaelumRecipeSession.Get(u);
        if(phase==0){Check(r!=null && r.Open && !r.BrowsingLibrary && r.Book!=null,"normal read action selects stored book");return;}
        Check(r!=null && r.Open && r.Active && r.Book.Owner==r.StoredSource,"normal read action begins original-book task");
        Check(r.TotalSeconds-r.RemainingSeconds>=.9,"native elapsed tics advance actual reading");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410rd_profile'){Profile(u);return;}
        if(e.Name=='ca410rd_core')Core(u);
        else if(e.Name=='ca410rd_limits')Limits(u);
        else if(e.Name=='ca410rd_access')AccessChecks(u);
        else if(e.Name=='ca410rd_seed')Seed(u);
        else if(e.Name=='ca410rd_resume')Resume(u,e.Args[0]!=0);
        else if(e.Name=='ca410rd_view')View(u,e.Args[0]);
        else if(e.Name=='ca410rd_migration')Migration(u);
        else if(e.Name=='ca410rd_input')InputCheck(u,e.Args[0]);
        else return;
        Console.Printf("CA410RD RESULT passed=%d failed=%d",Passed,Failed);
    }
}
