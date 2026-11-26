class CA864StorageReference : Object play
{
    static clearscope bool NativeCarrierBody(Actor body)
    {return body is 'CaelumGateBlocker' || body is 'CaelumVehiclePart';}
    static CaelumContaminationState Get(Actor body,bool create=false,bool raw=false)
    {
        if(body==null || body is 'CaelumPlayer')return null;
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.ContaminationBodyReady && (npc.ContaminationBody!=null || !create))
        {
            if(create)npc.ContaminationBody.Ensure();
            return npc.ContaminationBody;
        }
        if(NativeCarrierBody(body))return GetCarrier(body,create,npc);
        if(CaelumContaminationStack.Eligible(Inventory(body)))return CaelumContaminationStack.Record(Inventory(body),create);
        let proxy=CaelumDiningBlock(body);
        let dining=proxy!=null?proxy.Table:CaelumDiningTable(body);
        if(!raw && dining!=null && !dining.ContaminationMigrating)
        {
            CaelumDiningContamination.Ensure(dining);
            if(proxy!=null)return Get(dining,create,true);
        }
        let furniture=CaelumStorageFurnitureItem(body);
        if(furniture!=null)
        {
            if(furniture.ContaminationState==null && create)furniture.ContaminationState=new('CaelumContaminationState');
            if(furniture.ContaminationState!=null && create)furniture.ContaminationState.Ensure();
            return furniture.ContaminationState;
        }
        let decor=CaelumDecorBody(body);
        if(decor!=null && decor.PackedItem!=null)return Get(decor.PackedItem,create);
        let rest=CaelumRestFurniture(body);
        let table=CaelumPortableDiningTable(body);
        if(table!=null && table.PackedItem!=null)return Get(table.PackedItem,create);
        if(rest!=null && rest.PackedItem!=null)return Get(rest.PackedItem,create);
        let desk=CaelumPortableReadingDesk(body);
        if(desk!=null && desk.PackedItem!=null)return Get(desk.PackedItem,create);
        let sofa=CaelumSofa(body);
        if(sofa!=null && sofa.PackedItem!=null)return Get(sofa.PackedItem,create);
        let seat=CaelumSofaSeat(body);
        if(seat!=null)return seat.Sofa==null || seat.Sofa.bDestroyed?null:Get(seat.Sofa,create);
        let equipment=CaelumEquipmentItem(body);
        if(equipment!=null)
        {
            if(equipment.ContaminationState==null && create)
                equipment.ContaminationState=new('CaelumContaminationState');
            if(equipment.ContaminationState!=null && create)equipment.ContaminationState.Ensure();
            return equipment.ContaminationState;
        }
        return GetCarrier(body,create,npc);
    }
    static CaelumContaminationState GetCarrier(Actor body,bool create,CaelumCombatActor npc)
    {
        let carrier=CaelumContaminationCarrier(body.FindInventory('CaelumContaminationCarrier'));
        if(carrier==null && create)
        {
            carrier=CaelumContaminationCarrier(Actor.Spawn('CaelumContaminationCarrier',body.Pos,NO_REPLACE));
            if(carrier!=null){carrier.AttachToOwner(body);carrier.AttachmentRevision=1;}
        }
        if(carrier==null)
        {
            if(npc!=null)npc.ContaminationBodyReady=true;
            return null;
        }
        carrier.EnsureAttachment();
        if(carrier.State==null && create)carrier.State=new('CaelumContaminationState');
        if(carrier.State!=null && create)carrier.State.Ensure();
        if(npc!=null){npc.ContaminationBody=carrier.State;npc.ContaminationBodyReady=true;}
        return carrier.State;
    }
    static double Value(Actor body)
    {
        if(CaelumContaminationStack.Eligible(Inventory(body)))return CaelumContaminationStack.Value(Inventory(body));
        let remote=CaelumHouseStorageEntry.Remote(body);if(remote!=null)remote.SyncDirt();
        let user=CaelumPlayer(body);
        if(user!=null)return CaelumFoodIllness.Value(user);
        let entry=Get(body);
        // Contacto/recogida pueden ocurrir antes del primer tic tras cargar.
        // Cerrar primero el intervalo guardado o cargado, sin buscar otros actores.
        if(entry!=null && entry.Exposure!=null)entry.Exposure.SettleNow();
        return entry!=null && entry.Revision>=CaelumContaminationData.STATE_REVISION
            ? entry.Concentration : 0;
    }
}
class CA864ExposureReference : Object play
{
    static bool Eligible(Actor body)
    {
        let rock=CaelumTarotRock(body);if(rock!=null && rock.Contained)return false;
        if(body==null || body.bDestroyed || body is 'CaelumPlayer' || body is 'CaelumCombatActor' || body.bMissile)return false;
        // Estos cuerpos no pueden ser inventarios ni muebles con propietario delegado.
        if(CaelumContaminationStorage.NativeCarrierBody(body))
            return (body.bSolid || GetDefaultByType(body.GetClass()).bSolid) && body.Radius>0 && body.Height>0;
        let proxy=CaelumDiningBlock(body);
        if(proxy!=null)return proxy.Table!=null && proxy.Table.ContaminationMigrating;
        if(CaelumHouseStorageEntry.Remote(body)!=null)return false;
        let table=CaelumPortableDiningTable(body);
        let block=CaelumDiningBlock(body);if(block!=null)table=CaelumPortableDiningTable(block.Table);
        let diningSeat=CaelumRestChair(body);if(diningSeat!=null)table=CaelumPortableDiningTable(diningSeat.DiningTable);
        if(table!=null && table.Packed())return false;
        let decor=CaelumDecorBody(body);
        if(decor!=null && decor.PackedItem!=null && decor.PackedItem.Owner!=body)return false;
        let desk=CaelumPortableReadingDesk(body);
        if(desk!=null && desk.PackedItem!=null && desk.PackedItem.Owner!=body)return false;
        let shelf=CaelumPortableReadingShelf(body);
        if(shelf!=null && shelf.Storage!=null && shelf.Storage.Cargo!=null)return false;
        if(body is 'CaelumPortableBookcaseStorage')return false;
        let rest=CaelumRestFurniture(body);
        if(rest!=null && rest.PackedItem!=null && rest.PackedItem.Owner!=body)return false;
        let sofa=CaelumSofa(body);
        if(sofa!=null && sofa.PackedItem!=null && sofa.PackedItem.Owner!=body)return false;
        if(body is 'CaelumSofaSeat')return false;
        let vendor=CaelumCityMerchant(body);if(vendor!=null && vendor.DomesticMarketParked)return false;
        let item=Inventory(body);
        if(item!=null)return (item is 'CaelumEquipmentItem' || item is 'CaelumStorageFurnitureItem') && item.Owner==null;
        // Una silla ocupada presta su colisión al jugador, pero sigue siendo
        // un mueble expuesto. Su configuración física de clase no desaparece.
        return (body is 'CaelumDiningTable' || body is 'CaelumPhysicalScenery' || body.bSolid || GetDefaultByType(body.GetClass()).bSolid)
            && body.Radius>0 && body.Height>0;
    }
}

class CA864GateProbe : CaelumGateBlocker { override void Tick() {} }
class CA864VehicleProbe : CaelumVehiclePart { override void Tick() {} }
class CA864NpcProbe : CaelumCombatActor { override void Tick() {} }
class CA864CarrierChecks : EventHandler
{
    int Revision,Checks,Errors;
    Array<Actor> SavedBodies;
    void Check(bool good,String label)
    {Checks++;if(!good){Errors++;Console.Printf("CA864 FAIL %s",label);}}
    void Query(Actor body,bool create,bool raw)
    {
        let expected=CA864StorageReference.Get(body,create,raw);
        let actual=CaelumContaminationStorage.Get(body,create,raw);
        Check(actual==expected,"record identity");
        Check(CA864ExposureReference.Eligible(body)==CaelumContaminationObject.Eligible(body),"exposure eligibility");
    }
    void NativeRecord(Actor body)
    {
        let actual=CaelumContaminationStorage.Get(body,true);
        let carrier=CaelumContaminationCarrier(body.FindInventory('CaelumContaminationCarrier'));
        Check(actual!=null && carrier!=null && carrier.Owner==body && carrier.State==actual && carrier.AttachmentRevision>=1,"native carrier attachment");
        if(actual==null)return;
        Check(actual.Revision==CaelumContaminationData.STATE_REVISION,"created revision");
        actual.Revision=0;actual.Concentration=37;
        Query(body,false,false);Check(actual.Revision==0 && actual.Concentration==37,"read preserves legacy fields");
        Query(body,true,false);Check(actual.Revision==CaelumContaminationData.STATE_REVISION && actual.Concentration==0,"create ensures legacy fields");
    }
    void Exercise(CaelumPlayer user)
    {
        Query(null,false,false);Query(user,false,false);
        Array<class<Actor> > types={'CaelumGateBlocker','CaelumRamBlock','CaelumRamHead','CaelumCannonBlock','CaelumVehiclePart','CaelumGiantRat','CaelumShopSign','CaelumMaterialPickup'};
        for(int i=0;i<types.Size();i++)
        {
            let body=Actor.Spawn(types[i],user.Pos+(512,512,0),NO_REPLACE);
            Check(body!=null,"native class spawn");if(body==null)continue;
            if(i<6)NativeRecord(body);
            for(int raw=0;raw<2;raw++)for(int create=0;create<2;create++)Query(body,create!=0,raw!=0);
            bool solid=body.bSolid,missile=body.bMissile;double radius=body.Radius,height=body.Height;
            body.bSolid=false;Query(body,false,false);body.bSolid=solid;
            body.bMissile=true;Query(body,false,false);body.bMissile=missile;
            body.A_SetSize(0,height);Query(body,false,false);body.A_SetSize(radius,height);
            body.A_SetSize(radius,0);Query(body,false,false);body.A_SetSize(radius,height);
            let npc=CaelumCombatActor(body);
            if(npc!=null)
            {
                npc.ContaminationBodyReady=false;npc.ContaminationBody=null;
                let cold=CaelumContaminationStorage.Get(npc,false);
                Check(cold!=null && npc.ContaminationBody==cold && npc.ContaminationBodyReady,"cold NPC reconstruction");
                npc.ContaminationBodyReady=true;npc.ContaminationBody=null;
                Check(CaelumContaminationStorage.Get(npc,false)==null,"warm empty read");
                Check(CaelumContaminationStorage.Get(npc,true)==cold,"warm empty creation resolves native carrier");
                Query(npc,true,true);
            }
            body.Destroy();
        }
        for(Inventory item=user.Inv;item!=null;item=item.Inv)Query(item,false,false);
    }
    void Seed(CaelumPlayer user)
    {
        Array<class<Actor> > types={'CA864GateProbe','CA864VehicleProbe','CA864NpcProbe'};
        for(int i=0;i<types.Size();i++)
        {
            let body=Actor.Spawn(types[i],user.Pos+(1024+i*128,1024,0),NO_REPLACE);SavedBodies.Push(body);
            let entry=CaelumContaminationStorage.Get(body,true);Check(entry!=null,"saved record seed");
            if(entry!=null)
            {
                entry.Concentration=37+i;entry.EnsurePhysiology();entry.DiseaseFraction=0.25;
            }
        }
        Revision=1;
    }
    void Benchmark()
    {
        for(int bodyIndex=0;bodyIndex<SavedBodies.Size();bodyIndex++)
        {
            let body=SavedBodies[bodyIndex];double expected=CA864StorageReference.Value(body);
            for(int mode=0;mode<2;mode++)
            {
                let entry=CaelumContaminationStorage.Get(body,true);
                if(mode==1 && bodyIndex<2)
                {
                    if(entry.Exposure!=null)entry.Exposure.Release();
                    let world=CaelumThermalWorld.Get();Check(world!=null && world.ReferenceClock!=null,"benchmark clock");
                    let exposure=new('CaelumContaminationObject');exposure.Body=body;exposure.Revision=4;
                    exposure.Ready=true;exposure.HistoryReady=true;exposure.HistoryNoWash=true;
                    exposure.Stamp=CaelumThermalRuntime.Stamp(world.ReferenceClock);exposure.HistoryStamp=exposure.Stamp;
                    exposure.HistoryAmbient=entry.Concentration;exposure.HistoryArea=1;entry.Exposure=exposure;
                }
                double original=0,candidate=0;int differences=0;
                for(int round=0;round<16;round++)for(int order=0;order<2;order++)
                {
                    bool current=(round+order)%2==0;double start=MSTimeF();
                    if(current){for(int n=0;n<10000;n++)if(CaelumContaminationStorage.Value(body)!=expected)differences++;}
                    else {for(int n=0;n<10000;n++)if(CA864StorageReference.Value(body)!=expected)differences++;}
                    double elapsed=MSTimeF()-start;if(current)candidate+=elapsed;else original+=elapsed;
                }
                Check(differences==0,"value benchmark parity");
                Console.Printf("CA864 VALUE_BENCH class=%s mode=%d calls_each=160000 original_ms=%.6f candidate_ms=%.6f mismatches=%d",body.GetClassName(),mode,original,candidate,differences);
            }
        }
    }
    void ValueMatrix(CaelumPlayer user)
    {
        Check(CaelumContaminationStorage.Value(null)==CA864StorageReference.Value(null),"null value");
        Check(CaelumContaminationStorage.Value(user)==CA864StorageReference.Value(user),"player value");
        Array<class<Actor> > types={'CA864GateProbe','CA864VehicleProbe','CaelumMachineBlock','CaelumRamBlock','CaelumRamHead','CaelumCannonBlock','CA864NpcProbe'};
        let world=CaelumThermalWorld.Get();Check(world!=null && world.ReferenceClock!=null,"matrix clock");
        if(world==null || world.ReferenceClock==null)return;
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        for(int typeIndex=0;typeIndex<types.Size();typeIndex++)for(int mode=0;mode<8;mode++)
        {
            let first=Actor.Spawn(types[typeIndex],user.Pos+(1536,1536,0),NO_REPLACE);
            let second=Actor.Spawn(types[typeIndex],user.Pos+(1792,1536,0),NO_REPLACE);
            Check(first!=null && second!=null,"paired native bodies");
            if(first==null || second==null)continue;
            let a=CaelumContaminationStorage.Get(first,true),b=CaelumContaminationStorage.Get(second,true);
            Check(a!=null && b!=null && a!=b,"independent records");
            a.Concentration=17;b.Concentration=17;
            if(a.Exposure!=null)a.Exposure.Release();if(b.Exposure!=null)b.Exposure.Release();
            if(mode>0)
            {
                let x=new('CaelumContaminationObject'),y=new('CaelumContaminationObject');
                x.Body=first;y.Body=second;x.Revision=4;y.Revision=4;
                x.Ready=mode!=1 && mode!=7;y.Ready=x.Ready;x.HistoryReady=mode>=3;y.HistoryReady=x.HistoryReady;
                x.Stamp=now-(mode==2?10:0);y.Stamp=x.Stamp;
                x.Ambient=72;y.Ambient=72;x.Rain=0;y.Rain=0;
                x.HistoryStamp=now+(mode==5?10:mode==4?0:-10);y.HistoryStamp=x.HistoryStamp;
                x.HistoryAmbient=72;y.HistoryAmbient=72;x.HistoryArea=1;y.HistoryArea=1;
                x.HistoryNoWash=true;y.HistoryNoWash=true;
                a.Exposure=x;b.Exposure=y;
                if(mode==6){a.Revision=0;b.Revision=0;}
            }
            int phase=world.NextPhase;
            double expected=CA864StorageReference.Value(first);int afterPhase=world.NextPhase;
            world.NextPhase=phase;double actual=CaelumContaminationStorage.Value(second);
            Check(actual==expected,"value matches original");
            Check(a.Concentration==b.Concentration && a.Revision==b.Revision,"record effects match");
            Check(world.NextPhase==afterPhase,"world scheduling effects match");
            if(a.Exposure!=null && b.Exposure!=null)
            {
                let x=a.Exposure,y=b.Exposure;
                Check(x.Ready==y.Ready && x.Stamp==y.Stamp && x.HistoryStamp==y.HistoryStamp && x.HistoryReady==y.HistoryReady,"settlement effects match");
                x.Release();y.Release();
            }
            first.Destroy();second.Destroy();
        }
    }
    void IsolatePersistence()
    {
        for(int i=0;i<SavedBodies.Size();i++)
        {
            let body=SavedBodies[i];
            // Fixture-only flag blocks event-driven exposure registration after benchmarking.
            body.bMissile=true;
            let entry=CaelumContaminationStorage.Get(body,false);
            if(entry.Exposure!=null)entry.Exposure.Release();
            Check(!CaelumContaminationObject.Eligible(body) && entry.Exposure==null,"persistence exposure isolated");
        }
    }
    void Resume()
    {
        Check(Revision==1 && SavedBodies.Size()==3,"saved fixture revision");
        for(int i=0;i<SavedBodies.Size();i++)
        {
            let body=SavedBodies[i];Check(body!=null,"saved native body");if(body==null)continue;
            let entry=CaelumContaminationStorage.Get(body,false);
            let carrier=CaelumContaminationCarrier(body.FindInventory('CaelumContaminationCarrier'));
            Check(entry!=null && carrier!=null && carrier.Owner==body && carrier.State==entry,"saved attachment/record identity");
            if(entry!=null)Check(entry.Concentration==37+i && entry.DiseaseFraction==0.25 && entry.Revision==CaelumContaminationData.STATE_REVISION,"saved fields");
            Query(body,true,false);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca849_check")return;Checks=Errors=0;
        let user=CaelumPlayer(players[e.Player].mo);
        if(Revision!=0)Resume();Exercise(user);ValueMatrix(user);if(Revision==0){Seed(user);Benchmark();IsolatePersistence();}
        Console.Printf("CA864 CARRIER_CHECKS checks=%d errors=%d",Checks,Errors);
    }
}
