class CA410MealsChecks : CA410FoodChecks
{
    Array<CaelumConsumableItem> SavedMeals;
    Array<String> Readings;
    bool Gallery;
    double DigestionStart,DigestionExpected;
    CaelumConsumableItem Meal(CaelumPlayer u,int kind,int count,double contamination)
    {
        let item=CaelumConsumableItem(Actor.Spawn(CaelumMealData.ItemClass(kind),u.Pos,NO_REPLACE));
        item.Amount=count;item.AttachToOwner(u);
        let lots=CaelumFoodInventory.Prepare(item);lots.Lots[0].BaseContamination=contamination;return item;
    }
    void MealCore(CaelumPlayer u)
    {
        Setup(u);
        for(int kind=21;kind<=24;kind++)
        {
            let item=Meal(u,kind,5,20);CaelumFoodIllness.Get(u).Contamination=0;
            Check(item.GetConsumableType()==kind && Near(item.GetUnitWeight(),0.1),"distinct prepared meal is a 100g native portion");
            Check(CaelumFoodInventory.Kind(item)==CaelumMealData.FoodKind(kind),"prepared meal keeps its own spoilage kind");
            let size=TexMan.GetScaledSize(item.Icon);Check(item.Icon.IsValid() && size.X==128,"prepared meal selects a registered 128px sprite");
            Check(CaelumFoodData.ServingGrams(item.FoodLots.Kind)==100,"prepared meal serving mass stays separate from the 200g ration");
            u.CurrentHunger=100;Check(u.UseInventory(item) && item.Amount==4 && item.FoodLots.Units()==4,"native meal consumes one full portion at full Hunger");
            Check(Near(CaelumFoodIllness.Value(u),20*80/u.DerivedStats.BaseMass),"prepared meal intake uses its full 100g contamination dose");
            double kcal=kind==21?268:kind==22?230:kind==23?110:80;
            let power=CaelumHungerRegeneration(u.FindInventory('CaelumHungerRegeneration'));
            Check(power!=null && Near(power.FoodRecoveryPerPulse,kcal/240*800/u.DerivedStats.BaseMass/10),"prepared meal configures its approved distinct nutrition");
            item.InMagicBox=true;Check(!u.UseInventory(item) && item.Amount==4,"Box prevents prepared-meal consumption");
            Check(u.GetConsumableClassName(kind)==item.GetClassName(),"native consumable selector resolves the correct meal class");
            Check(CaelumEconomyRules.GetInventoryUnitBaseValue(item)>0,"prepared meal derives its commercial value from the approved recipe");
            item.Destroy();
        }
        Summary();
    }
    void MealForecast(CaelumPlayer u)
    {
        Setup(u);
        for(int kind=21;kind<=24;kind++)
        {
            let item=Meal(u,kind,5,30);double kcal=kind==21?268:kind==22?230:kind==23?110:80;
            let model=new('CaelumJourneyModel');model.Capture(u,false);model.Hunger=0;model.Thirst=0;
            double before=model.FoodIllness.Contamination;model.BeginServings();
            Check(model.FoodStock==5 && model.FoodSpent==1 && Near(model.FoodPulse,kcal/240*800/model.Mass/10),"journey eats a prepared meal using its own nutrition");
            Check(Near(model.FoodIllness.Contamination-before,30*80/model.Mass),"journey applies the prepared meal 100g dose");
            Check(item.Amount==5 && item.FoodLots.Units()==5,"journey preview leaves native prepared meals untouched");
            let waterModel=new('CaelumJourneyModel');waterModel.Capture(u,false);waterModel.Hunger=100;waterModel.Thirst=0;waterModel.WaterStock=1;waterModel.BeginServings();
            model.FoodEffectTics=1;model.WaterStock=1;model.WaterEffectTics=0;model.BeginServings();
            Check(Near(model.WaterPulse,waterModel.WaterPulse),"meal nutrition does not change the existing journey water dose");
            let row=new('CaelumSkipSupply');row.Capture(item);
            let waitModel=new('CaelumTimeSkipModel');waitModel.Mass=model.Mass;waitModel.FoodIllness=new('CaelumFoodIllness');waitModel.FoodIllness.Ensure();
            waitModel.Hunger=0;waitModel.Thirst=100;waitModel.FoodTrigger=100;waitModel.Supplies.Push(row);waitModel.ServeSupplies();
            Check(row.Count==4 && Near(waitModel.FoodPulse,kcal/240*800/model.Mass/10),"calendar wait predicts the same prepared-meal nutrition");
            Check(Near(waitModel.FoodIllness.Contamination,30*80/model.Mass),"calendar wait predicts the same 100g contamination dose");
            Check(item.Amount==5 && row.FoodLots!=item.FoodLots,"calendar forecast keeps an independent lot ledger");
            model.FoodInventory.Commit(u);Check(item.Amount==4 && item.FoodLots.Units()==4,"journey commits prepared-meal consumption exactly once");
            item.Destroy();
        }
        Summary();
    }
    void MealTransfers(CaelumPlayer u)
    {
        Setup(u);SavedMeals.Clear();
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(64,0,0),NO_REPLACE));
        chest.ChestUnlocked=true;chest.ChestOpen=true;chest.EnsureStorage();
        let session=CaelumContainerSession.Get(u,true);session.Chest=chest;SavedChest=chest;
        for(int kind=21;kind<=24;kind++)
        {
            let item=Meal(u,kind,5,30);item.FoodLots.Lots[0].CreatedStamp=-100;
            let fresh=CaelumConsumableItem(Actor.Spawn(CaelumMealData.ItemClass(kind),u.Pos+(300,300,0),NO_REPLACE));fresh.Amount=2;
            Check(item.HandlePickup(fresh) && item.Amount==7 && item.FoodLots.Lots.Size()==2,"native meal merge keeps old and fresh lots separate");
            Check(CaelumInventoryService.TransferContainerItem(u,chest,item,2,true),"prepared meal deposits through the real coffer service");
            let stored=CaelumConsumableItem(chest.FindInventory(CaelumMealData.ItemClass(kind)));
            Check(stored!=null && stored.Amount==2 && stored.FoodLots.Units()==2 && stored.FoodLots!=item.FoodLots,"prepared meal coffer split conserves quantity and independent lots");
            Check(Near(item.FoodLots.OldestContamination(),30) && stored!=null && Near(stored.FoodLots.OldestContamination(),30),"coffer transfer preserves the original contamination");
            Check(!CaelumFoodInventory.CanSell(item),"contaminated prepared meals cannot be laundered by resale");
            SavedMeals.Push(item);
        }
        u.CurrentHunger=100;session.Close();Summary();
    }
    void MealLoaded(CaelumPlayer u,bool fromHub=false)
    {
        Check(SavedMeals.Size()==4 && SavedChest!=null,"save or hub restores the four distinct prepared meals and coffer");
        for(int i=0;i<SavedMeals.Size();i++)
        {
            let item=fromHub?CaelumConsumableItem(u.FindInventory(CaelumMealData.ItemClass(21+i))):SavedMeals[i];
            let stored=CaelumConsumableItem(SavedChest.FindInventory(CaelumMealData.ItemClass(21+i)));
            Console.Printf("CA410M SAVED kind=%d count=%d lots=%d stored=%d",21+i,item!=null?item.Amount:-1,item!=null && item.FoodLots!=null?item.FoodLots.Units():-1,stored!=null?stored.Amount:-1);
            Check(item!=null && item.Owner==u && item.Amount==5 && item.GetConsumableType()==21+i,"native meal identity and owned portions survive serialization");
            if(item==null || stored==null){Check(false,"serialized meal/coffer references must exist");continue;}
            CaelumFoodInventory.Reconcile(item);CaelumFoodInventory.Reconcile(stored);
            Check(item.FoodLots.Units()==5 && item.FoodLots.Lots.Size()==2 && stored.Amount==2,"serialization preserves both oldest and fresh lots");
            Check(item.FoodLots.OldestContamination()>=30 && stored.FoodLots.OldestContamination()>=30,"serialization never rejuvenates prepared food");
            Check(item.FoodClock!=null && item.FoodClock.Item==item && stored.FoodClock.Item==stored,"loaded meal clocks keep the original inventory bindings");
            if(fromHub)Check(stored.FoodLots.OldestContamination()>30.5,"unloaded prepared meal coffer ages at its saved location climate");
        }
        Summary();
    }
    void MealMixed(CaelumPlayer u)
    {
        Setup(u);
        let raw=CaelumMaterialPickup(u.CreateDetachedMaterialStack(109,1,500));raw.AttachToOwner(u);
        CaelumFoodInventory.Prepare(raw).Lots[0].CreatedStamp=-300;
        let bread=Meal(u,21,1,20);bread.FoodLots.Lots[0].CreatedStamp=-200;
        let fish=Meal(u,23,1,40);fish.FoodLots.Lots[0].CreatedStamp=-100;
        let ration=Food(2,10,u);ration.FoodLots.Lots[0].CreatedStamp=-50;
        let model=new('CaelumJourneyModel');model.Capture(u,false);model.Hunger=0;model.Thirst=100;
        Check(model.FoodStock==4,"journey counts prepared portions and excludes raw grams");
        model.BeginServings();Check(Near(model.FoodPulse,268.0/240*800/model.Mass/10),"mixed journey consumes oldest bread before fish and ration");
        model.FoodEffectTics=0;model.BeginServings();Check(Near(model.FoodPulse,110.0/240*800/model.Mass/10),"mixed journey changes nutrition for the next fish portion");
        model.FoodEffectTics=0;model.BeginServings();Check(Near(model.FoodPulse,CaelumFoodRules.ServingHunger(CaelumFoodData.RATION,model.Mass)/10),"mixed journey returns to legacy ration nutrition");
        model.FoodInventory.Commit(u);
        Check(raw.Amount==500 && ration.Amount==1 && u.FindInventory('CaelumBread')==null && u.FindInventory('CaelumRoastFish')==null,"mixed commit spends only the chosen prepared portions");
        Summary();
    }
    void MealDigest(CaelumPlayer u,int kind,bool finish=false)
    {
        if(!finish)
        {
            Setup(u);u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentAnima=u.DerivedStats.MaximumAnima;
            DigestionStart=u.CurrentHunger;DigestionExpected=0;
            if(kind>=21)
            {
                let item=Meal(u,kind,1,0);DigestionExpected=CaelumFoodRules.ServingHunger(CaelumMealData.FoodKind(kind),u.DerivedStats.BaseMass);
                Check(u.UseInventory(item),"native prepared meal begins its timed digestion");
            }
        }
        else
        {
            Console.Printf("CA410M DIGESTION actual=%.8f expected=%.8f",u.CurrentHunger-DigestionStart,DigestionExpected);
            Check(u.FindInventory('CaelumHungerRegeneration')==null,"prepared meal digestion finishes after its native ten pulses");Summary();
        }
    }
    void MealServices(CaelumPlayer u)
    {
        Setup(u);let table=CaelumDiningTable(Actor.Spawn('CA410MealsTable',u.Pos+(64,0,0),NO_REPLACE));
        for(int kind=21;kind<=24;kind++)
        {
            let item=Meal(u,kind,3,19);
            Check(table.PlaceItem(u,false) && item.Amount==2,"real dining table accepts one prepared portion");
            let placed=table.Items[0];let visual=table.Displays[0];
            Check(placed!=null && placed.GetConsumableType()==kind && placed.FoodLots.Units()==1,"table stores the real meal with one lot unit");
            String spawnSprite=kind==21?"FBRD":kind==22?"FRBF":kind==23?"FRFS":"FPCH";
            Console.Printf("CA410M TABLE kind=%d display=%d carried=%d default=%d wanted=%d",kind,
                visual!=null?visual.Sprite:-1,item.Sprite,GetDefaultByType(item.GetClass()).Sprite,Actor.GetSpriteIndex(spawnSprite));
            Check(visual!=null && visual.GetClass()==CaelumMealData.TableDisplay(kind)
                && visual.Sprite==Actor.GetSpriteIndex(spawnSprite)
                && visual.Sprite!=Actor.GetSpriteIndex("TNT1") && visual.Scale==item.Scale,"table selects visible meal spawn art instead of the hidden carried-item state");
            Check(table.Withdraw(u,false) && item.Amount==3 && item.FoodLots.Units()==3 && table.Items[0]==null,"table withdrawal preserves portions without adding or consuming food");
            u.OnNativeInventoryChanged();u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
            for(int i=0;i<u.FormalInventoryEntryCount;i++)
                if(u.GetFormalInventoryEntryAt(i)==item){u.FormalInventorySelectionIndex=i;break;}
            u.RefreshFormalInventorySnapshot();u.ActivateFormalInventorySelection();
            Check(item.Amount==2 && item.FoodLots.Units()==2,"native journal activation consumes exactly one prepared portion");
            item.Destroy();
        }
        let shop=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',u.Pos+(300,0,0),NO_REPLACE));shop.Category=0;shop.EnsureStock(u);
        bool invented=false;
        for(Inventory it=shop.Inv;it!=null;it=it.Inv)
        {let item=CaelumConsumableItem(it);if(item!=null && CaelumMealData.IsMeal(item.GetConsumableType()))invented=true;}
        for(int i=0;i<shop.Products.Size();i++)
            for(int kind=21;kind<=24;kind++)if(shop.Products[i].NativeClass==CaelumMealData.ItemClass(kind))invented=true;
        Check(!invented,"adding consumable IDs does not invent unapproved shop stocks for prepared meals");
        Summary();
    }
    void ReadMeals(CaelumPlayer u)
    {
        Readings.Clear();
        for(int kind=21;kind<=24;kind++)
        {
            let item=CaelumConsumableItem(u.FindInventory(CaelumMealData.ItemClass(kind)));if(item==null)continue;
            CaelumFoodInventory.Reconcile(item);
            String line=String.Format("%s: %d x100g | C %.2f | %.0f kcal/100g",StringTable.Localize(CaelumMealData.NameKey(kind),false),
                item.Amount,item.FoodLots.OldestContamination(),CaelumFoodData.PortionKcal(item.FoodLots.Kind));
            Readings.Push(line);Console.Printf("CA410M %s",line);
        }
        String body=String.Format("Cuerpo C %.2f | Hambre %.2f",CaelumFoodIllness.Value(u),u.CurrentHunger);
        Readings.Push(body);Console.Printf("CA410M %s",body);
    }
    void ManualMeals(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=90;Gallery=true;CaelumFoodIllness.Get(u).Contamination=0;
        for(int kind=21;kind<=24;kind++)
        {let old=u.FindInventory(CaelumMealData.ItemClass(kind));if(old!=null)old.Destroy();Meal(u,kind,5,0);}
        u.OnNativeInventoryChanged();u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)
            if(u.GetFormalInventoryEntryAt(i)==u.FindInventory('CaelumBread')){u.FormalInventorySelectionIndex=i;break;}
        u.RefreshFormalInventorySnapshot();ReadMeals(u);Summary();
    }
    void TableView(CaelumPlayer u)
    {
        Setup(u);Gallery=false;u.CurrentHunger=100;u.Angle=0;u.Pitch=10;
        let table=CaelumDiningTable(Actor.Spawn('CA410MealsTable',u.Pos+(100,0,0),NO_REPLACE));
        for(int kind=21;kind<=24;kind++)
        {
            let item=CaelumConsumableItem(Actor.Spawn(CaelumMealData.ItemClass(kind),table.Pos,NO_REPLACE));
            item.AttachToOwner(table);table.Items[kind-21]=item;
        }
        table.RefreshDisplays();Summary();
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Gallery)return;
        let f=Font.GetFont('CaelumMono');Screen.Dim(0x181512,.88,0,0,Screen.GetWidth(),int(Screen.GetHeight()*.68));
        Screen.DrawText(f,Font.CR_GOLD,12,8,"#410 - Platos: sprites, nutricion y conservacion",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        for(int i=0;i<4;i++)
        {
            let texture=TexMan.CheckForTexture(CaelumMealData.Icon(21+i),TexMan.Type_MiscPatch);let size=TexMan.GetScaledSize(texture);
            if(texture.IsValid() && size.X>0)Screen.DrawTexture(texture,false,25+i*154,27,DTA_DestWidth,90,DTA_DestHeight,90,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        }
        for(int i=0;i<Readings.Size();i++)Screen.DrawText(f,Font.CR_WHITE,12,120+i*15,Readings[i],DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_GOLD,12,218,"F1 reiniciar | F2 leer | F3 comer pan | F4 envejecer 6h",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,12,234,"T inventario; F5 oculta/muestra. Elaboracion aun pendiente.",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
    void Summary(){Console.Printf("CA410M RESULT passed=%d failed=%d",Passed,Failed);}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410m_core')MealCore(u);
        else if(e.Name=='ca410m_forecast')MealForecast(u);
        else if(e.Name=='ca410m_mixed')MealMixed(u);
        else if(e.Name=='ca410m_services')MealServices(u);
        else if(e.Name=='ca410m_seed')MealTransfers(u);
        else if(e.Name=='ca410m_load')MealLoaded(u);
        else if(e.Name=='ca410m_hubreturn')MealLoaded(u,true);
        else if(e.Name=='ca410m_digest')MealDigest(u,e.Args[0]);
        else if(e.Name=='ca410m_digested')MealDigest(u,0,true);
        else if(e.Name=='ca410m_manual')ManualMeals(u);
        else if(e.Name=='ca410m_tableview')TableView(u);
        else if(e.Name=='ca410m_read')ReadMeals(u);
        else if(e.Name=='ca410m_view')Gallery=!Gallery;
        else if(e.Name=='ca410m_eat'){let item=u.FindInventory('CaelumBread');if(item!=null)u.UseInventory(item);u.RefreshFormalInventorySnapshot();ReadMeals(u);}
        else if(e.Name=='ca410m_age')
        {
            for(int kind=21;kind<=24;kind++)
            {let item=CaelumConsumableItem(u.FindInventory(CaelumMealData.ItemClass(kind)));if(item!=null){CaelumFoodInventory.Reconcile(item);item.FoodLots.Advance(21600,20,50);}}
            u.RefreshFormalInventorySnapshot();ReadMeals(u);
        }
        else Super.NetworkProcess(e);
    }
}
class CA410MealsTable : CaelumDiningTableSmall
{
    override int ForecastDailyTarget(){return 0;}
}
class CA410MealsMenu : CaelumLiveMenu
{
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_KeyDown)
        {
            String command="";
            if(e.KeyChar==UIEvent.Key_F1)command="ca410m_manual";
            else if(e.KeyChar==UIEvent.Key_F2)command="ca410m_read";
            else if(e.KeyChar==UIEvent.Key_F3)command="ca410m_eat";
            else if(e.KeyChar==UIEvent.Key_F4)command="ca410m_age";
            else if(e.KeyChar==UIEvent.Key_F5)command="ca410m_view";
            if(command.Length()>0){EventHandler.SendNetworkEvent(command);return true;}
        }
        return Super.OnUIEvent(e);
    }
}
