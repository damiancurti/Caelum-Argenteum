// Render-only ablation: explicitly not a playable combat result.
class CA318FlatFreeze : EventHandler
{
    int Start,At;
    bool Active,Done;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca318_begin")
        {Start=level.time;At=Start+CVar.GetCVar("ca318_warmup").GetInt();Active=true;}
    }
    override void WorldTick()
    {
        if(!Active || Done || level.time<At)return;
        Array<Actor> bodies;let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)if(body!=players[0].mo)bodies.Push(body);
        for(int i=0;i<bodies.Size();i++)bodies[i].ChangeStatNum(CaelumCorpseArchiveData.DORMANT_STAT);
        Done=true;
        Console.Printf("CA318 FROZEN tic=%d bodies=%d nonplayer_actors_frozen=1 player_and_events_active=1",level.time,bodies.Size());
    }
}
