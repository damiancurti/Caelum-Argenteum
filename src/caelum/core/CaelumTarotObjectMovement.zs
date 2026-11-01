// Fuerza de movimiento separada de daño, carga normal y atributos personales.
class CaelumTarotObjectMovement : Object play
{
    static clearscope bool Active(CaelumPlayer user)
    {
        let record=user!=null?CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')):null;
        return CaelumTarotService.IsActive(record,11);
    }
    static double Strength(CaelumPlayer user)
    {return user.Attributes.Strength*(Active(user)?CaelumMajorArcanaData.STRENGTH_MOVEMENT:1);}
    static double Push(CaelumPlayer user)
    {
        if(user==null || user.Attributes==null || user.DerivedStats==null)return 0;
        return user.DerivedStats.CalculateType1Percent(Strength(user))/100.0*user.DerivedStats.BaseMassMultiplier;
    }
    static double Capacity(CaelumPlayer user)
    {
        if(user==null || user.Attributes==null || user.DerivedStats==null)return 0;
        return user.DerivedStats.BaseMass*user.DerivedStats.CalculateType4Percent(Strength(user))/100.0;
    }
    static clearscope CaelumTarotLift View(CaelumPlayer user)
    {return user!=null?CaelumTarotLift(user.FindInventory('CaelumTarotLift')):null;}
    static double Weight(CaelumPlayer user)
    {
        let held=View(user);
        return held!=null && held.Body!=null && !held.Body.bDestroyed && held.MapName==level.MapName
            ? Max(0.0,double(held.Body.Mass)):0;
    }
    static bool Eligible(CaelumMovableProp body)
    {
        return body!=null && !body.bDestroyed && body.health>0 && body.GetRequiredPhysicalPower()>0
            && !body.bNoInteraction && !body.bDormant && !CaelumTelekinesisRules.Held(body)
            && body.TarotLift==null;
    }
    static bool Permitted(CaelumPlayer user)
    {
        return CaelumTarotService.ValidUser(user) && !CaelumRacialAbilityRules.Interrupted(user)
            && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),11);
    }
    static void Release(CaelumPlayer user)
    {let held=View(user);if(held!=null)held.Release();}
    static void Guard(CaelumPlayer user)
    {
        let held=View(user);if(held==null || held.Body==null)return;
        // La recuperación de red valida la identidad antes de reanudar el cuerpo.
        if(user.SessionIdentityPending)return;
        if(!Permitted(user) || held.MapName!=level.MapName || held.Body.bDestroyed
            || held.Body.health<=0 || user.DerivedStats.CarriedWeight>Capacity(user)+0.0005)
            held.Release();
    }
    static bool Use(CaelumPlayer user,CaelumMovableProp body)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return false;
        if(CaelumRacialAbilityRules.MenuBlocked(user))return false;
        let held=View(user);
        if(held!=null && held.Body!=null){held.Release();return true;}
        if(!Permitted(user) || !Eligible(body))return false;
        if(user.DerivedStats.CarriedWeight+double(body.Mass)>Capacity(user)+0.0005)
        {CaelumTarotService.Feedback(user,"CA_TAROT_LIFT_HEAVY");return true;}
        if(held==null)held=CaelumTarotLift(user.GiveInventoryType('CaelumTarotLift'));
        held.Revision=CaelumMajorArcanaData.OBJECT_MOVEMENT_REVISION;
        held.Body=body;held.Holding=true;held.MapName=level.MapName;held.HadNoGravity=body.bNoGravity;
        held.Distance=Max(user.Distance2D(body),user.Radius+body.Radius+0.01);
        body.TarotLift=held;body.bNoGravity=true;body.Vel=(0,0,0);
        user.RefreshCarriedInventorySummary();
        if(!held.Follow(user)){held.Release();return true;}
        CaelumTarotService.Feedback(user,"CA_TAROT_LIFT_STARTED");return true;
    }
}

// Mantener el cuerpo real conserva identidad, contaminación, desgaste y colisión.
class CaelumTarotLift : Inventory
{
    int Revision;
    CaelumMovableProp Body;
    String MapName;
    bool HadNoGravity,Holding;
    double Distance;

    void Release()
    {
        let previous=Body;Body=null;Holding=false;
        if(previous!=null && !previous.bDestroyed && previous.TarotLift==self)
        {previous.TarotLift=null;previous.bNoGravity=HadNoGravity;}
        let user=CaelumPlayer(Owner);
        if(user!=null && !user.bDestroyed)user.RefreshCarriedInventorySummary();
    }
    bool Follow(CaelumPlayer user)
    {
        if(Body==null || Body.bDestroyed)return false;
        vector3 destination=user.Pos+(Distance*Cos(user.Angle),Distance*Sin(user.Angle),
            Max(0.0,(user.Height-Body.Height)/2));
        vector3 movement=destination-Body.Pos;
        // Un teletransporte no arrastra el objeto a través de paredes.
        if(movement.Length()>user.UseRange+Distance)return false;
        int count=Max(1,int(Ceil(movement.Length()/Max(1.0,Min(Body.Radius,Body.Height)/2))));
        vector3 origin=Body.Pos;
        for(int i=1;i<=count;i++)
        {
            vector3 point=origin+movement*(double(i)/count);
            if(!Body.Warp(user,point.X,point.Y,point.Z,Body.Angle,
                WARPF_ABSOLUTEPOSITION|WARPF_ABSOLUTEANGLE|WARPF_STOP|WARPF_INTERPOLATE))return false;
        }
        return true;
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        if(user==null){Release();return;}
        if(user.SessionIdentityPending)return;
        if(Body==null && Holding){Release();return;}
        CaelumTarotObjectMovement.Guard(user);
        if(Body!=null && !Follow(user))Release();
    }
    override void OnDestroy(){Release();Super.OnDestroy();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumMajorWorldEvents : StaticEventHandler
{
    transient bool TimeSnapshotReady;
    transient int TimeSnapshotTic;
    transient Array<Actor> TimeEffects;

    static void TimeSourcesChanged()
    {
        let world=CaelumMajorWorldEvents(StaticEventHandler.Find('CaelumMajorWorldEvents'));
        if(world!=null)world.TimeSnapshotReady=false;
    }
    static bool HasTimeEffects()
    {
        let world=CaelumMajorWorldEvents(StaticEventHandler.Find('CaelumMajorWorldEvents'));
        if(world==null)return false;
        if(!world.TimeSnapshotReady || world.TimeSnapshotTic!=level.time)world.TimeSnapshot();
        for(int i=0;i<world.TimeEffects.Size();i++)
            if(world.TimeEffects[i]!=null && !world.TimeEffects[i].bDestroyed)return true;
        return false;
    }

    void IncludeTimeEffect(Actor effect)
    {
        if(effect==null || effect.bDestroyed || TimeEffects.Find(effect)<TimeEffects.Size())return;
        TimeEffects.Push(effect);
    }
    void TimeSnapshot()
    {
        TimeSnapshotReady=true;TimeSnapshotTic=level.time;TimeEffects.Clear();
        // Una lectura por dueño y fotograma acelerado; máximo cuatro efectos
        // por plaza. No se recorre el mundo ni se reescanean inventarios por subpaso.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            let cart=CaelumTarotChariotState(user.FindInventory('CaelumTarotChariotState'));
            let mine=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));
            let plant=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState'));
            let duel=CaelumJusticeLink.View(user);
            if(cart!=null)IncludeTimeEffect(cart.Projection);
            if(mine!=null)IncludeTimeEffect(mine.Mine);
            if(plant!=null)IncludeTimeEffect(plant.Roots);
            if(duel!=null)IncludeTimeEffect(duel.Duel);
        }
    }
    static void AdvanceSkippedTic()
    {
        let world=CaelumMajorWorldEvents(StaticEventHandler.Find('CaelumMajorWorldEvents'));
        if(world==null)return;
        if(!world.TimeSnapshotReady || world.TimeSnapshotTic!=level.time)world.TimeSnapshot();
        // El mismo duelo puede enlazar dos jugadores; la lista lo incluye una vez.
        for(int i=0;i<world.TimeEffects.Size();i++)
        {
            let effect=world.TimeEffects[i];if(effect==null || effect.bDestroyed)continue;
            let cart=CaelumTarotChariot(effect);if(cart!=null){cart.AdvanceEffect();continue;}
            let mine=CaelumTarotMine(effect);if(mine!=null){mine.AdvanceEffect();continue;}
            let plant=CaelumTarotRoots(effect);if(plant!=null){plant.AdvanceEffect();continue;}
            let duel=CaelumTarotJustice(effect);if(duel!=null)duel.AdvanceEffect();
        }
    }
    override void WorldLoaded(WorldEvent e)
    {TimeSnapshotReady=false;TimeEffects.Clear();}
    override void WorldUnloaded(WorldEvent e)
    {
        TimeSnapshotReady=false;TimeEffects.Clear();
        // Sólo los propietarios de la sesión: sin censo de actores del mapa.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);CaelumTarotObjectMovement.Release(user);
            let cart=user!=null?CaelumTarotChariotState(user.FindInventory('CaelumTarotChariotState')):null;
            if(cart!=null && cart.Projection!=null)cart.Projection.Destroy();
            let mine=user!=null?CaelumTarotMineState(user.FindInventory('CaelumTarotMineState')):null;
            if(mine!=null && mine.Mine!=null)mine.Mine.Destroy();
            let plant=user!=null?CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState')):null;
            if(plant!=null && plant.Roots!=null)plant.Roots.Destroy();
            if(user!=null)
            {
                let record=user.GetPersistentCharacterState(false);
                if(record!=null)
                {
                    // Los cuerpos temporales pertenecen al mapa que se abandona.
                    for(int card=0;card<CaelumConstants.TAROT_MAJOR_COUNT;card++)
                        if(card==1 || card==2 || card==3 || card==18)
                        {record.TarotRemaining[card]=0;record.TarotActive[card]=false;}
                    CaelumTarotSequence.Advance(user,record,0);
                }
            }
        }
    }
}
