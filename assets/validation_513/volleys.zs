// Full-roster firearm component load, not natural combat or route acceptance.
// Keep all 600 real housed bodies and their original statistics/resources.
// Stationary diagnostic targets do not pursue, attack or simulate physiology.
class CA133VolleyTarget : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 16; Height 57.6; Health 1000000; +SOLID +SHOOTABLE }
    States { Spawn:DOID A -1;Stop; }
}
class CA133Volleys : EventHandler
{
    Array<CA133VolleyTarget> Targets;
    Actor View;
    override void WorldTick()
    {
        let port=CaelumPortSiege.Get();if(port==null)return;
        if(level.time==70)
        {
            let user=CaelumPlayer(players[0].mo);user.CreationWizardOpen=false;
            for(int i=0;i<CaelumCityData.HOUSE_COUNT;i++)
                Targets.Push(CA133VolleyTarget(Actor.Spawn("CA133VolleyTarget",CaelumCityData.DoorInside(i))));
            View=Actor.Spawn("CaelumSiegeRouteNode",CaelumCityData.HouseOrigin(0)+(832,224,48));
            View.Angle=180;players[0].camera=View;
            Console.Printf("CA133 VOLLEY_SCOPE 600 original bodies; one stationary target per home; staggered four-tic requests; native recovery, heat, projectiles and collision retained");
        }
        if(Targets.Size()==0)return;
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let b=port.Defenders[i];if(b==null || b.health<=0 || i%4!=level.time%4)continue;
            if(!b.PulseResourceRecovery())b.Carbine.Attack(b,Targets[i%CaelumCityData.HOUSE_COUNT]);
        }
        if(level.time%35!=0)return;
        int alive=0,shots=0,reloads=0,reloading=0,hits=0,projectiles=0;
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let b=port.Defenders[i];if(b==null)continue;
            if(b.health>0)alive++;shots+=b.Carbine.ShotCount;reloads+=b.Carbine.ReloadCount;
            if(b.Carbine.ReloadRemaining>0)reloading++;
        }
        for(int i=0;i<Targets.Size();i++)if(Targets[i]!=null)hits+=Targets[i].Hits;
        let it=ThinkerIterator.Create("CaelumCarbineProjectile");while(it.Next()!=null)projectiles++;
        Console.Printf("CA133 VOLLEY tic=%d ms=%.6f alive=%d shots=%d reloads=%d reloading=%d hits=%d projectiles=%d",level.time,MSTimeF(),alive,shots,reloads,reloading,hits,projectiles);
        if(level.time==3500)Console.Printf("CA133 VOLLEY_COMPLETE");
    }
}
