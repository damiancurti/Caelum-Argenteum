// Comparación nativa entre búsqueda original y poda; incluye el RNG de visión.
class CA128CannonStudy : EventHandler
{
    override void WorldTick()
    {
        if(level.MapName!="QA128B" || level.time!=2)return;
        let port=CaelumPortSiege(Actor.Spawn("CA128Port",(0,0,0),NO_REPLACE));
        port.SetupRevision=1;port.HighDensity=true;
        let crew=CaelumHostileMachine(Actor.Spawn("CaelumHostileMachine",(0,0,0),NO_REPLACE));
        let gun=CaelumCannon(Actor.Spawn("CaelumCannon",(0,0,0),NO_REPLACE));
        gun.Defending=true;
        gun.Barrel=CaelumCannonBarrel(Actor.Spawn("CaelumCannonBarrel",(0,0,64),NO_REPLACE));
        for(int i=0;i<40;i++)
        {
            let body=CaelumCombatActor(Actor.Spawn("CA128Body",(128+i*128,256,0),NO_REPLACE));
            let entry=port.RegisterAttacker(body);
            if(i%4==0)entry.CrewMachine=crew;
            if(i%5==1)body.bInvisible=true;
            if(i%5==2)body.bMInvisible=true;
            if(i%5==3)body.A_SetRenderStyle(0,STYLE_Translucent);
            if(i%5==4)body.A_SetRenderStyle(0.5,STYLE_Translucent);
        }
        for(int n=0;n<96;n++)
        {
            if(n==24)crew.Neutralized=true;
            if(n==48)
                for(int i=0;i<8;i++)port.Attackers[i].Body.health=0;
            if(n==72)
                for(int i=8;i<40;i++)port.Attackers[i].Body.SetOrigin((0,18000,0),false);
            let chosen=CaelumCombatActor(port.CannonTarget(gun));
            int id=chosen==null ? -1 : chosen.SiegeCombatant.StableIdentity;
            // El mismo flujo nativo debe quedar en la misma posición después
            // de cada consulta, incluso para candidatos que no pueden ganar.
            int randomState=Random[CheckSight](0,255);
            Console.Printf("CA128 CANNON_CASE n=%d target=%d sightRng=%d",n,id,randomState);
        }
        Console.Printf("CA128 CANNON_STUDY_COMPLETE cases=96");
    }
}
