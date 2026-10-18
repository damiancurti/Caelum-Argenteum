// Author-requested ablation: remove both visible leaves and solid helpers.
// Ordinary geometry and every soldier remain. Only the isolated addon uses this.
class CA318NoDoors : EventHandler
{
    bool Removed;
    override void WorldTick()
    {
        if(Removed || level.time<100)return;
        let port=CaelumPortSiege.Get();if(port==null || port.InteriorDoorRevision<1)return;
        Removed=true;Array<Actor> bodies;Actor body;
        let it=ThinkerIterator.Create("Actor");int leaves=0,blockers=0;
        while((body=Actor(it.Next()))!=null)
        {
            if(body is "CaelumSlidingDoorLeaf"){leaves++;bodies.Push(body);}
            else if(body is "CaelumSlidingDoorBlocker"){blockers++;bodies.Push(body);}
        }
        for(int i=0;i<bodies.Size();i++)bodies[i].Destroy();
        Console.Printf("CA318 NO_DOORS tic=%d leaves=%d blockers=%d diagnostic_only=1",level.time,leaves,blockers);
    }
}
