// Cada cuerpo guarda sus pactos; cada lanzador mantiene solamente sus receptores.
class CaelumTarotEmperorCast : Inventory
{
    Array<CaelumTarotEmperorBody> Bodies;
    void Remove(CaelumTarotEmperorBody body)
    {for(int i=Bodies.Size()-1;i>=0;i--)if(Bodies[i]==body || Bodies[i]==null)Bodies.Delete(i);}
    void AdvanceEffect()
    {
        let user=CaelumPlayer(Owner);if(user==null || user.SessionIdentityPending)return;
        for(int i=Bodies.Size()-1;i>=0;i--)
        {if(i>=Bodies.Size())continue;let body=Bodies[i];if(body!=null)body.AdvanceSource(user.PlayerNumber());else Bodies.Delete(i);}
    }
    void End()
    {
        let user=CaelumPlayer(Owner);if(user==null)return;
        for(int i=Bodies.Size()-1;i>=0;i--)
        {if(i>=Bodies.Size())continue;let body=Bodies[i];if(body!=null)body.Expire(user.PlayerNumber());}
        Bodies.Clear();
    }
    override void OnDestroy(){End();Super.OnDestroy();}
    override void PreTravelled(){End();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotEmperorBody : Inventory
{
    int Revision,Remaining[MAXPLAYERS],OriginalFriendPlayer;
    CaelumPlayer Sources[MAXPLAYERS],Controller;
    CaelumTarotEmperorCast Casts[MAXPLAYERS];
    Actor OriginalMaster,CommandTarget;
    bool OriginalFriendly;

    static clearscope CaelumTarotEmperorBody View(Actor body)
    {
        let user=CaelumPlayer(body);if(user!=null)return user.TarotEmperor;
        let npc=CaelumCombatActor(body);return npc!=null?npc.TarotEmperor:null;
    }
    static CaelumTarotEmperorBody Get(Actor body)
    {
        let status=View(body);if(status!=null)return status;
        status=CaelumTarotEmperorBody(body.GiveInventoryType('CaelumTarotEmperorBody'));
        if(status==null)return null;
        status.Revision=CaelumMajorArcanaData.EMPEROR_REVISION;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null)user.TarotEmperor=status;else if(npc!=null)npc.TarotEmperor=status;
        return status;
    }
    clearscope bool Blocks(Actor other)
    {
        let user=CaelumPlayer(other);if(user==null)return false;
        int slot=user.PlayerNumber();
        return slot>=0 && slot<MAXPLAYERS && Sources[slot]==user && Remaining[slot]>0;
    }
    void ClearTarget()
    {
        if(Owner==null)return;
        Owner.target=null;Owner.LastEnemy=null;
        let npc=CaelumCombatActor(Owner);
        if(npc!=null && npc.VisualEvidence!=null)
        {
            npc.VisualEvidence.CandidateCacheReady=false;
            if(npc.VisualEvidence.Memory!=null)
            {npc.VisualEvidence.Memory.Focus=null;npc.VisualEvidence.Memory.ClearGoal(npc);}
        }
    }
    void Restore()
    {
        if(Controller==null && OriginalMaster==null)return;
        if(Owner!=null)
        {Owner.master=OriginalMaster;Owner.bFriendly=OriginalFriendly;Owner.FriendPlayer=OriginalFriendPlayer;}
        Controller=null;CommandTarget=null;OriginalMaster=null;ClearTarget();
    }
    void Apply(CaelumPlayer user,int duration,Actor aimed)
    {
        int slot=user.PlayerNumber();if(slot<0 || slot>=MAXPLAYERS || duration<=0)return;
        let cast=CaelumTarotEmperorCast(user.FindInventory('CaelumTarotEmperorCast'));
        if(cast==null)cast=CaelumTarotEmperorCast(user.GiveInventoryType('CaelumTarotEmperorCast'));
        if(Casts[slot]!=null && Casts[slot]!=cast)Casts[slot].Remove(self);
        Casts[slot]=cast;Sources[slot]=user;Remaining[slot]=duration;
        if(cast.Bodies.Find(self)>=cast.Bodies.Size())cast.Bodies.Push(self);
        if(Owner is 'CaelumSummonedZupay')
        {
            // Un nuevo controlador no reemplaza la afiliación original guardada.
            if(Controller==null)
            {OriginalMaster=Owner.master;OriginalFriendly=Owner.bFriendly;OriginalFriendPlayer=Owner.FriendPlayer;}
            Controller=user;CommandTarget=CaelumMajorTargets.Visible(user,aimed)?aimed:null;
            Owner.master=user;Owner.bFriendly=true;Owner.SetFriendPlayer(user.player);ClearTarget();
            // Orientación única hacia la orden recibida, nunca hacia un blanco oculto futuro.
            if(CommandTarget!=null)Owner.Angle=Owner.AngleTo(CommandTarget);
        }
        else if(Owner.target==user)ClearTarget();
        CaelumMajorWorldEvents.TimeSourcesChanged();
    }
    void Expire(int slot)
    {
        if(slot<0 || slot>=MAXPLAYERS)return;
        if(Controller==Sources[slot] && (Controller!=null || OriginalMaster!=null))Restore();
        Sources[slot]=null;Remaining[slot]=0;
        let cast=Casts[slot];Casts[slot]=null;if(cast!=null)cast.Remove(self);
    }
    void AdvanceSource(int slot)
    {
        if(slot<0 || slot>=MAXPLAYERS || Remaining[slot]<=0)return;
        let receiver=CaelumPlayer(Owner);
        if((receiver!=null && receiver.SessionIdentityPending)
            || (Sources[slot]!=null && Sources[slot].SessionIdentityPending))return;
        if(Owner==null || Owner.health<=0 || Sources[slot]==null || --Remaining[slot]<=0)Expire(slot);
    }
    override void Tick()
    {
        Super.Tick();
        for(int i=0;i<MAXPLAYERS;i++)AdvanceSource(i);
    }
    void Cleanse(){for(int i=0;i<MAXPLAYERS;i++)Expire(i);}
    override void OnDestroy()
    {
        Cleanse();let user=CaelumPlayer(Owner);let npc=CaelumCombatActor(Owner);
        if(user!=null && user.TarotEmperor==self)user.TarotEmperor=null;
        if(npc!=null && npc.TarotEmperor==self)npc.TarotEmperor=null;
        Super.OnDestroy();
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotEmperor : Object play
{
    static clearscope bool Blocks(Actor source,Actor victim)
    {let status=CaelumTarotEmperorBody.View(source);return source!=victim && status!=null && status.Blocks(victim);}
    static clearscope CaelumPlayer Commander(Actor body)
    {let status=CaelumTarotEmperorBody.View(body);return status!=null?status.Controller:null;}
    static Actor CommandCandidate(CaelumCombatActor body)
    {
        let status=CaelumTarotEmperorBody.View(body);
        if(status==null || status.Controller==null || status.Controller.SessionIdentityPending)return null;
        let aimed=status.CommandTarget;
        return CaelumVisualPerception.Opponent(body,aimed) && CaelumVisualPerception.CanSee(body,aimed)?aimed:null;
    }
    static bool Eligible(Actor body)
    {
        if(!CaelumVisualPerception.Living(body) || body.bNoInteraction || body.bDormant || body.bInConversation
            || (!(body is 'CaelumPlayer') && !(body is 'CaelumCombatActor')))return false;
        let user=CaelumPlayer(body);if(user!=null && user.SessionIdentityPending)return false;
        let resident=CaelumAnchoredResident(body);
        if(resident!=null && resident.IsProtectedStoryResident())return false;
        let palomo=CaelumPalomo(body);
        return palomo==null || !(palomo.bInvisible || (palomo.NarrativeRevealRequired && !palomo.NarrativeRevealed)
            || (palomo.DepartureStarted && !palomo.DepartureDone));
    }
    static void Add(CaelumPlayer user,Actor body,double radius,Array<Actor> visited,int duration,Actor aimed)
    {
        if(body==user || visited.Find(body)<visited.Size() || !Eligible(body)
            || user.Distance3D(body)>radius || !user.CheckSight(body))return;
        visited.Push(body);
        int adjusted=int(CaelumTemperance.Duration(body,double(duration)/TICRATE)*TICRATE);
        if(adjusted<=0)return;
        let status=CaelumTarotEmperorBody.Get(body);if(status!=null)status.Apply(user,adjusted,aimed);
    }
    static void Pulse(CaelumPlayer user,int duration,Actor aimed)
    {
        if(user==null || user.DerivedStats==null || duration<=0)return;
        double radius=CaelumPhysicsUnits.MapUnits(CaelumMajorArcanaData.AREA_METERS)
            *Max(0.0,user.DerivedStats.AbilityRangePercent)/100.0;
        Array<Actor> visited;
        let nearby=BlockThingsIterator.Create(user,radius);
        while(nearby.Next())Add(user,nearby.thing,radius,visited,duration,aimed);
        // Los cuerpos fuera del blockmap ya pertenecen a la rejilla de contactos.
        let world=CaelumContaminationWorld.Get();let grid=world!=null?world.ContactGrid():null;
        if(grid!=null && grid.Heads.Size()>0)
        {
            int left=int(Floor((user.Pos.X-radius)/grid.CELL)),right=int(Floor((user.Pos.X+radius)/grid.CELL));
            int low=int(Floor((user.Pos.Y-radius)/grid.CELL)),high=int(Floor((user.Pos.Y+radius)/grid.CELL));
            for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
                for(let row=grid.Heads[grid.Hash(x,y)];row!=null;row=row.GridNext)
                    if(row.GridX==x && row.GridY==y)Add(user,row.GridBody,radius,visited,duration,aimed);
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Add(user,players[i].mo,radius,visited,duration,aimed);
    }
}
