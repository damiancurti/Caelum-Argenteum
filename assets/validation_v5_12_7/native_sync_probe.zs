// Observación independiente del resultado funcional; nunca borra el aviso nativo.
class CA435NativeSyncProbe : StaticEventHandler
{
    bool Failed;
    int LastReport;
    override void WorldLoaded(WorldEvent e){Failed=false;LastReport=-175;}
    override void WorldTick()
    {
        if(Failed)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].inconsistent!=0)
        {
            Failed=true;
            Console.Printf("CA435SYNC FAIL peer=%d slot=%d native=%d tic=%d",consoleplayer,i,players[i].inconsistent,level.time);
            return;
        }
        if(level.time-LastReport>=175)
        {LastReport=level.time;Console.Printf("CA435SYNC OK peer=%d map=%s tic=%d",consoleplayer,level.MapName,level.time);}
    }
}
