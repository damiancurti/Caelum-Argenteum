// Fixture privado: los saltos/posiciones no cambian el balance de campaña.
class CA406Mark : Inventory
{
    double Remaining,Carry,Stamp;
    int CalendarId,VendorStock,VendorWallet;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA406Checks : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA406 %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA406 RESULT passed=%d failed=%d",Passed,Failed);}
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CreationWizardOpen=false;u.CurrentThirst=100;u.CurrentHunger=100;u.CurrentSleep=100;
        let c=CaelumWorldClock.Get(u,true);CaelumCalendarState.Get(u,true).EnsureCampaign(c);
    }
    double Now(CaelumPlayer u)
    {let c=CaelumWorldClock.Get(u);return double(c.CompletedDays)*CaelumWorldClock.TicsPerDay()+c.DayTics;}
    Name Type(int index)
    {
        switch(index){case 0:return 'CaelumSourceYerbaMate';case 1:return 'CaelumSourceMarcela';
        case 2:return 'CaelumSourceIrupeFlower';case 3:return 'CaelumSourceCypellaFlower';
        case 4:return 'CaelumSourceSugarcane';case 5:return 'CaelumSourceCotton';case 6:return 'CaelumSourceHoney';
        case 7:return 'CaelumTreePlainsTala';case 8:return 'CaelumVeinIron';default:return 'CaelumFiberBush';}
    }
    CaelumEnvironmentProp Node(CaelumPlayer u,int index,int id)
    {
        let s=CaelumEnvironmentProp(Actor.Spawn(Type(index),(500+(id%5)*180,500+(id%3)*240,0),NO_REPLACE));
        s.args[4]=1;s.EnsureResourceState();s.ChangeTid(id);
        s.ResourceRemainingUnits=s.GetResourceCapacityUnits()*.25;
        s.ResourceClockInitialized=true;s.ResourceClockStamp=Now(u);return s;
    }
    CaelumEnvironmentProp Find(int id)
    {let it=ActorIterator.Create(id);return CaelumEnvironmentProp(it.Next());}
    CaelumCityMerchant Vendor(CaelumPlayer u)
    {
        let v=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(48,0,0),NO_REPLACE));
        v.Category=0;v.ShopIdentity=9406;v.WalletCopper=12345;v.EnsureStock(u);return v;
    }
    CaelumShopProduct Product(CaelumCityMerchant v)
    {for(int i=0;i<v.Products.Size();i++)if(v.Products[i].ImportedMaterial && v.Products[i].ItemType==81)return v.Products[i];return null;}
    void Matrix(CaelumPlayer u)
    {
        Prepare(u);let c=CaelumWorldClock.Get(u);
        for(int i=0;i<10;i++)
        {
            let a=Node(u,i,40600+i*2);let b=Node(u,i,40601+i*2);
            double start=a.ResourceRemainingUnits,cap=a.GetResourceCapacityUnits();
            for(int hour=0;hour<24;hour++){c.AdvanceTics(CaelumWorldClock.TicsPerHour());a.SyncResourceClock();}
            b.SyncResourceClock();
            Check(Abs(a.ResourceRemainingUnits-b.ResourceRemainingUnits)<0.000001,String.Format("profile %d stepped and one-day catch-up agree",i));
            Check(Abs(b.ResourceRemainingUnits-start-cap*.001)<0.000001,"one game day restores authored 0.1 percent");
            double amount=b.ResourceRemainingUnits;b.SyncResourceClock();b.SyncResourceClock();
            Check(b.ResourceRemainingUnits==amount,"repeated observation cannot credit time twice");
            a.ResourceYieldCarry=.5;a.ResourceRemainingUnits=cap-cap*.0005;
            c.AdvanceTics(CaelumWorldClock.TicsPerDay());a.SyncResourceClock();
            Check(a.ResourceRemainingUnits==cap && a.ResourceYieldCarry==.5,"cap bounds source and preserves already extracted fractional carry");
        }
        Result();
    }
    void Boundaries(CaelumPlayer u)
    {
        Prepare(u);let c=CaelumWorldClock.Get(u);let s=Node(u,1,40650);
        s.ResourceClockInitialized=false;s.ResourceRemainingUnits=7.25;s.ResourceYieldCarry=.5;
        c.AdvanceTics(CaelumWorldClock.TicsPerDay()*50);s.SyncResourceClock();
        Check(s.ResourceRemainingUnits==7.25 && s.ResourceYieldCarry==.5 && s.ResourceClockInitialized,"old unstamped source starts now without inventing absent recovery");
        double original=Now(u),amount=s.ResourceRemainingUnits;c.CompletedDays--;s.SyncResourceClock();
        Check(s.ResourceClockStamp==original && s.ResourceRemainingUnits==amount,"backward observation cannot rewind credited timestamp");
        c.CompletedDays++;s.SyncResourceClock();
        Check(s.ResourceRemainingUnits==amount,"returning to previously observed time does not grant another day");
        c.AdvanceTics(CaelumWorldClock.TicsPerDay());s.SyncResourceClock();
        Check(Abs(s.ResourceRemainingUnits-amount-.05)<.000001,"only genuinely new day grants recovery after backward observation");
        int days=c.CompletedDays;c.CompletedDays+=1000000;double before=MSTimeF();s.SyncResourceClock();double cost=MSTimeF()-before;
        Check(s.ResourceRemainingUnits==50,"million-day catch-up is capped without replaying days");
        Console.Printf("CA406 COST million_day_catchup_ms=%.6f",cost);c.CompletedDays=days;
        let finite=CaelumEnvironmentProp(Actor.Spawn("CaelumTutorialGoldVein",(1800,1000,0),NO_REPLACE));
        finite.EnsureResourceState();finite.ResourceRemainingUnits=7;finite.ResourceClockInitialized=true;finite.ResourceClockStamp=Now(u);
        c.AdvanceTics(CaelumWorldClock.TicsPerDay());finite.SyncResourceClock();
        Check(finite.ResourceRemainingUnits==7 && finite.ResourceCalendarId==0,"finite tutorial gold neither recovers nor schedules regeneration");
        let decor=CaelumLandSource(Actor.Spawn("CaelumSourceMarcelaDecoration",(2100,1000,0),NO_REPLACE));
        decor.SyncResourceClock();Check(!decor.ResourceClockInitialized && decor.ResourceCalendarId==0,"decorative plants have no recovery state");
        Result();
    }
    void Separation(CaelumPlayer u)
    {
        Prepare(u);let c=CaelumWorldClock.Get(u);let s=Node(u,0,40660);let v=Vendor(u);let p=Product(v);
        p.Stock.Amount=990;CaelumShopRestock.Sync(v,u,true);int wallet=v.WalletCopper;
        double start=s.ResourceRemainingUnits;s.ScheduleResourceRecovery(u);
        let agenda=CaelumScheduleState.Get(u);int size=agenda.Events.Size(),id=s.ResourceCalendarId;
        s.ScheduleResourceRecovery(u);s.ScheduleResourceRecovery(u);
        Check(id>0 && id==s.ResourceCalendarId && agenda.Events.Size()==size,"repeated schedule updates one calendar entry");
        c.AdvanceTics(CaelumWorldClock.TicsPerDay());s.SyncResourceClock();
        Check(Abs(s.ResourceRemainingUnits-start-.25)<.000001 && p.Stock.Amount==990,"source renewal does not produce shop stock");
        CaelumShopRestock.Sync(v,u);
        Check(p.Stock.Amount==991 && Abs(s.ResourceRemainingUnits-start-.25)<.000001 && v.WalletCopper==wallet,"merchant catch-up independently produces one gram without changing source or wallet");
        CaelumShopRestock.Sync(v,u);s.SyncResourceClock();
        Check(p.Stock.Amount==991 && Abs(s.ResourceRemainingUnits-start-.25)<.000001,"both systems are idempotent at the same calendar time");
        s.ScheduleResourceRecovery(u);let entry=agenda.FindId(id);
        double due=CaelumScheduleRules.Stamp(entry.DueDay,entry.DueTic);
        c.CompletedDays--;s.SyncResourceClock();s.ScheduleResourceRecovery(u);
        Check(CaelumScheduleRules.Stamp(entry.DueDay,entry.DueTic)==due,"calendar deadline includes the wait for a future credited source timestamp");
        c.CompletedDays++;s.SyncResourceClock();s.ScheduleResourceRecovery(u);
        Check(CaelumScheduleRules.Stamp(entry.DueDay,entry.DueTic)==due,"restoring observed time keeps one unchanged recovery deadline");
        Result();
    }
    void Save(CaelumPlayer u,bool legacy=false)
    {
        Prepare(u);let m=CA406Mark(u.GiveInventoryType("CA406Mark"));let s=Node(u,6,40670);
        s.ResourceRemainingUnits=123.25;s.ResourceYieldCarry=.75;s.ScheduleResourceRecovery(u);
        m.Remaining=s.ResourceRemainingUnits;m.Carry=s.ResourceYieldCarry;m.Stamp=s.ResourceClockStamp;m.CalendarId=s.ResourceCalendarId;
        let v=Vendor(u);let p=Product(v);p.Stock.Amount=777;CaelumShopRestock.Sync(v,u,true);m.VendorStock=777;m.VendorWallet=v.WalletCopper;
        u.PersistCharacterState();Verify(u,false);if(legacy)Console.Printf("CA406 LEGACY saved prior-runtime source state");
    }
    void Verify(CaelumPlayer u,bool advance=false)
    {
        let m=CA406Mark(u.FindInventory("CA406Mark"));Check(m!=null,"traveling comparison marker survives");if(m==null){Result();return;}
        if(level.MapName=="CARESRC")
        {
            let s=Find(40670);Check(s!=null,"map-owned source survives save and hub travel");if(s==null){Result();return;}
            double expected=m.Remaining+(s.ResourceClockStamp-m.Stamp)*.5/CaelumWorldClock.TicsPerDay();
            Check(Abs(s.ResourceRemainingUnits-expected)<.000001 && s.ResourceYieldCarry==m.Carry && s.ResourceCalendarId==m.CalendarId,"saved fraction, calendar identity and elapsed recovery are conserved");
            let v=CaelumCityMerchant.Find(9406);Check(v!=null && Product(v).Stock.Amount==m.VendorStock && v.WalletCopper==m.VendorWallet,"source load never restocks merchant or wallet");
            if(advance)
            {
                double before=Now(u);s.SyncResourceClock();double amount=s.ResourceRemainingUnits;
                CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay()*5);s.SyncResourceClock();
                Check(Abs(s.ResourceRemainingUnits-amount-2.5)<.000001,"loaded source catches up exactly five days");
                amount=s.ResourceRemainingUnits;s.SyncResourceClock();Check(s.ResourceRemainingUnits==amount,"loaded catch-up cannot replay");
                m.Remaining=s.ResourceRemainingUnits;m.Stamp=s.ResourceClockStamp;
            }
        }
        Result();
    }
    void Active(CaelumPlayer u,bool verify)
    {
        if(!verify){Prepare(u);let s=Node(u,6,40680);s.SetOrigin((2500,1600,0),false);Result();return;}
        let s=Find(40680);double elapsed=Now(u)-s.ResourceClockStamp;
        Check(s.ResourceRemainingUnits>125 && elapsed<=TICRATE && elapsed>=0,"offscreen source advances through normal unpaused native ticks");
        Result();
    }
    void Author(CaelumPlayer u,int mode)
    {
        if(level.MapName!="CARESRC")return;
        Prepare(u);
        let s=Find(40690);
        if(s==null)
        {
            s=Node(u,6,40690);s.SetOrigin((48,0,0),false);
            s.ResourceRemainingUnits=s.GetResourceCapacityUnits();
            u.SetOrigin((0,0,0),false);u.Angle=0;u.Pitch=25;
        }
        if(mode==1)CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay()*100);
        if(mode==3)
        {
            let clock=CaelumWorldClock.Get(u);
            if(clock.CompletedDays<100){u.A_Print("Primero pulsa F2 para avanzar 100 dias.");return;}
            clock.CompletedDays-=100;
        }
        s.SyncResourceClock();
        String message=String.Format("Colmena: %.3f / 500 g. E: recoger 50 g. F2: +100 dias. F3: estado.",s.ResourceRemainingUnits);
        u.A_Print(message);Console.Printf("CA406 AUTHOR %s",message);Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca406_matrix")Matrix(u);
        else if(e.Name=="ca406_boundaries")Boundaries(u);
        else if(e.Name=="ca406_separation")Separation(u);
        else if(e.Name=="ca406_save")Save(u);
        else if(e.Name=="ca406_legacy_save")Save(u,true);
        else if(e.Name=="ca406_verify")Verify(u);
        else if(e.Name=="ca406_resume")Verify(u,true);
        else if(e.Name=="ca406_active")Active(u,false);
        else if(e.Name=="ca406_active_verify")Active(u,true);
        else if(e.Name=="ca406_author")Author(u,e.Args[0]);
        else if(e.Name=="ca406_author_verify")
        {Check(Abs(Find(40690).ResourceRemainingUnits-e.Args[0])<.01,"author controls preserve expected honey reserve");Result();}
    }
}
