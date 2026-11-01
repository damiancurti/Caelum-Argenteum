// La proyección conserva un solo impulso por cuerpo y lanzamiento.
class CaelumTarotFragileObstacle : CaelumMovableProp
{
    bool TarotBroken;
    virtual bool BreakByTarot()
    {
        if(TarotBroken)return false;
        TarotBroken=true;bSolid=false;bShootable=false;bInvisible=true;Vel=(0,0,0);
        return true;
    }
}

class CaelumTarotChariotState : Inventory
{
    CaelumTarotChariot Projection;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotChariot : Actor
{
    int Revision,Age,QueryCount,CandidateCount;
    CaelumPlayer Caster;
    CaelumTarotChariotState Ledger;
    CaelumPlacementProbe Geometry;
    Array<Actor> Contacted,LocalUnlinked;
    vector2 Direction;
    double Travelled,Power;

    void IncludeUnlinked(Actor body)
    {
        if(body==null || !body.bNoBlockmap || Distance2D(body)
            >CaelumMajorArcanaData.CHARIOT_DISTANCE_MU-Travelled+CaelumMajorArcanaData.CHARIOT_LENGTH_MU/2+body.Radius)return;
        for(int i=0;i<LocalUnlinked.Size();i++)if(LocalUnlinked[i]==body)return;
        LocalUnlinked.Push(body);
    }
    static void RegisteredUnlinked(Actor body)
    {
        // Altas tardías del encuentro, no un recorrido por tic o destinatario.
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p] && players[p].mo!=null)
        {
            let holder=CaelumTarotChariotState(players[p].mo.FindInventory('CaelumTarotChariotState'));
            if(holder!=null && holder.Projection!=null)holder.Projection.IncludeUnlinked(body);
        }
    }

    static CaelumTarotChariot Launch(CaelumPlayer user)
    {
        if(user==null || user.DerivedStats==null)return null;
        let ledger=CaelumTarotChariotState(user.FindInventory('CaelumTarotChariotState'));
        if(ledger==null)ledger=CaelumTarotChariotState(user.GiveInventoryType('CaelumTarotChariotState'));
        if(ledger.Projection!=null)ledger.Projection.Destroy();
        let cart=CaelumTarotChariot(Actor.Spawn('CaelumTarotChariot',user.Pos,NO_REPLACE));
        cart.Revision=CaelumMajorArcanaData.CHARIOT_REVISION;cart.Caster=user;cart.Ledger=ledger;
        ledger.Projection=cart;cart.Direction=(Cos(user.Angle),Sin(user.Angle));cart.Angle=user.Angle;
        cart.Power=CaelumTarotObjectMovement.Push(user);
        cart.Geometry=CaelumPlacementProbe(Actor.Spawn('CaelumPlacementProbe',cart.Pos,NO_REPLACE));
        cart.Geometry.A_SetSize(CaelumMajorArcanaData.CHARIOT_WIDTH_MU/2,
            CaelumMajorArcanaData.CHARIOT_HEIGHT_MU,false);
        // Los guardias sin blockmap están estacionados. Filtrar una sola vez
        // el registro tipado compartido y conservar sólo el entorno del recorrido.
        let population=CaelumPopulationState.Get();
        if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)
        {
            let entry=population.UnlinkedGuards[i];let body=entry!=null?entry.Body:null;
            cart.IncludeUnlinked(body);
        }
        if(!cart.Fits(cart.Pos)){cart.Destroy();return null;}
        return cart;
    }

    bool Fits(vector3 point)
    {
        if(Geometry==null)return false;
        double offset=(CaelumMajorArcanaData.CHARIOT_LENGTH_MU-CaelumMajorArcanaData.CHARIOT_WIDTH_MU)/2;
        for(int i=-1;i<=1;i++)
        {
            Geometry.SetOrigin(point+(Direction.X*offset*i,Direction.Y*offset*i,0),false);
            if(!Geometry.TestMobjLocation())return false;
        }
        return true;
    }

    bool Touch(Actor body)
    {
        CandidateCount++;
        if(body==null || body==Caster || body==self || body==Geometry || body.bDestroyed
            || body is 'Inventory' || !body.bSolid || body.Pos.Z>=Pos.Z+CaelumMajorArcanaData.CHARIOT_HEIGHT_MU
            || body.Pos.Z+body.Height<=Pos.Z)return true;
        vector2 delta=body.Pos.XY-Pos.XY;
        if(Abs(delta.X*Direction.X+delta.Y*Direction.Y)>CaelumMajorArcanaData.CHARIOT_LENGTH_MU/2+body.Radius
            || Abs(delta.X*-Direction.Y+delta.Y*Direction.X)>CaelumMajorArcanaData.CHARIOT_WIDTH_MU/2+body.Radius
            || !CheckSight(body,SF_IGNOREVISIBILITY))return true;
        for(int i=0;i<Contacted.Size();i++)if(Contacted[i]==body)return true;
        Contacted.Push(body);
        let fragile=CaelumTarotFragileObstacle(body);
        if(fragile!=null){fragile.BreakByTarot();return true;}
        if(body.bDONTTHRUST)return false;
        let movable=CaelumMovableProp(body);
        if(movable!=null)return movable.TarotLift==null && !CaelumTelekinesisRules.Held(body)
            && movable.TryPushFrom(self,Power,CaelumConstants.BASE_ATTACK_PUSH_FORCE*Power);
        if(body.health<=0 || (!body.bShootable && !(body is 'PlayerPawn')))return false;
        if(Caster!=null)Caster.ApplyAttackPushToTarget(body,Angle,Power);
        return true;
    }

    bool Contacts()
    {
        QueryCount++;
        let nearby=BlockThingsIterator.Create(self,CaelumMajorArcanaData.CHARIOT_LENGTH_MU/2);
        bool clear=true;
        while(nearby.Next())if(!Touch(nearby.thing))clear=false;
        for(int i=0;i<LocalUnlinked.Size();i++)
            if(LocalUnlinked[i]!=null && LocalUnlinked[i].bNoBlockmap && !Touch(LocalUnlinked[i]))clear=false;
        return clear;
    }

    override void Tick()
    {
        Super.Tick();
        if(Caster!=null && Caster.SessionIdentityPending)return;
        if(Age>=CaelumMajorArcanaData.CHARIOT_SECONDS*TICRATE
            || Travelled>=CaelumMajorArcanaData.CHARIOT_DISTANCE_MU){Destroy();return;}
        double step=Min(CaelumMajorArcanaData.CHARIOT_SPEED_MU/TICRATE,
            CaelumMajorArcanaData.CHARIOT_DISTANCE_MU-Travelled);
        vector3 next=Pos+(Direction.X*step,Direction.Y*step,0);
        if(!Fits(next)){Destroy();return;}
        SetOrigin(next,true);Travelled+=step;Age++;
        if(!Contacts())Destroy();
    }
    override void OnDestroy()
    {
        if(Ledger!=null && Ledger.Projection==self)Ledger.Projection=null;
        if(Geometry!=null)Geometry.Destroy();Geometry=null;
        Super.OnDestroy();
    }
    Default {+NOBLOCKMAP +NOGRAVITY -SOLID +DONTTHRUST Radius 1;Height 1;}
    States {Spawn:CAHC A -1;Stop;}
}
