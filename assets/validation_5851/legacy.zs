// Native fixture shared by the original 5.8.50 and current runtimes.
class CA415LegacyChecks : EventHandler
{
    CaelumPortSiege Port;
    CaelumPortDefender Resident;
    Inventory Possession;
    int Life,Passed,Failed;
    double Dirt,Start;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA415L %s %s",value?"PASS":"FAIL",label);}
    void Seed(CaelumPlayer user)
    {
        Port=CaelumPortSiege.Get();
        Check(Port!=null && Port.SetupRevision>0 && !Port.SiegeStarted,"original runtime owns a prepared peaceful city");
        if(Port==null)return;
        let roster=CaelumHouseResidents.Get(true);
        Resident=roster.CreateResident(0,CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(0)));
        Resident.PostBeginPlay();Resident.health-=77;Life=Resident.health;
        let dirtEntry=CaelumContaminationStorage.Get(Resident,true);dirtEntry.Concentration=29;Dirt=dirtEntry.Concentration;
        Possession=Inventory(Actor.Spawn('CaelumCarbineAmmo',Resident.Pos,NO_REPLACE));
        Possession.BecomeItem();Resident.AddInventory(Possession);Possession.Amount=17;
        roster.Residents[0].Suspend();
        Port.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        roster.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        let calendar=CaelumCalendarState.Get(user,true);let clock=CaelumWorldClock.Get(user,true);
        calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay()+1,0,false);
        Check(!Port.SiegeStarted && Resident.health==Life && Possession.Owner==Resident,"fixture retains observed Life and inventory beyond the siege date");
    }
    void Retained()
    {
        Check(Port!=null && !Port.SiegeStarted,"load preserves the existing encounter rather than inventing past combat");
        let dirtEntry=CaelumContaminationStorage.Get(Resident,false);
        Check(Resident!=null && Resident.health==Life && dirtEntry!=null && dirtEntry.Concentration==Dirt,"load preserves original Life and bodily contamination");
        Check(Possession!=null && Possession.Owner==Resident && Possession.Amount==17,"load preserves the actual owned inventory object and amount");
        Check(CaelumHouseResidents.Get().Residents[0].Body==Resident,"load preserves household body identity");
    }
    void Upgrade(CaelumPlayer user)
    {
        // CURRENT_UPGRADE
    }
    void Resume(CaelumPlayer user)
    {
        // CURRENT_RESUME
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name.Left(12)!="ca415legacy_")return;
        Passed=Failed=0;let user=CaelumPlayer(players[consoleplayer].mo);
        if(e.Name=="ca415legacy_seed")Seed(user);
        else if(e.Name=="ca415legacy_upgrade"){Retained();Upgrade(user);}
        else if(e.Name=="ca415legacy_resume"){Retained();Resume(user);}
        else if(e.Name=="ca415legacy_rollback")Retained();
        else return;
        Console.Printf("CA415L RESULT passed=%d failed=%d",Passed,Failed);
    }
}
