// Private measured comparison; no production movement or balance overrides.
class CA430SpeedChecks : EventHandler
{
    Array<CaelumCombatActor> Bodies;
    Array<double> PreviousX,PreviousY;
    Array<double> Distance,MaximumRatio;
    int Started,Failures;
    bool Active;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA430 PASS %s",label);else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca430_speed_seed')
        {
            let user=CaelumPlayer(players[0].mo);user.bInvulnerable=true;
            user.SetOrigin((3000,0,0),false);user.Angle=0;
            for(int i=0;i<4;i++)
            {
                user.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_FOLLOWING);
                Name kind=i==0?'CaelumPrisonerUnitario':i==1?'CaelumPrisonerFederal':i==2?'CaelumPrisonerTarot':'CaelumPrisonerBestia';
                Bodies.Push(CaelumCombatActor(Actor.Spawn(kind,(-1500,-300+i*200,0),NO_REPLACE)));
            }
        }
        if(e.Name=='ca430_speed_start')
        {
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo),true);
            for(int i=0;i<Bodies.Size();i++)
            {
                let b=Bodies[i];Check(party.Recruit(b),String.Format("recruit %s",b.GetTag()));
                // Reset after recruiting: the pre-recruitment escort can recover
                // distant prisoners beside the player before the first command.
                b.SetOrigin((-1500,-300+i*200,0),false);b.Vel=(0,0,0);
                PreviousX.Push(b.Pos.X);PreviousY.Push(b.Pos.Y);Distance.Push(0);MaximumRatio.Push(0);
            }
            party.Formation.SetShape(CaelumFormationData.COLUMN,true);Started=level.time;Active=true;
        }
        if(e.Name=='ca430_speed_reload')
        {
            for(int i=0;i<Bodies.Size();i++)
                Check(Bodies[i].Companion.Motion!=null && Bodies[i].Companion.Motion.Running,
                    String.Format("saved running controller %s",Bodies[i].GetTag()));
            Console.Printf("CA430 RESULT speed reload failures=%d",Failures);
        }
    }
    override void WorldTick()
    {
        if(!Active)return;
        int elapsed=level.time-Started;
        for(int i=0;i<Bodies.Size();i++)
        {
            let b=Bodies[i];let m=b.Companion.Motion;
            double step=(b.Pos.XY-(PreviousX[i],PreviousY[i])).Length();PreviousX[i]=b.Pos.X;PreviousY[i]=b.Pos.Y;
            if(elapsed==0 || elapsed==490)Console.Printf("CA430 DIAG %d %s pos=(%.1f,%.1f,%.1f) distance=%.1f running=%d target=%s pose=%d controlled=%d air=%.1f",
                elapsed,b.GetTag(),b.Pos.X,b.Pos.Y,b.Pos.Z,b.Distance3D(players[0].mo),m!=null && m.Running,
                b.target!=null?b.target.GetTag():"none",CaelumCompanionMotion.Pose(b),CaelumCompanions.Controlled(b),b.CurrentCombatAir);
            if(elapsed>350 && m!=null)
            {
                double expected=m.Walker.WalkingSpeed(b)*CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED/CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED;
                Distance[i]+=step;if(expected>0)MaximumRatio[i]=Max(MaximumRatio[i],step/expected);
            }
            if(elapsed==490)
            {
                Check(Distance[i]>0 && MaximumRatio[i]<=1.001,String.Format("no duplicate displacement %s",b.GetTag()));
                Check(m!=null && m.Running,String.Format("running beyond six meters %s",b.GetTag()));
                Console.Printf("CA430 SPEED %s agility=%d armorBonus=%d mass=%.3f carried=%.3f walk=%.4f run_mps=%.4f max_ratio=%.6f air=%.3f/%.3f",
                    b.GetTag(),b.CombatAgility,b.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY),
                    double(b.Mass),b.GetAttackCarriedWeight(),m.Walker.WalkingSpeed(b),Distance[i]/4/CaelumPhysicsUnits.MapUnits(1),
                    MaximumRatio[i],b.CurrentCombatAir,b.MaximumCombatAir);
            }
        }
        if(elapsed==490){Active=false;Console.Printf("CA430 RESULT speed comparison failures=%d",Failures);}
    }
}
