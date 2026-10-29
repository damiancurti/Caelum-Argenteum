// #415: estado guardable de la carga. El menu pausa el reloj nativo mientras
// mensajes de red acotados resuelven las mismas fases que el resumen sincrono.
class CaelumAbsentArrival : Actor
{
    const ROW_SLICE=16;
    const PULSE_BUDGET_MS=8;
    CaelumPlayer Observer;
    Array<CaelumAbsentBattle> Battles;
    Array<CaelumCombatActor> Bodies;
    int BattleCursor,BodyCursor,Serial,Pulses;
    bool Running,Prepared,IntervalPending,WasFrozen;
    double TargetTime,CivilEnd,LimboEnd;

    static CaelumAbsentArrival Find()
    {
        let search=ThinkerIterator.Create('CaelumAbsentArrival');
        return CaelumAbsentArrival(search.Next());
    }
    static bool Begin(CaelumPlayer user)
    {
        if(user==null || multiplayer)return false;
        let job=Find();if(job==null)job=CaelumAbsentArrival(Spawn('CaelumAbsentArrival',(0,0,0),NO_REPLACE));
        if(job==null)return false;
        job.Observer=user;job.Battles.Clear();job.Bodies.Clear();
        job.CivilEnd=CaelumHouseAwayWork.Civil(user);
        job.LimboEnd=CaelumContaminationAbsence.Clock(user,"MAP01");
        job.BattleCursor=0;job.BodyCursor=0;job.Prepared=false;job.IntervalPending=false;
        job.Serial++;job.Pulses=0;
        // Los dos censos sustituyen los ya existentes en WorldLoaded. Nunca
        // se repiten por pulso, combatiente ni ronda.
        let encounters=ThinkerIterator.Create('CaelumSiegeEncounter');CaelumSiegeEncounter encounter;
        while((encounter=CaelumSiegeEncounter(encounters.Next()))!=null)
            if(encounter.AbsentBattle!=null && encounter.AbsentBattle.Away)
            {encounter.AbsentBattle.Reanchor(encounter,user);job.Battles.Push(encounter.AbsentBattle);}
        let actors=ThinkerIterator.Create('CaelumCombatActor');CaelumCombatActor body;
        while((body=CaelumCombatActor(actors.Next()))!=null)job.Bodies.Push(body);
        job.Running=true;job.WasFrozen=level.isFrozen();level.setFrozen(true);
        let events=CaelumAbsentArrivalEvents.Get();if(events!=null)events.Job=job;
        Menu.SetMenu('CaelumAbsentArrivalMenu');
        return true;
    }

    bool BattleStep()
    {
        let battle=Battles[BattleCursor];
        if(!Prepared)
        {
            TargetTime=EndFor(battle.SourceMap);
            if(!battle.Away || battle.SourceMap!=level.MapName || TargetTime<0
                || battle.SchemaRevision!=CaelumAbsentBattle.REVISION || !battle.RebindResidents())return true;
            Prepared=true;battle.Busy=true;
        }
        if(IntervalPending)
        {
            if(battle.Work.Advance(ROW_SLICE))
            {battle.Stamp=battle.Work.End;battle.Fraction=0;IntervalPending=false;}
            return false;
        }
        double limit=battle.ScheduleWaiting?Min(TargetTime,battle.ScheduledCivil):TargetTime;
        double first=battle.Stamp-battle.Fraction;
        double elapsed=Max(0,limit-first);
        if((battle.ScheduleWaiting && battle.Rows.Size()==0) || battle.Terminal())
        {battle.Stamp=limit;battle.Fraction=elapsed-Floor(elapsed+0.000000001);}
        else if(elapsed+0.000000001>=1)
        {StartInterval(battle,first+1,1);return false;}
        else {battle.Stamp=limit;battle.Fraction=elapsed;}
        battle.SimulationTime=limit;
        if(battle.ScheduleWaiting && TargetTime>=battle.ScheduledCivil)
        {battle.StartScheduled();return false;}
        if(battle.Fraction>0.000000001)
        {StartInterval(battle,TargetTime,battle.Fraction);return false;}
        battle.Fraction=0;battle.SimulationTime=TargetTime;battle.FinishRestore();return true;
    }
    void StartInterval(CaelumAbsentBattle battle,double end,double seconds)
    {
        if(battle.Work==null)battle.Work=new('CaelumAbsentWork');
        battle.Work.Begin(battle,end,seconds,true);IntervalPending=true;
    }
    double EndFor(String map)
    {return CaelumWorldCatalogue.IsLimboMap(map)?LimboEnd:CivilEnd;}
    bool BodyStep()
    {
        let body=Bodies[BodyCursor];if(body==null || body.bDestroyed)return true;
        let defender=CaelumPortDefender(body);
        bool parked=defender!=null && defender.Residence!=null && defender.Residence.Suspended;
        if(!parked)
        {
            let absent=body.ContaminationAbsence;
            if(absent!=null && absent.Away)
            {
                double end=EndFor(absent.Map);
                if(end>absent.Stamp && absent.Life>0
                    && absent.Revision==CaelumContaminationData.NPC_ABSENCE_REVISION)
                {
                    // Cortar en el mismo limite temporal que SyncTo; repartir
                    // el trabajo no cambia su integracion de clima/fisiologia.
                    double scale=CaelumWorldClock.SecondsPerGameHour(absent.Map)/3600.0;
                    double step=Min(1/scale,(Floor(absent.Civil/60)+1)*60-absent.Civil);
                    absent.SyncTo(body,Min(end,absent.Stamp+step));return false;
                }
                CaelumContaminationAbsence.Restore(body,Observer,end);
            }
        }
        if(body.ThermalState!=null)
        {
            body.ThermalState.RuntimeReady=false;body.ThermalState.SourceMap="";
            body.ThermalState.PendingActivityJoules=0;body.ThermalState.PropelledVelocity=(0,0);
        }
        return true;
    }
    void Advance()
    {
        if(!Running)return;
        Pulses++;double started=MSTimeF();
        do
        {
            if(BattleCursor<Battles.Size())
            {if(BattleStep()){BattleCursor++;Prepared=false;IntervalPending=false;}}
            else if(BodyCursor<Bodies.Size())
            {if(BodyStep())BodyCursor++;}
            else {Running=false;level.setFrozen(WasFrozen);return;}
        }while(MSTimeF()-started<PULSE_BUDGET_MS);
    }
    Default { +NOGRAVITY +NOBLOCKMAP +NOSECTOR +INVISIBLE Radius 0; Height 0; }
    States { Spawn: TNT1 A -1; Stop; }
}

// Estatico para que tambien exista al cargar partidas anteriores al cambio;
// los cursores y resultados viven en el actor serializado, nunca en la UI.
class CaelumAbsentArrivalEvents : StaticEventHandler
{
    CaelumAbsentArrival Job;
    static CaelumAbsentArrivalEvents Get()
    {return CaelumAbsentArrivalEvents(StaticEventHandler.Find('CaelumAbsentArrivalEvents'));}
    static bool Active()
    {let events=Get();return events!=null && events.Job!=null && events.Job.Running;}
    override void WorldLoaded(WorldEvent e)
    {
        Job=CaelumAbsentArrival.Find();
        if(Job!=null && Job.Running){level.setFrozen(true);Menu.SetMenu('CaelumAbsentArrivalMenu');}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_absent_arrival" || multiplayer || e.Player!=consoleplayer
            || Job==null || !Job.Running || e.Args[0]!=Job.Serial || e.Args[1]!=Job.Pulses)return;
        Job.Advance();EventHandler.SendInterfaceEvent(e.Player,"ca_absent_arrival_ack");
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_absent_arrival_ack")return;
        let menu=CaelumAbsentArrivalMenu(Menu.GetCurrentMenu());
        if(menu!=null && (Job==null || !Job.Running))menu.Close();
    }
    override void UiTick()
    {
        if(Job!=null && Job.Running && gamestate==GS_LEVEL && !multiplayer
            && !(Menu.GetCurrentMenu() is 'CaelumAbsentArrivalMenu'))Menu.SetMenu('CaelumAbsentArrivalMenu');
    }
}

class CaelumAbsentArrivalMenu : ListMenu
{
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);mParentMenu=null;menuactive=Menu.On;}
    override void Ticker()
    {
        menuactive=Menu.On;
        let events=CaelumAbsentArrivalEvents(StaticEventHandler.Find('CaelumAbsentArrivalEvents'));
        let job=events!=null?events.Job:null;
        if(job==null || !job.Running){Close();return;}
        // El par serial/pulso rechaza mensajes repetidos sin esperar otro
        // viaje de confirmacion UI->play->UI para enviar el siguiente bloque.
        EventHandler.SendNetworkEvent("ca_absent_arrival",job.Serial,job.Pulses);
    }
    override void Drawer()
    {
        String label=StringTable.Localize("CA_REGION_PREPARING",false);
        Screen.DrawText(SmallFont,Font.CR_WHITE,160-SmallFont.StringWidth(label)/2,96,label,
            DTA_VirtualWidth,320,DTA_VirtualHeight,200,DTA_KeepRatio,true);
    }
    override bool MenuEvent(int key,bool controller){return true;}
}
