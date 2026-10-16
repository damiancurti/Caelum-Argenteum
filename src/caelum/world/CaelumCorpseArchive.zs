// #304: presupuesto visual; los cuerpos conservan identidad para Redencion.
class CaelumCorpseArchiveData : Object
{
    const REVISION=1;
    const DORMANT_STAT=Thinker.STAT_FIRST_THINKING-1;
    const VISIBLE_LIMIT=100;
    const MAP="MAP06";
}

class CaelumArchivedCorpse : Inventory
{
    int Revision;
    bool Suspended,WasInvisible,WasSolid,WasShootable,WasNoInteraction,WasNoBlock,WasNoSector;

    void Suspend()
    {
        if(Suspended || Owner==null || Owner.health>0)return;
        Revision=CaelumCorpseArchiveData.REVISION;
        WasInvisible=Owner.bInvisible;WasSolid=Owner.bSolid;WasShootable=Owner.bShootable;
        WasNoInteraction=Owner.bNoInteraction;WasNoBlock=Owner.bNOBLOCKMAP;WasNoSector=Owner.bNOSECTOR;
        Suspended=true;
        Owner.bInvisible=true;Owner.bSolid=false;Owner.bShootable=false;Owner.bNoInteraction=true;
        Owner.A_ChangeLinkFlags(1,1);Owner.Vel=(0,0,0);Owner.A_StopAllSounds();
        // Lista local sin Tick; STAT_STATIC sobrevive al mapa y no sirve aqui.
        // El inventario sigue unido al mismo cuerpo y se guarda con el.
        Owner.ChangeStatNum(CaelumCorpseArchiveData.DORMANT_STAT);
        for(Inventory item=Owner.Inv;item!=null;item=item.Inv)item.ChangeStatNum(CaelumCorpseArchiveData.DORMANT_STAT);
    }

    void Resume()
    {
        if(!Suspended || Owner==null)return;
        Suspended=false;
        Owner.bInvisible=WasInvisible;Owner.bSolid=WasSolid;Owner.bShootable=WasShootable;
        Owner.bNoInteraction=WasNoInteraction;
        Owner.A_ChangeLinkFlags(WasNoBlock?1:0,WasNoSector?1:0);
        Owner.ChangeStatNum(Owner.player!=null?STAT_PLAYER:STAT_DEFAULT);
        for(Inventory item=Owner.Inv;item!=null;item=item.Inv)item.ChangeStatNum(STAT_INVENTORY);
        Owner.FindFloorCeiling();Owner.ClearInterpolation();
    }
}

// El contenedor pertenece al mapa: los EventHandler no conservan sus referencias
// al volver a un hub. La lista local dormida se serializa junto al mapa.
class CaelumCorpseArchiveStore : Actor
{
    CaelumCorpseArchive Registry;
    Default { +NOINTERACTION +NOSECTOR +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumCorpseArchive : Object play
{
    int Revision,ArchivedCount;
    Array<Actor> Recent,Pending;

    static CaelumCorpseArchive Get(bool create=false)
    {
        if(level.MapName!=CaelumCorpseArchiveData.MAP)return null;
        let it=ThinkerIterator.Create("CaelumCorpseArchiveStore",CaelumCorpseArchiveData.DORMANT_STAT);
        let holder=CaelumCorpseArchiveStore(it.Next());
        if(holder==null)
        {
            if(!create)return null;
            holder=CaelumCorpseArchiveStore(Actor.Spawn("CaelumCorpseArchiveStore",(0,0,0)));
            holder.ChangeStatNum(CaelumCorpseArchiveData.DORMANT_STAT);
            holder.Registry=new("CaelumCorpseArchive");
        }
        return holder.Registry;
    }

    static bool Suspended(Actor body)
    {
        let mark=body==null?null:CaelumArchivedCorpse(body.FindInventory("CaelumArchivedCorpse"));
        return mark!=null && mark.Suspended;
    }

    static void Died(Actor body)
    {
        let registry=Get();if(registry==null || body==null)return;
        // WorldThingDied puede adelantarse a los flags finales de la muerte.
        if(registry.Pending.Find(body)==registry.Pending.Size())registry.Pending.Push(body);
    }

    static void Recall(Actor body)
    {
        let mark=body==null?null:CaelumArchivedCorpse(body.FindInventory("CaelumArchivedCorpse"));
        if(mark!=null)mark.Resume();
        let registry=Get();if(registry==null)return;
        int index=registry.Recent.Find(body);if(index<registry.Recent.Size())registry.Recent.Delete(index);
        index=registry.Pending.Find(body);if(index<registry.Pending.Size())registry.Pending.Delete(index);
    }

    void Observe(Actor body)
    {
        if(body==null || body.health>0 || !body.bCorpse || Suspended(body))return;
        if(Recent.Find(body)==Recent.Size())Recent.Push(body);
    }

    void Tick()
    {
        if(Revision<CaelumCorpseArchiveData.REVISION)
        {
            // Las partidas antiguas no guardaban orden de muerte. Su primera
            // importacion usa el orden estable de Thinkers, sin recrear cuerpos.
            let it=ThinkerIterator.Create("Actor");Actor body;
            while((body=Actor(it.Next()))!=null)Observe(body);
            Revision=CaelumCorpseArchiveData.REVISION;
        }
        for(int i=0;i<Pending.Size();i++)Observe(Pending[i]);
        Pending.Clear();
        for(int i=Recent.Size()-1;i>=0;i--)
            if(Recent[i]==null || Recent[i].health>0 || !Recent[i].bCorpse || Suspended(Recent[i]))Recent.Delete(i);
        while(Recent.Size()>CaelumCorpseArchiveData.VISIBLE_LIMIT)
        {
            int oldest=0;
            // La camara del jugador muerto actual debe conservar su cuerpo.
            while(oldest<Recent.Size() && Recent[oldest].player!=null
                && Recent[oldest].player.mo==Recent[oldest])oldest++;
            if(oldest==Recent.Size())break;
            Actor body=Recent[oldest];Recent.Delete(oldest);
            let mark=CaelumArchivedCorpse(body.GiveInventoryType("CaelumArchivedCorpse"));
            if(mark!=null){mark.Suspend();ArchivedCount++;}
        }
    }
}
