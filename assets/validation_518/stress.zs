// Short identical scene, not a campaign/siege fluency claim.
class CA137Stress : StaticEventHandler
{
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        int population=CVar.GetCVar("ca137_mode").GetInt();
        bool battle=CVar.GetCVar("ca137_view").GetInt()==1;
        if(level.time==70)
        {
            u.SetOrigin((2048,4096,0),false);u.Angle=0;u.Pitch=0;u.CurSector.SetLightLevel(128);
            for(int i=0;i<population;i++)
            {
                let npc=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(2500+(i%20)*40,3300+(i/20)*40,0)));
                if(!battle){npc.bDORMANT=true;npc.bNOTARGET=true;npc.target=null;npc.tics=-1;}
            }
        }
        if(battle && level.time==105)
        {
            u.bINVULNERABLE=true;
            let actors=ThinkerIterator.Create("CaelumMandinga");CaelumCombatActor npc;
            while((npc=CaelumCombatActor(actors.Next()))!=null){npc.target=u;npc.SetStateLabel("Missile");}
        }
        if(!battle && level.time>=105 && level.time<525)
        {
            if(level.time%3==0)
            {
                int count=population>=499 ? 24 : population>0 ? 8 : 1;
                for(int i=0;i<count;i++)
                {
                    int kind=(level.time/3+i)%9;
                    let p=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",(2220,3900+i*16,50+(i%3)*12)));
                    p.target=u;p.StoreCaelumElementalPayload(kind==8 ? 4 : kind/2,kind!=8 && kind%2==1,100,100);
                    p.Vel=(0,20,0);p.ConfigureCaelumTravelDistance(500);
                }
            }
        }
        if(level.time==140)
        {
            let state=CaelumPopulationState.Get();
            Console.Printf("CA137 COST_BEGIN population=%d living=%d dense=%d",population,state!=null ? state.LivingCombatants : -1,state!=null && state.HighDensity);
        }
        if(level.time==490)Console.Printf("CA137 COST_END tic=%d",level.time);
        if(battle && level.time==525)
        {
            let actors=ThinkerIterator.Create("CaelumMandinga");Actor npc;
            while((npc=Actor(actors.Next()))!=null)npc.Destroy();
        }
        if(level.time==(battle ? 890 : 565))
        {
            int shots=0;let it=ThinkerIterator.Create("CaelumActorProjectile");while(it.Next()!=null)shots++;
            Console.Printf("CA137 %s bounded projectile cleanup count=%d",shots==0 ? "PASS" : "FAIL",shots);
            Console.Printf("CA137 STRESS COMPLETE failures=%d",int(shots!=0));
        }
    }
}
