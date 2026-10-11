class CA194PressureTarget : CA194Target
{
    int DuplicateLoss;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        int before=health;
        int result=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
        Console.Printf("CA194 TRACE pulse tick=%d input=%d mod=%s loss=%d hp=%d z=%.3f h=%.3f",level.time,damage,mod,before-health,health,Pos.Z,Height);
        if (mod=='Crush')
        {
            int after=health;
            Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
            DuplicateLoss+=after-health;
        }
        return result;
    }
}
class CA194Pressure : CA194Combat
{
    CaelumCrusherTrap Crusher;
    CaelumCombatActor Victim, Lower, Upper;
    int NativePulses, LastPulse, LastHealth;
    override void WorldTick()
    {
        Age++;
        if(Age==3)
        {
            Check("weight below tolerance",CaelumWeightPressure.DamageRate(50,0,80),0);
            Check("weight creep SI",CaelumWeightPressure.DamageRate(180,0,80),0.0981);
            Check("weight carried load included",CaelumWeightPressure.DamageRate(180,20,80),0.11772);
            Check("weight no max HP input",CaelumWeightPressure.DamageRate(1000000,0,80),980.92152);
            let legacy=Fresh();legacy.SetOrigin((1500,1664,0),false);
            let old=CaelumWeightPressure(legacy.GiveInventoryType("CaelumWeightPressure"));
            old.EnergyRevision=0;old.DamageCarry=5000;
            CaelumWeightPressure.Update(legacy);
            Check("legacy carry cannot apply when released",legacy.health,1000000);
            Check("legacy carry clears once",old.DamageCarry,0);legacy.Destroy();
            Crusher=CaelumCrusherTrap(ActorIterator.Create(43613,"CaelumCrusherTrap").Next());
            Check("MAP08 crusher exists",Crusher!=null,1);
            if(Crusher==null)return;
            Check("native ceiling starts",Crusher.Release(),1);
            Check("whole solid stone mass",Crusher.CrushingMassKg,507600);
            Check("four native panels",Crusher.Panels.Size(),4);
            Victim=CaelumCombatActor(Actor.Spawn("CA194PressureTarget",(2224,1200,0)));
            Victim.Mass=80;Victim.CombatToughness=0;Victim.CombatArmor=new("CaelumArmorModel");Victim.CombatArmor.InitializeDefaults();
            Victim.health=Victim.CombatMaximumHealth=2000000000;LastHealth=Victim.health;LastPulse=-1;
            Lower=Fresh();Lower.SetOrigin((1152,1664,0),false);Lower.CombatStrength=0;
            Upper=Fresh(1000000);Upper.SetOrigin(Lower.Pos+(0,0,Lower.Height),false);
            Upper.bNoGravity=false;Upper.bOnMobj=true;Upper.Vel=(0,0,0);
        }
        if(Victim!=null)
        {
            let pressure=CaelumCeilingPressure(Victim.FindInventory("CaelumCeilingPressure"));
            if(pressure!=null && pressure.LastPulseTick!=LastPulse)
            {
                NativePulses++;LastPulse=pressure.LastPulseTick;
                Check("native pulse mass",pressure.LastMassKg,507600);
                Check("native pulse work",pressure.LastWorkJoules,507600*9.81*pressure.LastCompressionMeters,0.00001);
                Check("native pulse final once",LastHealth-Victim.health,int(Max(0,pressure.LastWorkJoules-80)+0.5));
                LastHealth=Victim.health;
                Check("same tic native/proxy callback no repeat",CA194PressureTarget(Victim).DuplicateLoss,0);
            }
        }
        if(Age==45 && Lower!=null)
        {
            let pressure=CaelumWeightPressure(Lower.FindInventory("CaelumWeightPressure"));
            Check("native static support registered",pressure!=null,1);
            if(pressure!=null)
            {
                Check("native static work per second",pressure.LastDamagePerSecond,980.92152);
                Check("native static work accumulated once",pressure.LastWorkJoules,980.92152,0.00001);
                Check("static one R final",1000000-Lower.health,901);
            }
            Upper.Destroy();Upper=null;
        }
        if(Age==110)
        {
            Check("live ceiling multiple pulses",NativePulses>=2,1);
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
