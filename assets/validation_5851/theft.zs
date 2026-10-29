class CA415TheftObstacle : Actor
{
    Default { Radius 48; Height 128; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA415TheftChecks : EventHandler
{
    CaelumCombatActor Thief;
    CaelumStashChest FirstChest,SecondChest;
    Inventory Taken;
    CaelumEquipmentItem Gear;
    CaelumTheftPlan Plan;
    int Passed,Failed;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA415T %s %s",value?"PASS":"FAIL",label);}
    Inventory Put(class<Inventory> type,Actor owner,int count)
    {
        let item=Inventory(Actor.Spawn(type,owner.Pos,NO_REPLACE));
        item.BecomeItem();owner.AddInventory(item);item.Amount=count;return item;
    }
    CaelumMaterialPickup Material(Actor owner,int type,int count)
    {let item=CaelumMaterialPickup(Put('CaelumMaterialPickup',owner,count));item.args[0]=type;item.args[1]=1;return item;}
    void Prepare(CaelumPlayer user)
    {
        Thief=CaelumCombatActor(Actor.Spawn('CA415RoundSoldier',user.Pos+(128,0,0),NO_REPLACE));
        FirstChest=CaelumStashChest(Actor.Spawn('CaelumStashChest',user.Pos+(0,128,0),NO_REPLACE));
        SecondChest=CaelumStashChest(Actor.Spawn('CaelumStashChest',user.Pos+(128,128,0),NO_REPLACE));
    }
    void Transfers()
    {
        Array<CaelumStashChest> targets;targets.Push(FirstChest);targets.Push(SecondChest);
        let cheap=Material(FirstChest,CaelumConstants.MATERIAL_WOOD,100);
        let valuable=Material(SecondChest,CaelumConstants.MATERIAL_GOLD_INGOT,100);
        let excess=Material(FirstChest,CaelumConstants.MATERIAL_GOLD_INGOT,1000000);
        let quest=Material(FirstChest,CaelumConstants.MATERIAL_GOLD_INGOT,101);quest.LimboQuestUnits=1;
        Check(CaelumTheftTransfer.Value(valuable)>CaelumTheftTransfer.Value(cheap),"selection uses actual commercial values");
        Check(CaelumTheftTransfer.Weight(excess)>CaelumTheftTransfer.Capacity(Thief),"oversized real stack exceeds native Strength capacity");
        Check(CaelumTheftTransfer.Select(Thief,targets)==valuable,"highest-value accessible whole stack fits without splitting or taking quest stock");
        let padlock=CaelumLockItem(Put('CaelumLockItem',SecondChest,1));padlock.LockItemType=0;
        padlock.PairIdentity=new('CaelumLockIdentity');padlock.PairIdentity.Token="CA415-THEFT-PAIR";
        SecondChest.InstalledPadlock=padlock;
        Check(CaelumTheftTransfer.Select(Thief,targets)==cheap,"locked valuable chest does not hide an accessible lower-value stack");
        let key=CaelumLockItem(Put('CaelumLockItem',Thief,1));key.LockItemType=3;
        key.PairIdentity=new('CaelumLockIdentity');key.PairIdentity.Token="WRONG";
        Check(!CaelumTheftTransfer.Move(Thief,SecondChest,valuable) && valuable.Owner==SecondChest,"wrong padlock key leaves actual item and quantity untouched");
        key.PairIdentity.Token="CA415-THEFT-PAIR";
        Check(CaelumTheftTransfer.Select(Thief,targets)==valuable,"equal serialized key identity grants access without pointer equality");
        double before=CaelumTheftTransfer.Carried(Thief),weight=CaelumTheftTransfer.Weight(valuable);
        Check(CaelumTheftTransfer.Move(Thief,SecondChest,valuable),"authorized whole-stack transfer succeeds");Taken=valuable;
        Check(Taken.Owner==Thief && Taken.Amount==100 && key.Owner==Thief && key.Amount==1,"transfer retains the exact stack and does not consume its key");
        Check(Abs(CaelumTheftTransfer.Carried(Thief)-before-weight)<.0000001,"actual acquired material counts against later carrying room");
        Check(!CaelumTheftTransfer.Move(Thief,SecondChest,valuable) && Taken.Amount==100,"replaying the same transfer cannot duplicate the item");
        Check(padlock.Owner==SecondChest && !CaelumTheftTransfer.Eligible(SecondChest,padlock),"installed padlock remains part of its chest");
        Check(!CaelumTheftTransfer.Move(Thief,FirstChest,excess) && excess.Amount==1000000,"capacity failure does not partially steal or split a stack");
        Check(!CaelumTheftTransfer.Move(Thief,FirstChest,quest) && quest.LimboQuestUnits==1,"quest provenance is retained");
        let food=CaelumConsumableItem(Put('CaelumFoodRation',FirstChest,2));
        let lots=CaelumFoodInventory.Prepare(food);lots.Lots.Clear();lots.Add(1,20,1);lots.Add(1,80,2);
        let oldest=lots.Lots[0];let newest=lots.Lots[1];
        Check(CaelumTheftTransfer.Move(Thief,FirstChest,food),"food stack transfers through the native inventory");
        Check(CaelumFoodInventory.GetLots(food)==lots && lots.Lots[0]==oldest && lots.Lots[1]==newest && food.Amount==2,
            "whole food transfer preserves both physical age/contamination lots");
        let water=CaelumWaterContainer(Put('CaelumBottleNormal',FirstChest,1));water.WaterLiters=.5;
        water.WaterQuality=CaelumWaterQuality.BIOLOGICAL;water.WaterTemperatureC=57;
        Check(CaelumTheftTransfer.Move(Thief,FirstChest,water) && water.WaterLiters==.5
            && water.WaterQuality==CaelumWaterQuality.BIOLOGICAL && water.WaterTemperatureC==57,"water retains volume, contamination flags and temperature");
        Gear=CaelumEquipmentItem(Put('CaelumEquipmentItem',FirstChest,1));
        Gear.PostBeginPlay();
        Gear.PickupDataInitialized=true;Gear.AcquisitionResolved=false;Gear.ItemId=77;
        Gear.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Gear.ItemType=CaelumConstants.WEAPON_TYPE_DAGGER;
        Gear.Tier=2;Gear.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_S;Gear.args[3]=18;
        let model=new('CaelumWeaponModel');double expected=model.GetWeightFor(Gear.ItemType,2,Gear.EquipmentSize);
        Check(Abs(CaelumTheftTransfer.Weight(Gear)-expected)<.0000001,"unresolved stored equipment uses its catalogue mass before selection");
        Check(CaelumTheftTransfer.Move(Thief,FirstChest,Gear) && Gear.AcquisitionResolved
            && Gear.UnitWeight==expected && Gear.ItemId==77 && Gear.Durability==17,"equipment transfer resolves original size, weight and encoded wear without changing identity");
        let nativeChest=CaelumStashChest(Actor.Spawn('CaelumLockedStashChest',FirstChest.Pos+(64,0,0),NO_REPLACE));
        let nativeLoot=Material(nativeChest,CaelumConstants.MATERIAL_GOLD_INGOT,1);
        Check(!CaelumTheftTransfer.KeyAccess(nativeChest,Thief),"native LOCKDEFS chest remains inaccessible without its key");
        let nativeKey=Put('CaelumSilverKey',Thief,1);
        Check(CaelumTheftTransfer.Move(Thief,nativeChest,nativeLoot) && nativeKey.Owner==Thief && nativeKey.Amount==1,
            "native LOCKDEFS authorizes the matching key without consuming it");
        Thief.health=0;
        Check(CaelumTheftTransfer.Select(Thief,targets)==null && !CaelumTheftTransfer.Move(Thief,FirstChest,cheap),"dead thieves cannot take another stack");
        Thief.health=100;Thief.ChangeStatNum(Thinker.STAT_DEFAULT);
    }
    void Loaded()
    {
        Check(Taken!=null && Taken.Owner==Thief && Taken.Amount==100,"saved transfer restores exact ownership and amount");
        Check(!CaelumTheftTransfer.Move(Thief,SecondChest,Taken),"saved transfer remains exactly once");
        Check(Gear!=null && Gear.Owner==Thief && Gear.ItemId==77 && Gear.Durability==17
            && Gear.EquipmentSize==CaelumConstants.EQUIPMENT_SIZE_S,"saved equipment retains actual owner, identity, wear and size");
    }
    void Planned(CaelumPlayer user)
    {
        FirstChest.GrantLawfulTitle(user);SecondChest.GrantLawfulTitle(user);
        Array<CaelumStashChest> targets;targets.Push(FirstChest);targets.Push(SecondChest);targets.Push(FirstChest);
        let cheap=Material(FirstChest,CaelumConstants.MATERIAL_WOOD,100);
        let valuable=Material(SecondChest,CaelumConstants.MATERIAL_GOLD_INGOT,100);
        Plan=new('CaelumTheftPlan');Plan.Begin(Thief,"MAP03",100,targets);
        Check(Plan.Accessible.Size()==2 && Plan.NextDue==3700,"explicit plan deduplicates access and starts one world hour later");
        Check(!Plan.Step(3699) && valuable.Owner==SecondChest,"no theft occurs before its world-hour deadline");
        Check(Plan.Step(3700) && valuable.Owner==Thief && cheap.Owner==FirstChest,"one due hour transfers exactly one best eligible stack");
        Check(Plan.Receipts.Size()==1 && Plan.Receipts[0].Item==valuable && Plan.Receipts[0].When==3700,"receipt retains real item, owner and actual loss time");
        Check(!Plan.Step(3700) && Plan.Attempts==1,"repeated reconciliation cannot repeat a due theft");
        Check(Plan.Discover(user,"MAP01")==0 && !Plan.Receipts[0].Known,"remote region does not reveal the theft");
        Check(Plan.Discover(user,"MAP03")==1 && Plan.Discover(user,"MAP03")==0,"return to the affected region discovers the loss once");
        Check(Plan.Finish(5500) && Plan.Remaining==1800,"return retains partial progress toward the next theft opportunity");
        Plan.Begin(Thief,"MAP03",10000,targets);
        Check(Plan.NextDue==11800 && Plan.Attempts==1,"later departure retains its half-hour remainder without charging observed time");
    }
    void PlanLoaded()
    {
        Check(Plan!=null && Plan.Away && Plan.NextDue==11800 && Plan.Attempts==1,"save restores exact next opportunity and previous attempt count");
        Check(Plan.Receipts.Size()==1 && Plan.Receipts[0].Known && Plan.Receipts[0].Item.Owner==Thief,"save retains discovery and actual stolen possession");
        Thief.health=0;
        Check(Plan.Step(11800) && Plan.Attempts==2 && Plan.Receipts.Size()==1,"death before the next hour prevents another theft without replaying time");
        Check(Plan.Finish(11801),"dead thief finishes reconciliation without losing prior stolen possessions");
    }
    void Access()
    {
        let query=new('CaelumTheftAccess');query.Prepare(Thief);
        vector3 original=Thief.Pos;int count=Thief.Inv!=null?Thief.Inv.Amount:0;
        double started=MSTimeF();
        Check(query.Reachable(FirstChest),"native floor and collision query finds an unobstructed container");
        FirstChest.SetOrigin(Thief.Pos+(256,0,0),false);FirstChest.FindFloorCeiling();
        let obstruction=Actor.Spawn('CA415TheftObstacle',Thief.Pos+(128,0,0),NO_REPLACE);
        Check(query.Reachable(FirstChest),"bounded native search finds a route around a blocking furnishing");
        FirstChest.SetOrigin(Thief.Pos+(256,0,512),false);
        Check(!query.Reachable(FirstChest),"an unreachable elevated container is not authorized through XY distance");
        FirstChest.SetOrigin(Thief.Pos+(256,0,0),false);
        obstruction.A_SetSize(96,256);obstruction.SetOrigin(FirstChest.Pos,false);
        Check(!query.Reachable(FirstChest),"solid enclosure blocks both body access and the final reach trace");
        Check(Thief.Pos==original && (Thief.Inv==null || Thief.Inv.Amount==count),"route queries neither move the thief nor consume inventory");
        let leaf=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',Thief.Pos+(0,256,0),NO_REPLACE));
        leaf.args[3]=CaelumConstants.LOCK_CAELUM_SILVER_STASH;query.Doors.Push(leaf);
        Check(!query.DoorAllowed(leaf),"missing native door key denies virtual opening");
        Put('CaelumSilverKey',Thief,1);
        Check(query.DoorAllowed(leaf) && !leaf.DoorRequested,"matching native key allows querying without opening the real door");
        leaf.RuloArenaLocked=true;
        Check(!query.DoorAllowed(leaf),"arena/story door restrictions remain authoritative despite owning the key");
        Console.Printf("CA415T TIMING access_ms=%.6f native_points=%d",MSTimeF()-started,query.Checks);
        query.Close();
        Check(query.Probe==null && query.FloorProbe==null,"temporary access probes are released after the query");
    }
    void NativeDoors()
    {
        let events=CaelumPolyDoorEvents.Get();let leaf=events!=null && events.Leaves.Size()>1?events.Leaves[1]:null;
        Check(leaf!=null && leaf.NativeFaces.Size()==4,"owned diagnostic fixture has the real four native PolyObject faces");
        if(leaf==null)return;
        Thief.SetOrigin((0,-96,0),false);Thief.FindFloorCeiling();FirstChest.SetOrigin((0,96,0),false);
        leaf.args[3]=CaelumConstants.LOCK_CAELUM_SILVER_STASH;
        let query=new('CaelumTheftAccess');query.Prepare(Thief);double floor;
        Check(!query.Point((0,-32,0),(0,0),floor),"native closed face rejects passage without its actual key");
        Put('CaelumSilverKey',Thief,1);
        Check(query.OpenableFace(leaf.NativeFaces[0]),"native face identity resolves to the authorized leaf");
        Check(query.Point((0,-32,0),(0,0),floor) && floor==0,"keyed native doorway admits a virtual body using the actual floor");
        FCheckPosition fit;
        Check(!Thief.CheckPosition((0,0),false,fit) && leaf.SlideProgress==0 && !leaf.DoorRequested,
            "virtual passage does not mutate the closed native geometry or start its motor");
        leaf.RuloArenaLocked=true;
        Check(!query.Point((0,-32,0),(0,0),floor),"native arena restriction blocks virtual passage even with its key");
        leaf.RuloArenaLocked=false;
        Check(!query.Point((-480,-100,0),(-512,-100),floor),"ordinary world walls cannot use the door exception");
        query.Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca415t_prepare"){Prepare(CaelumPlayer(players[consoleplayer].mo));return;}
        Passed=Failed=0;
        if(e.Name=="ca415t_transfer")Transfers();else if(e.Name=="ca415t_load")Loaded();
        else if(e.Name=="ca415t_plan")Planned(CaelumPlayer(players[consoleplayer].mo));
        else if(e.Name=="ca415t_planload")PlanLoaded();else if(e.Name=="ca415t_access")Access();
        else if(e.Name=="ca415t_doors")NativeDoors();else return;
        Console.Printf("CA415T RESULT passed=%d failed=%d",Passed,Failed);
    }
}
