class CA502ObjectProp : CaelumRestChair {}
class CA502ObjectHolder : Actor {States {Spawn:TNT1 A -1;Stop;}}
class CA502ObjectProof : Inventory {
    double Saved;
    bool HasGear;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502ObjectChecks : EventHandler {
    Actor Inside,Outside,Holder;
    CaelumEquipmentItem Item;
    int Passed,Failed;
    bool Manual;
    double StoredValue;
    String Reading,GearReading,AirReading;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502O %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    CaelumContaminationObject Node(Actor a){let entry=CaelumContaminationStorage.Get(a);return entry==null?null:entry.Exposure;}
    void Prepare(CaelumPlayer u){
        if(Inside==null){Inside=Actor.Spawn('CA502ObjectProp',(-64,64,0),NO_REPLACE);Inside.ChangeTid(905051);}
        if(Outside==null){Outside=Actor.Spawn('CA502ObjectProp',(64,64,0),NO_REPLACE);Outside.ChangeTid(905052);}
        if(Holder==null)Holder=Actor.Spawn('CA502ObjectHolder',(-128,64,0),NO_REPLACE);
        if(Item==null){
            Item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',(-64,-64,0),NO_REPLACE));
            Item.ItemId=905053;Item.ChangeTid(905053);Item.AcquisitionResolved=Item.PickupDataInitialized=true;
            Item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
            Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;Item.Amount=1;Item.Tier=1;Item.UnitWeight=1;
        }
        u.SetOrigin((-192,-128,0),false);u.Angle=48;
    }
    void Reset(){
        CaelumContaminationStorage.Set(Inside,0);CaelumContaminationStorage.Set(Outside,0);CaelumContaminationStorage.Set(Item,0);
        Node(Inside).Ready=false;Node(Inside).Advance();Node(Outside).Ready=false;Node(Outside).Advance();
        if(Item.Owner==null){Node(Item).Ready=false;Node(Item).Advance();}
    }
    void Core(CaelumPlayer u){
        Check(Node(Inside)!=null && Node(Outside)!=null,"native spawn event registers solid props");
        Check(Node(Item)!=null,"native loose equipment is registered");
        Check(!CaelumContaminationObject.Eligible(u) && !CaelumContaminationObject.Eligible(Holder),"player and nonsolid helper excluded");
        let n=Node(Inside);CaelumContaminationObject.Register(Inside);Check(Node(Inside)==n,"registration idempotent");
        Check(Near(CaelumContaminationObject.Area(Inside),4.125*CaelumThermalData.CIRCLE_PI),"real chair collision cylinder uses 32 units per metre");
        Check(Near(CaelumContaminationObject.Area(Item),0.16),"loose sword uses approved area not collision cylinder");
        Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_XL;
        Check(Near(CaelumContaminationObject.Area(Item),0.16*(1.5**(2.0/3.0))),"loose equipment scales geometric area by size");
        Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        Reset();Check(n.Ambient>0 && Node(Outside).Ambient>0,"actual indoor and outdoor climate resolve");
        n.Ambient=80;n.Rain=0;n.Stamp-=10;n.Advance();
        double expected=Sqrt(2*0.1*80*4.125*CaelumThermalData.CIRCLE_PI*10-1);
        Check(Near(CaelumContaminationStorage.Value(Inside),expected),"ten world seconds integrate cylinder area from zero");
        double once=CaelumContaminationStorage.Value(Inside);n.Advance();
        Check(CaelumContaminationStorage.Value(Inside)==once,"same clock never charges twice");
        let c=CaelumContaminationStorage.Get(Inside).Copy();
        Check(c.Exposure==null && c.Concentration==once,"state copy preserves concentration without sharing scheduler");
        let chair=CaelumRestChair(Inside);u.SetOrigin((-64,0,0),false);
        Check(chair.Seat(u) && !chair.bSolid,"native chair lends collision to occupant");
        n.Tick();Check(Node(Inside)==n && !n.bDestroyed,"occupied furniture retains environmental scheduler");
        u.SetOrigin((-192,-128,0),false);chair.Occupant=null;chair.RestoreSolid();
        CaelumContaminationStorage.Set(Item,20);let gear=Node(Item);gear.Ambient=80;gear.Rain=0;gear.Stamp-=10;
        Item.InMagicBox=true;Item.AttachToOwner(Holder);
        Check(Near(CaelumContaminationStorage.Value(Item),Sqrt(425.6)),"pickup closes exposed interval before ownership changes");
        Check(Node(Item)==null && Item.Owner==Holder,"owned equipment releases world scheduler");
        double stored=CaelumContaminationStorage.Value(Item);
        CaelumContaminationObject.Register(Item);Check(Node(Item)==null,"closed storage cannot register world exposure");
        Item.InMagicBox=false;Item=CaelumEquipmentItem(Item.CreateTossable(1));
        Check(Item!=null && Item.Owner==null && Node(Item)!=null,"native toss restores scheduler");
        Check(CaelumContaminationStorage.Value(Item)==stored,"toss retains dirt");
        let doomed=Actor.Spawn('CA502ObjectProp',(200,64,0),NO_REPLACE);CaelumContaminationObject.Register(doomed);let deadNode=Node(doomed);
        doomed.Destroy();deadNode.Tick();Check(deadNode==null || (deadNode.bDestroyed && deadNode.Body==null),"destroyed actor releases node safely");
    }
    void RainSetup(CaelumPlayer u){
        let calendar=CaelumCalendarState.Get(u),clock=CaelumWorldClock.Get(u),weather=CaelumWeatherState.Get(u);
        let sample=new('CaelumWeatherSample');int first=calendar.DateSerial(clock),day=first,hour=0;bool found=false;
        for(int d=first+1;d<first+90 && !found;d++)for(int h=6;h<22;h++){
            sample.EvaluateRegion(1,d,h*CaelumWorldClock.TicsPerHour(),weather.Seed);
            if(sample.PrecipitationMmPerHour>=2){day=d;hour=h;found=true;break;}}
        clock.AdvanceTics((day-first)*CaelumWorldClock.TicsPerDay()+hour*CaelumWorldClock.TicsPerHour()-calendar.CivilDayTics(clock));
        CaelumWeatherState.Sync(u,clock,calendar);
        Reset();CaelumContaminationStorage.Set(Inside,100);CaelumContaminationStorage.Set(Outside,100);
        Node(Inside).Advance();Node(Outside).Advance();
        Console.Printf("CA502O RAIN found=%d day=%d hour=%d profile=%d region=%d outside=%f inside=%f roof=%d weather=%f",found,day,hour,weather.Profile,weather.Region,Node(Outside).Rain,Node(Inside).Rain,CaelumThermalShelter.Roof(Outside),weather.Outside.PrecipitationMmPerHour);
        Check(found && Node(Outside).Rain>=2 && Node(Inside).Rain==0,"actual rain reaches outdoor prop but not roofed prop");
    }
    void HalfHour(){
        // Integrates the actual sampled conditions without simulating 30 minutes of unrelated AI.
        let a=Node(Inside),b=Node(Outside);double reduction=10+10*Clamp((b.Rain-2)/8.0,0.0,1.0);
        double before=CaelumContaminationStorage.Value(Outside);
        a.Stamp-=1800;b.Stamp-=1800;a.Advance();b.Advance();
        Check(CaelumContaminationStorage.Value(Inside)==100,"roofed prop retains concentration during rain");
        if(before>=b.Ambient+reduction)Check(Near(CaelumContaminationStorage.Value(Outside),before-reduction),"outdoor prop loses approved rain amount in thirty minutes");
    }
    void Save(CaelumPlayer u){
        let proof=CA502ObjectProof(u.GiveInventoryType('CA502ObjectProof'));
        proof.Saved=CaelumContaminationStorage.Value(Inside);
        Check(proof.Saved>0,"native scheduler advances stationary prop while clock runs");
        Item.InMagicBox=true;Item.AttachToOwner(u);CaelumContaminationStorage.Set(Item,31);proof.HasGear=true;
    }
    void Load(CaelumPlayer u,bool legacy){
        Inside=ActorIterator.Create(905051).Next();Outside=ActorIterator.Create(905052).Next();
        Check(Inside!=null && Outside!=null,"saved props restored");if(Inside==null || Outside==null)return;
        let a=Node(Inside),b=Node(Outside);
        Check(a!=null && b!=null && a.Revision==1 && b.Revision==1,"revisioned world exposure restored or migrated");
        let it=ThinkerIterator.Create('CaelumContaminationObject');CaelumContaminationObject n;int count=0;
        while((n=CaelumContaminationObject(it.Next()))!=null)if(n.Body==Inside)count++;
        Check(count==1,"load or hub reconstruction does not duplicate scheduler");
        if(legacy)Check(CaelumContaminationStorage.Value(Inside)==0 && CaelumContaminationStorage.Value(Outside)==80,"migration preserves concentration without historical dirt");
        else {let proof=CA502ObjectProof(u.FindInventory('CA502ObjectProof'));
            Check(proof!=null && CaelumContaminationStorage.Value(Inside)>=proof.Saved,"save or hub retains accumulated contamination");
            CaelumEquipmentItem gear;
            for(Inventory cursor=u.Inv;cursor!=null;cursor=cursor.Inv)if(cursor is 'CaelumEquipmentItem' && CaelumEquipmentItem(cursor).ItemId==905053)gear=CaelumEquipmentItem(cursor);
            Item=gear;
            if(proof!=null && proof.HasGear)Check(gear!=null && CaelumContaminationStorage.Value(gear)==31 && Node(gear)==null,"boxed sword travels without dangling map node or new exposure");}
    }
    override void WorldTick(){
        if(!Manual || Inside==null || Outside==null || Item==null)return;
        Reading=String.Format("Mueble interior: %.3f | exterior: %.3f | lluvia: %.2f mm/h",CaelumContaminationStorage.Value(Inside),CaelumContaminationStorage.Value(Outside),Node(Outside).Rain);
        GearReading=String.Format("Espada: %.3f | %s",CaelumContaminationStorage.Value(Item),Item.Owner==null?"expuesta":"guardada (protegida)");
        AirReading=String.Format("Indice ambiental: interior %.2f | exterior %.2f",Node(Inside).Ambient,Node(Outside).Ambient);
    }
    override void NetworkProcess(ConsoleEvent e){
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502o_prepare')Prepare(u);
        else if(e.Name=='ca502o_core')Core(u);
        else if(e.Name=='ca502o_reset'){Reset();Manual=true;}
        else if(e.Name=='ca502o_rain'){RainSetup(u);Manual=true;}
        else if(e.Name=='ca502o_halfhour')HalfHour();
        else if(e.Name=='ca502o_store'){Item.InMagicBox=true;Item.AttachToOwner(u);StoredValue=CaelumContaminationStorage.Value(Item);}
        else if(e.Name=='ca502o_stored_check')Check(Node(Item)==null && CaelumContaminationStorage.Value(Item)==StoredValue,"native clock never exposes stored equipment");
        else if(e.Name=='ca502o_dropped_check')Check(Node(Item)!=null && CaelumContaminationStorage.Value(Item)>StoredValue,"native clock resumes exposure after toss");
        else if(e.Name=='ca502o_drop'){if(Item.Owner!=null){Item.InMagicBox=false;Item=CaelumEquipmentItem(Item.CreateTossable(1));}}
        else if(e.Name=='ca502o_save')Save(u);
        else if(e.Name=='ca502o_load')Load(u,false);
        else if(e.Name=='ca502o_legacy')Load(u,true);
        else if(e.Name=='ca502o_read')Console.Printf("CA502O %s | %s",Reading,GearReading);
        else if(e.Name=='ca502o_math')MathChecks();
        else if(e.Name=='ca502o_census')Census();
        else return;Console.Printf("CA502O RESULT passed=%d failures=%d",Passed,Failed);
    }
    void MathChecks(){
        #include "math.zs"
    }
    void Census(){
        int population=0;let actors=ThinkerIterator.Create('Actor');while(actors.Next()!=null)population++;
        WorldEvent reload;double began=MSTimeF();CaelumContaminationWorld.Get().WorldLoaded(reload);
        double elapsed=MSTimeF()-began;int count=0;let nodes=ThinkerIterator.Create('CaelumContaminationObject');
        CaelumContaminationObject n;bool valid=true;
        while((n=CaelumContaminationObject(nodes.Next()))!=null){count++;if(!CaelumContaminationObject.Eligible(n.Body))valid=false;}
        Console.Printf("CA502O CENSUS map=%s actors=%d nodes=%d elapsed_ms=%.6f",level.MapName,population,count,elapsed);
        Check(count>0 && count<=population && valid,"campaign map retains only eligible physical-object schedulers");
    }
}
class CA502ObjectMenu : CaelumLiveMenu {
    override bool OnUIEvent(UIEvent e){
        if(e.Type==UIEvent.Type_KeyDown){String command="";
            if(e.KeyChar==UIEvent.Key_F1)command="ca502o_reset";
            else if(e.KeyChar==UIEvent.Key_F2)command="ca502o_read";
            else if(e.KeyChar==UIEvent.Key_F3)command="ca502o_store";
            else if(e.KeyChar==UIEvent.Key_F4)command="ca502o_drop";
            else if(e.KeyChar==UIEvent.Key_F5)command="ca502o_rain";
            else if(e.KeyChar==UIEvent.Key_F6)command="ca502o_halfhour";
            if(command.Length()>0){EventHandler.SendNetworkEvent(command);return true;}}
        return Super.OnUIEvent(e);
    }
    override void Drawer(){Super.Drawer();let c=CA502ObjectChecks(EventHandler.Find('CA502ObjectChecks'));if(c==null || !c.Manual)return;
        let f=Font.GetFont('CaelumMono');Screen.Dim(0x000000,0.9,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.27));
        Screen.DrawText(f,Font.CR_GOLD,8,8,"#502 Objetos expuestos: cambian los muebles y la espada",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,24,c.Reading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,40,c.GearReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,56,c.AirReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,72,"F1 limpiar | F2 leer | F3 guardar | F4 soltar | F5 lluvia | F6 simula30min",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
}
