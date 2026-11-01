// El pulso reconoce estados mágicos explícitos, no banderas genéricas de amistad.
class CaelumTarotJudgement : Object play
{
    static void Collect(CaelumPlayer user,Actor body,double radius,Array<Actor> reached)
    {
        if(reached.Find(body)<reached.Size() || !CaelumTarotEmperor.Eligible(body)
            || user.Distance3D(body)>radius || (body!=user && !user.CheckSight(body)))return;
        reached.Push(body);
    }

    static bool Dispel(Actor body)
    {
        if(!CaelumTarotEmperor.Eligible(body))return false;
        let illusion=CaelumTarotClone(body);
        if(illusion!=null){illusion.Destroy();return true;}
        let control=CaelumTarotEmperorBody.View(body);
        if(control==null)return false;
        bool active=false;
        for(int i=0;i<MAXPLAYERS;i++)active|=control.Remaining[i]>0;
        if(active)control.Cleanse();return active;
    }

    static int Pulse(CaelumPlayer user)
    {
        if(user==null || user.DerivedStats==null)return 0;
        double radius=CaelumPhysicsUnits.MapUnits(CaelumMajorArcanaData.AREA_METERS)
            *Max(0.0,user.DerivedStats.AbilityRangePercent)/100.0;
        Array<Actor> reached;
        let nearby=BlockThingsIterator.Create(user,radius);
        while(nearby.Next())Collect(user,nearby.thing,radius,reached);
        // Reutilizar la rejilla local de cuerpos que no están en el blockmap.
        let world=CaelumContaminationWorld.Get();let grid=world!=null?world.ContactGrid():null;
        if(grid!=null && grid.Heads.Size()>0)
        {
            int left=int(Floor((user.Pos.X-radius)/grid.CELL)),right=int(Floor((user.Pos.X+radius)/grid.CELL));
            int low=int(Floor((user.Pos.Y-radius)/grid.CELL)),high=int(Floor((user.Pos.Y+radius)/grid.CELL));
            for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
                for(let row=grid.Heads[grid.Hash(x,y)];row!=null;row=row.GridNext)
                    if(row.GridX==x && row.GridY==y)Collect(user,row.GridBody,radius,reached);
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Collect(user,players[i].mo,radius,reached);
        // Destruir después de recorrer: una ilusión puede retirar entradas locales.
        int count=0;for(int i=0;i<reached.Size();i++)if(Dispel(reached[i]))count++;
        return count;
    }
}
