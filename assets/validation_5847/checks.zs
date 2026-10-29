class CA502StackProof : Inventory
{
    CaelumMaterialPickup Item;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502StackChecks : EventHandler
{
    int Passed,Failed;
    CaelumMaterialPickup GroundItem;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502S %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.0000001;}
    CaelumMaterialPickup Material(CaelumPlayer u,int count,int kind=20)
    {
        let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos+(128,128,0),NO_REPLACE));
        item.args[0]=kind;item.args[1]=1;item.Amount=count;item.UpdateMaterialVisuals();
        CaelumContaminationStack.Reconcile(item);return item;
    }
    void Core(CaelumPlayer u)
    {
        let a=Material(u,100);let b=Material(u,50);
        Check(Near(CaelumStackSurfaceData.UnitArea(a),0.000483597586204941),"one gram approved sphere area");
        Check(CaelumContaminationStack.Prepare(a).Units()==100,"revision adopts native quantity");
        CaelumContaminationStorage.Set(a,80);CaelumContaminationStorage.Set(b,20);
        Check(CaelumContaminationStack.Transfer(a,b,40,false),"mixed concentrations transfer");
        a.Amount-=40;b.Amount+=40;
        let lots=CaelumContaminationStack.Prepare(b);
        Check(lots.Lots.Size()==2 && lots.Units()==90,"mixed pile preserves two lots and real quantity");
        Check(Near(lots.Contamination(0),20) && Near(lots.Contamination(1),80),"same timestamp retains separate concentrations");
        let c=Material(u,1);Check(CaelumContaminationStack.Transfer(b,c,60,true),"split crosses lot boundary");
        b.Amount-=60;c.Amount=60;
        Check(CaelumContaminationStack.Prepare(c).Lots[0].Units==50 && CaelumContaminationStack.Prepare(c).Lots[1].Units==10,"split transfers exact FIFO units");
        Check(CaelumContaminationStack.Prepare(b).Units()==30 && Near(CaelumContaminationStack.Value(b),80),"remaining lot never diluted");
        Check(Near((a.Amount+b.Amount+c.Amount)*CaelumStackSurfaceData.UnitArea(a),150*CaelumStackSurfaceData.UnitArea(a)),"area additive across split");
        Check(!CaelumContaminationStack.Transfer(b,c,31,false),"overdraw rejected");
        Check(CaelumContaminationStack.Prepare(b).Units()==30 && CaelumContaminationStack.Prepare(c).Units()==60,"failed transfer atomic");
        let clone=CaelumContaminationStack.Prepare(c).Copy();
        CaelumContaminationStack.Expose(clone,100,CaelumStackSurfaceData.UnitArea(c),0,0,3600);
        Check(Near(CaelumContaminationStack.Prepare(c).Contamination(0),20),"forecast never aliases real lots");
        a.Destroy();b.Destroy();c.Destroy();
    }
    void PickupChecks(CaelumPlayer u)
    {
        Actor holder=u;
        let a=Material(u,100);a.AttachToOwner(holder);CaelumContaminationStorage.Set(a,80);
        let b=Material(u,50);CaelumContaminationStorage.Set(b,20);
        Actor receiver=holder;bool picked=b.CallTryPickup(receiver);
        Check(picked && a.Amount==150,"native pickup merges actual quantity");
        Check(CaelumContaminationStack.Prepare(a).Units()==150 && CaelumContaminationStack.Prepare(a).Lots.Size()==2,"native pickup retains heterogeneous lots");
        let dropped=a.CreateTossable(120);
        Check(dropped!=null && dropped.Amount==120 && a.Amount==30,"native toss splits actual quantity");
        Check(CaelumContaminationStack.Prepare(dropped).Lots.Size()==2 && Near(CaelumContaminationStack.Prepare(dropped).Contamination(0),80),"native toss retains oldest contamination");
        Check(Near(CaelumContaminationStack.Value(a),20),"native remainder retains newer lot");
        if(dropped!=null)dropped.Destroy();a.Destroy();
    }
    CaelumThermalState Climate()
    {
        let t=new('CaelumThermalState');t.Initialize();t.Available=true;t.BodyMassKg=80;t.SurfaceArea=2;
        for(int i=0;i<4;i++)t.Coverage[i]=.25;
        return t;
    }
    void Exposure(CaelumPlayer u)
    {
        let a=Material(u,100);a.AttachToOwner(u);CaelumContaminationStorage.Set(a,20);
        let f=new('CaelumContaminationExposure');f.Capture(u,Climate());
        let illness=new('CaelumFoodIllness');f.Advance(illness,80,1000);
        double expected=CaelumContaminationRules.AfterContact(20,80,CaelumStackSurfaceData.UnitArea(a),1000);
        Check(Near(CaelumContaminationStack.Value(a),20),"independent carried preview leaves source unchanged");
        f.Commit(u);Check(Near(CaelumContaminationStack.Value(a),expected),"actual carried commit uses one unit area");
        CaelumContaminationStorage.Set(a,20);a.Amount=10;CaelumContaminationStack.Reconcile(a);
        f.Capture(u,Climate());f.Advance(illness,80,1000);f.Commit(u);
        Check(Near(CaelumContaminationStack.Value(a),expected),"per-unit exposure independent of pile size");
        a.InMagicBox=true;f.Capture(u,Climate());f.Advance(illness,100,1000);f.Commit(u);
        Check(Near(CaelumContaminationStack.Value(a),expected),"Box shields carried stack");
        a.InMagicBox=false;CaelumContaminationStorage.Set(a,20);
        let t=Climate();for(int i=0;i<4;i++){t.SubmergedCoverage[i]=.25;t.DirtyWaterCoverage[i]=.25;}
        f.Capture(u,t);f.Advance(illness,0,1000);f.Commit(u);
        Check(Near(CaelumContaminationStack.Value(a),CaelumContaminationRules.AfterContact(20,100,CaelumStackSurfaceData.UnitArea(a),1000)),"submerged loose stack receives dirty water");
        a.Destroy();
    }
    void Contact(CaelumPlayer u)
    {
        let a=Material(u,100);let b=Material(u,100);
        CaelumContaminationStorage.Set(a,80);CaelumContaminationStorage.Set(b,20);
        double area=CaelumStackSurfaceData.UnitArea(a)*100;
        CaelumContaminationStorage.Touch(a,b,area,10);
        Check(Near(CaelumContaminationStack.Value(a),80),"source retains concentration");
        Check(Near(CaelumContaminationStack.Value(b),CaelumContaminationRules.AfterContact(20,80,area/100,10)),"stack contact distributes total touched area per unit");
        b.InMagicBox=true;double old=CaelumContaminationStack.Value(b);CaelumContaminationStorage.Touch(a,b,area,100);
        Check(Near(CaelumContaminationStack.Value(b),old),"protected stack rejects contact");
        b.InMagicBox=false;CaelumContaminationStorage.Set(b,80);CaelumContaminationStorage.Touch(a,b,area,100);
        Check(Near(CaelumContaminationStack.Value(b),80),"equal concentration no transfer");
        a.Destroy();b.Destroy();
    }
    void Storage(CaelumPlayer u)
    {
        let a=Material(u,100);a.AttachToOwner(u);CaelumContaminationStorage.Set(a,72);
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(64,0,0)));
        chest.args[4]=3;chest.EnsureStorage();chest.GrantLawfulTitle(u);CaelumContainerSession.Open(u,chest);
        u.DerivedStats.CarryCapacity=10000;
        Check(CaelumInventoryService.TransferContainerItem(u,chest,a,35,true),"actual partial deposit succeeds");
        let stored=CaelumContainerRules.MatchingStack(chest,a);
        Check(stored!=null && stored.Amount==35 && Near(CaelumContaminationStack.Value(stored),72),"container split retains concentration and units");
        Check(a.Amount==65 && CaelumContaminationStack.Prepare(a).Units()==65,"deposit retains source identity and quantity");
        CaelumContaminationStorage.Set(a,15);
        Check(CaelumInventoryService.TransferContainerItem(u,chest,stored,10,false),"actual partial withdrawal succeeds");
        Check(a.Amount==75 && CaelumContaminationStack.Prepare(a).Lots.Size()==2,"withdrawal retains heterogeneous destination lots");
        Check(stored.Amount==25 && Near(CaelumContaminationStack.Value(stored),72),"withdrawal does not dilute remainder");
        CaelumContainerSession.Get(u).Close();CaelumContaminationStack.Clock(stored).Sync();
        Check(CaelumContaminationStack.Clock(stored).HistoryArea==0,"closed chest suspends ambient exposure");
        u.ClearFormalInventoryRow(0);u.FillFormalInventoryRow(0,a);
        Check(u.FormalInventoryRowFoodLots[0]==2 && Near(u.FormalInventoryRowFoodContamination[0],15),"ordinary inventory displays oldest contamination and lot count");
        a.Destroy();stored.Destroy();chest.Destroy();
    }
    void Ground(CaelumPlayer u)
    {
        let item=Material(u,100);let node=CaelumContaminationStack.Clock(item);node.Sync();
        Check(node.HistoryReady && node.HistoryArea>0,"native source weather captured on ground");
        Check(Near(node.HistoryArea,CaelumStackSurfaceData.UnitArea(item)),"ground history uses unit surface");
        double ambient=node.HistoryAmbient,area=node.HistoryArea;
        node.HistoryStamp-=3600;CaelumContaminationStack.Reconcile(item);
        Check(CaelumContaminationStack.Value(item)>0,"saved source interval accumulates real ground exposure");
        double c=CaelumContaminationStack.Value(item);CaelumContaminationStack.Reconcile(item);
        Check(Near(CaelumContaminationStack.Value(item),c),"same historical interval cannot run twice");
        item.AttachToOwner(u);item.InMagicBox=true;node.Sync();
        Check(!node.HistoryReady,"pickup hands schedule to owner without duplicate history");
        item.Destroy();
    }
    void Seed(CaelumPlayer u)
    {
        let proof=CA502StackProof(u.GiveInventoryType('CA502StackProof'));
        let a=Material(u,50);a.AttachToOwner(u);CaelumContaminationStorage.Set(a,20);
        let b=Material(u,50);CaelumContaminationStorage.Set(b,80);
        CaelumContaminationStack.Transfer(b,a,50,false);a.Amount+=50;b.Destroy();
        a.InMagicBox=true;proof.Item=a;
        Check(a.Amount==100 && CaelumContaminationStack.Prepare(a).Lots.Size()==2,"current save seeds distinct real lots");
    }
    void Resume(CaelumPlayer u)
    {
        let proof=CA502StackProof(u.FindInventory('CA502StackProof'));
        Check(proof!=null && proof.Item!=null && proof.Item.Owner==u,"original native inventory identity restored");
        if(proof==null || proof.Item==null)return;
        let lots=CaelumContaminationStack.Prepare(proof.Item);
        Check(proof.Item.Amount==100 && lots.Units()==100 && lots.Lots.Size()==2,"save retains quantities and distinct lots");
        Check(Near(lots.Contamination(0),20) && Near(lots.Contamination(1),80),"save preserves both concentrations without averaging");
        Check(CaelumContaminationStack.Record(proof.Item).StackRevision==1,"stack migration revision persists");
    }
    void Upgrade(CaelumPlayer u)
    {
        let proof=CA502StackProof(u.FindInventory('CA502StackProof'));
        Check(proof!=null && proof.Item!=null && proof.Item.Amount==100,"actual previous runtime quantity retained");
        if(proof==null || proof.Item==null)return;
        CaelumContaminationStack.Reconcile(proof.Item);
        Check(CaelumContaminationStack.Prepare(proof.Item).Units()==100,"old native quantity adopted once");
        Check(Near(CaelumContaminationStack.Value(proof.Item),37),"old generic contact record adopted without resetting dirt");
        CaelumContaminationStack.Reconcile(proof.Item);
        Check(CaelumContaminationStack.Prepare(proof.Item).Units()==100 && Near(CaelumContaminationStack.Value(proof.Item),37),"migration idempotent");
    }
    void Performance(CaelumPlayer u)
    {
        let item=Material(u,1000000000);let lots=CaelumContaminationStack.Prepare(item);
        double area=CaelumStackSurfaceData.UnitArea(item),start=MSTimeF();
        for(int i=0;i<1000;i++)CaelumContaminationStack.Expose(lots,80,area,0,0,1);
        double elapsed=MSTimeF()-start;
        Check(lots.Lots.Size()==1 && lots.Units()==1000000000,"billion-unit pile remains one homogeneous lot");
        Check(Near(lots.Contamination(0),CaelumContaminationRules.AfterContact(0,80,area,1000)),"repeated exposure retains analytical result");
        Console.Printf("CA502S TIMING billion_units_1000_steps_ms=%.6f",elapsed);item.Destroy();
    }
    void Catalogue(CaelumPlayer u)
    {
        for(int id=0;id<CaelumConstants.MATERIAL_TYPE_COUNT;id++)
        {
            if(!CaelumStackSurfaceData.AbstractMaterial(id))continue;
            let a=Material(u,10,id);double area=CaelumStackSurfaceData.UnitArea(a);
            Check(area>0 && CaelumContaminationStack.Prepare(a).Units()==10,"abstract material uses own native unit mass");a.Destroy();
        }
        for(int size=0;size<3;size++)for(int family=0;family<3;family++)
        {
            int kind=CaelumPotionRules.Kind(family,size);
            let a=CaelumConsumableItem(Actor.Spawn(CaelumPotionRules.ItemClass(kind),u.Pos+(128,128,0)));
            a.Amount=3;a.AttachToOwner(u);CaelumContaminationStorage.Set(a,73);
            Check(CaelumContaminationStack.Eligible(a) && CaelumContaminationStack.Prepare(a).Units()==3,"prepared dose is tracked");
            let b=a.CreateTossable(1);
            Check(b!=null && a.Amount==2 && Near(CaelumContaminationStack.Value(b),73),"prepared dose native toss preserves concentration");
            if(b!=null)b.Destroy();a.Destroy();
        }
    }
    void Npc(CaelumPlayer u)
    {
        let npc=CaelumCombatActor(Actor.Spawn('CaelumGiantRat',u.Pos+(256,0,0)));
        let a=Material(u,100);a.AttachToOwner(npc);CaelumContaminationStorage.Set(a,20);
        let model=new('CaelumContaminationNPC');model.Capture(npc,Climate());
        model.AdvanceCaptured(npc,1000,80);
        Check(Near(CaelumContaminationStack.Value(a),CaelumContaminationRules.AfterContact(20,80,CaelumStackSurfaceData.UnitArea(a),1000)),"NPC uses real carried native stack");
        a.InMagicBox=true;model.Capture(npc,Climate());double old=CaelumContaminationStack.Value(a);
        model.AdvanceCaptured(npc,1000,100);
        Check(Near(CaelumContaminationStack.Value(a),old),"NPC protected stack remains shielded");
        a.Destroy();npc.Destroy();
    }
    void MerchantClock(CaelumPlayer u)
    {
        let clock=CaelumWorldClock.Get(u,true);CaelumCalendarState.Get(u,true).EnsureCampaign(clock);
        let merchant=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',u.Pos+(256,256,0)));
        merchant.StockInitialized=true;merchant.DomesticMarketParked=true;
        let item=Material(u,100);item.AttachToOwner(merchant);CaelumContaminationStorage.Set(item,20);
        let node=CaelumContaminationStack.Clock(item);
        node.HistoryReady=true;node.HistoryVariable=false;node.HistoryArea=CaelumStackSurfaceData.UnitArea(item);
        node.HistoryAmbient=80;node.HistoryRain=0;node.HistoryProfile=CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL;
        node.HistoryStamp=CaelumThermalRuntime.Stamp(clock);
        node.HistoryCivilOffset=CaelumHouseAwayWork.Civil(u)-node.HistoryStamp;
        double before=node.HistoryStamp;
        for(int i=0;i<20*TICRATE;i++)clock.AdvanceOnMap("MAP01");
        node.Sync();
        Console.Printf("CA502S CLOCK before=%.9f after=%.9f concentration=%.9f civil=%.9f offset=%.9f",before,node.HistoryStamp,CaelumContaminationStack.Prepare(item).Contamination(0),CaelumHouseAwayWork.Civil(u),node.HistoryCivilOffset);
        // The absolute civil epoch is about 6e10 seconds; one double ULP is 7.6 us.
        Check(Near(CaelumContaminationStack.Prepare(item).Contamination(0),20) && Abs(node.HistoryStamp-before)<.00001,"parked merchant exposure freezes during Limbo time");
        clock.AdvanceTics(TICRATE);node.Sync();
        double expected=CaelumContaminationRules.AfterContact(20,80,node.HistoryArea,20);
        Check(Near(CaelumContaminationStack.Prepare(item).Contamination(0),expected),"parked merchant follows source civil seconds");
        Check(node.HistoryAmbient==80 && node.HistoryProfile==CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL,"parked merchant retains source climate");
        node.Sync();Check(Near(CaelumContaminationStack.Prepare(item).Contamination(0),expected),"merchant interval is charged once");
        item.Destroy();merchant.Destroy();
    }
    void HomeRebase(CaelumPlayer u)
    {
        let entry=new('CaelumHouseStorageEntry');entry.Parked=true;
        entry.Chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(128,0,0)));
        entry.Climate=new('CaelumFoodClimate');entry.Climate.Ready=true;
        entry.Climate.CivilSeconds=CaelumHouseAwayWork.Civil(u)-50;entry.ClimateStamp=100;
        let item=Material(u,10);item.AttachToOwner(entry.Chest);
        CaelumContaminationStorage.Set(item,37);let node=CaelumContaminationStack.Clock(item);
        node.HistoryStamp=100;node.Stamp=100;node.HistoryCivilOffset=1000;
        double shift=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(u))-entry.SourceNow(u);
        entry.Rebase(u);
        Check(Near(node.HistoryStamp,100+shift) && Near(node.Stamp,100+shift),"house restoration rebases stack exposure boundary");
        Check(Near(node.HistoryStamp+node.HistoryCivilOffset,1100),"house restoration preserves absolute civil instant");
        Check(Near(CaelumContaminationStack.Prepare(item).Contamination(0),37),"rebasing preserves stored contamination");
        item.Destroy();entry.Chest.Destroy();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;Passed=Failed=0;
        if(e.Name=="ca502s_core")Core(u);
        else if(e.Name=="ca502s_native")PickupChecks(u);
        else if(e.Name=="ca502s_exposure")Exposure(u);
        else if(e.Name=="ca502s_contact")Contact(u);
        else if(e.Name=="ca502s_storage")Storage(u);
        else if(e.Name=="ca502s_ground")Ground(u);
        else if(e.Name=="ca502s_seed")Seed(u);
        else if(e.Name=="ca502s_resume")Resume(u);
        else if(e.Name=="ca502s_upgrade")Upgrade(u);
        else if(e.Name=="ca502s_perf")Performance(u);
        else if(e.Name=="ca502s_catalogue")Catalogue(u);
        else if(e.Name=="ca502s_npc")Npc(u);
        else if(e.Name=="ca502s_merchant")MerchantClock(u);
        else if(e.Name=="ca502s_rebase")HomeRebase(u);
        else if(e.Name=="ca502s_groundseed")
        {GroundItem=Material(u,100);CaelumContaminationStorage.Set(GroundItem,0);Check(GroundItem!=null,"native ground fixture created");}
        else if(e.Name=="ca502s_groundlive")
        {Check(GroundItem!=null && CaelumContaminationStack.Value(GroundItem)>0,"unpaused native scheduler exposes loose stack");}
        else if(e.Name=="ca502s_away"){Level.ChangeLevel("CST502B",0,CHANGELEVEL_NOINTERMISSION);return;}
        else if(e.Name=="ca502s_home"){Level.ChangeLevel("CST502",0,CHANGELEVEL_NOINTERMISSION);return;}
        else return;
        Console.Printf("CA502S RESULT passed=%d failed=%d",Passed,Failed);
    }
}
