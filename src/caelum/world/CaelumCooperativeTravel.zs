// Una salida pertenece a la sesión. Ningún consentimiento cobra ni cambia mapa.
class CaelumCooperativeTravel : Inventory
{
    enum TravelKind { JOURNEY, HOUSE, BOARD, DISEMBARK, RESUME, ABANDON, TUTORIAL, LIMBO, LIMBO_RETURN, ARENA, ARENA_RETURN }
    enum Operation { ACCEPT, CANCEL }
    CaelumPlayer Members[MAXPLAYERS];
    CaelumJourneyPlan Plans[MAXPLAYERS];
    CaelumHousePortal Portal;
    CaelumM00ReturnDoor TutorialDoor;
    CaelumTravelVehicle Vehicle;
    CaelumTransportTicket Ride;
    int Fare;
    int ArenaVenue,ArenaMode,ArenaTeams[MAXPLAYERS];
    Actor ArenaOrganizer;
    bool ExceptionalFool;
    bool TarotSelection[CaelumConstants.TAROT_CARD_COUNT];
    bool TarotAcquired[CaelumConstants.TAROT_CARD_COUNT];
    int TarotOrder[CaelumConstants.TAROT_CARD_COUNT],TarotOrderCount,FoolSequenceRevision;
    bool FoolDevilPayment;
    Actor TarotTarget;
    CaelumPalomo FoolSpeaker;
    int Mask,AliveMask,Accepted,Serial,Kind,Connection,Mode,Entry,Elapsed;
    bool Opened,Committed,Interrupted;
    double Pace;
    String OriginMap,Destination;
    vector3 OriginPosition;

    clearscope bool IsTransport() const { return Kind>=BOARD && Kind<=ABANDON; }

    // El viaje de El Loco consulta a los vivos; la excepción de todos muertos
    // y los demás traslados conservan la unanimidad de participantes.
    clearscope int RequiredMask() const {return Kind==LIMBO && AliveMask!=0?AliveMask:Mask;}
    clearscope bool Consented() const {return (Accepted&RequiredMask())==RequiredMask();}

    static clearscope CaelumCooperativeTravel View(CaelumPlayer user)
    {
        let clock=user!=null?CaelumWorldClock(user.FindInventory('CaelumWorldClock')):null;
        return clock!=null?clock.TravelVote:null;
    }
    clearscope int Slot(CaelumPlayer user)
    {
        if(user==null || user.player==null)return -1;
        int n=user.PlayerNumber();return n>=0 && n<MAXPLAYERS && Members[n]==user?n:-1;
    }
    static bool BodyReady(CaelumPlayer user)
    {
        if(!CaelumWorldClockTicker.Ready(user))return false;
        if(!CaelumCooperativeTime.Living(user))return true;
        return !user.HasActiveConversation() && !user.CraftingTaskActive && !user.CraftingMenuOpen
            && !user.PalomoMerchantMenuOpen && !user.EquipmentMenuOpen
            && !CaelumRestState.IsActive(user) && !(user.player.cheats&CF_TOTALLYFROZEN);
    }
    bool RosterValid()
    {
        if(OriginMap!=level.MapName || !LevelInfo.MapExists(Destination))return false;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(playeringame[i]!=(Members[i]!=null))return false;
            if(Members[i]!=null && (players[i].mo!=Members[i] || !CaelumWorldClockTicker.Ready(Members[i])
                || CaelumCooperativeTime.Living(Members[i])!=((AliveMask&(1<<i))!=0)))return false;
        }
        return true;
    }
    bool SourceValid()
    {
        let proposer=CaelumPlayer(Owner);
        if(Kind==ARENA || Kind==ARENA_RETURN)return CaelumArena.Valid(self);
        if(Kind==LIMBO || Kind==LIMBO_RETURN)return CaelumFoolTravel.Valid(self);
        if(!CaelumCooperativeTime.Living(proposer))return false;
        if(Kind==TUTORIAL)return TutorialDoor!=null && !TutorialDoor.bDestroyed
            && CaelumMainM00Return.CanApproach(proposer,TutorialDoor);
        if(IsTransport())return CaelumCooperativeTransport.SourceValid(self);
        if(Kind==HOUSE)return Portal!=null && !Portal.bDestroyed
            && Portal.DestinationMap()==Destination && CaelumUseGeometry.AimedAt(proposer,Portal);
        return (proposer.Pos-OriginPosition).Length()<=64;
    }
    bool NextSerial()
    {
        let source=CaelumWorldClockTicker.CampaignOwner();let clock=CaelumWorldClock.Get(source);
        if(clock==null || clock.CooperativeSerial==2147483647)return false;
        Serial=++clock.CooperativeSerial;CaelumWorldClockTicker.Mirror(source);return true;
    }
    static CaelumCooperativeTravel Draft(CaelumPlayer user,bool allowDead=false,bool allowSolo=false)
    {
        if((!multiplayer && !allowSolo) || !CaelumPlayerAuthority.CanMutate(user) || (!allowDead && !CaelumCooperativeTime.Living(user)))return null;
        let clock=CaelumWorldClock.Get(CaelumWorldClockTicker.CampaignOwner());
        if(clock==null || (clock.TimeVote!=null && clock.TimeVote.Opened)
            || (clock.TravelVote!=null && clock.TravelVote.Opened))return null;
        let vote=CaelumCooperativeTravel(user.FindInventory('CaelumCooperativeTravel'));
        if(vote==null)vote=CaelumCooperativeTravel(user.GiveInventoryType('CaelumCooperativeTravel'));
        if(vote==null)return null;
        vote.ReleasePlans();vote.Mask=vote.AliveMask=vote.Accepted=0;
        vote.Opened=vote.Committed=vote.Interrupted=false;vote.Portal=null;vote.TutorialDoor=null;vote.Vehicle=null;vote.Ride=null;
        vote.Elapsed=0;vote.Pace=0;vote.Fare=0;
        vote.FoolSequenceRevision=0;vote.FoolDevilPayment=false;vote.TarotTarget=null;
        vote.OriginMap=level.MapName;vote.OriginPosition=user.Pos;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            vote.Members[i]=null;if(!playeringame[i])continue;
            let member=CaelumPlayer(players[i].mo);if(!BodyReady(member))return null;
            vote.Members[i]=member;vote.Mask|=1<<i;
            if(CaelumCooperativeTime.Living(member))vote.AliveMask|=1<<i;
        }
        return vote;
    }
    bool Publish()
    {
        let clock=CaelumWorldClock.Get(CaelumWorldClockTicker.CampaignOwner());
        if(clock==null)return false;
        clock.TravelVote=self;
        if(!NextSerial()){clock.TravelVote=null;ReleasePlans();return false;}
        Opened=true;return true;
    }
    static bool ProposeHouse(CaelumPlayer user,CaelumHousePortal portal)
    {
        if(portal==null || portal.bDestroyed || !CaelumUseGeometry.AimedAt(user,portal)
            || !LevelInfo.MapExists(portal.DestinationMap()))return false;
        let vote=Draft(user);if(vote==null)return false;
        vote.Kind=HOUSE;vote.Portal=portal;vote.Destination=portal.DestinationMap();
        vote.Entry=portal.args[1]==0?0:portal.args[0]+1;
        return vote.Publish();
    }
    static bool ProposeJourney(CaelumPlayer user,int connection,int mode)
    {
        if(!CaelumJourneyRules.ValidMode(connection,mode) || !CaelumTravelService.CanDepart(user,connection))return false;
        let vote=Draft(user);if(vote==null)return false;
        vote.Kind=JOURNEY;vote.Connection=connection;vote.Mode=mode;
        vote.Destination=CaelumWorldCatalogue.MapForLocation(CaelumWorldCatalogue.ConnectionDestination(connection));
        vote.Entry=CaelumWorldCatalogue.ConnectionDestination(connection)==CaelumWorldCatalogue.LOCATION_SEWERS?1:0;
        bool okay,changed;[okay,changed]=vote.PreparePlans(false);
        if(!okay){vote.ReleasePlans();return false;}
        return vote.Publish();
    }
    void ReleasePlans()
    {for(int i=0;i<MAXPLAYERS;i++){if(Plans[i]!=null)Plans[i].Destroy();Plans[i]=null;}}
    static bool SameCosts(CaelumJourneyPlan a,CaelumJourneyPlan b)
    {
        if(a==null || b==null)return a==b;
        return a.PlannedWalkTics==b.PlannedWalkTics && a.Available.ElapsedTics==b.Available.ElapsedTics
            && a.Available.FoodSpent==b.Available.FoodSpent && a.Available.WaterSpent==b.Available.WaterSpent
            && Abs(a.Available.ContainerSpent-b.Available.ContainerSpent)<0.000001
            && (a.Available.Health<=0)==(b.Available.Health<=0)
            && a.Available.FoodStock==b.Available.FoodStock && a.Available.WaterStock==b.Available.WaterStock
            && Abs(a.Available.ContainerStock-b.Available.ContainerStock)<0.000001;
    }
    bool,bool PreparePlans(bool compare)
    {
        if(IsTransport()){bool okay,changed;[okay,changed]=CaelumCooperativeTransport.Prepare(self,compare);return okay,changed;}
        if(Kind==TUTORIAL)return CaelumCooperativeReturn.Prepare(self),false;
        if(Kind!=JOURNEY)return true,false;
        double speed=0;
        for(int i=0;i<MAXPLAYERS;i++)if((AliveMask&(1<<i))!=0)
        {
            let member=Members[i];if(!CaelumTravelService.CanDepart(member,Connection))return false,false;
            if(CaelumJourneyRules.DistanceKm(Connection)<=0)continue;
            String reason=CaelumJourneyRules.BlockReason(member);
            if(reason!=""){CaelumNotifications.Notify(member,StringTable.Localize(reason,false));return false,false;}
            double current=CaelumJourneyRules.SpeedForMode(member,Mode);
            if(current<=0)return false,false;
            speed=speed<=0?current:Min(speed,current);
        }
        if(CaelumJourneyRules.DistanceKm(Connection)<=0){Elapsed=0;return true,false;}
        // Sólo ocho modelos como máximo, calculados al proponer/confirmar, nunca por tic.
        CaelumJourneyPlan fresh[MAXPLAYERS];int elapsed=2147483647;bool failed=false;
        for(int i=0;i<MAXPLAYERS;i++)if((AliveMask&(1<<i))!=0)
        {
            fresh[i]=CaelumJourneyPlan(Actor.Spawn('CaelumJourneyPlan',Members[i].Pos,NO_REPLACE));
            if(fresh[i]==null || !fresh[i].Calculate(Members[i],Connection,Mode,speed)){failed=true;break;}
            elapsed=Min(elapsed,fresh[i].Available.ElapsedTics);
        }
        // Si alguien muere en marcha, todos llegan al mismo instante, sin adelantar
        // al superviviente hasta el destino ni consumir su siguiente tramo.
        if(!failed)for(int i=0;i<MAXPLAYERS;i++)if(fresh[i]!=null && fresh[i].Available.ElapsedTics!=elapsed)
            if(!fresh[i].Calculate(Members[i],Connection,Mode,speed,elapsed)){failed=true;break;}
        if(failed){for(int i=0;i<MAXPLAYERS;i++)if(fresh[i]!=null)fresh[i].Destroy();return false,false;}
        bool changed=false;Interrupted=false;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(compare && !SameCosts(Plans[i],fresh[i]))changed=true;
            if(Plans[i]!=null)Plans[i].Destroy();Plans[i]=fresh[i];
            if(fresh[i]!=null && fresh[i].Available.Health<=0)Interrupted=true;
        }
        Pace=speed;Elapsed=elapsed;return true,changed;
    }
    bool Request(CaelumPlayer user,int operation,int expected)
    {
        int slot=Slot(user);
        if(!Opened || slot<0 || expected!=Serial || !RosterValid())return false;
        if(operation==CANCEL){Finish("CA_COOP_TRAVEL_CANCELLED");return true;}
        if(operation!=ACCEPT || (Accepted&(1<<slot))!=0 || !BodyReady(user))return false;
        if(!SourceValid()){Finish("CA_COOP_TRAVEL_CANCELLED");return false;}
        Accepted|=1<<slot;
        if(!Consented())return true;
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null && !BodyReady(Members[i]))
        {Finish("CA_COOP_TRAVEL_CANCELLED");return false;}
        bool okay,changed;[okay,changed]=PreparePlans(true);
        if(!okay){Finish("CA_COOP_TRAVEL_CANCELLED");return false;}
        if(changed)
        {
            Accepted=0;if(!NextSerial()){Finish("CA_COOP_TRAVEL_CANCELLED");return false;}
            for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
                CaelumNotifications.Notify(Members[i],StringTable.Localize("CA_JOURNEY_REVISED",false));
            return false;
        }
        Commit();return true;
    }
    void Finish(String reason)
    {
        if(Kind==DISEMBARK && !Committed && Ride!=null)Ride.TransferDeclined=true;
        Opened=false;NextSerial();
        if(Kind==TUTORIAL && !Committed)CaelumMainM00Return.Cancel(CaelumPlayer(Owner),false);
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {
            let clock=CaelumWorldClock.Get(Members[i]);if(clock!=null && clock.TravelVote==self)clock.TravelVote=null;
            if(reason!="")CaelumNotifications.Notify(Members[i],StringTable.Localize(reason,false));
        }
        ReleasePlans();
    }
    void Commit()
    {
        if(!Opened || !Consented() || !RosterValid() || !SourceValid())return;
        if(Kind==ARENA || Kind==ARENA_RETURN)
        {
            if(!CaelumArena.Commit(self)){Finish("CA_ARENA_NOT_READY");return;}
            Committed=true;Finish("");CaelumDeadTraveler.ChangeMap(Destination,Entry,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(Kind==LIMBO || Kind==LIMBO_RETURN)
        {
            if(!CaelumFoolTravel.Commit(self)){Finish("CA_COOP_TRAVEL_CANCELLED");return;}
            Committed=true;Finish("");CaelumDeadTraveler.ChangeMap(Destination,Entry,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(Kind==TUTORIAL)
        {
            if(!CaelumCooperativeReturn.Commit(self)){Finish("CA_COOP_RETURN_READY");return;}
            Committed=true;Finish("");
            CaelumDeadTraveler.ChangeMap(Destination,Entry,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(IsTransport())
        {
            if(!CaelumCooperativeTransport.Commit(self)){Finish("CA_COOP_TRAVEL_CANCELLED");return;}
            Committed=true;Finish("");
            if(Kind!=ABANDON)CaelumDeadTraveler.ChangeMap(Destination,Entry,CHANGELEVEL_NOINTERMISSION);
            return;
        }
        Committed=true;
        // Registrar todas las salidas antes de avanzar un único reloj compartido.
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {
            let member=Members[i];CaelumTransportTrip.CloseActivities(member);
            if(Kind==HOUSE){member.PendingTravelWipe=CaelumConstants.TRAVEL_WIPE_HOUSE_DOOR;continue;}
            let journey=CaelumJourneyState.Get(member,true);journey.Sequence=Min(journey.Sequence,2147483646)+1;
            journey.ConnectionId=Connection;journey.TravelMode=Mode;journey.RecordDepartureTime(member);
            journey.Status=Interrupted?CaelumJourneyState.STATUS_INTERRUPTED:CaelumJourneyState.STATUS_DEPARTED;
            if(Interrupted)journey.Interruptions=Min(journey.Interruptions,2147483646)+1;
            journey.LiveTransport=false;journey.LiveWorldSeconds=0;
            journey.DistanceKm=CaelumJourneyRules.DistanceKm(Connection);journey.WalkingKmh=Pace;
            let plan=Plans[i];journey.WalkTics=plan!=null?plan.Available.WalkTics:0;
            journey.SleepTics=plan!=null?plan.Available.SleepTics:0;
            journey.FoodConsumed=plan!=null?plan.Available.FoodSpent:0;
            journey.WaterConsumed=plan!=null?plan.Available.WaterSpent:0;
            journey.ContainerLitersConsumed=plan!=null?plan.Available.ContainerSpent:0;
        }
        if(Elapsed>0)
        {
            let source=CaelumWorldClockTicker.CampaignOwner();
            CaelumWorldClock.Get(source).AdvanceTics(Elapsed);CaelumWorldClockTicker.Mirror(source);
        }
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {
            let member=Members[i];if(Plans[i]!=null)Plans[i].Apply(member,false);
            if(Kind==JOURNEY && !Interrupted)
            {let record=member.GetPersistentCharacterState(false);record.WorldConnectionKnown[Connection]=true;record.WorldPendingConnection=Connection;}
            member.PersistCharacterState();
        }
        Finish(Interrupted?"CA_COOP_TRAVEL_INTERRUPTED":"");
        if(Interrupted)
        {
            for(int i=0;i<MAXPLAYERS;i++)if((AliveMask&(1<<i))!=0 && Members[i].health<=0)
                Members[i].Die(Members[i],Members[i],0,'CaelumSurvival');
            return;
        }
        CaelumDeadTraveler.ChangeMap(Destination,Entry,CHANGELEVEL_NOINTERMISSION);
    }
    override void Tick(){Super.Tick();if(Opened && (!RosterValid() || !SourceValid()))Finish("CA_COOP_TRAVEL_CANCELLED");}
    override void PreTravelled(){if(Opened)Finish("CA_COOP_TRAVEL_CANCELLED");Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
