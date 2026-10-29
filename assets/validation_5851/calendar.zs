class CA415CalendarChecks : EventHandler
{
    int Passed,Failed,RetainedLife,InitialUnresolved;
    CaelumAbsentBattle Battle;
    CaelumPortSiege Port;
    CaelumPortDefender Retained;
    Inventory Possession;
    double Due;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA415C %s %s",value?"PASS":"FAIL",label);}

    void Prepare(CaelumPlayer user)
    {
        Port=CaelumPortSiege.Get();
        Check(Port!=null && Port.SetupRevision>0 && !Port.SiegeStarted && CaelumHouseHub.IsCity(Port),"native MAP03 is prepared and peaceful before the authored date");
        if(Port==null || Port.SiegeStarted)return;
        Due=CaelumCityWorld.SiegeCivilSeconds();
        let roster=CaelumHouseResidents.Get(true);
        Retained=roster.CreateResident(0,CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(0)));
        Retained.PostBeginPlay();Retained.health-=77;RetainedLife=Retained.health;
        Possession=Inventory(Actor.Spawn('CaelumCarbineAmmo',Retained.Pos,NO_REPLACE));
        Possession.BecomeItem();Retained.AddInventory(Possession);Possession.Amount=17;
        roster.Residents[0].Suspend();
        let absence=Retained.ContaminationAbsence;
        absence.Stamp=absence.Civil=Due-60;absence.RecoveryRate=0;absence.Immune=true;absence.Exposure=null;
        CaelumAbsentBattles.Capture(user);Battle=Port.AbsentBattle;
        Check(Battle!=null && Battle.Away && Battle.ScheduleWaiting && Battle.ScheduledCivil==Due,"departure retains the authored siege deadline without deploying parked residents");
        double before=MSTimeF();Battle.SyncTo(Due-1);
        Console.Printf("CA415C TIMING peaceful_skip_ms=%.6f",MSTimeF()-before);
        Check(Battle.Stamp==Due-1 && !Port.SiegeStarted && Port.Attackers.Size()==0,"empty peaceful interval skips to the deadline without premature reserves");
        Battle.SyncTo(Due);
        Check(Port.SiegeStarted && Port.RosterSealed && !Battle.ScheduleWaiting && Battle.Stamp==Due,"exact calendar boundary initializes and seals the real encounter once");
        Check(Port.Boss!=null && Port.Boss.Body.CombatProfileInitialized && CaelumZupayColossus(Port.Boss.Body).ZupayBirthInitialized,"scheduled commander owns its complete guarded native profile before rounds");
        double anima=Port.Boss.Body.CurrentCombatAnima-17;Port.Boss.Body.CurrentCombatAnima=anima;
        Port.Boss.Body.PostBeginPlay();
        Check(Port.Boss.Body.CurrentCombatAnima==anima,"later native birth callback does not reset the summarized commander");
        InitialUnresolved=roster.Unresolved;
        Battle.SyncTo(Due+1);
        Check(roster.PendingCursor==1 && roster.Unresolved==InitialUnresolved-1,"first exterior second admits one resident at the existing one-attempt-per-active-tic cadence");
        Check(Port.Defenders[0]==Retained && Retained.Residence.Emitted && Retained.Residence.Suspended
            && Retained.AbsentCombatant!=null && Retained.AbsentCombatant.Battle==Battle,"admission reuses and parks the actual resident at its authored door");
        Check(Retained.health==RetainedLife && Possession.Owner==Retained && Possession.Amount==17,"admission preserves existing Life and the exact owned inventory object");
        Check(Retained.Carbine!=null && Retained.Carbine.Weapon!=null && Retained.AbsentCombatant.Friendly,"admitted defender has native firearm and faction without waiting for a loaded Tick");
        Battle.SyncTo(Due+2);
        Check(roster.PendingCursor==3 && roster.Unresolved==InitialUnresolved-3,"fractional active tic budget carries forward without an extra placement attempt");
        int rows=Battle.Rows.Size(),attackers=Port.Attackers.Size();Battle.SyncTo(Due+2);
        Check(Battle.Rows.Size()==rows && Port.Attackers.Size()==attackers && roster.PendingCursor==3,"repeated reconciliation does not repeat event birth, inventories or admissions");
        FreezeNative();
    }

    void FreezeNative()
    {
        // Keep the isolated summary snapshot stable while the native save is written.
        Port.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        CaelumHouseResidents.Get().ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        for(int i=0;i<Battle.Rows.Size();i++)
        {
            let body=Battle.Rows[i].Body;body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            for(Inventory item=body.Inv;item!=null;item=item.Inv)item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        }
        for(int i=0;i<Battle.Machines.Size();i++)Battle.Machines[i].Machine.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
    }

    void Loaded()
    {
        let roster=CaelumHouseResidents.Get();
        Check(!Port.UnvisitedCalendarPending,"older save defaults to an already visited city without inventing first-arrival history");
        Check(Port!=null && Battle!=null && Port.AbsentBattle==Battle && !Battle.ScheduleWaiting,"save retains the started event and its authoritative controller");
        Check(Port.Defenders[0]==Retained && Possession.Owner==Retained && Possession.Amount==17,"save preserves the admitted resident and actual possession identity");
        Battle.SyncTo(Due+3);
        Check(roster.PendingCursor==5 && roster.Unresolved==InitialUnresolved-5,"loaded fractional deployment cadence resumes without restarting the roster");
        Port.Boss.Body.health=0;
        for(int i=0;i<Port.Machines.Size();i++)Port.Machines[i].Neutralized=true;
        Battle.SyncTo(Due+4);
        let agenda=CaelumScheduleState.Get(CaelumPlayer(players[0].mo));
        let outcome=agenda!=null?agenda.FindKey("port16_siege_end"):null;
        Check(Port.Victory && outcome!=null && outcome.DueDay==CaelumCityWorld.SiegeDay()
            && outcome.DueTic==CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()+int(4.0*CaelumWorldClock.TicsPerHour()/3600),"absent victory records the actual round timestamp rather than the observer's return date");
        Battle.SyncTo(Due+5);
        Check(agenda.FindKey("port16_siege_end")==outcome && Port.VictoryCount==1,"victory outcome and withdrawal remain exactly once after another reconciliation");
        FreezeNative();
    }

    void Depart(CaelumPlayer user)
    {
        Port=CaelumPortSiege.Get();Due=CaelumCityWorld.SiegeCivilSeconds();
        Check(Port!=null && !Port.SiegeStarted,"real hub departure begins in the peaceful city");
        let calendar=CaelumCalendarState.Get(user,true);let clock=CaelumWorldClock.Get(user,true);
        calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-CaelumWorldClock.TicsPerHour()/60,false);
        let roster=CaelumHouseResidents.Get(true);
        Retained=roster.CreateResident(0,CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(0)));
        Retained.PostBeginPlay();
        Possession=Inventory(Actor.Spawn('CaelumCarbineAmmo',Retained.Pos,NO_REPLACE));
        Possession.BecomeItem();Retained.AddInventory(Possession);Possession.Amount=17;
        roster.Residents[0].Suspend();
        level.ChangeLevel("CABS415B",0,CHANGELEVEL_NOINTERMISSION,-1);
    }

    void ReturnCity(CaelumPlayer user)
    {
        let calendar=CaelumCalendarState.Get(user,true);let clock=CaelumWorldClock.Get(user,true);
        calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()+CaelumWorldClock.TicsPerHour()/60,false);
        level.ChangeLevel("MAP03",0,CHANGELEVEL_NOINTERMISSION,-1);
    }

    void Home()
    {
        Port=CaelumPortSiege.Get();Battle=Port!=null?Port.AbsentBattle:null;
        let roster=CaelumHouseResidents.Get();let resident=roster.Residents[0].Body;
        Console.Printf("CA415C ARRIVAL emitted=%d suspended=%d same=%d life=%d ready=%d placement=%d rows=%d rounds=%d unresolved=%d cursor=%d",
            roster.Residents[0].Emitted,roster.Residents[0].Suspended,Port.Defenders[0]==resident,resident!=null?resident.health:-1,
            roster.Ready,roster.PlacementPending.Size(),Battle.Rows.Size(),Battle.Rounds,roster.Unresolved,roster.PendingCursor);
        Check(Port!=null && Port.SiegeStarted && Battle!=null && !Battle.Away && Battle.Rounds>0,"native reopen crosses the scheduled date and resolves actual absent rounds");
        Check(Battle!=null && Battle.Encounter==Port && Port.Boss!=null,"reopened encounter remains the authoritative owner of its new boss and summary");
        Check(resident!=null && roster.Residents[0].Emitted && Port.Defenders[0]==resident,"return deploys the original traveling household resident instead of a hub copy");
        Check(resident!=null && !resident.Residence.Suspended && resident.AbsentCombatant!=null
            && !resident.AbsentCombatant.NativeResumePending && (resident.health<=0 || resident.bSolid),"returned resident resumes natively only after collision-safe placement");
        let item=resident!=null?resident.FindInventory('CaelumCarbineAmmo'):null;
        Check(item!=null && item.Amount==17,"real hub return retains the resident's actual finite possession");
        int count=0;let search=ThinkerIterator.Create('CaelumPortDefender');CaelumPortDefender body;
        while((body=CaelumPortDefender(search.Next()))!=null)if(body.HomeRevision>0 && body.HomeIdentity==0)count++;
        Check(count==1,"scheduled native travel does not duplicate the household body");
        int serial=Port.Attackers.Size();CaelumAbsentBattles.Restore(CaelumPlayer(players[0].mo));
        Check(Port.Attackers.Size()==serial && !Battle.Away,"second native restore cannot redeploy the calendar event");
    }

    void EnterUnvisited(CaelumPlayer user)
    {
        let calendar=CaelumCalendarState.Get(user,true);let clock=CaelumWorldClock.Get(user,true);
        calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()+CaelumWorldClock.TicsPerHour()/60,false);
        level.ChangeLevel("MAP03",0,CHANGELEVEL_NOINTERMISSION,-1);
    }
    void ArrivalGuards(CaelumPlayer user)
    {
        Port=CaelumPortSiege.Get();let calendar=CaelumCalendarState.Get(user,true);let clock=CaelumWorldClock.Get(user,true);
        Port.UnvisitedCalendarPending=true;CaelumAbsentBattles.FirstArrival(Port);
        Check(!Port.UnvisitedCalendarPending && Port.AbsentBattle==null && !Port.SiegeStarted,"first arrival before the deadline retains the existing peaceful city");
        calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()+CaelumWorldClock.TicsPerHour()/60,false);
        CaelumAbsentBattles.FirstArrival(Port);
        Check(Port.AbsentBattle==null,"visited or legacy state is not retroactively initialized as an unseen region");
        let roster=CaelumHouseResidents.Get(true);let resident=roster.CreateResident(0,CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(0)));
        resident.PostBeginPlay();resident.health-=17;int life=resident.health;
        let item=Inventory(Actor.Spawn('CaelumCarbineAmmo',resident.Pos,NO_REPLACE));
        item.BecomeItem();resident.AddInventory(item);item.Amount=17;
        Port.UnvisitedCalendarPending=true;CaelumAbsentBattles.FirstArrival(Port);
        Check(!Port.UnvisitedCalendarPending && Port.AbsentBattle==null && resident.health==life && item.Owner==resident && item.Amount==17,
            "previously observed household bodies are never reset to fabricate a missing past state");
    }
    void FirstHome(CaelumPlayer user)
    {
        Port=CaelumPortSiege.Get();Battle=Port!=null?Port.AbsentBattle:null;
        Check(Port!=null && Port.SiegeStarted && Battle!=null && !Battle.Away,"first visit after the scheduled date resolves the unseen city's real encounter");
        if(Battle==null)return;
        Check(Battle.Rounds>=60 && Battle.Stamp>=CaelumCityWorld.SiegeCivilSeconds()+60,"first-arrival summary begins at the authored date rather than the arrival date");
        Check(Port.Boss!=null && Port.Boss.Body.CombatProfileInitialized && Port.RosterSealed,"first-arrival summary uses the guarded native boss and sealed roster");
        let roster=CaelumHouseResidents.Get();int admitted=0;
        for(int i=0;i<roster.Residents.Size();i++)if(roster.Residents[i].Emitted)admitted++;
        Check(admitted>0 && roster.Residents[0].Body!=null && Port.Defenders[0]==roster.Residents[0].Body,"unseen resident admission creates authoritative households and binds their actual bodies");
        int rows=Battle.Rows.Size(),attackers=Port.Attackers.Size(),rounds=Battle.Rounds;
        CaelumAbsentBattles.FirstArrival(Port);CaelumAbsentBattles.Restore(user);
        Check(!Port.UnvisitedCalendarPending && Battle.Rows.Size()==rows && Port.Attackers.Size()==attackers && Battle.Rounds==rounds,"first-arrival catch-up is idempotent after initialization");
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca415r_calendar")Prepare(user);
        else if(e.Name=="ca415r_calendarload")Loaded();
        else if(e.Name=="ca415r_calendardepart")Depart(user);
        else if(e.Name=="ca415r_calendarreturn")ReturnCity(user);
        else if(e.Name=="ca415r_calendarhome")Home();
        else if(e.Name=="ca415r_firstvisit")EnterUnvisited(user);
        else if(e.Name=="ca415r_firsthome")FirstHome(user);
        else if(e.Name=="ca415r_arrivalguards")ArrivalGuards(user);
        else return;
        Console.Printf("CA415C RESULT passed=%d failed=%d",Passed,Failed);
    }
}
