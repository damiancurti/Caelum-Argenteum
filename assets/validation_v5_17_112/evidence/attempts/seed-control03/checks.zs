// Private native diagnostic: no fixture classes are distributed in the runtime.
class CA868GateProbe : CaelumGateBlocker { override void Tick() {} }
class CA868VehicleProbe : CaelumVehiclePart { override void Tick() {} }
class CA868NpcProbe : CaelumCombatActor { override void Tick() {} }
class CA868RatProbe : CaelumGiantRat { override void Tick() {} }
class CA868SavedContact : CaelumContaminationContact { override void Tick() {} }

class CA868Checks : EventHandler
{
    int Checks,Errors,Revision;
    CA868SavedContact SavedPair;
    double SavedFirst,SavedSecond;
    override void WorldLoaded(WorldEvent e)
    {Console.Printf("CA868 WORLD_LOADED save=%d tic=%d",e.IsSaveGame,level.maptime);}
    void Check(bool good,String label)
    {Checks++;if(!good){Errors++;Console.Printf("CA868 FAIL %s",label);}}
    void Same(CaelumContaminationContactPoint a,CaelumContaminationContactPoint b,String label)
    {
        Check((a==null)==(b==null),label.." presence");
        if(a==null || b==null)return;
        Check(a.Body==b.Body,label.." body");Check(a.Record==b.Record,label.." record");
        Check(a.Dose==b.Dose,label.." dose");
    }
    void Query(Actor body,int slot)
    {
        Same(CA868Reference.Exterior(body,slot),CaelumContaminationCombat.Exterior(body,slot),"fresh exterior");
        let a=new('CaelumContaminationContactPoint'),b=new('CaelumContaminationContactPoint');
        let entry=new('CaelumContaminationState');entry.Ensure();entry.Concentration=37;
        a.Body=null;a.Record=entry;a.Dose=123;b.Body=null;b.Record=entry;b.Dose=123;
        let expected=CA868Reference.Exterior(body,slot,a),actual=CaelumContaminationCombat.Exterior(body,slot,b);
        Same(expected,actual,"reused exterior");
        Check((expected==a)==(actual==b),"reuse identity");
        if(actual==null){Same(a,b,"rejected reuse retained");Check(b.Record==entry && b.Dose==123,"rejection does not overwrite");}
        Same(CA868Reference.ActorPoint(body,a),CaelumContaminationCombat.ActorPoint(body,b),"direct actor fallback");
    }
    void Matrix(CaelumPlayer user)
    {
        Query(null,0);
        Array<class<Actor> > types={'CA868GateProbe','CA868VehicleProbe','CaelumRamBlock','CaelumRamHead','CaelumCannonBlock','CA868NpcProbe','CA868RatProbe','CaelumShopSign','CaelumMaterialPickup','CaelumTarotRock'};
        for(int i=0;i<types.Size();i++)
        {
            let body=Actor.Spawn(types[i],user.Pos+(512,512,0),NO_REPLACE);
            Check(body!=null,"spawn matrix");if(body==null)continue;
            for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)Query(body,slot);
            body.Mass=40;Query(body,0);body.Mass=160;Query(body,0);
            let npc=CaelumCombatActor(body);
            if(npc!=null)
            {
                npc.CombatArmor=new('CaelumArmorModel');npc.CombatArmor.InitializeDefaults();
                for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
                {
                    Query(body,slot);
                    let point=CaelumContaminationCombat.Exterior(body,slot);
                    Check(CaelumThermalBody.FurryAnimal(body)?point.Body==body:point.Record==npc.CombatArmor.ContaminationState[slot],"armor versus fur authority");
                }
                npc.CombatArmor=null;Query(body,0);
            }
            let material=CaelumMaterialPickup(body);
            if(material!=null)
            {
                material.InMagicBox=true;Query(body,0);
                Check(CaelumContaminationCombat.Exterior(body,0)==null,"Box shields");
                material.InMagicBox=false;Query(body,0);
                let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',user.Pos+(768,768,0),NO_REPLACE));
                material.BecomeItem();chest.AddInventory(material);chest.ChestOpen=false;
                Query(body,0);Check(CaelumContaminationCombat.Exterior(body,0)==null,"closed chest shields");
                chest.ChestOpen=true;Query(body,0);
                Check(CaelumContaminationCombat.Exterior(body,0)!=null,"open chest exposes");
                chest.RemoveInventory(material);chest.Destroy();
            }
            let rock=CaelumTarotRock(body);
            if(rock!=null)
            {
                rock.Contained=true;Query(body,0);Check(CaelumContaminationCombat.Exterior(body,0)==null,"contained rock shields");
                rock.Contained=false;Query(body,0);
            }
            body.Destroy();
        }
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)Query(user,slot);
        let stats=user.DerivedStats;
        user.DerivedStats=null;Query(user,0);user.DerivedStats=stats;
        if(stats!=null)
        {
            double mass=stats.BaseMass;stats.BaseMass=40;Query(user,0);stats.BaseMass=160;Query(user,0);stats.BaseMass=mass;
        }
        let entry=new('CaelumContaminationState'),point=new('CaelumContaminationContactPoint');
        point.Body=user;point.Record=null;point.Dose=123;
        Check(CaelumContaminationCombat.ModelPoint(entry,point)==point && point.Body==null && point.Record==entry && point.Dose==1,"body-to-model resets");
        Check(CaelumContaminationCombat.ModelPoint(null,point)==null && point.Record==entry,"null model preserves rejected reuse");
        let gate=Actor.Spawn('CA868GateProbe',user.Pos+(1024,1024,0),NO_REPLACE);
        Check(CaelumContaminationCombat.Exterior(gate,0,point)==point && point.Body==gate && point.Record==null && point.Dose==1,"model-to-native resets");
        gate.Destroy();
    }
    void Benchmark(CaelumPlayer user)
    {
        Array<class<Actor> > types={'CA868GateProbe','CA868VehicleProbe','CA868NpcProbe','CA868RatProbe','CaelumMaterialPickup','CaelumShopSign'};
        for(int i=0;i<=types.Size();i++)
        {
            Actor body=i==types.Size()?Actor(user):Actor.Spawn(types[i],user.Pos+(1024,1024,0),NO_REPLACE);
            Check(body!=null,"benchmark body");if(body==null)continue;
            for(int armored=0;armored<(body is 'CA868NpcProbe'?2:1);armored++)
            {
                let npc=CaelumCombatActor(body);
                if(armored!=0){npc.CombatArmor=new('CaelumArmorModel');npc.CombatArmor.InitializeDefaults();}
                let point=new('CaelumContaminationContactPoint');
                double original=0,candidate=0;int count=0;
                for(int round=0;round<16;round++)for(int order=0;order<2;order++)
                {
                    bool current=(round+order)%2==0;double begin=MSTimeF();
                    if(current){for(int n=0;n<10000;n++)if(CaelumContaminationCombat.Exterior(body,0,point)==point)count++;}
                    else {for(int n=0;n<10000;n++)if(CA868Reference.Exterior(body,0,point)==point)count++;}
                    double duration=MSTimeF()-begin;if(current)candidate+=duration;else original+=duration;
                }
                Check(count==320000,"benchmark endpoint identity");
                Console.Printf("CA868 BENCH type=%s armor=%d calls=160000 original_ms=%.6f candidate_ms=%.6f",body.GetClassName(),armored,original,candidate);
            }
            if(body!=user)body.Destroy();
        }
    }
    void TransferCases(CaelumPlayer user)
    {
        for(int kind=0;kind<3;kind++)for(int direction=0;direction<3;direction++)
        {
            let first=Actor.Spawn('CA868GateProbe',user.Pos+(1536,1536,0),NO_REPLACE);
            let second=Actor.Spawn('CA868VehicleProbe',first.Pos,NO_REPLACE);
            first.bMissile=true;second.bMissile=true;
            if(kind==1)first.SetOrigin(second.Pos+(0,0,second.Height),false);
            if(kind==2)second.SetOrigin(first.Pos+(0,0,first.Height),false);
            let a=CaelumContaminationStorage.Get(first,true),b=CaelumContaminationStorage.Get(second,true);
            double x=direction==0?80:20,y=direction==2?20:direction==0?20:80;
            a.Concentration=x;b.Concentration=y;
            int sa=kind==1?CaelumConstants.ARMOR_SLOT_FEET:kind==2?CaelumConstants.ARMOR_SLOT_HEAD:CaelumConstants.ARMOR_SLOT_BODY;
            int sb=kind==2?CaelumConstants.ARMOR_SLOT_FEET:kind==1?CaelumConstants.ARMOR_SLOT_HEAD:CaelumConstants.ARMOR_SLOT_BODY;
            double area=kind==0?CaelumContaminationData.BODY_CONTACT_M2:CaelumContaminationData.FOOT_CONTACT_M2;
            CaelumContaminationCombat.Transfer(CA868Reference.Exterior(first,sa),CA868Reference.Exterior(second,sb),area,10);
            double expectedA=a.Concentration,expectedB=b.Concentration;
            a.Concentration=x;b.Concentration=y;
            let pair=new('CA868SavedContact');pair.First=first;pair.Second=second;
            pair.FirstPoint=new('CaelumContaminationContactPoint');pair.FirstPoint.Record=new('CaelumContaminationState');pair.FirstPoint.Dose=123;
            pair.Exchange(10);
            Check(a.Concentration==expectedA && b.Concentration==expectedB,"native pair transfer parity");
            Check(pair.FirstPoint.Body==first && pair.FirstPoint.Record==null && pair.FirstPoint.Dose==1,"pair resets stale model");
            Check(pair.SecondPoint.Body==second && pair.SecondPoint.Record==null && pair.SecondPoint.Dose==1,"pair initializes second");
            pair.Destroy();first.Destroy();second.Destroy();
        }
    }
    void Persistence(CaelumPlayer user)
    {
        if(Revision==0)
        {
            SavedPair=new('CA868SavedContact');
            SavedPair.First=Actor.Spawn('CA868GateProbe',user.Pos+(2048,2048,0),NO_REPLACE);
            SavedPair.Second=Actor.Spawn('CA868VehicleProbe',SavedPair.First.Pos,NO_REPLACE);
            SavedPair.First.bMissile=true;SavedPair.Second.bMissile=true;
            CaelumContaminationStorage.Set(SavedPair.First,80);CaelumContaminationStorage.Set(SavedPair.Second,20);
            CaelumContaminationContacts.Get(SavedPair.First,true).Pairs.Push(SavedPair);
            CaelumContaminationContacts.Get(SavedPair.Second,true).Pairs.Push(SavedPair);
            SavedPair.Revision=1;SavedPair.Exchange(10);Revision=1;
        }
        else
        {
            Check(SavedPair!=null && SavedPair.First!=null && SavedPair.Second!=null,"saved native pair and bodies");
            if(SavedPair==null)return;
            Check(SavedPair.FirstPoint==null && SavedPair.SecondPoint==null,"transient points omitted from save");
            let firstLinks=CaelumContaminationContacts.Get(SavedPair.First),secondLinks=CaelumContaminationContacts.Get(SavedPair.Second);
            Console.Printf("CA868 RESUME first=%s second=%s first_inventory=%s second_inventory=%s links=%d/%d",SavedPair.First.GetClassName(),SavedPair.Second.GetClassName(),SavedPair.First.Inv!=null?SavedPair.First.Inv.GetClassName():'None',SavedPair.Second.Inv!=null?SavedPair.Second.Inv.GetClassName():'None',firstLinks!=null,secondLinks!=null);
            Check(firstLinks!=null && secondLinks!=null,"saved contact records available");
            if(firstLinks==null || secondLinks==null)return;
            Check(firstLinks.Pairs.Size()>0 && secondLinks.Pairs.Size()>0,"saved pair lists nonempty");
            if(firstLinks.Pairs.Size()==0 || secondLinks.Pairs.Size()==0)return;
            Check(firstLinks.Pairs[0]==SavedPair && secondLinks.Pairs[0]==SavedPair,"saved symmetric links");
            Check(CaelumContaminationStorage.Value(SavedPair.First)==SavedFirst && CaelumContaminationStorage.Value(SavedPair.Second)==SavedSecond,"saved concentrations");
            double expected=CaelumContaminationRules.AfterContact(SavedSecond,SavedFirst,CaelumContaminationData.BODY_CONTACT_M2,10,1);
            SavedPair.Exchange(10);
            Check(SavedPair.FirstPoint.Body==SavedPair.First && SavedPair.SecondPoint.Body==SavedPair.Second,"lazy transient rebuild");
            Check(CaelumContaminationStorage.Value(SavedPair.Second)==expected,"resumed transfer");
        }
        SavedFirst=CaelumContaminationStorage.Value(SavedPair.First);SavedSecond=CaelumContaminationStorage.Value(SavedPair.Second);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca868_check" && e.Name!="ca868_seed" && e.Name!="ca868_matrix" && e.Name!="ca868_transfer" && e.Name!="ca868_bench")return;
        Checks=0;Errors=0;let user=CaelumPlayer(players[0].mo);
        Check(user!=null,"player available");if(user!=null)
        {
            if(e.Name=="ca868_check" || e.Name=="ca868_matrix")Matrix(user);
            if(e.Name=="ca868_check" || e.Name=="ca868_transfer")TransferCases(user);
            Persistence(user);
            if(e.Name=="ca868_check" || e.Name=="ca868_bench")Benchmark(user);
        }
        Console.Printf("CA868 RESULT checks=%d errors=%d",Checks,Errors);
    }
}
