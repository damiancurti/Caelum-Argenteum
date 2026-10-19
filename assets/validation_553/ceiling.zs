// Reanuda después de STAT_INVENTORY y antes del pensador de sector.
class CA312LateResume : Actor
{
    int ResumeTick;
    bool Resumed;
    override void Tick()
    {
        if(!Resumed && level.time==ResumeTick)
        {A_CallSpecial(42,44556,64,1,2);Resumed=true;}
    }
    States { Spawn: TNT1 A -1; Stop; }
}
// Techo nativo etiquetado; sólo la fixture pausa y reanuda su mecanismo.
class CA312Ceiling : CA194Combat
{
    CA194PressureTarget Body;
    int LastPulse,StopAt,ResumeAt,Pulses;
    int SampleTick[16];
    double SampleStep[16];
    bool Paused,Resumed;
    bool Crossed,CrossValidated;
    int ReturnAt;
    CA312LateResume LateResume;
    bool LateValidated;
    override void WorldTick()
    {
        Age++;
        if(Age>60)return;
        if(Age==3)
        {
            Body=CA194PressureTarget(Actor.Spawn("CA194PressureTarget",(320,0,0)));
            Body.Mass=80;Body.CombatToughness=0;Body.CombatMaximumHealth=Body.health=1000000000;
            Body.CombatArmor=new("CaelumArmorModel");Body.CombatArmor.InitializeDefaults();
            Check("native tagged crusher starts",Body.A_CallSpecial(42,44556,64,1,2),1);
            LastPulse=-1;
        }
        if(Body==null)return;
        let p=CaelumCeilingPressure(Body.FindInventory("CaelumCeilingPressure"));
        let ceiling=Ceiling(Body.ceilingsector.ceilingdata);
        if(p!=null && p.LastPulseTick!=LastPulse)
        {
            double expected=0;
            if(LastPulse<0)expected=8.0/32.0;
            else for(int t=LastPulse+1;t<=p.LastPulseTick;t++)
                if(SampleTick[t%16]==t)expected+=SampleStep[t%16];
            if(Crossed && !CrossValidated){expected=8.0/32.0;CrossValidated=true;}
            if(LateResume!=null && !LateValidated)
            {expected=8.0/32.0;LateValidated=true;Check("late actor actually resumed",LateResume.Resumed,1);}
            Console.Printf("CA312 CEILING observed=%d pulse=%d prior=%d step=%.9f measured=%.9f paused=%d resumed=%d",level.time,p.LastPulseTick,LastPulse,expected,p.LastCompressionMeters,Paused,Resumed);
            Check("ceiling raw force uses native sector stroke",p.LastMassKg,162000);
            Check("native attempted descent excludes paused tics",p.LastCompressionMeters,expected);
            Check("native damage work uses attempted descent",p.LastWorkJoules,162000*9.81*expected,0.00001);
            Check("same-tic native replay still inert",Body.DuplicateLoss,0);
            LastPulse=p.LastPulseTick;Pulses++;
            if(!Paused)
            {
                Check("native stop retains thinker",Body.A_CallSpecial(44,44556,1),1);
                Check("native ceiling paused",ceiling.GetDirection(),Ceiling.dirWait);
                Paused=true;StopAt=level.time;ResumeAt=level.time+2;
            }
            if(Pulses==3 && !Crossed)
            {
                Body.SetOrigin((-256,0,0),false);Body.FindFloorCeiling();
                Body.A_CallSpecial(42,44557,8,1,2);
                Crossed=true;ReturnAt=level.time+1;
            }
            if(CrossValidated && LateResume==null)
            {
                Body.A_CallSpecial(44,44556,1);
                LateResume=CA312LateResume(Actor.Spawn("CA312LateResume",(-900,0,0)));
                LateResume.ResumeTick=p.LastPulseTick+4;
            }
        }
        if(Crossed && level.time==ReturnAt)
        {Body.SetOrigin((320,0,0),false);Body.FindFloorCeiling();}
        ceiling=Ceiling(Body.ceilingsector.ceilingdata);
        if(Paused && !Resumed && level.time==ResumeAt)
        {
            Body.A_CallSpecial(42,44556,64,1,2);
            Check("native same ceiling resumes",Ceiling(Body.ceilingsector.ceilingdata)==ceiling && ceiling.GetDirection()==Ceiling.dirDown,1);
            Resumed=true;
        }
        SampleTick[level.time%16]=level.time;
        SampleStep[level.time%16]=ceiling!=null && ceiling.GetDirection()==Ceiling.dirDown?ceiling.m_Speed/32.0:0;
        if(Age==60)
        {
            Check("native paused run includes resumed pulses",Pulses>=3 && Resumed,1);
            Check("return from another ceiling starts fresh contact",CrossValidated,1);
            Check("actor-tick resume reconciles current sample",LateValidated,1);
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}

class CA312Ceilingsave : CA194Combat
{
    bool Loaded;
    CA194PressureTarget Body;
    int LastPulse,Pulses,Mode;
    override void WorldLoaded(WorldEvent e)
    {
        Loaded=e.IsSaveGame;Age=0;LastPulse=-1;Mode=0;
        if(!Loaded)return;
        Body=CA194PressureTarget(ActorIterator.Create(45800).Next());
        Check("saved native crusher body",Body!=null,1);
        if(Body==null)return;
        let p=CaelumCeilingPressure(Body.FindInventory("CaelumCeilingPressure"));
        Check("saved ongoing native pressure",p!=null && p.Initialized && p.PressureSource!=null,1);
        if(p!=null)
        {
            LastPulse=p.LastPulseTick;
            Console.Printf("CA312 CEILING RESTORED pulse=%d work=%.9f",p.LastPulseTick,p.LastWorkJoules);
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="c312_rollback")Mode=1;}
    override void WorldTick()
    {
        Age++;
        if(!Loaded && Age==3)
        {
            Body=CA194PressureTarget(Actor.Spawn("CA194PressureTarget",(320,0,0)));
            Body.ChangeTid(45800);Body.Mass=80;Body.CombatToughness=0;
            Body.CombatMaximumHealth=Body.health=1000000000;
            Body.CombatArmor=new("CaelumArmorModel");Body.CombatArmor.InitializeDefaults();
            Body.A_CallSpecial(42,44556,64,1,2);
        }
        if(Body!=null)
        {
            let p=CaelumCeilingPressure(Body.FindInventory("CaelumCeilingPressure"));
            if(p!=null && p.LastPulseTick!=LastPulse)
            {
                double expected=LastPulse>=0?1:0.25;
                Check("ongoing native ceiling preserves interval",p.LastCompressionMeters,expected);
                Check("ongoing native ceiling preserves force",p.LastMassKg,162000);
                Check("ongoing native ceiling preserves work",p.LastWorkJoules,162000*9.81*expected,0.00001);
                LastPulse=p.LastPulseTick;Pulses++;
            }
        }
        if((!Loaded && Age==14) || (Loaded && Age==12))
        {
            Check("ceiling checkpoint has actual pulse",Pulses>0,1);
            Console.Printf("CA194 DONE failures=%d passes=%d ceiling-save loaded=%d mode=%d",Failures,Passes,Loaded,Mode);
        }
    }
}
