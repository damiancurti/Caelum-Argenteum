// La campaña conserva consecuencias, no copias de actores ni reservas nuevas.
class CaelumBattleConsequences : Object play
{
    int Revision,Serial;
    bool Observed,Defeated,Won,Recovered,LegacyVictory;
    double DefeatCivil,VictoryCivil,RecoveryCivil;
    bool DeadShop[CaelumCityData.SHOP_COUNT];
    CaelumCooperativeObjective Reward,RewardPaid;

    static clearscope CaelumBattleConsequences View(CaelumPlayer user)
    {
        let clock=user==null?null:CaelumWorldClock(user.FindInventory('CaelumWorldClock'));
        return clock==null || clock.CampaignQuests==null?null:clock.CampaignQuests.BattleConsequences;
    }
    static CaelumBattleConsequences Get(CaelumPlayer user,bool create=false)
    {
        let result=View(user);if(result!=null || !create)return result;
        let world=CaelumCooperativeQuests.Get(user);if(world==null)return null;
        world.BattleConsequences=new('CaelumBattleConsequences');
        world.BattleConsequences.Revision=CaelumBattleConsequenceData.REVISION;
        world.BattleConsequences.DefeatCivil=world.BattleConsequences.VictoryCivil=world.BattleConsequences.RecoveryCivil=-1;
        return world.BattleConsequences;
    }
    static clearscope double Now(CaelumPlayer user)
    {
        let clock=user==null?null:CaelumWorldClock(user.FindInventory('CaelumWorldClock'));
        let calendar=user==null?null:CaelumCalendarState(user.FindInventory('CaelumCalendarState'));
        if(clock==null || calendar==null || calendar.DateSerial(clock)<0)return -1;
        return double(calendar.DateSerial(clock))*86400+double(calendar.CivilDayTics(clock))*3600/CaelumWorldClock.TicsPerHour();
    }
    static void Initialize(CaelumPortSiege port)
    {
        if(port==null || port.Director==null)return;
        let result=Get(CaelumWorldClockTicker.CampaignOwner(),true);
        if(result==null || result.Observed)return;
        let director=port.Director;result.Observed=true;
        result.Defeated=director.Defeated;result.Won=director.Won;
        result.DefeatCivil=director.Defeated?director.DefeatCivil:-1;
        result.VictoryCivil=director.Won?director.VictoryCivil:-1;
        // Una victoria anterior no contiene una nómina fiable de participantes.
        // Conservarla sin inventar elegibilidad ni volver a pagar al cargar.
        result.LegacyVictory=director.Won;
        if(result.Defeated && result.Won && result.VictoryCivil>=0)
            result.RecoveryCivil=result.VictoryCivil+CaelumBattleConsequenceData.RECOVERY_HOURS*3600;
    }
    static void Observe(CaelumPortSiege port,double civil)
    {
        Initialize(port);if(port==null || port.Director==null)return;
        let result=Get(CaelumWorldClockTicker.CampaignOwner());if(result==null)return;
        let director=port.Director;
        if(director.Defeated && !result.Defeated)
        {result.Defeated=true;result.DefeatCivil=director.DefeatCivil;result.Serial++;}
        if(director.Won && !result.Won)
        {
            result.Won=true;result.VictoryCivil=director.VictoryCivil;result.Serial++;
            if(result.Defeated)result.RecoveryCivil=director.VictoryCivil+CaelumBattleConsequenceData.RECOVERY_HOURS*3600;
            result.Reward=new('CaelumCooperativeObjective');result.Reward.Capture();
            result.RewardPaid=new('CaelumCooperativeObjective');result.RewardPaid.EnsureIdentity();
            for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])Update(CaelumPlayer(players[p].mo));
        }
        result.Recover(civil);
    }
    void Recover(double civil)
    {
        if(Defeated && Won && !Recovered && RecoveryCivil>=0 && civil>=RecoveryCivil)
        {Recovered=true;Serial++;}
    }
    static clearscope bool Closed(CaelumPlayer user)
    {
        let result=View(user);
        return result!=null && result.ClosedAt(Now(user));
    }
    clearscope bool ClosedAt(double civil)
    {
        return Defeated && (civil<0 || DefeatCivil<0 || civil>=DefeatCivil)
            && (!Won || (RecoveryCivil>=0 && civil<RecoveryCivil));
    }
    static bool HistoricalMarketClosed(CaelumPlayer user,double scheduleStamp)
    {
        let result=View(user);
        return result!=null && result.ClosedAt(scheduleStamp*3600/CaelumWorldClock.TicsPerHour());
    }
    static bool AllowDeparture(CaelumPlayer user,bool notify=true)
    {
        if(level.MapName!="MAP03" || !Closed(user))return true;
        if(notify)CaelumNotifications.Notify(user,StringTable.Localize("CA_CITY_SERVICES_CLOSED",false));
        return false;
    }
    static bool HoldDeparture(CaelumPlayer user,CaelumTransportTicket ticket,double civil)
    {
        if(ticket==null || ticket.Status!=CaelumTransportTicket.WAITING
            || CaelumTransportData.Map(CaelumTransportData.Origin(ticket.Route))!="MAP03")return false;
        let result=View(user);if(result==null || !result.Defeated)return false;
        // Un salto del calendario conserva una salida realmente anterior a la caída.
        if(result.DefeatCivil>=0 && Max(ticket.Stamp,ticket.Departure)<result.DefeatCivil)return false;
        if(!result.Won || (result.RecoveryCivil>=0 && civil<result.RecoveryCivil))
        {ticket.Stamp=Max(ticket.Stamp,civil);return true;}
        if(result.RecoveryCivil>=0)ticket.Stamp=Max(ticket.Stamp,result.RecoveryCivil);
        return false;
    }
    static void MerchantDied(CaelumCityMerchant vendor)
    {
        if(vendor==null || vendor.health>0 || vendor.ShopIdentity<0 || vendor.ShopIdentity>=CaelumCityData.SHOP_COUNT)return;
        let result=Get(CaelumWorldClockTicker.CampaignOwner(),true);if(result==null)return;
        if(!result.DeadShop[vendor.ShopIdentity]){result.DeadShop[vendor.ShopIdentity]=true;result.Serial++;}
    }
    static bool MerchantDead(int identity)
    {
        let result=Get(CaelumWorldClockTicker.CampaignOwner());
        return result!=null && identity>=0 && identity<CaelumCityData.SHOP_COUNT && result.DeadShop[identity];
    }
    static bool MerchantAvailable(CaelumPlayer user,CaelumCityMerchant vendor)
    {
        return vendor!=null && !vendor.bDestroyed && vendor.health>0 && !Closed(user);
    }
    static void Update(CaelumPlayer user)
    {
        if(!CaelumWorldClockTicker.Ready(user))return;
        let result=View(user);if(result==null)return;
        result.Recover(Now(user));
        let record=user.GetPersistentCharacterState(false);
        if(result.Reward==null || result.RewardPaid==null || !result.Reward.Contains(record)
            || result.RewardPaid.Contains(record))return;
        result.RewardPaid.EligibleIdentities.Push(record.LawfulIdentity);
        record.ChangeFactionReputation(CaelumMilitaryData.GUARD_FACTION,CaelumBattleConsequenceData.REPUTATION);
        user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
    }
    static void Calendar(CaelumPlayer user)
    {
        let result=View(user);
        if(result==null || !result.Defeated || !result.Won || result.RecoveryCivil<0)return;
        let agenda=CaelumScheduleState.Get(user,true);if(agenda==null || agenda.FindKey("port451_recovery")!=null)return;
        int day=int(Floor(result.RecoveryCivil/86400));
        int tic=int((result.RecoveryCivil-double(day)*86400)*CaelumWorldClock.TicsPerHour()/3600);
        agenda.Add("port451_recovery",CaelumScheduleRules.NOTICE,"CA_CITY_RECOVERY_DATE","MAP03",day,tic,0,1,"port451_recovery",false);
        CaelumScheduleState.Sync(user);
    }
    static ui String Text(CaelumPlayer user)
    {
        let result=View(user);if(result==null || (!result.Defeated && !result.Won))return "";
        String key=!result.Won?"CA_CITY_OCCUPIED":result.Defeated
            ?(Closed(user)?"CA_CITY_RECOVERING":"CA_CITY_RECOVERED"):"CA_CITY_VICTORY";
        return StringTable.Localize(key,false);
    }
}
