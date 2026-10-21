// La tarea de lectura conserva su duración al iniciarse y pausa al cerrar.
class CaelumRecipeSession : Inventory
{
    CaelumRecipeBook Book;
    Actor Anchor;
    bool Open, Active, Rereading;
    int Filter, Selection, TaskSlot;
    double PreviewSeconds, TotalSeconds, RemainingSeconds;
    int ReadingCount, PracticeCount, PracticeCap;
    double Efficiency50, Efficiency100, BookWeight;
    Array<int> Rows, TaskSheets;
    Array<String> Labels;
    String Status;

    static CaelumRecipeSession Get(CaelumPlayer user, bool create=false)
    {
        if(user==null)return null;
        let session=CaelumRecipeSession(user.FindInventory("CaelumRecipeSession"));
        if(session==null && create)
        {
            session=CaelumRecipeSession(Actor.Spawn("CaelumRecipeSession",user.Pos,NO_REPLACE));
            if(session!=null)session.AttachToOwner(user);
        }
        return session;
    }

    static bool OpenBook(CaelumPlayer user, CaelumRecipeBook book)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || book==null || book.Owner!=user
            || (book.InMagicBox && !user.MagicBoxOwned) || user.HasActiveConversation())return false;
        let session=Get(user,true);if(session==null)return false;
        if(session.Active && session.Book!=book)
        {
            if(session.Book!=null && session.Book.Owner==user)return false;
            session.Active=false;session.Anchor=null;session.TaskSheets.Clear();
        }
        user.EquipmentMenuOpen=false;
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
        user.ClosePalomoMerchant();
        let chest=CaelumContainerSession.Get(user);if(chest!=null)chest.Close();
        session.Book=book;session.Open=true;
        if(user.CraftingTaskActive)session.Status="CA_RECIPE_CRAFT_BUSY";
        session.Refresh();return true;
    }

    static bool Working(CaelumPlayer user)
    {
        let session=Get(user);
        return session!=null && !user.CraftingTaskActive && session.Open && session.Active && session.Book!=null
            && session.Book.Owner==user && CanReach(user,session.Anchor);
    }

    void Refresh()
    {
        Rows.Clear();Labels.Clear();PreviewSeconds=0;
        ReadingCount=0;PracticeCount=0;PracticeCap=0;Efficiency50=10;Efficiency100=100;
        let user=CaelumPlayer(Owner);
        if(user==null || Book==null || Book.Owner!=user){Open=false;return;}
        let record=user.GetPersistentCharacterState(false);
        BookWeight=Book.GetUnitWeight();
        for(int slot=0;slot<CaelumRecipeLearning.SLOT_COUNT;slot++)
        {
            if(!Book.Sheets[slot])continue;
            int recipe=slot/CaelumRecipeLearning.TIERS,tier=slot%CaelumRecipeLearning.TIERS+1;
            if(!CaelumCraftingRules.RecipeMatchesFilter(recipe,Filter))continue;
            Rows.Push(slot);
            String state=StringTable.Localize(record!=null && record.KnowsCraftingRecipe(recipe,tier)
                ? "CA_RECIPE_KNOWN" : "CA_RECIPE_UNREAD",false);
            Labels.Push(String.Format("%s  /  T%d  /  %s",CaelumCraftingBrowser.RecipeName(recipe,tier),tier,state));
        }
        Selection=Clamp(Selection,0,Max(0,int(Rows.Size())-1));
        if(Rows.Size()>0)
        {
            int slot=Rows[Selection];
            let quote=new("CaelumRecipeQuote");quote.Build(user,slot/3,slot%3+1);
            double intelligence=user.Attributes==null ? 0 : user.Attributes.Intelligence;
            PreviewSeconds=quote.Seconds/Max(1.0,CaelumGrowthRules.Multiplier(intelligence,3));
            ReadingCount=record.RecipeRereadings[slot];PracticeCount=record.RecipePractice[slot];
            PracticeCap=CaelumRecipeLearning.PracticeLimit(slot/3);
            Efficiency50=CaelumRecipeLearning.TimeFactor(ReadingCount,PracticeCount,slot/3,1);
            Efficiency100=CaelumRecipeLearning.TimeFactor(ReadingCount,PracticeCount,slot/3,2);
        }
    }

    static bool CanReach(CaelumPlayer user,Actor station)
    {
        return user!=null && station!=null && (station is "CaelumDiningTable" || station is "CaelumReadingShelf")
            && user.Distance2D(station)<=CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE+station.Radius
            && Abs(user.Pos.Z-station.Pos.Z)<64 && user.CheckSight(station);
    }

    static Actor FindStation(CaelumPlayer user)
    {
        let nearby=BlockThingsIterator.Create(user,CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE+128);
        while(nearby.Next())if(CanReach(user,nearby.thing))return nearby.thing;
        return null;
    }

    bool Start()
    {
        let user=CaelumPlayer(Owner);
        if(!Open || Book==null || Book.Owner!=user || Rows.Size()==0)return false;
        if(user.CraftingTaskActive){Status="CA_RECIPE_CRAFT_BUSY";return false;}
        let station=FindStation(user);
        if(station==null){Status="CA_RECIPE_NEEDS_STATION";return false;}
        int slot=Rows[Selection];
        if(Active)
        {
            if(slot!=TaskSlot){Status="CA_RECIPE_CANCEL_FIRST";return false;}
            Anchor=station;Status="CA_RECIPE_READING";return true;
        }
        let quote=new("CaelumRecipeQuote");quote.Build(user,slot/3,slot%3+1);
        double intelligence=user.Attributes==null ? 0 : user.Attributes.Intelligence;
        double seconds=quote.Seconds/Max(1.0,CaelumGrowthRules.Multiplier(intelligence,3));
        if(seconds<=0)return false;
        TaskSheets.Clear();
        for(int i=0;i<quote.Sheets.Size();i++)TaskSheets.Push(quote.Sheets[i]);
        let record=user.GetPersistentCharacterState(true);
        Rereading=record.KnowsCraftingRecipe(slot/3,slot%3+1);
        TaskSlot=slot;Anchor=station;TotalSeconds=seconds;RemainingSeconds=seconds;
        Active=true;Status="CA_RECIPE_READING";return true;
    }

    void Complete()
    {
        let user=CaelumPlayer(Owner);
        if(!Active || RemainingSeconds>0 || user==null || Book==null || Book.Owner!=user || !Book.Sheets[TaskSlot])return;
        Active=false;Anchor=null;
        let record=user.GetPersistentCharacterState(true);
        if(Rereading)record.RecipeRereadings[TaskSlot]=Min(CaelumRecipeLearning.MAX_READINGS,record.RecipeRereadings[TaskSlot]+1);
        else for(int i=0;i<TaskSheets.Size();i++)record.LearnCraftingRecipe(TaskSheets[i]/3,TaskSheets[i]%3+1);
        TaskSheets.Clear();Status=Rereading ? "CA_RECIPE_REVIEWED" : "CA_RECIPE_LEARNED";
        user.RefreshCraftingRecipeBookSummary();user.PersistCharacterState();Refresh();
    }

    override void Tick()
    {
        Super.Tick();
        Advance();
    }

    void Advance()
    {
        let user=CaelumPlayer(Owner);
        if(user==null || Book==null || Book.Owner!=user)
        {Open=false;Active=false;Anchor=null;TaskSheets.Clear();return;}
        if(!Open || !Active || user.health<=0 || user.HasActiveConversation() || user.CraftingTaskActive
            || user.CraftingMenuOpen || user.EquipmentMenuOpen || user.PalomoMerchantMenuOpen
            || CaelumSleepRules.IsSleeping(user) || !CanReach(user,Anchor))return;
        RemainingSeconds=Max(0.0,RemainingSeconds-1.0/TICRATE);
        CaelumTimeSkipState.RecordWork(user);
        if(RemainingSeconds<=0)Complete();
    }

    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}

class CaelumReadingShelf : Actor
{
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || !CaelumUseGeometry.AimedAt(user,self) || !CaelumRecipeSession.CanReach(user,self))return false;
        let book=CaelumRecipeBook(user.FindInventory("CaelumRecipeBook"));
        if(book==null){CaelumNotifications.Notify(user,StringTable.Localize("CA_RECIPE_NO_BOOK",false));return true;}
        return CaelumRecipeSession.OpenBook(user,book);
    }
    Default
    {
        Radius CaelumReadingFurnitureData.RADIUS;
        Height CaelumReadingFurnitureData.HEIGHT;
        +SOLID
        +USESPECIAL
        Tag "$CA_RECIPE_SHELF";
    }
    States { Spawn: CBOO A -1; Stop; }
}

class CaelumRecipeEvents : StaticEventHandler
{
    static ui bool Key(CaelumPlayer user,int type,int scan,String key)
    {
        let session=user==null ? null : CaelumRecipeSession(user.FindInventory("CaelumRecipeSession"));
        if(session==null || !session.Open || type!=InputEvent.Type_KeyDown || scan==InputEvent.Key_Grave)return false;
        if(scan==InputEvent.Key_UpArrow)EventHandler.SendNetworkEvent("ca_recipe_move",-1);
        else if(scan==InputEvent.Key_DownArrow)EventHandler.SendNetworkEvent("ca_recipe_move",1);
        else if(scan==InputEvent.Key_Enter || scan==InputEvent.Key_Pad_A)EventHandler.SendNetworkEvent("ca_recipe_read");
        else if(key~=="g")EventHandler.SendNetworkEvent("ca_recipe_filter");
        else if(key~=="c")EventHandler.SendNetworkEvent("ca_recipe_cancel");
        else if(key~=="t")EventHandler.SendNetworkEvent("ca_time_fast");
        else if(key~=="y" || CaelumInputHints.Matches(scan,"ca_time_skip"))EventHandler.SendNetworkEvent("ca_skip_open");
        else if(scan==InputEvent.Key_Tab || scan==InputEvent.Key_Pad_B || key~=="q")EventHandler.SendNetworkEvent("ca_recipe_close");
        return true;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_recipe_move" && e.Name!="ca_recipe_read" && e.Name!="ca_recipe_filter"
            && e.Name!="ca_recipe_cancel" && e.Name!="ca_recipe_close" && e.Name!="ca_recipe_select")return;
        if(e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let user=CaelumPlayer(players[e.Player].mo);
        let session=CaelumRecipeSession.Get(user);
        if(!CaelumPlayerAuthority.CanMutate(user) || session==null || !session.Open)return;
        if(e.Name=="ca_recipe_close"){session.Open=false;return;}
        if(e.Name=="ca_recipe_read"){session.Start();return;}
        if(e.Name=="ca_recipe_cancel")
        {session.Active=false;session.Anchor=null;session.TaskSheets.Clear();session.Status="CA_RECIPE_CANCELLED";return;}
        if(e.Name=="ca_recipe_filter")
        {session.Filter=(session.Filter+1)%CaelumConstants.CRAFTING_RECIPE_FILTER_COUNT;session.Selection=0;}
        else if(e.Name=="ca_recipe_select")session.Selection=Clamp(e.Args[0],0,Max(0,int(session.Rows.Size())-1));
        else if(session.Rows.Size()>0)
            session.Selection=(session.Selection+(e.Args[0]<0?-1:1)+session.Rows.Size())%session.Rows.Size();
        session.Refresh();
    }
    static ui void Draw(CaelumPlayer user)
    {
        let session=user==null?null:CaelumRecipeSession(user.FindInventory("CaelumRecipeSession"));
        if(session==null || !session.Open)return;
        let font=Font.GetFont("CaelumSmall");
        CaelumPresentation.MenuBackground(0x05070A,0.94);
        CaelumChestPreview.DrawLine(font,Font.CR_GOLD,32,String.Format("%s · %.3f kg",
            StringTable.Localize("CA_KEY_ITEM_RECIPE_BOOK",false),session.BookWeight));
        let journal=CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));
        CaelumChestPreview.DrawLine(font,Font.CR_WHITE,56,StringTable.Localize(journal.GetCraftingFilterKey(session.Filter),false));
        int first=Max(0,session.Selection-2);
        for(int i=first;i<Min(first+5,int(session.Labels.Size()));i++)
            CaelumChestPreview.DrawLine(font,i==session.Selection?Font.CR_GOLD:Font.CR_WHITE,82+(i-first)*21,session.Labels[i]);
        CaelumChestPreview.DrawLine(font,Font.CR_WHITE,200,String.Format(StringTable.Localize("CA_RECIPE_SECONDS",false),
            session.Active?session.RemainingSeconds:session.PreviewSeconds));
        CaelumChestPreview.DrawLine(font,Font.CR_WHITE,222,String.Format(StringTable.Localize("CA_RECIPE_PROGRESS",false),
            session.ReadingCount,session.PracticeCount,session.PracticeCap));
        CaelumChestPreview.DrawLine(font,Font.CR_WHITE,244,String.Format(StringTable.Localize("CA_RECIPE_FACTORS",false),
            session.Efficiency50,session.Efficiency100));
        if(session.Status!="")CaelumChestPreview.DrawLine(font,Font.CR_WHITE,265,StringTable.Localize(session.Status,false));
    }
}
