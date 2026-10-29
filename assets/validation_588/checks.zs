class CA411PObstacle : Actor
{
    Default {Radius 8;Height 64;+SOLID +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA411PRecord : Inventory
{
    CaelumChestCargo Cargo;
    Inventory Contents;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
}
class CA411PChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String message)
    {if(ok)Passed++;else Failed++;Console.Printf("CA411P %s %s",ok?"PASS":"FAIL",message);}
    void Prepare(CaelumPlayer u)
    {
        u.CreationWizardOpen=false;u.bInvulnerable=true;u.CancelCraftingTask();
        u.ClosePalomoMerchant();u.CloseCraftingStationSession();u.Vel=(0,0,0);u.Angle=0;
        u.SetOrigin((64,128,0),false);u.DerivedStats.CarryCapacity=1000;
    }
    bool Fits(CaelumPlayer u,double x,double y,double z=0,double radius=16,double height=30)
    {return CaelumPlacementGeometry.Fits(u,(x,y,z),radius,height);}
    void Core(CaelumPlayer u)
    {
        Prepare(u);
        Check(Fits(u,128,128),"dry level ground accepts the full footprint");
        Check(!Fits(u,8,128),"solid wall overlap rejected");
        Check(!Fits(u,128,8),"corner support cannot extend beyond wall");
        Check(!Fits(u,256,128),"footprint spanning a step rejected");
        Check(Fits(u,384,128,16),"flat raised ground accepts its actual elevation");
        Check(!Fits(u,384,128,0),"placement below the floor rejected");
        Check(!Fits(u,128,128,8),"unsupported floating placement rejected");
        Check(!Fits(u,640,128,0,16,60),"full object height checked under low ceiling");
        Check(!Fits(u,896,128),"liquid floor rejected even without deep water");
        let narrow=CaelumPlacementProbe(Actor.Spawn('CaelumPlacementProbe',(1792,128,0),NO_REPLACE));
        let nearLines=BlockLinesIterator.Create(narrow,48);
        while(nearLines.Next())
        {
            let line=nearLines.CurLine;
            if(line.v1.p.X<1700 || line.v1.p.X>1900)continue;
            Console.Printf("CA411P STRIP line=(%.2f %.2f)-(%.2f %.2f) back=%d crosses=%d",line.v1.p.X,line.v1.p.Y,line.v2.p.X,line.v2.p.Y,line.backsector!=null,CaelumPlacementGeometry.CrossesBox(line.v1.p,line.v2.p,(1792,128),32));
        }
        bool narrowSupport=CaelumPlacementGeometry.Supported(narrow,(1800.01,128,0),30);
        let nt=narrow.CurSector.GetFloorTerrain(Sector.floor);
        Console.Printf("CA411P STRIP support=%d liquid=%d terrain=%s floor=%.2f pos=%.2f",narrowSupport,nt.IsLiquid,nt.TerrainName,narrow.FloorZ,narrow.Pos.X);
        narrow.Destroy();
        Check(!Fits(u,1792,128,0,32),"narrow liquid strip between footprint samples rejected");
        Check(!Fits(u,2176,128),"3D swimmable water volume rejected");
        Check(Fits(u,2432,128),"dry solid 3D floor above a liquid basement remains usable");
        Check(Fits(u,2560,128),"continuous dry 3D support ignores an unrelated basement step");
        Check(!Fits(u,1264,128),"open door linedef clearance preserved");
        Check(!Fits(u,1520,128),"cross-map transition clearance preserved");
        Check(Fits(u,1152,128),"ordinary dry two-sided sector boundary allowed");
        Check(!Fits(u,u.Pos.X,u.Pos.Y),"player body cannot be enclosed by placed solid");
        let obstacle=Actor.Spawn('CA411PObstacle',(128,128,0),NO_REPLACE);
        Check(!Fits(u,128,128),"local solid actor overlap rejected");
        obstacle.SetOrigin((128,128,64),false);
        Check(Fits(u,128,128),"vertically separated actor does not block ground placement");
        obstacle.Destroy();
        let door=CaelumSlidingDoorLeaf(Actor.Spawn('CaelumSlidingDoorLeaf',(192,128,0),NO_REPLACE));
        door.ClosedPosition=(128,128,0);door.bSolid=false;
        Check(!Fits(u,128,128),"retracted sliding leaf preserves its closed doorway");
        door.Destroy();
        Check(CaelumPlacementGeometry.CrossesBox((-3,0),(3,0),(0,0),1),"segment crossing rectangle detected");
        Check(!CaelumPlacementGeometry.CrossesBox((-3,3),(3,3),(0,0),1),"parallel separated segment excluded");
        Check(CaelumPlacementGeometry.CrossesBox((1,1),(3,3),(0,0),1),"corner contact retained");
        Check(!CaelumPlacementGeometry.CrossesBox((2,0),(0,3),(0,0),1),"diagonal separated segment excluded");
        Check(!Fits(u,128,128,0,0),"invalid geometry rejected without allocation");
        let it=ThinkerIterator.Create('CaelumPlacementProbe');
        Check(it.Next()==null,"temporary placement probes are cleaned up");
    }
    CaelumStashChest Carry(CaelumPlayer u)
    {
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(0,48,0),NO_REPLACE));
        chest.EnsureStorage();chest.StorageTier=0;chest.ApplyStorageSize();
        let contents=Inventory(Actor.Spawn('CaelumLifePotion',u.Pos,NO_REPLACE));
        contents.Amount=3;contents.AttachToOwner(chest);
        let record=CA411PRecord(u.FindInventory('CA411PRecord'));
        if(record==null)record=CA411PRecord(u.GiveInventoryType('CA411PRecord'));
        record.Contents=contents;
        Check(CaelumInventoryService.CarryStorageChest(u,chest),"native chest acquisition succeeds");
        record.Cargo=chest.Cargo;return chest;
    }
    void Storage(CaelumPlayer u)
    {
        Prepare(u);u.SetOrigin((95,128,0),false);
        let chest=Carry(u);let cargo=chest.Cargo;
        let record=CA411PRecord(u.FindInventory('CA411PRecord'));
        u.SetOrigin((223,128,0),false);
        Check(!chest.TryPlaceStorage(u),"real chest placement rejects step");
        Check(chest.Cargo==cargo && cargo.Owner==u && record.Contents.Owner==chest
            && record.Contents.Amount==3 && chest.bInvisible && !chest.bSolid,"failed placement retains exact cargo and contents");
        u.SetOrigin((863,128,0),false);
        Check(!chest.TryPlaceStorage(u) && chest.Cargo==cargo,"real chest placement rejects water atomically");
        u.SetOrigin((1231,128,0),false);
        Check(!chest.TryPlaceStorage(u) && chest.Cargo==cargo,"real chest placement preserves open doorway");
        u.SetOrigin((95,128,0),false);
        Check(chest.TryPlaceStorage(u),"real chest places on free dry stable ground");
        Check(chest.Cargo==null && record.Contents.Owner==chest && record.Contents.Amount==3
            && !chest.bInvisible && chest.bSolid,"successful placement retains exact content without duplication");
        record.Cargo=null;chest.Destroy();record.Contents.Destroy();record.Contents=null;
    }
    void Seed(CaelumPlayer u)
    {Prepare(u);Carry(u);u.PersistCharacterState();}
    void Loaded(CaelumPlayer u)
    {
        let record=CA411PRecord(u.FindInventory('CA411PRecord'));
        bool ok=record!=null && record.Cargo!=null && record.Cargo.Owner==u
            && record.Cargo.Chest!=null && record.Cargo.Chest.Cargo==record.Cargo;
        Check(ok,"native save or hub retains actual carried chest");
        Check(ok && record.Contents!=null && record.Contents.Amount==3
            && record.Contents.Owner==record.Cargo.Chest,"native save or hub retains exact contents");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca411p_core')Core(u);
        else if(e.Name=='ca411p_storage')Storage(u);
        else if(e.Name=='ca411p_seed')Seed(u);
        else if(e.Name=='ca411p_loaded')Loaded(u);
        else if(e.Name=='ca411p_dry' || e.Name=='ca411p_step' || e.Name=='ca411p_water' || e.Name=='ca411p_door')
        {
            double x=e.Name=='ca411p_dry'?95:e.Name=='ca411p_step'?223:e.Name=='ca411p_water'?863:1231;
            u.SetOrigin((x,128,0),false);u.Angle=0;u.Vel=(0,0,0);return;
        }
        else if(e.Name=='ca411p_place')
        {
            let r=CA411PRecord(u.FindInventory('CA411PRecord'));
            bool placed=r!=null && r.Cargo!=null && r.Cargo.Chest!=null && r.Cargo.Chest.TryPlaceStorage(u);
            Console.Printf("CA411P placement %s",placed?"accepted":"rejected; carried contents preserved");return;
        }
        else if(e.Name=='ca411p_contents')
        {
            let r=CA411PRecord(u.FindInventory('CA411PRecord'));
            Console.Printf("CA411P contents=%d owner=%s",r!=null && r.Contents!=null?r.Contents.Amount:0,
                r!=null && r.Contents!=null && r.Contents.Owner!=null?r.Contents.Owner.GetClassName():'none');return;
        }
        else return;
        Console.Printf("CA411P RESULT passes=%d failures=%d",Passed,Failed);
    }
}
