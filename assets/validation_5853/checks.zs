class CA417Gunman : CaelumTravelCarbineBandit {override void Tick(){}}
class CA417Fencer : CaelumTravelBandit {override void Tick(){}}
class CA417Target : CaelumPortDefender {override void Tick(){}}
class CA417Controlled : CaelumTravelIncidents
{
    bool Attack,Failure;
    override bool RollAmbush(){return Attack;}
    override bool RollBreakdown(){return Failure;}
}
class CA417Checks : EventHandler
{
    int Passed,Failed;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA417 %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b,double tolerance=.0001){return Abs(a-b)<tolerance;}
    CA417Gunman Gunman;
    CA417Target Dummy;
    CA417Fencer Blade;
    CA417Gunman Loot;
    CaelumStashChest CampChest;
    Inventory CampGold;
    void Camp(CaelumPlayer user,int phase)
    {
        if(phase==0)
        {
            CampChest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(384,512,0),NO_REPLACE));
            CampChest.ChangeTID(941741);CampChest.GrantLawfulTitle(user);
            let gold=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',CampChest.Pos,NO_REPLACE));
            gold.args[0]=CaelumConstants.MATERIAL_GOLD_INGOT;gold.args[1]=1;gold.Amount=100;gold.AttachToOwner(CampChest);CampGold=gold;
            return;
        }
        if(phase==1)
        {user.PersistCharacterState();Level.ChangeLevel("CAT519",0,CHANGELEVEL_NOINTERMISSION);return;}
        if(phase==2)
        {
            let clock=CaelumWorldClock.Get(user);let calendar=CaelumCalendarState.Get(user,true);
            int day=calendar.DateSerial(clock),ticks=calendar.CivilDayTics(clock)+CaelumWorldClock.TicsPerHour();
            calendar.SetAnchor(clock,day+ticks/CaelumWorldClock.TicsPerDay(),ticks%CaelumWorldClock.TicsPerDay(),false);
            Level.ChangeLevel("CAR01",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        let chest=CaelumStashChest(ActorIterator.Create(941741).Next());
        let group=CaelumTravelAmbush(ThinkerIterator.Create('CaelumTravelAmbush').Next());
        Check(chest==CampChest && chest!=null && group!=null,"actual camp and surviving encounter return from their native hub");
        if(chest==null || group==null)return;
        int receipts=0,known=0;CaelumTravelBandit thief;
        for(int i=0;i<group.Bandits.Size();i++)
        {
            let body=group.Bandits[i];let plan=body.AbsentTheft;
            Check(plan!=null && !plan.Away && plan.Attempts==1,"surviving bandit receives one actual absent-hour opportunity");
            if(plan==null)continue;
            receipts+=plan.Receipts.Size();for(int j=0;j<plan.Receipts.Size();j++)if(plan.Receipts[j].Known)known++;
            if(CampGold.Owner==body)thief=body;
        }
        Check(receipts==1 && known==1 && thief!=null && CampGold.Amount==100,"accessible camp stack has one real thief and one disclosed loss");
        Check(!CaelumAbsentArrivalEvents.Active() && !level.isFrozen(),"theft and physiology finish before play resumes");
        if(thief!=null)
        {
            thief.bInvulnerable=false;thief.health=0;thief.Die(user,user,0,'None');
            let search=ThinkerIterator.Create('CaelumMaterialPickup');CaelumMaterialPickup piece;int dropped=0;
            while((piece=CaelumMaterialPickup(search.Next()))!=null)
                if(piece.Owner==null && piece.args[0]==CaelumConstants.MATERIAL_GOLD_INGOT)dropped+=piece.Amount;
            Check(dropped==100 && (CampGold.Owner!=thief || CampGold.Amount==0 || CampGold.bDestroyed),"defeated thief releases the stolen property with its real loot");
            Console.Printf("CA417 LOOT gold=%d previous=%d destroyed=%d killed=%d",dropped,CampGold.Amount,CampGold.bDestroyed,thief.bKilled);
        }
    }
    void PrepareBandits(CaelumPlayer user)
    {
        user.bInvulnerable=true;
        Gunman=CA417Gunman(Actor.Spawn('CA417Gunman',(128,48,0),NO_REPLACE));
        Dummy=CA417Target(Actor.Spawn('CA417Target',(128,208,0),NO_REPLACE));
        Blade=CA417Fencer(Actor.Spawn('CA417Fencer',(-128,48,0),NO_REPLACE));
        Loot=CA417Gunman(Actor.Spawn('CA417Gunman',(512,256,0),NO_REPLACE));
    }
    void Bandits(CaelumPlayer user)
    {
        let blade=Blade;
        Check(Gunman!=null && Dummy!=null && blade!=null,"native human actors spawn");
        if(Gunman==null || Dummy==null || blade==null)return;
        Dummy.bInvulnerable=true;Dummy.bFriendly=true;
        Check(!Gunman.bFriendly && !blade.bFriendly && Gunman.CombatStrength==CaelumPortData.DEFENDER_ATTRIBUTE,"bandits use existing hostile human profile");
        Check(blade.Sword!=null && blade.Sword.WeaponType==CaelumConstants.WEAPON_TYPE_MACHETE && blade.Sword.Tier==1,"melee bandit uses real T1 machete");
        Check(Gunman.Sword==null && Gunman.Carbine!=null && Gunman.Carbine.FiniteReserve,"gunman has finite carbine and no invented sidearm");
        Check(Gunman.Gear!=null && Gunman.Gear.Owner==Gunman && Gunman.Gear.ItemType==CaelumConstants.WEAPON_TYPE_CARBINE,"weapon is actual owned inventory");
        Check(Gunman.AbsentTheft!=null && blade.AbsentTheft!=null && Dummy.AbsentTheft==null,"only explicit bandits are thieves");
        Check(Gunman.Carbine.Reserve()==20,"gunman owns exactly twenty real cartridges");
        Check(Gunman.Carbine.LoadCount()==Min(20,CaelumRangedRules.MagazineCapacity(CaelumConstants.WEAPON_TYPE_CARBINE)),"loaded magazine references existing cartridges");
        Check(Gunman.CarbineTarget(user) && !Gunman.CarbineTarget(blade),"gunman targets the player without shooting its bandit group");
        let attack=new('CaelumAbsentAttack');
        Check(attack.Configure(blade,false) && attack.Weapon==CaelumConstants.WEAPON_TYPE_MACHETE,"absent melee keeps the actual machete profile");
        Check(attack.Configure(Gunman,false) && attack.Kind==CaelumAbsentAttack.CARBINE,"ranged-only gunman retains its attack at close range");
        let thermal=CaelumThermalService.CaptureForecast(blade);let exposure=new('CaelumContaminationNPC');
        exposure.Capture(blade,thermal);int views=0;
        for(int i=0;i<exposure.Frame.Items.Size();i++)
            if(exposure.Frame.Items[i].Item==blade.Gear || exposure.Frame.Items[i].Endpoint.Record==blade.Sword.ContaminationState)views++;
        Check(views==1 && blade.Gear.HasAcquiredIdentity(),"native sidearm has one authoritative exposure and acquired identity");
        for(int i=0;i<20;i++)
        {
            Gunman.target=Dummy;Gunman.CurrentCombatAir=Gunman.MaximumCombatAir;Gunman.RecoveryPhase=0;
            Gunman.Carbine.NextShotTic=0;
            if(Gunman.Carbine.Magazine==0)
            {
                Gunman.Carbine.Attack(Gunman,Dummy);
                Check(Gunman.Carbine.ReloadRemaining>0,"empty native magazine requires reload");
                Gunman.Carbine.ReloadRemaining=1.0/TICRATE;Gunman.Carbine.Tick(Gunman);
            }
            Gunman.Carbine.Attack(Gunman,Dummy);
            Check(Gunman.Carbine.ShotCount==i+1 && Gunman.Carbine.Reserve()==19-i,"successful native projectile consumes one real cartridge");
        }
        Check(!Gunman.Carbine.HasAmmunition() && !Gunman.Carbine.Attack(Gunman,Dummy) && Gunman.Carbine.ShotCount==20,"empty reserve cannot create a twenty-first projectile");
        Check(!attack.Configure(Gunman,true),"absent combat also rejects exhausted ammunition");
        Dummy.Carbine=new('CaelumCityCarbine');Dummy.Carbine.Initialize(Dummy);
        Check(Dummy.Carbine.HasAmmunition() && Dummy.Carbine.Reserve()==0 && Dummy.Carbine.LoadCount()==CaelumRangedRules.MagazineCapacity(CaelumConstants.WEAPON_TYPE_CARBINE),"existing defenders retain approved unlimited supply");

        // Test a separate live owner so remaining rounds and wear are meaningful loot.
        let loot=Loot;
        loot.Carbine.CommitRound();loot.Carbine.CommitRound();loot.Carbine.CommitRound();
        loot.Carbine.Weapon.Durability-=7;
        loot.Carbine.Weapon.ContaminationState.Ensure();loot.Carbine.Weapon.ContaminationState.Concentration=37;
        int wear=loot.Carbine.Weapon.Durability;let gear=loot.Gear;
        loot.health=0;loot.Die(user,user,0,'None');
        int rounds=0,owned=0;let search=ThinkerIterator.Create('CaelumCarbineAmmo');Inventory item;
        while((item=Inventory(search.Next()))!=null)if(item.Owner==null)rounds+=item.Amount;
        search=ThinkerIterator.Create('CaelumWeaponPickup');CaelumWeaponPickup pickup;
        while((pickup=CaelumWeaponPickup(search.Next()))!=null)
            if(pickup.Owner==null && pickup.ItemType==CaelumConstants.WEAPON_TYPE_CARBINE)
            {owned++;Check(pickup.Durability==wear && Near(pickup.ContaminationState.Concentration,37),"native dropped weapon retains wear and contamination");}
        let remaining=loot.FindInventory('CaelumCarbineAmmo');
        Check(rounds==17 && owned==1 && (remaining==null || remaining.Amount==0),"death releases exact remaining rounds and one weapon");
        loot.Die(user,user,0,'None');
        rounds=0;search=ThinkerIterator.Create('CaelumCarbineAmmo');
        while((item=Inventory(search.Next()))!=null)if(item.Owner==null)rounds+=item.Amount;
        Check(rounds==17 && loot.Gear==null && loot.Carbine.Weapon==null,"repeat death cannot duplicate ammunition or recreate a weapon");
    }
    void Encounter(CaelumPlayer user,int phase)
    {
        user.bInvulnerable=true;user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.GetPersistentCharacterState(true).ProfileCommitted=true;
        let booking=CaelumTransportBooking.Find(user);
        if(phase==0)
        {
            booking=CaelumTransportBooking(user.GiveInventoryType('CaelumTransportBooking'));booking.Revision=2;
            booking.Sequence=1;booking.Ticket=CaelumTransportTicket.Create(19,5,1,0,0);
            let events=CA417Controlled(new('CA417Controlled'));events.Attack=true;events.Initialize(booking.Ticket);
            events.Advance(booking.Ticket,booking.Ticket.Departure+CaelumTravelIncidents.SecondsAt(booking.Ticket,10),0,0);
            booking.Incidents=events;booking.StopMap=booking.TransferMap=level.MapName;booking.ArrivalPending=true;
            CaelumTransportTrip.Loaded(user);
            Check(!booking.ArrivalPending && !events.AmbushPending,"native arrival consumes the pending encounter once");return;
        }
        if(phase==3)
        {
            Check(CaelumTransportTrip.Aboard(user),"fleeing boards the same paid service");
            Check(booking.Incidents.Ambushes==1 && booking.Incidents.AmbushRolls==1,"fleeing never rerolls the encountered boundary");
            CaelumTransportTrip.RequestExit(user);return;
        }
        let search=ThinkerIterator.Create('CaelumTravelAmbush');CaelumTravelAmbush group;int count=0;
        while((group=CaelumTravelAmbush(search.Next()))!=null)count++;
        search=ThinkerIterator.Create('CaelumTravelAmbush');group=CaelumTravelAmbush(search.Next());
        Check(count==1 && group!=null,"one native encounter marker survives the hub");if(group==null)return;
        Check(group.Bandits.Size()==3 && group.Cursor==3,"three bandits fit actual roadside collision geometry");
        if(group.Bandits.Size()!=3)return;
        Check(group.Bandits[0].Sword!=null && group.Bandits[1].Sword!=null && group.Bandits[2].Carbine!=null,"encounter contains two machetes and one carbine");
        Check(group.Bandits[0].AbsentTheft!=null && group.Bandits[1].AbsentTheft!=null && group.Bandits[2].AbsentTheft!=null,"all surviving bandits participate in approved theft");
        if(phase==1)
        {
            for(int i=0;i<3;i++){group.Bandits[i].bDormant=true;group.Bandits[i].SetState(group.Bandits[i].SpawnState);}
            group.Bandits[0].Sword.Durability=33;
            booking.Incidents.AmbushPending=true;CaelumTravelAmbush.Enter(user,booking);
            Check(group.Bandits.Size()==3 && group.Bandits[0].Sword.Durability==33,"repeated arrival reuses existing equipment without respawn");
        }
        else
        {
            Check(group.Bandits[0].Sword.Durability==33,"saved or revisited encounter keeps actual weapon wear");
            Check(phase==2?Near(booking.Ticket.CoveredKm(),10):booking.Ticket.CoveredKm()>10 && booking.Ticket.CoveredKm()<20,"paid progress is preserved on load and advances only aboard");
            if(phase==2)
            {
                for(int i=0;i<3;i++){group.Bandits[i].bDormant=false;group.Bandits[i].target=user;}
                Check(CaelumTravelIncidents.MayResume(user,booking),"ambush permits fleeing despite nearby hostile actors");
                Check(CaelumTransportTrip.Resume(user),"native resume leaves the encounter without buying another fare");
            }
        }
    }
    void Core(CaelumPlayer user)
    {
        Check(CaelumTravelIncidentData.AMBUSH_PERCENT==1 && CaelumTravelIncidentData.AMBUSH_KM==10,"approved ambush calibration");
        Check(CaelumTravelIncidentData.BREAKDOWN_PERCENT==2 && CaelumTravelIncidentData.BREAKDOWN_KM==100 && CaelumTravelIncidentData.REPAIR_SECONDS==7200,"approved mechanical calibration");
        Check(CaelumTravelIncidentData.Storm(60,0) && CaelumTravelIncidentData.Storm(0,20),"either exact weather threshold blocks movement");
        Check(!CaelumTravelIncidentData.Storm(59.999,19.999),"both weather quantities below threshold permit movement");
        for(int mode=3;mode<=6;mode++)
        {
            Check(CaelumTravelIncidentData.AmbushMode(mode)==(mode==3 || mode==5),"only road horse/cart journeys have ambush rolls");
            Check(CaelumTravelIncidentData.BreakdownMode(mode)==(mode!=5),"horses have no mechanical failure roll");
        }
        let ticket=CaelumTransportTicket.Create(19,6,1,0,0);
        let events=CA417Controlled(new('CA417Controlled'));events.Initialize(ticket);
        double departure=ticket.Departure;
        events.Advance(ticket,departure+60,60,0);
        Check(ticket.Elapsed==0 && events.Storm && ticket.Stamp==departure+60,"storm advances the observation clock without paid distance");
        events.Advance(ticket,departure+120,0,20);
        Check(ticket.Elapsed==0 && events.Storm,"rain alone retains the hold");
        events.Advance(ticket,departure+180,59,19);
        Check(Near(ticket.Elapsed,60) && !events.Storm,"clearing weather resumes only the new elapsed interval");
        events.Advance(ticket,departure+180,0,0);
        Check(Near(ticket.Elapsed,60),"repeated clock observation does not move again");

        ticket=CaelumTransportTicket.Create(19,6,1,0,0);
        events=CA417Controlled(new('CA417Controlled'));events.Failure=true;events.Initialize(ticket);
        double boundary=CaelumTravelIncidents.SecondsAt(ticket,100);
        events.Advance(ticket,ticket.Departure+boundary+40,0,0);
        Check(events.Breakdowns==1 && events.BreakdownRolls==1 && events.BreakdownIndex==2,"crossing 100 km records one mechanical roll before stopping");
        Check(Near(ticket.CoveredKm(),100) && Near(events.RepairUntil,ticket.Departure+boundary+7200),"failure stops at the distance boundary with a two-hour world deadline");
        double end=events.RepairUntil;events.Advance(ticket,end-1,0,0);
        Check(Near(ticket.CoveredKm(),100),"crew repair consumes time without moving");
        events.Advance(ticket,end+60,0,0);
        Check(events.RepairUntil==0 && Near(ticket.Elapsed,boundary+60),"movement resumes after exactly the repair interval");
        Check(events.BreakdownRolls==1 && events.Breakdowns==1,"repair and repeated observations never reroll that interval");

        ticket=CaelumTransportTicket.Create(19,5,1,0,0);
        events=CA417Controlled(new('CA417Controlled'));events.Attack=true;events.Initialize(ticket);
        boundary=CaelumTravelIncidents.SecondsAt(ticket,10);
        events.Advance(ticket,ticket.Departure+boundary+3,0,0);
        Check(events.AmbushPending && events.AmbushActive && events.Ambushes==1 && ticket.Status==CaelumTransportTicket.STOPPED,"rural attack interrupts the actual ticket");
        Check(Near(ticket.CoveredKm(),10) && events.AmbushRolls==1 && events.AmbushIndex==2,"ambush retains exact position and consumes its roll");
        events.Advance(ticket,ticket.Stamp+86400,0,0);
        Check(Near(ticket.CoveredKm(),10) && events.AmbushRolls==1,"a day ashore cannot move or replay the encounter");
        Check(ticket.Resume(ticket.Stamp+86400),"existing ticket can resume after an encounter");
        events.Attack=false;events.Advance(ticket,ticket.Stamp+60,0,0);
        Check(Near(ticket.CoveredKm(),10+8.0/60) && events.AmbushRolls==1,"resumption continues beyond the consumed interval");

        ticket=CaelumTransportTicket.Create(19,3,1,0,0);
        ticket.Observe(ticket.Departure+CaelumTravelIncidents.SecondsAt(ticket,150));
        events=CA417Controlled(new('CA417Controlled'));events.Initialize(ticket);
        Check(events.AmbushIndex==16 && events.BreakdownIndex==2 && events.AmbushRolls==0,"old paid distance initializes after its traversed boundaries");
        events.Advance(ticket,ticket.Stamp+1,0,0);
        Check(events.AmbushRolls==0 && events.BreakdownRolls==0,"migration creates no retrospective incidents");

        ticket=CaelumTransportTicket.Create(19,3,1,0,0);
        events=CA417Controlled(new('CA417Controlled'));events.Initialize(ticket);
        for(int i=0;i<8;i++)events.Advance(ticket,ticket.Departure+ticket.DurationSeconds,0,0);
        Check(ticket.Status==CaelumTransportTicket.COMPLETE && Near(ticket.CoveredKm(),ticket.DistanceKm),"bounded catch-up eventually drains a large clock observation exactly");
        Check(events.AmbushRolls==int(Floor(ticket.DistanceKm/10)) && events.BreakdownRolls==int(Floor(ticket.DistanceKm/100)),"each eligible traveled interval receives exactly one roll");

        // Save the actual authority while interrupted for repair.
        ticket=CaelumTransportTicket.Create(19,6,1,0,0);
        events=CA417Controlled(new('CA417Controlled'));events.Failure=true;events.Initialize(ticket);
        boundary=CaelumTravelIncidents.SecondsAt(ticket,100);
        events.Advance(ticket,ticket.Departure+boundary+40,0,0);
        let booking=CaelumTransportBooking(user.GiveInventoryType('CaelumTransportBooking'));
        booking.Revision=2;booking.Ticket=ticket;booking.Incidents=events;booking.Onboard=false;
        Check(booking.Incidents==events,"saved booking owns the exact incident state");
    }
    void Reload(CaelumPlayer user)
    {
        let booking=CaelumTransportBooking.Find(user);
        Check(booking!=null && booking.Incidents!=null,"native save retains ticket and incident authority");if(booking==null || booking.Incidents==null)return;
        let events=booking.Incidents;let ticket=booking.Ticket;
        Check(events.Breakdowns==1 && events.BreakdownRolls==1 && events.BreakdownIndex==2 && events.RepairUntil>0,"saved repair deadline and consumed roll survive reload");
        double elapsed=ticket.Elapsed;events.Advance(ticket,events.RepairUntil-1,0,0);
        Check(Near(elapsed,ticket.Elapsed) && events.Breakdowns==1,"reload cannot skip remaining repair time or create a second failure");
        events.Advance(ticket,events.RepairUntil+60,0,0);
        Check(Near(ticket.Elapsed,elapsed+60) && events.RepairUntil==0,"saved repair resumes once at its original deadline");
    }
    void NativeClock(CaelumPlayer user)
    {
        user.bInvulnerable=true;user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        let booking=CaelumTransportBooking(user.GiveInventoryType('CaelumTransportBooking'));booking.Revision=2;
        booking.Ticket=CaelumTransportTicket.Create(19,6,1,0,0);booking.Onboard=true;
        let ticket=booking.Ticket;ticket.Departure=CaelumTransportBooking.Now(user);ticket.Stamp=ticket.Departure-60;ticket.Status=CaelumTransportTicket.TRAVELLING;
        booking.Incidents=new('CA417Controlled');let incidents=CaelumTravelIncidents.Get(booking);
        let weather=CaelumWeatherState.Get(user);weather.Current.WindSpeedKmh=weather.Current.PrecipitationMmPerHour=0;
        weather.Outside.Available=true;weather.Outside.WindSpeedKmh=60;weather.Outside.PrecipitationMmPerHour=0;
        Check(CaelumTransportTrip.Aboard(user),"native weather check is inside the actual train service");
        CaelumTransportTrip.Step(user);
        Check(incidents.Storm && ticket.Elapsed==0,"covered train observes exterior storm despite calm sheltered sample");
        weather.Outside.WindSpeedKmh=0;weather.Outside.PrecipitationMmPerHour=20;ticket.Stamp-=60;CaelumTransportTrip.Step(user);
        Check(incidents.Storm && ticket.Elapsed==0,"actual passenger is held by exterior rain alone");
        weather.Outside.PrecipitationMmPerHour=0;ticket.Stamp-=60;CaelumTransportTrip.Step(user);
        Check(!incidents.Storm && Near(ticket.Elapsed,60),"actual trip resumes when both exterior measures clear");
        incidents.RepairUntil=CaelumTransportBooking.Now(user)+120;
        double hunger=user.CurrentHunger,thirst=user.CurrentThirst,start=ticket.Elapsed;
        for(int i=0;i<105;i++)CaelumTimeAdvanceState.SimulatePersonalTic(user);
        Check(Near(ticket.Elapsed,start) && incidents.RepairUntil>CaelumTransportBooking.Now(user),"native personal clock advances crew repair without distance");
        Check(user.CurrentHunger<hunger && user.CurrentThirst<thirst,"waiting for repair spends actual Hunger and Thirst");
        for(int i=0;i<175;i++)CaelumTimeAdvanceState.SimulatePersonalTic(user);
        Check(incidents.RepairUntil==0 && ticket.Elapsed>start,"native personal clock completes repair and resumes travel");
        Check(CaelumTimeSkipState.OpenMenu(user),"passenger can open native waiting controls");
        let skip=CaelumTimeSkipState.Get(user);if(skip==null)return;skip.Active=true;skip.TravelDestination=true;
        skip.TargetDay=CaelumTimeSkipState.NowDay(user);skip.TargetTics=CaelumTimeSkipState.NowTics(user);
        CaelumTimeSkipState.AfterStep(user);
        Check(skip.Active && (skip.TargetDay>CaelumTimeSkipState.NowDay(user) || skip.TargetTics>CaelumTimeSkipState.NowTics(user)),"arrival wait extends past its nominal deadline while still aboard");
        skip.Active=false;booking.Onboard=false;ticket.Status=CaelumTransportTicket.STOPPED;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);Passed=Failed=0;
        if(e.Name=="ca417_prepare_bandits"){PrepareBandits(user);return;}
        if(e.Name=="ca417_camp"){Camp(user,e.Args[0]);Console.Printf("CA417 RESULT camp=%d passed=%d failed=%d",e.Args[0],Passed,Failed);return;}
        if(e.Name=="ca417_encounter"){Encounter(user,e.Args[0]);Console.Printf("CA417 RESULT phase=%d passed=%d failed=%d",e.Args[0],Passed,Failed);return;}
        if(e.Name=="ca417_core")Core(user);else if(e.Name=="ca417_reload")Reload(user);else if(e.Name=="ca417_bandits")Bandits(user);else if(e.Name=="ca417_native_clock")NativeClock(user);else return;
        Console.Printf("CA417 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
