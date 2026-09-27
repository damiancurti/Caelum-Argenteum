// Carril optativo de #20; jamás se crea en MAP06 ni suma a sus 1.000 enemigos.
class CaelumRamTrialEncounter : CaelumSiegeEncounter { }
class CaelumRamTrialOperator : CaelumMandinga
{
    States
    {
    Spawn:
        MIID A -1;
        Stop;
    Pain:
        MIID A 4;
        Goto Spawn;
    }
}
class CaelumDebugRamTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        if (level.MapName!="MAP03") return false;
        let it=ThinkerIterator.Create("CaelumRamTrialEncounter");
        if (it.Next()!=null) return true;
        let encounter=CaelumRamTrialEncounter(Actor.Spawn("CaelumRamTrialEncounter",Owner.Pos,NO_REPLACE));
        for (int i=0;i<CaelumRamData.TRIAL_LANES;i++)
        {
            double x=CaelumRamData.TRIAL_FIRST_X+i*CaelumRamData.TRIAL_SPACING_X;
            let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",
                (x,CaelumRamData.TRIAL_GATE_Y,0),NO_REPLACE));
            gate.args[1]=i%3; gate.InitializeGate();
            let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",
                (x,CaelumRamData.TRIAL_START_Y,0),NO_REPLACE));
            ram.Large=i==CaelumRamData.TRIAL_LANES-1;
            ram.Angle=90; ram.InitializeRam(); encounter.RegisterMachine(ram);
            for (int j=0;j<ram.RequiredCrew;j++)
            {
                double side=(j%2==0 ? -1 : 1)*CaelumRamData.TRIAL_CREW_SIDE*ram.SizeFactor;
                double along=((j/2)-(ram.RequiredCrew/2-1)/2.0)*CaelumRamData.TRIAL_CREW_STEP;
                let body=CaelumCombatActor(Actor.Spawn("CaelumRamTrialOperator",ram.Pos+(side,along,0),NO_REPLACE));
                ram.AssignCrew(encounter.RegisterAttacker(body));
            }
            ram.SetRoute(gate,90);
            ram.AddRoutePoint((x,CaelumRamData.TRIAL_GATE_Y-CaelumRamData.TRIAL_CONTACT_DISTANCE*ram.SizeFactor,0));
        }
        encounter.SealRoster();
        for (int i=0;i<encounter.Machines.Size();i++)
            CaelumBatteringRam(encounter.Machines[i]).ActivateRam();
        return true;
    }
}
class CaelumDebugRamStatus : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let it=ThinkerIterator.Create("CaelumBatteringRam");
        CaelumBatteringRam ram;
        while ((ram=CaelumBatteringRam(it.Next()))!=null)
            Console.Printf("Ram x=%.0f y=%.3f blocked=%d large=%d phase=%d crew=%d/%d present=%d neutralized=%d hits=%d damage=%d gate=%d",
                ram.Pos.X,ram.Pos.Y,ram.Obstructed,ram.Large,ram.Phase,ram.Crew.Size(),ram.RequiredCrew,ram.FullCrewPresent(),
                ram.Neutralized,ram.ImpactCount,ram.LastDamage,ram.TargetGate==null ? -1 : ram.TargetGate.health);
        return true;
    }
}
