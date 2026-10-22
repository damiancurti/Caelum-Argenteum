// Pruebas aisladas: las cantidades y coordenadas no son datos de campaña.
class CA408Checks : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok, String message)
    { if(ok)Passed++;else Failed++;Console.Printf("CA408 %s %s",ok?"PASS":"FAIL",message); }
    void Result() { Console.Printf("CA408 RESULT passed=%d failed=%d",Passed,Failed); }
    void Prepare(CaelumPlayer u)
    {
        Console.Printf("CA408 SETTINGS pause=%d render=%d lower=%d sound=%d volume=%.3f tic=%d",
            CVar.GetCVar('i_pauseinbackground').GetBool(),CVar.GetCVar('vid_activeinbackground').GetBool(),
            CVar.GetCVar('vid_lowerinbackground').GetBool(),CVar.GetCVar('i_soundinbackground').GetBool(),
            CVar.GetCVar('snd_mastervolume').GetFloat(),level.time);
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.CloseCraftingStationSession();u.CreationWizardOpen=false;
        u.GrantMagicBoxFromPalomo(false);u.CurrentThirst=25;
    }
    CaelumWaterContainer Bottle(CaelumPlayer u, Name type='CaelumCanteenLarge')
    {
        let old=u.FindInventory(type);if(old!=null)old.Destroy();
        let b=CaelumWaterContainer(Actor.Spawn(type,u.Pos,NO_REPLACE));b.AttachToOwner(u);return b;
    }
    void Suite(CaelumPlayer u)
    {
        Prepare(u);let b=Bottle(u);
        for(int first=0;first<=7;first++) for(int second=0;second<=7;second++)
        {
            b.EmptyWater(u);b.WaterLiters=0;b.WaterQuality=0;
            Check(b.AddWater(1,first) && b.AddWater(2,second)
                && b.WaterLiters==3 && b.WaterQuality==(first|second),String.Format("mix %d/%d preserves 3 L and contaminants",first,second));
        }
        double volume=b.WaterLiters,weight=b.GetUnitWeight();int quality=b.WaterQuality;
        Check(!b.AddWater(3,0) && !b.AddWater(-1,0) && !b.AddWater(1,-1)
            && !b.AddWater(1,32) && b.WaterLiters==volume && b.WaterQuality==quality
            && b.GetUnitWeight()==weight,"failed transfers leave amount, mass and quality intact");
        Check(!b.Drink() && !CaelumQuickUse.Available(u,b) && b.WaterLiters==volume,"dirty water rejected by direct and quick use");
        Check(CaelumTimeSkipRules.Kind(b)==0,"dirty water excluded from automatic meals");
        let model=new("CaelumJourneyModel");model.Capture(u,false);
        Check(model.ContainerStock==0,"dirty water excluded from travel provisions");
        let row=new("CaelumSkipSupply");row.Capture(b);
        Check(!row.Usable() && row.Liters==volume && row.WaterQuality==quality,"rest forecast preserves dirty volume but cannot drink it");
        let table=CaelumDiningTable(Actor.Spawn("CaelumDiningTable",u.Pos+(96,0,0),NO_REPLACE));
        if(table!=null){u.RemoveInventory(b);b.AttachToOwner(table);table.Items[0]=b;
            Check(!CaelumDiningSession.ConsumeItem(u,b,table) && b.Owner==table && b.WaterLiters==volume,"table cannot serve dirty water or transfer it on failure");
            table.RemoveInventory(b);b.AttachToOwner(u);table.Items[0]=null;table.Destroy();}
        b.InMagicBox=true;Check(!b.EmptyWater(u) && b.WaterLiters==volume,"Box blocks empty operation");b.InMagicBox=false;
        b.WaterQualityRevision=0;b.EnsureWaterQuality();b.EnsureWaterQuality();
        Check(b.WaterQualityRevision==1 && b.WaterLiters==volume && b.WaterQuality==quality,"migration idempotently preserves saved quality and amount");
        let tossed=CaelumWaterContainer(b.CreateTossable(1));
        Check(tossed!=null && tossed.WaterLiters==volume && tossed.WaterQuality==quality
            && tossed.WaterQualityRevision==1,"native drop preserves water state");
        if(tossed!=null)tossed.Destroy();
        if(b.bDestroyed || b.Owner!=u)b=Bottle(u);
        b.WaterLiters=3;b.WaterQuality=7;b.EmptyWater(u);
        Check(b.WaterLiters==0 && b.AddWater(1,0) && b.IsPotable(),"explicit empty permits fresh potable refill");
        u.CurrentThirst=25;double prior=b.WaterLiters;
        Check(b.Drink() && b.WaterLiters<prior,"potable dose retains native use");
        let effect=CaelumRegenerationPower(u.FindInventory("CaelumThirstRegeneration"));
        Check(effect!=null && Abs(effect.WaterRecoveryPerPulse*10-(prior-b.WaterLiters)*4000/u.DerivedStats.BaseMass)<0.00001,"potable dose preserves current mass-based restoration");
        if(effect!=null)effect.Destroy();
        b.WaterLiters=2;b.WaterQuality=0;b.WaterQualityRevision=0;b.EnsureWaterQuality();
        Check(b.WaterLiters==2 && b.IsPotable(),"legacy water remains potable without reset");
        for(int q=0;q<=7;q++)Check(CaelumWaterQuality.Label(q).Length()>0,String.Format("quality %d has bilingual label",q));
        Result();
    }
    void Save(CaelumPlayer u)
    {
        Prepare(u);u.CurrentThirst=100;let b=Bottle(u);b.AddWater(1.75,7);b.InMagicBox=true;
        let clean=Bottle(u,'CaelumBottleNormal');clean.AddWater(0.75,0);
        u.OnNativeInventoryChanged();u.PersistCharacterState();Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        let b=CaelumWaterContainer(u.FindInventory('CaelumCanteenLarge'));
        let clean=CaelumWaterContainer(u.FindInventory('CaelumBottleNormal'));
        Console.Printf("CA408 CHECKPOINT clean=%.6f quality=%d dirty=%.6f quality=%d thirst=%.6f",clean!=null?clean.WaterLiters:-1,clean!=null?clean.WaterQuality:-1,b!=null?b.WaterLiters:-1,b!=null?b.WaterQuality:-1,u.CurrentThirst);
        Check(b!=null && b.WaterLiters==1.75 && b.WaterQuality==7 && b.InMagicBox,"dirty water and ownership survive save/hub travel");
        Check(clean!=null && clean.WaterLiters==0.75 && clean.IsPotable(),"clean water survives alongside dirty container");
        Result();
    }
    void Source(CaelumPlayer u,int q)
    {
        u.SetOrigin(((q+1)*768+256,256,0),false);u.Vel=(0,0,0);u.CurrentAir=u.DerivedStats.MaximumAir;
        Console.Printf("CA408 SOURCE %d (%s)",q,q<=7?CaelumWaterQuality.Label(q):"unidentified");
    }
    void SourceCheck(CaelumPlayer u,int q)
    {
        let b=Bottle(u);b.AddWater(0.25,0);b.WasSubmerged=false;
        int expected=q<=7?q:-1;
        Check(u.WaterLevel==3 && CaelumWaterQuality.Source(u)==expected,String.Format("native submerged source %d has declared identity",q));
        b.ObserveImmersion(u);
        Check(b.WaterLiters==(q==0?5:0.25),"automatic fill is potable-only");
        if(q==0){b.EmptyWater(u);b.AddWater(0.25,0);}
        bool filled=b.FillFromSource(u);
        Check(filled==(q<=7) && b.WaterLiters==(q<=7?5:0.25) && b.WaterQuality==(q<=7?q:0),"explicit source transfer conserves mixed quality");
        Check(!b.FillFromSource(u),"full or unidentified source retry does not duplicate volume");
        if(q<=7)
        {
            b.EmptyWater(u);b.AddWater(0.25,4);double capacity=u.DerivedStats.CarryCapacity;
            u.DerivedStats.CarryCapacity=0;
            Check(!b.FillFromSource(u) && b.WaterLiters==0.25 && b.WaterQuality==4,"insufficient carrying capacity preserves existing water");
            u.DerivedStats.CarryCapacity=capacity;b.InMagicBox=true;
            Check(!b.FillFromSource(u) && b.WaterLiters==0.25,"source cannot fill a Box container");b.InMagicBox=false;
            Check(b.FillFromSource(u) && b.WaterQuality==(4|q),"refilling contaminated water never purifies it");
        }
        b.Destroy();Result();
    }
    void Author(CaelumPlayer u)
    {
        Prepare(u);u.CurrentThirst=75;u.CurrentHunger=100;u.CurrentSleep=100;
        u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentAnima=u.DerivedStats.MaximumAnima;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        let b=Bottle(u);b.AddWater(1,7);u.InvSel=b;
        u.FormalInventoryFilter=5;u.FormalInventorySelectionIndex=0;u.RefreshFormalInventorySnapshot();
        Console.Printf("CA408 READY: F1 potable; F2 biological; F3 salt; F4 chemical; F5 mixed. Inventory: R collect, V empty, Enter drink. No boiling in #408.");
        Result();
    }
    void Upgrade(CaelumPlayer u)
    {
        let b=CaelumWaterContainer(u.FindInventory('CaelumCanteenNormal'));
        Check(b!=null && b.WaterLiters==1.25 && b.IsPotable(),"real prior-release save retains exact potable water");
        if(b!=null){b.EnsureWaterQuality();b.EnsureWaterQuality();
            Check(b.WaterLiters==1.25 && b.WaterQualityRevision==1,"real legacy migration is revisioned and idempotent");}
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca408_setup")Prepare(u);
        else if(e.Name=="ca408_suite")Suite(u);
        else if(e.Name=="ca408_source")Source(u,e.Args[0]);
        else if(e.Name=="ca408_sourcecheck")SourceCheck(u,e.Args[0]);
        else if(e.Name=="ca408_save")Save(u);
        else if(e.Name=="ca408_verify")Verify(u);
        else if(e.Name=="ca408_author")Author(u);
        else if(e.Name=="ca408_upgrade")Upgrade(u);
        else if(e.Name=="ca408_dispatchcheck")
        {
            let b=CaelumWaterContainer(u.FindInventory('CaelumCanteenLarge'));
            Check(b!=null && b.WaterLiters==(e.Args[0]==0?0:5)
                && b.WaterQuality==(e.Args[0]==0?0:1),"production inventory network action targets selected container");Result();
        }
    }
}
