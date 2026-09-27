// Ensayo explícito, fuera de la campaña. Los figurantes comparten el modelo
// Mandinga existente; bFriendly distingue los operadores del bando defensor.
class CaelumCannonTrialEncounter : CaelumSiegeEncounter
{
    Array<CaelumCannon> TrialGuns;
    override void Tick()
    {
        Super.Tick();
        for(int i=0;i<TrialGuns.Size();i++)
        {
            let gun=TrialGuns[i];
            if(gun!=null && gun.IntendedTarget!=null && gun.IntendedTarget.health>0)
                gun.RequestShot(gun.AimPoint,gun.IntendedTarget);
        }
    }
}
class CaelumDebugCannonTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        if(level.MapName!="MAP03")return false;
        let it=ThinkerIterator.Create("CaelumCannonTrialEncounter");
        if(it.Next()!=null)return true;
        let encounter=CaelumCannonTrialEncounter(Actor.Spawn("CaelumCannonTrialEncounter",Owner.Pos));
        for(int i=0;i<CaelumCannonData.TRIAL_LANES;i++)
        {
            double x=CaelumCannonData.TRIAL_FIRST_X+i*CaelumCannonData.TRIAL_SPACING_X;
            let gun=CaelumCannon(Actor.Spawn("CaelumCannon",(x,CaelumCannonData.TRIAL_GUN_Y,0)));
            gun.InitializeCannon(i>=3);gun.Angle=90;gun.PlaceComponents();
            if(!gun.Defending)encounter.RegisterMachine(gun);
            for(int j=0;j<CaelumCannonData.CREW;j++)
            {
                let body=CaelumCombatActor(Actor.Spawn("CaelumRamTrialOperator",gun.Pos+((j==0 ? -1 : 1)*CaelumCannonData.TRIAL_OPERATOR_SIDE,0,0)));
                body.bFriendly=gun.Defending;
                if(!gun.Defending)encounter.RegisterAttacker(body);
                gun.AssignOperator(body);
            }
            Actor targetActor;
            if(!gun.Defending)
            {
                let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",(x,CaelumCannonData.TRIAL_TARGET_Y,0)));
                gate.args[1]=i;gate.InitializeGate();targetActor=gate;
            }
            else
            {
                let enemy=CaelumCombatActor(Actor.Spawn("CaelumRamTrialOperator",(x,CaelumCannonData.TRIAL_TARGET_Y,0)));
                encounter.RegisterAttacker(enemy);targetActor=enemy;
            }
            gun.IntendedTarget=targetActor;
            gun.AimPoint=targetActor.Pos+(0,0,CaelumCannonData.PIVOT_Z);
            encounter.TrialGuns.Push(gun);
        }
        encounter.SealRoster();
        for(int i=0;i<encounter.TrialGuns.Size();i++)encounter.TrialGuns[i].ActivateCannon(CaelumCannonData.TRIAL_ROUNDS);
        return true;
    }
}
class CaelumDebugCannonStatus : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let it=ThinkerIterator.Create("CaelumCannon");CaelumCannon gun;
        while((gun=CaelumCannon(it.Next()))!=null)
            Console.Printf("Cannon x=%.0f side=%s phase=%d crew=%d work=%d ammo=%d shots=%d contacts=%d damage=%d neutralized=%d flight=%d",
                gun.Pos.X,gun.Defending ? "defender":"attacker",gun.Phase,gun.OperatorsPresent(),gun.Work,gun.Ammunition,gun.Shots,gun.Contacts,gun.LastDamage,gun.Neutralized,gun.ActiveShot!=null);
        return true;
    }
}
