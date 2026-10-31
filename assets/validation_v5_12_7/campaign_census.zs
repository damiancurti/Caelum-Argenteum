// Sólo dos observaciones diagnósticas por ejecución; registros tipados existentes.
class CA435CampaignCensus : Object play
{
    static void Report(String label)
    {
        int defenders=0,attackers=0,health=0,parked=0;
        let port=CaelumPortSiege.Get();
        if(port!=null)
        {
            for(int i=0;i<port.Defenders.Size();i++)
            {
                let body=port.Defenders[i];if(body==null || body.health<=0)continue;
                defenders++;health=(health+body.health)%1000000007;
            }
            for(int i=0;i<port.Attackers.Size();i++)
            {
                let entry=port.Attackers[i];let body=entry==null?null:entry.Body;
                if(body==null || body.health<=0)continue;
                attackers++;health=(health+body.health)%1000000007;
            }
        }
        let houses=CaelumHouseResidents.Get(false);
        if(houses!=null)for(int i=0;i<houses.Residents.Size();i++)
        {
            let resident=houses.Residents[i];if(resident!=null && resident.Suspended)parked++;
        }
        let population=CaelumPopulationState.Get();
        Console.Printf("CA435PERF STATE peer=%d tic=%d defenders=%d attackers=%d registered_health=%d parked=%d population=%d dense=%d",
            consoleplayer,level.time,defenders,attackers,health,parked,
            population==null?-1:population.LivingCombatants,population!=null&&population.HighDensity);
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].mo!=null)
        {
            let user=players[i].mo;
            Console.Printf("CA435PERF STATE peer=%d slot=%d health=%d pos=%.6f,%.6f,%.6f",
                consoleplayer,i,user.health,user.Pos.X,user.Pos.Y,user.Pos.Z);
        }
        Console.Printf("CA510 CENSUS %s registered_defenders=%d registered_attackers=%d parked=%d",label,defenders,attackers,parked);
    }
}
