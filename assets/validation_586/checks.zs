// Diagnostico aislado; los comandos no forman parte del juego distribuido.
class CA411Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA411 %s %s",ok?"PASS":"FAIL",label);}
    void Core(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user,true);CaelumCalendarState.Get(user,true).EnsureCampaign(clock);
        let roster=CaelumHouseResidents.Get(true);roster.EnsureRecords();
        Check(roster.Residents.Size()==600,"resident census preserved");
        Check(CaelumPropertyData.ResidentHouse(69)==70 && CaelumPropertyData.ResidentHouse(229)==70
            && CaelumPropertyData.ResidentHouse(70)==70,"relocation keeps stable resident identities");
        for(int c=0;c<CaelumConstants.CURRENCY_TYPE_COUNT;c++){let coin=user.FindNativeCurrency(c);if(coin!=null)coin.Destroy();}
        user.OnNativeInventoryChanged();
        Check(!CaelumPropertyRules.Acquire(user,69,false),"insufficient funds do not start rent");
        let record=CaelumPropertyRules.Find(69);Check(record!=null && record.Holder==null && record.PaidUntil==0,"rejected contract has no title or deadline");
        let coins=CaelumCurrencyItem(user.GiveInventoryType(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD)));
        coins.Amount=int(Ceil(202000.0/CaelumEconomyRules.GetCurrencyFaceValue(CaelumConstants.CURRENCY_GOLD)));user.OnNativeInventoryChanged();
        double before=user.GetOwnedMoneyCopperValue();double now=CaelumScheduleState.Now(user);
        Check(CaelumPropertyRules.Acquire(user,69,false),"prepaid rent succeeds");
        Check(user.GetOwnedMoneyCopperValue()==before-1000 && record.RentPayments==1,"rent charges exactly one approved payment");
        double expected=now+30.0*CaelumWorldClock.TicsPerDay();
        Check(record.PaidUntil==expected && record.Current(now),"rent covers 30 calendar days");
        Check(!record.Current(expected) && record.Current(expected-1),"expiry boundary is exact");
        Check(CaelumPropertyRules.Acquire(user,69,false) && record.PaidUntil==expected+30.0*CaelumWorldClock.TicsPerDay(),"early renewal extends unspent time");
        before=user.GetOwnedMoneyCopperValue();
        Check(CaelumPropertyRules.Acquire(user,69,true),"purchase during rental succeeds");
        Check(record.Purchased && user.GetOwnedMoneyCopperValue()==before-100000 && record.RentPayments==2,"purchase does not refund previous rent");
        before=user.GetOwnedMoneyCopperValue();
        Check(!CaelumPropertyRules.Acquire(user,69,true) && !CaelumPropertyRules.Acquire(user,69,false)
            && user.GetOwnedMoneyCopperValue()==before,"owned property cannot charge again");
        Check(record.Current(expected+365.0*CaelumWorldClock.TicsPerDay()),"purchased residence never expires");
        Check(!CaelumPropertyRules.Acquire(user,68,false),"only authored property can be acquired");
        int count=roster.Properties.Size();roster.EnsureRecords();roster.EnsureRecords();
        Check(roster.Properties.Size()==count && record.Purchased && roster.PropertyRevision==1,"schema initialization preserves contract");
        Console.Printf("CA411 RESULT core passes=%d failures=%d",Passed,Failed);
    }
    void Routes()
    {
        bool same=true;
        for(int i=0;i<600;i++)
        {
            int count=CaelumPropertyRoutes.Count(i),old=CaelumCityRoutes.Count(i);
            if(CaelumPropertyData.ResidentHouse(i)!=i%CaelumCityData.HOUSE_COUNT)
                Check(CaelumPropertyRoutes.Point(i,count-1)==CaelumCityRoutes.Point(i,old-1),"relocated route retains combat destination");
            else
            {
                if(count!=old)same=false;
                for(int step=0;step<count;step++)if(CaelumPropertyRoutes.Point(i,step)!=CaelumCityRoutes.Point(i,step))same=false;
            }
        }
        Check(same,"all 596 unaffected deployment routes unchanged");
        Console.Printf("CA411 RESULT routes passes=%d failures=%d",Passed,Failed);
    }
    void MigrationCost(CaelumPlayer user)
    {
        let roster=CaelumHouseResidents.Get(true);roster.EnsureRecords();roster.Ready=true;
        Array<CaelumStashChest> chests;
        for(int i=0;i<256;i++)chests.Push(CaelumStashChest(Actor.Spawn("CaelumStashChest",user.Pos,NO_REPLACE)));
        double started=MSTimeF();roster.RelocatePropertyChest();
        Console.Printf("CA411 TIMING one-time 256-chest migration ms=%.6f",MSTimeF()-started);
        Check(roster.PropertyChestScanned && roster.RelocatingChest==null,"migration rejects unrelated chests");
        for(int i=0;i<chests.Size();i++)chests[i].Destroy();
        Console.Printf("CA411 RESULT migration cost passes=%d failures=%d",Passed,Failed);
    }
    void Verify(CaelumPlayer user)
    {
        let record=CaelumPropertyRules.Find(69);let roster=CaelumHouseResidents.Get();
        Check(record!=null && record.Purchased && record.RentPayments==2,"saved title and payment count");
        Check(CaelumPropertyRules.Holds(user,record),"saved lawful holder identity");
        Check(roster!=null && roster.Properties.Size()==1 && roster.Residents.Size()==600,"saved arrays without duplicate contracts or residents");
        Console.Printf("CA411 RESULT verification passes=%d failures=%d",Passed,Failed);
    }
    void House(CaelumPlayer user)
    {
        let roster=CaelumHouseResidents.Get(true);int house=CaelumHouseHubData.HouseForMap(level.MapName);
        Check(roster.Ready,"production house ready");
        if(house==69)
        {
            Check(roster.PropertyChestScanned,"original chest migration completed");
            Check(!CaelumPropertyRules.ResidenceAllowed(user),"unacquired dwelling blocks residential use");
            Check(CaelumRestSafety.BlockReason(user)=="CA_PROPERTY_NO_RESIDENCE","rest uses property access check");
            for(int i=69;i<600;i+=160)Check(!roster.Residents[i].Created || roster.Residents[i].ResidentMap!="CAH069","offered house vacated without deleting resident");
        }
        if(house==70)
        {
            for(int i=69;i<600;i+=160)Check(roster.Residents[i].Created && roster.Residents[i].Body!=null
                && roster.Residents[i].ResidentMap=="CAH070","relocated resident exists in nearby house");
            Check(roster.HouseChestIssued[69] && roster.HouseChestIssued[70],"both residents' chest entitlements preserved");
            Check(roster.RelocatingChest==null,"relocated chest placed");
        }
        Console.Printf("CA411 RESULT production house passes=%d failures=%d",Passed,Failed);
    }
    CaelumHousePortal Door(CaelumPlayer user)
    {
        let iterator=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal door;
        while((door=CaelumHousePortal(iterator.Next()))!=null)
            if(door.args[0]==69 && door.args[1]!=0)
            {
                user.SetOrigin(door.Pos+(-80,0,0),false);user.Angle=0;user.Pitch=0;return door;
            }
        return null;
    }
    void Preview(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user,true);CaelumCalendarState.Get(user,true).EnsureCampaign(clock);
        let coins=CaelumCurrencyItem(user.GiveInventoryType(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD)));
        coins.Amount=int(Ceil(102000.0/CaelumEconomyRules.GetCurrencyFaceValue(CaelumConstants.CURRENCY_GOLD)));user.OnNativeInventoryChanged();
        Check(CaelumPropertySession.Open(user,Door(user)),"property interface opens at real doorway");
        Console.Printf("CA411 RESULT property preview ready failures=%d",Failed);
    }
    void Author(CaelumPlayer user)
    {
        Preview(user);
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",CaelumCityData.ChestPosition(69),NO_REPLACE));
        chest.EnsureStorage();chest.GrantLawfulTitle(user);
        let item=Inventory(Actor.Spawn("CaelumFoodRation",chest.Pos,NO_REPLACE));item.Amount=2;item.AttachToOwner(chest);
        Check(chest.TestMobjLocation(),"private author chest has free placement");
        Console.Printf("CA411 RESULT author fixture ready failures=%d",Failed);
    }
    void Access(CaelumPlayer user)
    {
        Preview(user);let session=CaelumPropertySession.Get(user);if(session==null)return;
        session.Act(3);let record=CaelumPropertyRules.Find(69);double funds=user.GetOwnedMoneyCopperValue();
        Check(record!=null && record.RentPayments==1 && CaelumPropertyRules.ResidenceAllowed(user),"native doorway rent grants residence");
        if(record==null){Console.Printf("CA411 RESULT missing contract; status=%s valid=%d",session.Status,session.Valid());return;}
        session.Act(3);Check(user.GetOwnedMoneyCopperValue()==funds && record.RentPayments==1,"repeat UI input cannot charge twice");
        session.Act(0);
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",user.Pos+(-64,0,0),NO_REPLACE));
        chest.EnsureStorage();chest.GrantLawfulTitle(user);
        let item=Inventory(Actor.Spawn("CaelumFoodRation",user.Pos,NO_REPLACE));item.Amount=2;item.AttachToOwner(chest);
        Check(CaelumContainerRules.Allowed(user,item,true),"current lease permits storage");
        let clock=CaelumWorldClock.Get(user);clock.AdvanceTics(31*CaelumWorldClock.TicsPerDay());
        Check(!CaelumPropertyRules.ResidenceAllowed(user),"calendar advance expires rental");
        Check(CaelumRestSafety.BlockReason(user)=="CA_PROPERTY_NO_RESIDENCE","expired rental blocks normal and accelerated rest gate");
        Check(!CaelumContainerRules.Allowed(user,item,true) && CaelumContainerRules.Allowed(user,item,false),"expiry forbids deposit but permits retrieval");
        Check(item.Owner==chest && item.Amount==2 && user.GetOwnedMoneyCopperValue()==funds,"expiry preserves belongings and money");
        double now=CaelumScheduleState.Now(user);
        Check(CaelumPropertyRules.Acquire(user,69,false) && record.PaidUntil==now+30.0*CaelumWorldClock.TicsPerDay(),"renewal after lapse starts now without arrears");
        Check(chest.IsLawfulOwner(user) && CaelumPropertyRules.ResidenceAllowed(user),"renewal preserves storage ownership");
        Console.Printf("CA411 RESULT access passes=%d failures=%d",Passed,Failed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca411_core")Core(user);
        else if(e.Name=="ca411_verify")Verify(user);
        else if(e.Name=="ca411_routes")Routes();
        else if(e.Name=="ca411_cost")MigrationCost(user);
        else if(e.Name=="ca411_cross"){let session=CaelumPropertySession.Get(user);if(session!=null)session.Act(1);}
        else if(e.Name=="ca411_city")
        {Check(level.MapName=="MAP03","production doorway travels to city");Console.Printf("CA411 RESULT city failures=%d",Failed);}
        else if(e.Name=="ca411_house")House(user);
        else if(e.Name=="ca411_preview")Preview(user);
        else if(e.Name=="ca411_access")Access(user);
        else if(e.Name=="ca411_author")Author(user);
        else if(e.Name=="ca411_expire")
        {CaelumWorldClock.Get(user).AdvanceTics(31*CaelumWorldClock.TicsPerDay());Console.Printf("CA411 RESULT advanced 31 game days");}
    }
}
