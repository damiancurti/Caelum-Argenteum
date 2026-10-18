// #353: cada blanco conoce sólo los mandos que esperan su resultado.
// Las suscripciones son derivadas y se reconstruyen al consumir un caché guardado.
class CaelumTargetSubscriptions : Object play
{
    Array<CaelumSiegeCombatant> Users;

    static CaelumTargetSubscriptions Get(Actor body,bool create=false)
    {
        let npc=CaelumCombatActor(body);
        if(npc!=null)
        {
            if(create && npc.TargetSubscribers==null)npc.TargetSubscribers=new("CaelumTargetSubscriptions");
            return npc.TargetSubscribers;
        }
        let user=CaelumPlayer(body);
        if(user!=null)
        {
            if(create && user.TargetSubscribers==null)user.TargetSubscribers=new("CaelumTargetSubscriptions");
            return user.TargetSubscribers;
        }
        return null;
    }

    static void Unwatch(CaelumSiegeCombatant leader)
    {
        let subscribers=Get(leader.SharedTargetSubscription);
        if(subscribers!=null)
            for(int i=subscribers.Users.Size()-1;i>=0;i--)
                if(subscribers.Users[i]==null || subscribers.Users[i]==leader)subscribers.Users.Delete(i);
        leader.SharedTargetSubscription=null;
    }

    static void Watch(CaelumSiegeCombatant leader)
    {
        if(leader.SharedTarget==leader.SharedTargetSubscription)return;
        Unwatch(leader);
        let subscribers=Get(leader.SharedTarget,true);
        if(subscribers==null)return;
        subscribers.Users.Push(leader);
        leader.SharedTargetSubscription=leader.SharedTarget;
    }

    static void Invalidate(Actor body)
    {
        let subscribers=Get(body);
        if(subscribers==null)return;
        for(int i=0;i<subscribers.Users.Size();i++)
        {
            let leader=subscribers.Users[i];
            if(leader!=null && leader.SharedTarget==body)
            {
                leader.SharedTargetValid=false;
                leader.SharedTargetSubscription=null;
            }
        }
        subscribers.Users.Clear();
    }

    static void Retire(Actor body)
    {
        Invalidate(body);
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.SiegeCombatant!=null)Unwatch(npc.SiegeCombatant);
    }
}
