// Compare the actual mansion Caella with the released Leonor in the same hall.
class CA430PairChecks : EventHandler
{
    Array<CaelumCombatActor> Bodies;
    Array<double> X,Y,Distance,Ratio;
    int Started,Failures;
    bool Active;
    void Check(bool ok,String label)
    {if(ok)Console.Printf("CA430 PASS %s",label);else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca430_pair_seed')
        {
            let user=CaelumPlayer(players[0].mo);user.bInvulnerable=true;user.SetOrigin((1100,0,0),false);user.Angle=0;
            let world=CaelumMainM00QuestController(EventHandler.Find('CaelumMainM00QuestController'));
            world.EnsureResidentRegistry();
            for(int i=0;i<world.StoryResidents.Size();i++)
                if(world.StoryResidents[i] is 'CaelumCaella')Bodies.Push(world.StoryResidents[i]);
            Check(Bodies.Size()==1 && Bodies[0].GetClass()=="CaelumCaella","actual mansion Caella selected by class");
            user.SetPlayerPrisonerRescueState(CaelumConstants.PRISONER_UNITARIO,CaelumConstants.PRISONER_STATE_FOLLOWING);
            Bodies.Push(CaelumCombatActor(Actor.Spawn('CaelumPrisonerUnitario',(200,-100,0),NO_REPLACE)));
        }
        if(e.Name=='ca430_pair_start')
        {
            let party=CaelumCompanionParty.Get(CaelumPlayer(players[0].mo),true);
            for(int i=0;i<Bodies.Size();i++)
            {
                let b=Bodies[i];Check(party.Recruit(b),String.Format("recruit actual %s",b.GetTag()));
                b.SetOrigin((200,i==0?32:-32,0),false);b.Vel=(0,0,0);
                X.Push(b.Pos.X);Y.Push(b.Pos.Y);Distance.Push(0);Ratio.Push(0);
                Console.Printf("CA430 LOAD %s mass=%.3f carried=%.3f acceleration_seconds=%.3f",
                    b.GetTag(),double(b.Mass),b.GetAttackCarriedWeight(),
                    CaelumConstants.MOVEMENT_ACCELERATION_SECONDS*(b.Mass+b.GetAttackCarriedWeight())/CaelumConstants.MOVEMENT_ACCELERATION_REFERENCE_KG);
                for(Inventory item=b.Inv;item!=null;item=item.Inv)
                    if(item is 'CaelumEquipmentItem')Console.Printf("CA430 ITEM %s %s %.3fkg",
                        b.GetTag(),CaelumNotifications.Describe(CaelumPlayer(players[0].mo),item,item.Amount,true),CaelumContainerRules.Weight(CaelumPlayer(players[0].mo),item));
            }
            party.Formation.SetShape(CaelumFormationData.COLUMN,true);Started=level.time;Active=true;
        }
    }
    override void WorldTick()
    {
        if(!Active)return;
        int elapsed=level.time-Started;
        for(int i=0;i<Bodies.Size();i++)
        {
            let b=Bodies[i];let m=b.Companion.Motion;
            double step=(b.Pos.XY-(X[i],Y[i])).Length();X[i]=b.Pos.X;Y[i]=b.Pos.Y;
            if(elapsed>105 && m!=null)
            {
                Distance[i]+=step;
                double expected=m.Walker.WalkingSpeed(b)*CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED/CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED;
                if(expected>0)Ratio[i]=Max(Ratio[i],step/expected);
            }
            if(elapsed==140)
            {
                Check(m!=null && m.Running,String.Format("runs in mansion %s",b.GetTag()));
                Check(Distance[i]>0 && Ratio[i]<=1.001,String.Format("no duplicate motion %s",b.GetTag()));
                Console.Printf("CA430 PAIR %s walk=%.5f run_mps=%.5f ratio=%.6f distance=%.1f target=%s",
                    b.GetTag(),m.Walker.WalkingSpeed(b),Distance[i]/CaelumPhysicsUnits.MapUnits(1),Ratio[i],b.Distance3D(players[0].mo),b.target!=null?b.target.GetTag():"none");
            }
        }
        if(elapsed==140){Active=false;Console.Printf("CA430 RESULT Caella Leonor comparison failures=%d",Failures);}
    }
}
