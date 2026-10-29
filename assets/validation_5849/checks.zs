class CA502PhysicalNPC : CaelumPortDefender {override void Tick(){}}
class CA502PhysicalProof : Inventory
{
    CaelumMaterialPickup Material;
    CaelumConsumableItem Food;
    bool Legacy;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502PhysicalChecks : EventHandler
{
    int Passed,Failed;
    CA502PhysicalNPC Soldier;
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA502P %s %s",yes?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    CaelumMaterialPickup Material(CaelumPlayer u,int kind,int units,int tier=1)
    {
        let m=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos+(256,128,0)));
        m.args[0]=kind;m.args[1]=tier;m.Amount=units;CaelumFoodInventory.Reconcile(m);return m;
    }
    CaelumConsumableItem Food(CaelumPlayer u,int units)
    {
        let f=CaelumConsumableItem(Actor.Spawn('CaelumBread',u.Pos+(256,128,0)));
        f.Amount=units;CaelumFoodInventory.Reconcile(f);return f;
    }
    CaelumThermalState Climate()
    {
        let t=new('CaelumThermalState');t.Initialize();t.Available=true;t.BodyMassKg=80;t.SurfaceArea=2;
        for(int i=0;i<4;i++)t.Coverage[i]=.25;return t;
    }
    void Catalogue(CaelumPlayer u)
    {
        for(int kind=0;kind<CaelumConstants.MATERIAL_TYPE_COUNT;kind++)
            for(int tier=1;tier<=3;tier++)
            {
                let m=Material(u,kind,1,tier);double area=CaelumStackSurfaceData.UnitArea(m);
                Check(area>0,String.Format("material %d tier %d has documented geometry",kind,tier));
                m.Amount=1000000;CaelumFoodInventory.Reconcile(m);
                Check(Near(area,CaelumStackSurfaceData.UnitArea(m)),"unit area independent of pile size");
                Check(CaelumContaminationStack.Prepare(m).Units()==1000000,"million units remain exact");m.Destroy();
            }
        Check(Near(CaelumPhysicalSurfaceData.MaterialDensity(1,1),8150),"tier-one blade uses bronze");
        Check(Near(CaelumPhysicalSurfaceData.MaterialDensity(1,2),7870),"tier-two blade uses iron");
        Check(Near(CaelumPhysicalSurfaceData.MaterialDensity(1,3),7800),"tier-three blade uses steel");
        Check(Near(CaelumPhysicalSurfaceData.MaterialDensity(43,3),10490),"silver-chain recipe is retained");
    }
    void FoodLots(CaelumPlayer u)
    {
        let a=Food(u,3);a.AttachToOwner(u);CaelumContaminationStorage.Set(a,60);
        let b=Food(u,2);CaelumContaminationStorage.Set(b,10);
        Actor receiver=u;Check(b.CallTryPickup(receiver),"native food pickup succeeds");
        Check(a.Amount==5 && a.FoodLots.Units()==5,"native merge never duplicates food");
        Check(a.FoodLots.Lots.Size()==2,"native merge preserves distinct contamination");
        Check(Near(a.FoodLots.Contamination(0),60) && Near(a.FoodLots.Contamination(1),10),"native merge retains FIFO dose");
        let drop=CaelumConsumableItem(a.CreateTossable(4));
        Check(drop!=null && a.Amount==1 && drop.Amount==4,"native toss moves exact portions");
        if(drop!=null)
        {
            Check(drop.FoodLots.Units()==4 && a.FoodLots.Units()==1,"food and contact share quantity ledger");
            Check(Near(a.FoodLots.Contamination(0),10),"newer food is not dirtied by bookkeeping");
            Check(drop.FoodLots.Lots.Size()==2 && drop.FoodLots.Lots[0].Units==3,"toss retains oldest three portions");
            Check(!CaelumFoodInventory.CanSell(drop),"dirty food cannot become fresh commercial stock");
            double before=drop.FoodLots.Contamination(0);
            drop.FoodLots.Advance(3600,20,50);
            Check(Near(drop.FoodLots.Contamination(0),before+100.0/72),"contacted bread keeps approved ageing rate");
            CaelumFoodInventory.Remove(drop,2);drop.Amount-=2;CaelumFoodInventory.Reconcile(drop);
            Check(drop.Amount==2 && drop.FoodLots.Units()==2,"consumption removes once");drop.Destroy();
        }
        a.Destroy();
        let raw=Material(u,109,200);CaelumContaminationStorage.Set(raw,80);
        let clean=Material(u,109,100);CaelumContaminationStorage.Set(clean,20);
        Check(CaelumFoodInventory.Transfer(raw,clean,100),"raw-food FIFO transfer succeeds");raw.Amount-=100;clean.Amount+=100;
        Check(raw.FoodLots.Units()==100 && clean.FoodLots.Units()==200,"raw material not transferred twice");
        Check(clean.FoodLots.Lots.Size()==2,"raw ingredient retains dirty and fresh lots");raw.Destroy();clean.Destroy();
    }
    void Forecast(CaelumPlayer u)
    {
        let a=Food(u,3);a.AttachToOwner(u);CaelumContaminationStorage.Set(a,20);
        let foods=new('CaelumJourneyFood');foods.Capture(u);
        let exposure=new('CaelumContaminationExposure');exposure.Capture(u,Climate());exposure.BindFood(foods);
        let row=foods.Find(a);Check(row!=null,"journey captures actual food");
        let illness=new('CaelumFoodIllness');foods.Advance(3600,20,50);exposure.Advance(illness,80,3600);
        double expected=CaelumContaminationRules.AfterContact(20+100.0/72,80,CaelumStackSurfaceData.UnitArea(a),3600);
        Check(Near(row.Lots.Contamination(0),expected),"forecast combines ageing and exposure in one ledger");
        Check(Near(a.FoodLots.Contamination(0),20),"forecast remains isolated from native food");
        double dose;row.Lots.Consume(1,dose);Check(Near(dose,expected),"forecast consumes exposed dose");
        exposure.Commit(u);foods.Commit(u);
        Check(a.Amount==2 && a.FoodLots.Units()==2,"committed journey preserves consumed amount");
        Check(Near(a.FoodLots.Contamination(0),expected),"later food commit cannot erase exposure");
        a.InMagicBox=true;foods.Capture(u);exposure.Capture(u,Climate());exposure.BindFood(foods);
        foods.Advance(3600,20,50);exposure.Advance(illness,100,3600);foods.Commit(u);
        Check(Near(a.FoodLots.Contamination(0),Min(100.0,expected+100.0/72)),"Box protects contact but not ageing");
        a.InMagicBox=false;
        let skip=new('CaelumTimeSkipModel');skip.CaptureSkip(u,false);
        let shared=skip.FoodInventory.Find(a);bool bound=false;
        for(int i=0;i<skip.Supplies.Size();i++)if(skip.Supplies[i].FoodLots==shared.Lots)bound=true;
        Check(bound,"wait supply and contact forecast share food lots");
        Check(skip.ProvisionRevision==27,"stored wait forecasts require current schema");a.Destroy();
    }
    void Contact(CaelumPlayer u)
    {
        let raw=Material(u,109,100);let source=Material(u,0,100);
        CaelumContaminationStorage.Set(raw,20);CaelumContaminationStorage.Set(source,80);
        double area=Min(.1,Min(CaelumStackSurfaceData.UnitArea(raw)*100,CaelumStackSurfaceData.UnitArea(source)*100));
        CaelumContaminationStorage.Touch(raw,source,.1,10);
        double expected=CaelumContaminationRules.AfterContact(20,80,area/100,10);
        Check(Near(raw.FoodLots.Contamination(0),expected),"contact uses actual total contact area distributed among units");
        Check(Near(CaelumContaminationStorage.Value(source),80),"source concentration is conserved");
        Check(raw.FoodLots==CaelumContaminationStack.Prepare(raw),"ingestion sees the exact contact ledger");
        raw.Destroy();source.Destroy();
        let first=Material(u,92,10);let second=Material(u,93,10);first.AttachToOwner(u);second.AttachToOwner(u);
        let shared=new('CaelumContaminationState');shared.Ensure();shared.Concentration=41;
        first.ContaminationState=shared;second.ContaminationState=shared;
        Check(Near(CaelumContaminationStorage.Value(first),41) && Near(CaelumContaminationStorage.Value(second),41),"legacy aliased concentrations adopted without loss");
        CaelumContaminationStorage.Set(first,80);
        Check(Near(CaelumContaminationStorage.Value(second),41),"mutating one migrated item cannot mutate its former alias");
        Check(first.ContaminationState.StackOwner==first && second.ContaminationState.StackOwner==second,"each migrated record names its actual owner");
        first.Destroy();second.Destroy();
    }
    void Support(CaelumPlayer u)
    {
        let raw=Material(u,109,100);let fresh=Material(u,109,100);
        CaelumContaminationStorage.Set(raw,10);CaelumContaminationStorage.Set(fresh,60);
        CaelumFoodInventory.Transfer(fresh,raw,100);raw.Amount+=100;fresh.Amount-=100;fresh.Destroy();
        let sheet=CaelumContaminationSurfaces.CurrentMap(u);
        raw.SetOrigin(u.Pos+(64,0,0),false);raw.FindFloorCeiling();raw.SetOrigin((raw.Pos.X,raw.Pos.Y,raw.FloorZ),false);raw.FindFloorCeiling();raw.Vel=(0,0,0);raw.bNoGravity=false;
        let tile=CaelumContaminationSurfaceContact.FloorTile(raw,sheet,true);
        Check(tile!=null,"native floor tile available for a non-solid food pile");
        if(tile!=null)
        {
            tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);
            CaelumContaminationSurfaceContact.StackSupport(raw,10);
            Check(raw.FoodLots.Lots.Size()==2 && raw.FoodLots.Contamination(0)>10 && raw.FoodLots.Contamination(1)>60,
                "floor contact preserves distinct receiver lots");
            Check(Near(tile.Concentration,80),"floor source concentration retained");
        }
        raw.SetOrigin(u.Pos,false);raw.Vel=(0,0,0);CaelumContaminationContacts.Observe(raw);
        Check(CaelumContaminationContacts.Active(u),"local native query detects non-solid pile touching actor");
        CaelumContaminationContacts.Detach(raw);
        Check(CaelumContaminationContacts.Get(raw).Pairs.Size()==0,"detach clears item contact links");
        raw.Destroy();
    }
    void Absent(CaelumPlayer u)
    {
        let npc=Soldier;Check(npc!=null && npc.CombatProfileInitialized,"NPC completed native deferred initialization");if(npc==null)return;
        npc.CombatToughness=100;npc.health=npc.CombatMaximumHealth;CaelumContaminationStorage.Set(npc,0);
        let f=Food(u,2);f.AttachToOwner(npc);CaelumContaminationStorage.Set(f,20);
        let boxed=Material(u,109,200);boxed.AttachToOwner(npc);boxed.InMagicBox=true;CaelumContaminationStorage.Set(boxed,10);
        CaelumContaminationAbsence.Capture(npc,u);let row=npc.ContaminationAbsence;
        Check(row!=null && row.Away,"native departure captures absent food inventory");
        if(row!=null)
        {
            double end=row.Stamp+3600;row.SyncTo(npc,end);
            double first=f.FoodLots.Contamination(0),second=boxed.FoodLots.Contamination(0);
            Check(first>20 && second>10,"absent food ages outside and inside protected storage");
            Check(f.FoodLots.Units()==2 && boxed.FoodLots.Units()==200,"absent interval preserves actual quantities");
            row.SyncTo(npc,end);
            Check(Near(first,f.FoodLots.Contamination(0)) && Near(second,boxed.FoodLots.Contamination(0)),"absent interval idempotent");
            row.SyncTo(npc,end+3600);
            Check(f.FoodLots.Contamination(0)>first && boxed.FoodLots.Contamination(0)>second,"successive absence continues saved food clock");
            row.Away=false;
        }
        f.Destroy();boxed.Destroy();npc.Destroy();
    }
    void Seed(CaelumPlayer u)
    {
        CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        let proof=CA502PhysicalProof(u.GiveInventoryType('CA502PhysicalProof'));
        proof.Material=Material(u,92,75);proof.Material.AttachToOwner(u);proof.Material.InMagicBox=true;
        CaelumContaminationStorage.Set(proof.Material,67);
        proof.Food=Food(u,3);proof.Food.AttachToOwner(u);proof.Food.InMagicBox=true;
        CaelumContaminationStorage.Set(proof.Food,39);Check(true,"save seed created");
    }
    void Resume(CaelumPlayer u)
    {
        let p=CA502PhysicalProof(u.FindInventory('CA502PhysicalProof'));Check(p!=null,"persistent proof recovered");if(p==null)return;
        Check(p.Material!=null && p.Material.Owner==u && p.Material.Amount==75,"physical material identity and quantity restored");
        Console.Printf("CA502P MIGRATE material=%.9f record=%.9f schema=%d lots=%d",CaelumContaminationStorage.Value(p.Material),p.Material.ContaminationState.Concentration,p.Material.ContaminationState.StackRevision,CaelumContaminationStack.Prepare(p.Material).Units());
        Check(p.Material!=null && Near(CaelumContaminationStorage.Value(p.Material),67),"material contamination restored");
        Check(p.Food!=null && (p.Legacy?p.Food.Owner==null:p.Food.Owner==u) && p.Food.Amount==3,"food identity and quantity restored");
        Check(p.Food!=null && p.Food.FoodLots.Contamination(0)>=39 && p.Food.FoodLots.Contamination(0)<39.1,"food contamination and age restored");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;Passed=Failed=0;
        if(e.Name=="ca502p_npcprepare"){Soldier=CA502PhysicalNPC(Actor.Spawn('CA502PhysicalNPC',u.Pos+(128,0,0),NO_REPLACE));return;}
        if(e.Name=="ca502p_catalogue")Catalogue(u);
        else if(e.Name=="ca502p_food")FoodLots(u);
        else if(e.Name=="ca502p_forecast")Forecast(u);
        else if(e.Name=="ca502p_contact")Contact(u);
        else if(e.Name=="ca502p_support")Support(u);
        else if(e.Name=="ca502p_absent")Absent(u);
        else if(e.Name=="ca502p_seed")Seed(u);
        else if(e.Name=="ca502p_resume")Resume(u);
        else if(e.Name=="ca502p_away"){Level.ChangeLevel("CPH502B",0,CHANGELEVEL_NOINTERMISSION);return;}
        else if(e.Name=="ca502p_home"){Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;}
        else return;
        Console.Printf("CA502P RESULT passed=%d failed=%d",Passed,Failed);
    }
}
