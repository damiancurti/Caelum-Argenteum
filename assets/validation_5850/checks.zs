class CA502AdapterNPC : CaelumPortDefender {override void Tick(){}}
class CA502AdapterProp : CaelumPhysicalScenery
{
    Default {Radius 8;Height 8;+NOBLOCKMAP +NOGRAVITY -SOLID}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502AdapterProof : Inventory
{
    Inventory Cloth;bool Legacy;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502AdapterChecks : EventHandler
{
    int Passed,Failed;
    CA502AdapterNPC Soldier;
    Actor FirstProp,SecondProp;
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA502A %s %s",yes?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.000001;}
    void Core(CaelumPlayer u)
    {
        String names[]={"CaelumCleaningCloth","CaelumIronIngot","CaelumCopperCoin","CaelumCampTent","CaelumSleepingBag","CaelumRecipeBook","CaelumSealedLetter","CaelumProcessingManual"};
        for(int i=0;i<names.Size();i++)
        {
            let item=Inventory(Actor.Spawn(names[i],u.Pos+(96+i*32,0,0),NO_REPLACE));
            Check(item!=null && CaelumContaminationStack.Eligible(item),"generic physical class eligible");
            Check(CaelumStackSurfaceData.UnitArea(item)>0,"generic physical class has approved cylinder area");
            CaelumContaminationStorage.Set(item,68);
            Check(Near(CaelumContaminationStorage.Value(item),68),"generic value uses owned persistent record");
            Check(CaelumContaminationStack.Record(item).Exposure!=null,"generic class registered without lazy UI read");
            item.Destroy();
        }
        let old=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos+(128,128,0),NO_REPLACE));old.Amount=3;
        CaelumContaminationStorage.Set(old,70);old.AttachToOwner(u);
        let fresh=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos+(192,128,0),NO_REPLACE));fresh.Amount=2;
        CaelumContaminationStorage.Set(fresh,10);
        Check(old.HandlePickup(fresh),"native generic merge accepted");
        Check(old.Amount==5 && CaelumContaminationStack.Prepare(old).Units()==5,"generic merge conserves quantity");
        let lots=CaelumContaminationStack.Prepare(old);
        Check(lots.Lots.Size()==2 && Near(lots.Contamination(0),70) && Near(lots.Contamination(1),10),"generic merge retains distinct FIFO lots");
        fresh.Destroy();let dropped=old.CreateTossable(2);
        Check(dropped!=null && dropped.Amount==2 && old.Amount==3,"native generic toss conserves quantity");
        Check(Near(CaelumContaminationStorage.Value(dropped),70),"generic toss retains oldest dirt");
        Check(CaelumContaminationStack.Prepare(old).Units()==3,"generic remainder retains quantity");
        dropped.Destroy();old.Destroy();
        let copper=Inventory(Actor.Spawn('CaelumCopperCoin',u.Pos+(128,128,0),NO_REPLACE));copper.Amount=5;
        let more=Inventory(Actor.Spawn('CaelumCopperCoin',u.Pos+(192,128,0),NO_REPLACE));more.Amount=3;
        CaelumContaminationStorage.Set(copper,90);CaelumContaminationStorage.Set(more,20);
        Check(copper.HandlePickup(more),"currency native merge accepted");
        Check(copper.Amount==8 && CaelumContaminationStack.Prepare(copper).Lots.Size()==2,"currency merge retains exact lots");
        copper.Destroy();more.Destroy();
        let cloth=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos+(128,0,0),NO_REPLACE));cloth.Amount=3;
        CaelumContaminationStorage.Set(cloth,80);CaelumCleaningSupplies.RinseCloth(cloth);
        let rinsed=CaelumContaminationStack.Prepare(cloth);int clean=0,dirty=0;
        for(int i=0;i<rinsed.Lots.Size();i++)if(Near(rinsed.Contamination(i),0))clean+=rinsed.Lots[i].Units;else dirty+=rinsed.Lots[i].Units;
        Check(clean==1 && dirty==2 && cloth.Amount==3,"rinse cleans exactly one reusable cloth without changing stock");
        CaelumCleaningSupplies.RinseCloth(cloth);
        Check(rinsed.Lots.Size()==2,"successive rinse reuses the same clean cloth");cloth.Destroy();
        let bag=CaelumSleepingBag(Actor.Spawn('CaelumSleepingBag',u.Pos+(128,0,0),NO_REPLACE));
        CaelumContaminationStorage.Set(bag,73);bag.AttachToOwner(u);
        let mat=CaelumRestBag(Actor.Spawn('CaelumRestBag',u.Pos+(128,0,0),NO_REPLACE));mat.Bag=bag;mat.SyncContamination();
        Check(Near(CaelumContaminationStorage.Value(mat),73),"deployed bag adopts existing contamination");
        CaelumContaminationStorage.Set(mat,61);mat.RetainContamination();
        Check(Near(CaelumContaminationStorage.Value(bag),61),"bag return retains deployed cleaning");
        mat.Destroy();Check(Near(CaelumContaminationStorage.Value(bag),61),"bag teardown is idempotent");bag.Destroy();
        let wardrobe=Inventory(Actor.Spawn('CaelumWardrobeItem',u.Pos+(128,0,0),NO_REPLACE));wardrobe.AttachToOwner(u);
        CaelumContaminationStorage.Set(wardrobe,10);
        let frame=new('CaelumContaminationExposure');frame.Capture(u,CaelumThermalService.CaptureForecast(u));
        int selected=-1;for(int i=0;i<frame.Items.Size();i++)if(frame.Items[i].Item==wardrobe)selected=i;
        Check(selected>=0,"carried furniture uses the exposure forecast");
        if(selected>=0)
        {
            frame.Exterior(selected,80,frame.Items[selected].Area,0,0,10);
            Check(frame.Items[selected].Concentration>10 && Near(CaelumContaminationStorage.Value(wardrobe),10),"furniture forecast remains independent");
            frame.Commit(u);Check(CaelumContaminationStorage.Value(wardrobe)>10,"furniture forecast commits to native item");
        }
        wardrobe.Destroy();
        let table=CaelumDiningTable(Actor.Spawn('CaelumDiningTableSmall',u.Pos+(128,128,0),NO_REPLACE));
        let food=CaelumBread(Actor.Spawn('CaelumBread',table.Pos,NO_REPLACE));food.AttachToOwner(table);
        CaelumContaminationStorage.Set(food,0);
        let row=new('CaelumSkipSupply');row.Capture(food);
        let aged=new('CaelumSkipSupply');aged.Capture(food);aged.FoodArea=0;
        Check(row.FoodArea>0 && row.FoodClimate!=null,"deployed table food captures its own exposure forecast");
        row.AdvanceFood(10);aged.AdvanceFood(10);
        Check(row.FoodLots.Contamination(0)>aged.FoodLots.Contamination(0),"table forecast adds exposure to intrinsic ageing");
        Check(Near(CaelumContaminationStorage.Value(food),0),"table forecast cannot mutate native food");
        let record=CaelumContaminationStack.Record(food);record.StackRevision=2;record.Concentration=90;
        Check(Near(CaelumContaminationStack.Prepare(food).Contamination(0),0),"new adapter revision does not repeat old food migration");
        Check(CaelumTimeSkipModel.PROVISION_REVISION==28,"old saved forecasts are invalidated once");
        food.Destroy();table.Destroy();
        let prop=Actor.Spawn('CA502AdapterProp',(8,64,16),NO_REPLACE);
        let tile=CaelumContaminationSurfaceContact.WallTile(prop,CaelumContaminationSurfaces.CurrentMap(u),true);
        Check(tile!=null,"unlinked physical object resolves its actual wall contact");
        if(tile!=null)
        {
            tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);
            CaelumContaminationStorage.Set(prop,10);CaelumContaminationSurfaceContact.ObjectSupport(prop,10);
            Check(CaelumContaminationStorage.Value(prop)>10,"wall contact contaminates an airborne prop without floor contact");
        }
        prop.Destroy();
    }
    void TentTransfer(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.CombatTimeRemaining=0;
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.DerivedStats.CarryCapacity=1000;u.SetOrigin((64,128,0),false);u.Angle=0;u.Vel=(0,0,0);
        let item=CaelumCampTent(Actor.Spawn('CaelumCampTent',u.Pos,NO_REPLACE));item.AttachToOwner(u);
        CaelumContaminationStorage.Set(item,63);
        Check(CaelumCampTask.BeginSetup(u,item),"native tent setup starts");
        if(!CaelumCampTask.Active(u)){item.Destroy();return;}
        u.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();
        let tent=CaelumDeployedTent(item.Owner);
        Check(tent!=null && Near(CaelumContaminationStorage.Value(tent),63),"native deployment transfers contamination to original structure");
        if(tent==null){item.Destroy();return;}
        Check(CaelumContaminationStorage.IsShielded(item),"deployed original is shielded from duplicate exposure");
        CaelumContaminationStorage.Set(tent,49);
        Check(CaelumCampTask.BeginPack(u,tent),"native tent packing starts");
        if(CaelumCampTask.Active(u))
        {u.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();}
        Check(item.Owner==u && Near(CaelumContaminationStorage.Value(item),49),"native packing retains changes made to deployed structure");
        item.Destroy();
    }
    void Seed(CaelumPlayer u)
    {
        CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        let proof=CA502AdapterProof(u.GiveInventoryType('CA502AdapterProof'));
        let cloth=CaelumCleaningCloth(Actor.Spawn('CaelumCleaningCloth',u.Pos+(128,0,0),NO_REPLACE));
        cloth.Amount=3;CaelumContaminationStorage.Set(cloth,67);cloth.AttachToOwner(u);cloth.InMagicBox=true;proof.Cloth=cloth;
        Check(true,"current save seed created");
    }
    void Resume(CaelumPlayer u)
    {
        let proof=CA502AdapterProof(u.FindInventory('CA502AdapterProof'));
        Check(proof!=null && proof.Cloth!=null,"native save retains item identity");
        if(proof==null || proof.Cloth==null)return;
        Check(proof.Cloth.Amount==3,"native save retains quantity");
        Check(Near(CaelumContaminationStorage.Value(proof.Cloth),67),"native save retains original concentration");
        Check(CaelumContaminationStack.Prepare(proof.Cloth).Units()==3,"native save restores contamination ledger");
        Check(CaelumContaminationStack.Record(proof.Cloth).StackOwner==proof.Cloth,"native restored record has its own item owner");
    }
    void Contacts(CaelumPlayer u)
    {
        let first=FirstProp;let second=SecondProp;
        CaelumContaminationContacts.Observe(second);
        Check(CaelumContaminationStorage.Value(second)>20,"local grid finds two non-solid unlinked actors");
        Check(CaelumContaminationContacts.Get(second).Pairs.Size()==1,"one contact pair for unlinked overlap");
        double value=CaelumContaminationStorage.Value(second);CaelumContaminationContacts.Observe(first);
        Check(Near(value,CaelumContaminationStorage.Value(second)),"opposite observation does not duplicate contact");
        first.SetOrigin(first.Pos+(192,0,0),false);CaelumContaminationContacts.Observe(first);
        Check(CaelumContaminationContacts.Get(first).GridX==int(Floor(first.Pos.X/CaelumContaminationGrid.CELL)),"moving unlinked actor updates local index");
        let npc=Soldier;Check(npc!=null && npc.CombatProfileInitialized,"NPC native initialization complete");
        if(npc==null)return;
        npc.SetOrigin(u.Pos+(0,96,0),false);npc.FindFloorCeiling();npc.SetOrigin((npc.Pos.X,npc.Pos.Y,npc.FloorZ),false);npc.FindFloorCeiling();npc.Vel=(0,0,0);
        let tile=CaelumContaminationSurfaceContact.FloorTile(npc,CaelumContaminationSurfaces.CurrentMap(u),true);
        Check(tile!=null,"NPC uses existing shared floor tile");
        if(tile!=null)
        {
            tile.Concentration=80;tile.Stamp=CaelumContaminationSurfaces.Now(u);
            let foot=CaelumContaminationCombat.Exterior(npc,CaelumConstants.ARMOR_SLOT_FEET);foot.Set(10);
            let thermal=CaelumThermalService.CaptureForecast(npc);
            CaelumContaminationSurfaceContact.NPCContact(npc,thermal,10);
            Check(foot.Value()>10 && foot.Value()<=80,"NPC floor contact reaches actual outer equipment");
            Check(Near(tile.Concentration,80),"NPC floor source is not consumed");
        }
        npc.Destroy();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502a_prepare")
        {
            Soldier=CA502AdapterNPC(Actor.Spawn('CA502AdapterNPC',u.Pos+(0,96,0),NO_REPLACE));
            FirstProp=Actor.Spawn('CA502AdapterProp',u.Pos+(96,0,0),NO_REPLACE);
            SecondProp=Actor.Spawn('CA502AdapterProp',FirstProp.Pos,NO_REPLACE);
            CaelumContaminationStorage.Set(FirstProp,80);CaelumContaminationStorage.Set(SecondProp,20);return;
        }
        if(e.Name=="ca502a_separated")
        {
            Check(!CaelumContaminationContacts.Active(SecondProp),"native next tic removes separated contact");
            FirstProp.Destroy();SecondProp.Destroy();
            Console.Printf("CA502A RESULT passed=%d failed=%d",Passed,Failed);return;
        }
        if(e.Name=="ca502a_catalogue")Core(u);
        else if(e.Name=="ca502a_tent")TentTransfer(u);
        else if(e.Name=="ca502a_contact")Contacts(u);
        else if(e.Name=="ca502a_seed")Seed(u);
        else if(e.Name=="ca502a_resume")Resume(u);
        else if(e.Name=="ca502a_away"){level.ChangeLevel("CPH502B",0,CHANGELEVEL_NOINTERMISSION,-1);return;}
        else if(e.Name=="ca502a_home"){level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION,-1);return;}
        else return;
        Console.Printf("CA502A RESULT passed=%d failed=%d",Passed,Failed);
    }
}
