// Isolated catch-up diagnostic: the authorized 1,000 attackers / 600 defenders.
// Native profiles and inventory initialize; regular AI is frozen to isolate
// the absent-round kernel. This is not live rendering acceptance.
class CA415Performance : EventHandler
{
    CA415RoundEncounter Encounter;
    ui Array<double> Frames;
    ui double Previous;
    ui bool Reported;
    bool Staged,Running,WorkPending;
    double Deadline,Started,Duration;
    int Pulses,Serial;
    void Stage(double seconds)
    {
        Deadline=Encounter.AbsentBattle.Stamp+seconds;Duration=seconds;Started=MSTimeF();
        Running=true;WorkPending=false;Pulses=0;Serial++;Menu.SetMenu('CA415PerformanceMenu');
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca415perf_staged"){Staged=true;return;}
        if(e.Name!="ca415perf_step" || !Running || e.Args[0]!=Serial || e.Args[1]!=Pulses)return;
        let battle=Encounter.AbsentBattle;double pulse=MSTimeF();Pulses++;
        do
        {
            if(WorkPending)
            {
                if(battle.Work.Advance(CaelumAbsentArrival.ROW_SLICE))
                {battle.Stamp=battle.Work.End;WorkPending=false;}
            }
            else if(battle.Stamp<Deadline && !battle.Terminal())
            {
                if(battle.Work==null)battle.Work=new('CaelumAbsentWork');
                battle.Work.Begin(battle,battle.Stamp+1,1,true);WorkPending=true;
            }
            else {battle.Stamp=Deadline;battle.SimulationTime=Deadline;Running=false;break;}
        }while(MSTimeF()-pulse<CaelumAbsentArrival.PULSE_BUDGET_MS);
        Console.Printf("CA415P PULSE %.6f",MSTimeF()-pulse);
        if(!Running)
        {
            Console.Printf("CA415P TIMING staged_seconds=%.0f elapsed_ms=%.6f pulses=%d",Duration,MSTimeF()-Started,Pulses);
            Outcome(Duration==1?"first":Duration==60?"combat":"quiet");
        }
        EventHandler.SendInterfaceEvent(0,"ca415perf_ack");
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name!="ca415perf_ack")return;
        let menu=CA415PerformanceMenu(Menu.GetCurrentMenu());
        if(menu!=null && !Running)menu.Close();
    }
    void Outcome(String stage)
    {
        let battle=Encounter.AbsentBattle;
        double life=0,anima=0,air=0,dirt=0,heat=0;int shots=0;
        for(int i=0;i<battle.Rows.Size();i++)
        {
            let row=battle.Rows[i];let body=row.Body;if(body==null)continue;
            life+=body.health;anima+=body.CurrentCombatAnima;air+=body.CurrentCombatAir;
            dirt+=CaelumContaminationStorage.Value(body);
            if(body.ThermalState!=null)heat+=body.ThermalState.Exposure;
            shots+=row.Shots;
        }
        Console.Printf("CA415P OUTCOME %s life=%.9f anima=%.9f air=%.9f dirt=%.9f heat=%.9f shots=%d",stage,life,anima,air,dirt,heat,shots);
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(level.maptime>=100 && level.maptime<190)
        {
            double now=MSTimeF();if(Previous>0)Frames.Push(now-Previous);Previous=now;
        }
        else if(level.maptime>=190 && !Reported)
        {
            Reported=true;
            for(int i=0;i<Frames.Size();i++)Console.Printf("CA415P FRAME %.6f",Frames[i]);
        }
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        if(level.maptime==70)
        {
            Encounter=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(0,0,0),NO_REPLACE));
            Encounter.SiegeStarted=true;Encounter.SetupRevision=1;
            for(int i=0;i<1600;i++)
            {
                vector3 point=(-3200+(i%50)*128,-2048+(i/50)*128,0);
                if(i<1000)
                {
                    let body=CaelumCombatActor(Actor.Spawn('CA415RoundDemon',point,NO_REPLACE));
                    Encounter.RegisterAttacker(body);
                }
                else Encounter.Defenders.Push(CaelumPortDefender(Actor.Spawn('CA415RoundSoldier',point,NO_REPLACE)));
            }
        }
        if(level.maptime==105)
        {
            double begin=MSTimeF();
            Encounter.AbsentBattle=new('CaelumAbsentBattle');Encounter.AbsentBattle.Capture(Encounter,user);
            Console.Printf("CA415P TIMING capture_ms=%.6f rows=%d",MSTimeF()-begin,Encounter.AbsentBattle.Rows.Size());
        }
        if(level.maptime==106 || level.maptime==107)
        {
            let battle=Encounter.AbsentBattle;
            double seconds=level.maptime==106?1:60;
            if(Staged){Stage(seconds);return;}
            double begin=MSTimeF();battle.SyncTo(battle.Stamp+seconds);
            int alive=0;for(int i=0;i<battle.Rows.Size();i++)if(battle.Rows[i].Alive())alive++;
            Console.Printf("CA415P TIMING world_seconds=%.0f active_scale=%.6f elapsed_ms=%.6f alive=%d rounds=%d",seconds,battle.ActiveScale,MSTimeF()-begin,alive,battle.Rounds);
            Outcome(level.maptime==106?"first":"combat");
        }
        if(level.maptime==108)
        {
            let battle=Encounter.AbsentBattle;
            // Diagnostic terminal state: retain only the surviving defending
            // cohort in this calculation; do not destroy or reset any body.
            for(int i=0;i<battle.Rows.Size();i++)if(!battle.Rows[i].Friendly)battle.Rows[i].Participating=false;
            if(Staged){Stage(3600);return;}
            double begin=MSTimeF();battle.SyncTo(battle.Stamp+3600);
            Console.Printf("CA415P TIMING quiet_world_seconds=3600 elapsed_ms=%.6f",MSTimeF()-begin);
            Outcome("quiet");
        }
        if(level.maptime==190)Console.Printf("CA415P RESULT isolated catch-up timing complete");
    }
}

class CA415PerformanceMenu : ListMenu
{
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);mParentMenu=null;menuactive=Menu.On;}
    override void Ticker()
    {
        menuactive=Menu.On;
        let test=CA415Performance(EventHandler.Find('CA415Performance'));
        if(test!=null && test.Running)EventHandler.SendNetworkEvent("ca415perf_step",test.Serial,test.Pulses);
    }
    override void Drawer(){}
    override bool MenuEvent(int key,bool controller){return true;}
}
