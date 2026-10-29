// Native collision, persistence and contact-only laboratory. No thermal AI ticks.
class CA502ContactRat : CaelumGiantRat {
    Default {Radius 16;Height 56;}
    override void Tick(){}
    States {Spawn:RATG A -1;Stop;}
}
class CA502ContactSoldier : CaelumPortDefender {override void Tick(){}}
class CA502ContactProp : Actor {
    Default {Radius 16;Height 56;+SOLID +NOGRAVITY}
    States {Spawn:RATG A -1;Stop;}
}
class CA502ContactProof : Inventory {
    CA502ContactRat SourceBody,Recipient;
    double Saved;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502ContactChecks : EventHandler {
    CA502ContactRat SourceBody,Recipient;
    CA502ContactSoldier Armored;
    int Passed,Failed;bool Manual;double FrozenValue;
    String Reading;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502C %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    void Prepare(CaelumPlayer u){
        if(SourceBody==null)SourceBody=CA502ContactRat(Actor.Spawn('CA502ContactRat',(-80,0,0),NO_REPLACE));
        if(Recipient==null)Recipient=CA502ContactRat(Actor.Spawn('CA502ContactRat',(-48,0,0),NO_REPLACE));
        SourceBody.Mass=Recipient.Mass=80;SourceBody.DisableCaelumImpactContacts=Recipient.DisableCaelumImpactContacts=true;
        SourceBody.health=Recipient.health=10000;
        SourceBody.bNoGravity=Recipient.bNoGravity=true;
        if(Armored==null)Armored=CA502ContactSoldier(Actor.Spawn('CA502ContactSoldier',(160,0,0),NO_REPLACE));
        u.SetOrigin((-160,-120,0),false);u.Angle=55;
    }
    void Reset(){
        SourceBody.SetOrigin((-80,0,0),false);Recipient.SetOrigin((-48,0,0),false);
        CaelumContaminationStorage.Set(SourceBody,80);CaelumContaminationStorage.Set(Recipient,20);
    }
    void Join(){
        Recipient.SetOrigin((-48,0,0),false);
        SourceBody.TryMove((-79,0),0);
    }
    void Separate(){Recipient.SetOrigin((80,0,0),false);FrozenValue=CaelumContaminationStorage.Value(Recipient);}
    void Core(CaelumPlayer u){
        Reset();Join();
        let links=CaelumContaminationContacts.Get(SourceBody);
        Check(links!=null && links.Pairs.Size()==1,"native TryMove registers contact without diagnostic callback");
        if(links==null || links.Pairs.Size()!=1)return;
        let pair=links.Pairs[0];
        double firstDose=CaelumContaminationStorage.Value(Recipient);
        Check(Near(firstDose,CaelumContaminationRules.AfterContact(20,80,0.1,CaelumThermalRuntime.WorldTicSeconds())),"first native collision transfers exactly one world tic");
        let opposite=CaelumContaminationContacts.Get(Recipient);
        Check(opposite!=null && opposite.Pairs.Size()==1,"passive endpoint has one link");
        if(opposite==null || opposite.Pairs.Size()!=1)return;
        Check(opposite.Pairs[0]==pair,"active and passive bodies share one serialized pair");
        for(int i=0;i<20;i++){SourceBody.TryMove((-79,0),0);Recipient.TryMove((-49,0),0);}
        Check(links.Pairs.Size()==1 && CaelumContaminationStorage.Value(Recipient)==firstDose,"repeated native collisions do not duplicate pair or first-tic dose");
        CaelumContaminationStorage.Set(Recipient,20);
        pair.Exchange(10);
        Check(Near(CaelumContaminationStorage.Value(Recipient),Sqrt(416)),"ten world seconds of body brushing use 0.10 square metres");
        Check(CaelumContaminationStorage.Value(SourceBody)==80,"source concentration is retained");
        let world=CaelumThermalWorld.Get();pair.Rebase();CaelumContaminationStorage.Set(Recipient,20);
        world.ReferenceClock.AdvanceTics(35);pair.Tick();
        Check(Near(CaelumContaminationStorage.Value(Recipient),CaelumContaminationRules.AfterContact(20,80,0.1,20)),"calendar advance uses world seconds once");
        double once=CaelumContaminationStorage.Value(Recipient);pair.Tick();
        Check(CaelumContaminationStorage.Value(Recipient)==once,"repeated update at the same clock does not transfer twice");
        CaelumContaminationStorage.Set(Recipient,20);Recipient.Mass=40;pair.Exchange(10);
        Check(Near(CaelumContaminationStorage.Value(Recipient),Sqrt(432)),"body dose doubles at 40kg");Recipient.Mass=80;
        CaelumContaminationStorage.Set(Recipient,80);pair.Exchange(10);
        Check(CaelumContaminationStorage.Value(Recipient)==80,"equal concentrations do not transfer");
        CaelumContaminationStorage.Set(SourceBody,20);CaelumContaminationStorage.Set(Recipient,80);pair.Exchange(10);
        Check(Near(CaelumContaminationStorage.Value(SourceBody),Sqrt(416)),"transfer reverses toward the cleaner body");
        CaelumContaminationStorage.Set(SourceBody,80);CaelumContaminationStorage.Set(Recipient,20);
        Recipient.SetOrigin((-80,0,56),false);pair.Exchange(10);
        Check(Near(CaelumContaminationStorage.Value(Recipient),Sqrt(406.4)),"standing contact uses foot area 0.04 square metres");
        let soldier=Armored;
        soldier.DisableCaelumImpactContacts=true;
        pair.Second=soldier;CaelumContaminationCombat.Exterior(soldier,1).Set(20);CaelumContaminationStorage.Set(soldier,0);
        pair.Exchange(10);
        Check(Near(CaelumContaminationCombat.Exterior(soldier,1).Value(),Sqrt(416)),"NPC outer armor receives brushing first");
        Check(CaelumContaminationStorage.Value(soldier)==0,"brushing does not bypass armor into the body");
        let reused=pair.SecondPoint;pair.Exchange(1);
        Check(pair.SecondPoint==reused,"unchanged endpoint reuses allocation");
        pair.Second=Recipient;soldier.Destroy();
        let prop=CA502ContactProp(Actor.Spawn('CA502ContactProp',(160,0,0),NO_REPLACE));
        pair.Second=prop;CaelumContaminationStorage.Set(prop,20);pair.Exchange(10);
        Check(Near(CaelumContaminationStorage.Value(prop),Sqrt(416)),"ordinary solid object receives persistent contamination");
        pair.Second=Recipient;prop.Destroy();
        Recipient.SetOrigin((-48,0,0),false);Recipient.bNoClip=true;pair.Tick();Recipient.bNoClip=false;
        Check(links.Pairs.Size()==0 && opposite.Pairs.Size()==0,"invalid collision removes both references");
        Reset();Join();pair=links.Pairs[0];pair.LastCollisionTic=-1;Separate();pair.Tick();
        Check(links.Pairs.Size()==0,"separation ends the pair immediately");
        Reset();SourceBody.SetOrigin((-82,0,0),false);Join();pair=links.Pairs[0];
        Check(CaelumContaminationStorage.Value(Recipient)>20,"brief blocked collision transfers even with a remaining geometric gap");
        pair.LastCollisionTic=-1;pair.Tick();Check(links.Pairs.Size()==0,"brief collision cannot persist across a gap");
        Reset();Join();pair=links.Pairs[0];Recipient.Destroy();pair.Tick();
        Check(links.Pairs.Size()==0,"destroyed actor releases surviving endpoint");Recipient=null;Prepare(u);Reset();Join();
        Separate();u.SetOrigin((-48,0,0),false);u.TryMove((-49,0),0);
        Check(CaelumContaminationContacts.Active(u),"player collision hook participates");
        let forecast=new('CaelumTimeSkipModel');forecast.CaptureSkip(u,false);
        Check(forecast.Done && forecast.Reason=="CA_SKIP_FORECAST_EFFECT","calendar refuses an exact forecast across a mutable actor contact");
        u.SetOrigin((-160,-120,0),false);
    }
    void Save(CaelumPlayer u){
        SourceBody.ChangeTid(905041);Recipient.ChangeTid(905042);
        let p=CA502ContactProof(u.GiveInventoryType('CA502ContactProof'));p.SourceBody=SourceBody;p.Recipient=Recipient;
        p.Saved=CaelumContaminationStorage.Value(Recipient);
        Check(p.Saved>20,"native thinker advances contamination while bodies remain still");
    }
    void Load(CaelumPlayer u){
        let p=CA502ContactProof(u.FindInventory('CA502ContactProof'));
        let sources=ActorIterator.Create(905041),recipients=ActorIterator.Create(905042);
        SourceBody=CA502ContactRat(sources.Next());Recipient=CA502ContactRat(recipients.Next());
        Check(p!=null && SourceBody!=null && Recipient!=null,"saved contact bodies restored");
        if(p==null || SourceBody==null || Recipient==null)return;
        Check(sources.Next()==null && recipients.Next()==null,"hub restores each body exactly once");
        let a=CaelumContaminationContacts.Get(SourceBody),b=CaelumContaminationContacts.Get(Recipient);
        Check(a!=null && b!=null && a.Pairs.Size()==1 && b.Pairs.Size()==1 && a.Pairs[0]==b.Pairs[0],"saved pair has one identity and two endpoints");
        Check(CaelumContaminationStorage.Value(Recipient)>=p.Saved,"save or hub retains received contamination");
        Check(CaelumContaminationStorage.Value(SourceBody)==80,"save or hub retains source concentration");
        if(a!=null && a.Pairs.Size()==1){let pair=a.Pairs[0];double before=CaelumContaminationStorage.Value(Recipient);pair.Exchange(10);
            Check(Near(CaelumContaminationStorage.Value(Recipient),CaelumContaminationRules.AfterContact(before,80,0.1,10)),"restored pair continues with the same law");}
    }
    override void WorldTick(){
        if(!Manual || SourceBody==null || Recipient==null)return;
        Reading=String.Format("Fuente: %.3f | Receptor: %.3f | Contacto: %s",CaelumContaminationStorage.Value(SourceBody),
            CaelumContaminationStorage.Value(Recipient),CaelumContaminationContacts.Active(Recipient)?"SI":"NO");
    }
    override void RenderOverlay(RenderEvent e){
        if(!Manual)return;let f=SmallFont;Screen.Dim(0x000000,0.9,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.20));
        Screen.DrawText(f,Font.CR_GOLD,8,8,"#502 Roce sostenido: fuente 80, receptor 20",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,26,Reading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,8,44,"F1 reiniciar | F2 informar | F3 separar | F4 juntar | F6 consola",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
    override void NetworkProcess(ConsoleEvent e){
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502c_prepare')Prepare(u);
        else if(e.Name=='ca502c_core')Core(u);
        else if(e.Name=='ca502c_join'){Reset();Join();Manual=true;}
        else if(e.Name=='ca502c_separate')Separate();
        else if(e.Name=='ca502c_rejoin')Join();
        else if(e.Name=='ca502c_read')Console.Printf("CA502C %s",Reading);
        else if(e.Name=='ca502c_save')Save(u);
        else if(e.Name=='ca502c_load')Load(u);
        else if(e.Name=='ca502c_legacy'){
            let a=ActorIterator.Create(905041),b=ActorIterator.Create(905042);
            SourceBody=CA502ContactRat(a.Next());Recipient=CA502ContactRat(b.Next());
            Check(SourceBody!=null && Recipient!=null,"previous runtime actors load");
            if(SourceBody!=null && Recipient!=null){
                Check(CaelumContaminationStorage.Value(SourceBody)==80 && CaelumContaminationStorage.Value(Recipient)==20,"migration preserves old concentrations without retroactive transfer");
                Check(CaelumContaminationContacts.Get(SourceBody)==null,"old actors start without invented past contacts");
                Join();Check(CaelumContaminationContacts.Active(SourceBody),"first native contact initializes new state idempotently");
            }
        }
        else if(e.Name=='ca502c_stopped'){
            Check(CaelumContaminationStorage.Value(Recipient)==FrozenValue,"separated native clock never transmits");
            Check(!CaelumContaminationContacts.Active(Recipient),"separation removed the active native pair");
        }
        else if(e.Name=='ca502c_resumed'){
            Check(CaelumContaminationStorage.Value(Recipient)>FrozenValue,"native recontact resumes from retained concentration");
            Check(CaelumContaminationStorage.Value(SourceBody)==80,"native clock does not deplete source");
        }
        else return;Console.Printf("CA502C RESULT passed=%d failures=%d",Passed,Failed);
    }
}
