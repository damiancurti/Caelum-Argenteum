// Controles privados: recursos reales, marcas de ruta intactas y aliento legitimo.
class CA357Victim : Actor
{
    Default { Health 1000; Radius 16; Height 56; +SHOOTABLE +SOLID +INVULNERABLE +NOGRAVITY }
    States { Spawn: PLAY A -1; Stop; }
}
class CA357Probe : EventHandler
{
    int Age,Passes,Failures;
    CaelumCombatActor Demon,Boss;
    Actor Victim,Goal;
    void Check(bool value,String label)
    {if(value)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);}}
    void Ready(CaelumCombatActor body)
    {
        CaelumDemonService.StopBreath(body,true,false);
        body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        body.SetStateLabel("RestLying");body.Angle=0;
        body.RecoveryPhase=0;body.ForcedSleepTics=0;body.CombatLucidityPhysicalStunRemaining=0;
        body.CurrentCombatAnima=body.MaximumCombatAnima;
        if(body.ThermalState!=null){body.ThermalState.Exposure=0;body.ThermalState.Severity=0;}
        Victim.SetOrigin(CaelumDemonBreath.Mouth(body)+(CaelumDemonBreathRules.Range()/2,0,-Victim.Height/2),false);
        Goal.SetOrigin(body.Pos+(80,0,0),false);
    }
    void Cases(CaelumCombatActor body)
    {
        Ready(body);body.target=Goal;
        bool corrected=!CaelumDemonBreath.CanReach(body,Goal);
        Console.Printf("CA357 CONTROL class=%s excludes_navigation=%d",body.GetClassName(),corrected);
        Check(corrected,"navigation marker is not a breath combat/aim target");
        double before=body.CurrentCombatAnima;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"navigation marker does not start fire");
        Check(body.CurrentCombatAnima==before,"navigation does not spend breath anima");
        Check(Goal.bShootable && Goal.bInvulnerable && Goal.bNoTarget,"navigation flags remain intact");
        Check(body.target==Goal,"navigation target reference remains intact");

        Ready(body);body.target=Victim;
        vector3 mouth=CaelumDemonBreath.Mouth(body);
        Console.Printf("CA357 GEOMETRY class=%s sight=%d distance=%.6f radius=%.6f range=%.6f mouth=(%.3f,%.3f,%.3f) victim=(%.3f,%.3f,%.3f) height=%.3f",body.GetClassName(),body.CheckSight(Victim),
            (Victim.Pos+(0,0,Victim.Height/2)-mouth).Length(),Victim.Radius,CaelumDemonBreathRules.Range(),mouth.X,mouth.Y,mouth.Z,Victim.Pos.X,Victim.Pos.Y,Victim.Pos.Z,Victim.Height);
        Check(CaelumDemonBreath.CanReach(body,Victim),"real nearby target remains reachable");
        before=body.CurrentCombatAnima;double cost=body.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath!=null,"real target starts fire");
        Check(Abs(body.CurrentCombatAnima-(before-cost))<0.0000001,"real fire pays unchanged cost");
        let prior=body.DemonBreath;body.target=Goal;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"already-active fire stops after target becomes navigation");
        Check(prior==null || prior.bDestroyed,"old breath actor retires");
        Check(!body.InStateSequence(body.CurState,body.FindState("RacialBreath")),"stopped fire releases looping breath state");

        Ready(body);body.target=Victim;body.CurrentCombatAnima=0;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"empty anima still prevents fire");
        Ready(body);Victim.SetOrigin(body.Pos+(4096,0,0),false);body.target=Victim;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"out-of-range enemy still prevents fire");

        Ready(body);body.target=Goal;
        if(body.ThermalState==null)body.ThermalState=new("CaelumThermalState");
        body.ThermalState.Exposure=-1;body.ThermalState.Severity=1;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath!=null,"cold breath remains available with a navigation target");
        if(body.DemonBreath!=null)
            Check(Abs(body.DemonBreath.Direction.Z)<0.0000001,"noncombat breath does not aim down at the invisible marker");
        Ready(body);body.target=Goal;
        let binding=CaelumBolasFlight(Actor.Spawn("CaelumBolasFlight",body.Pos,NO_REPLACE));
        binding.AttachVictim(body);
        Check(CaelumBolas.Restrained(body),"real bolas attach before the fire control");
        before=body.CurrentCombatAnima;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath!=null,"restraint breath remains available with navigation target");
        Check(!CaelumBolas.Restrained(body),"paid fire contact frees the real bolas");
        Check(Abs(body.CurrentCombatAnima-(before-cost))<0.0000001,"restraint fire pays exactly one unchanged breath cost");
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"fire stops after restraint release with only navigation remaining");
        Ready(body);body.target=null;
    }
    override void WorldTick()
    {
        Age++;
        if(Age==3)
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
            Demon=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(1024,0,0),NO_REPLACE));
            Boss=CaelumCombatActor(Actor.Spawn("CaelumZupayColossus",(4096,0,0),NO_REPLACE));
            Victim=Actor.Spawn("CA357Victim",(2048,0,0),NO_REPLACE);
            Victim.bInvulnerable=true;Victim.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            Goal=Actor.Spawn("CaelumSewerEscapeTarget",(2048,0,0),NO_REPLACE);
        }
        if(Age==35)
        {
            Check(Demon!=null && Boss!=null && Victim!=null && Goal!=null,"native fixture actors exist");
            Cases(Demon);Cases(Boss);
            Console.Printf("CA357 CHECKS passes=%d failures=%d",Passes,Failures);
            if(Failures==0)Console.Printf("CA282 DONE passes=%d failures=0",Passes);
        }
    }
}
