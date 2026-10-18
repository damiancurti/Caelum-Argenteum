// #250: memoria por cuerpo. Persiste después del efecto para no repetir botín.
class CaelumRedemptionBody : Inventory
{
    int Revision,OriginalFriendPlayer;
    bool OriginalFriendly,AwaitingPlacement;
    bool SavedInvisible,SavedShootable,SavedSolid,SavedNoInteraction,SavedNoBlock,SavedNoSector;
    Actor OriginalMaster;
    CaelumRedemptionEffect Conversion;

    void Remember()
    {
        Revision=CaelumRedemption.REVISION;
        OriginalFriendly=Owner.bFriendly;OriginalFriendPlayer=Owner.FriendPlayer;
        OriginalMaster=Owner.master;
    }

    void Convert(CaelumRedemptionEffect effect)
    {
        Conversion=effect;
        Owner.bFriendly=true;Owner.SetFriendPlayer(effect.Owner.player);Owner.master=effect.Owner;
        Owner.target=null;Owner.LastEnemy=null;
    }

    void HideForPlacement()
    {
        if(AwaitingPlacement || Owner==null)return;
        SavedInvisible=Owner.bInvisible;SavedShootable=Owner.bShootable;
        SavedSolid=Owner.bSolid;SavedNoInteraction=Owner.bNoInteraction;
        SavedNoBlock=Owner.bNOBLOCKMAP;SavedNoSector=Owner.bNOSECTOR;
        AwaitingPlacement=true;
        Owner.bInvisible=true;Owner.bShootable=false;Owner.bSolid=false;Owner.bNoInteraction=true;
        Owner.A_ChangeLinkFlags(1,1);Owner.Vel=(0,0,0);Owner.target=null;Owner.LastEnemy=null;
    }

    void Place(vector3 point)
    {
        if(Owner==null)return;
        Owner.SetOrigin(point,false);
        if(AwaitingPlacement)
        {
            Owner.bInvisible=SavedInvisible;Owner.bShootable=SavedShootable;
            Owner.bSolid=SavedSolid;Owner.bNoInteraction=SavedNoInteraction;
            Owner.A_ChangeLinkFlags(SavedNoBlock?1:0,SavedNoSector?1:0);
        }
        Owner.FindFloorCeiling();Owner.ClearInterpolation();AwaitingPlacement=false;
    }

    void EndConversion()
    {
        Conversion=null;
        if(Owner==null)return;
        if(AwaitingPlacement)Place(Owner.Pos);
        Owner.bFriendly=OriginalFriendly;Owner.FriendPlayer=OriginalFriendPlayer;Owner.master=OriginalMaster;
        Owner.target=null;Owner.LastEnemy=null;
        if(Owner.health>0)
        {
            Owner.health=0;
            if(Owner.player!=null)Owner.player.health=0;
            Owner.Die(null,null,DMG_FORCED,'None');
        }
    }

    override void Tick()
    {
        Super.Tick();
        if(Conversion==null || Owner==null)return;
        if(!Conversion.Alive()){EndConversion();return;}
        if(AwaitingPlacement || Owner.health<=0)return;
        if(Owner.target!=null && !CaelumSummoning.Enemy(CaelumPlayer(Conversion.Owner),Owner.target))
        {Owner.target=null;Owner.LastEnemy=null;}
        let npc=CaelumCombatActor(Owner);
        if(npc!=null && npc.target==null && npc.ForcedSleepTics<=0
            && npc.CombatLucidityPhysicalStunRemaining<=0 && npc.RecoveryPhase==0
            && !CaelumTelekinesisRules.Held(npc) && !CaelumBolas.Restrained(npc)
            && (npc.InStateSequence(npc.CurState,npc.SpawnState)
                || npc.InStateSequence(npc.CurState,npc.FindState("IdleBreathing"))))
            npc.SetStateLabel("See");
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumRedemptionEffect : Inventory
{
    int Revision,RemainingTics,PulseTics;
    double Power,Range;
    Array<Actor> RaisedThisCast;
    Array<CaelumRedemptionBody> Converts;

    bool Alive()
    {return Revision==CaelumRedemption.REVISION && Owner!=null && Owner.health>0 && RemainingTics>0;}

    override void OwnerDied(){Destroy();}

    bool Raised(Actor body)
    {
        for(int i=0;i<RaisedThisCast.Size();i++)if(RaisedThisCast[i]==body)return true;
        return false;
    }

    void PlaceFollowers()
    {
        for(int i=0;i<Converts.Size();i++)
        {
            let bond=Converts[i];
            if(bond==null || bond.Conversion!=self || bond.Owner==null || !bond.AwaitingPlacement)continue;
            if(bond.Owner.health<=0){bond.Place(bond.Owner.Pos);continue;}
            vector2 size=CaelumResurrection.Dimensions(bond.Owner);
            let place=CaelumSummoning.FindPlace(CaelumPlayer(Owner),Owner.Pos,Range,size.X,size.Y);
            if(place.Found)bond.Place(place.Point);
        }
    }

    override void Tick()
    {
        Super.Tick();
        if(!Alive()){Destroy();return;}
        if(--PulseTics<=0)
        {
            PulseTics=TICRATE;PlaceFollowers();CaelumRedemption.Pulse(self);
        }
        if(--RemainingTics<=0)Destroy();
    }

    override void PreTravelled()
    {
        if(!Alive())return;
        for(int i=0;i<Converts.Size();i++)
        {
            let bond=Converts[i];
            if(bond==null || bond.Conversion!=self || bond.Owner==null || bond.Owner.health<=0
                || bond.Owner.player!=null)continue;
            Actor body=bond.Owner;let npc=CaelumCombatActor(body);
            if(npc!=null)
            {
                CaelumDemonService.StopBreath(npc,false,false);
                if(npc.RecoveryGoal!=null){npc.RecoveryGoal.Destroy();npc.RecoveryGoal=null;}
            }
            CaelumBreathing.StopAudio(body);body.A_StopSound(CHAN_7);bond.HideForPlacement();
            body.ChangeStatNum(STAT_TRAVELLING);
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
        }
    }

    override void Travelled()
    {
        for(int i=0;i<Converts.Size();i++)
        {
            let bond=Converts[i];
            if(bond==null || bond.Conversion!=self || bond.Owner==null || !bond.AwaitingPlacement)continue;
            Actor body=bond.Owner;body.ChangeStatNum(STAT_DEFAULT);
            let npc=CaelumCombatActor(body);
            if(npc!=null)npc.ResetMaintenanceForTravel();
            body.SetOrigin(Owner.Pos,false);body.FindFloorCeiling();
            for(Inventory item=body.Inv;item!=null;item=item.Inv)
            {item.ChangeStatNum(STAT_INVENTORY);item.SetOrigin(body.Pos,false);}
            body.target=null;body.LastEnemy=null;body.SetState(body.SpawnState);
        }
        if(Alive())PlaceFollowers();
    }

    override void OnDestroy()
    {
        RemainingTics=0;
        for(int i=0;i<Converts.Size();i++)
            if(Converts[i]!=null && Converts[i].Conversion==self)Converts[i].EndConversion();
        Super.OnDestroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumRedemption : Object play
{
    const REVISION=1;
    const BASE_TOUGHNESS_FACTOR=4.0;

    static clearscope CaelumRedemptionEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumRedemptionEffect(user.FindInventory("CaelumRedemptionEffect"));}

    static clearscope CaelumRedemptionBody Memory(Actor body)
    {return body==null?null:CaelumRedemptionBody(body.FindInventory("CaelumRedemptionBody"));}

    static clearscope bool PreviouslyRaised(Actor body)
    {let bond=Memory(body);return bond!=null && bond.Revision==REVISION;}

    static clearscope bool Pending(Actor body)
    {let bond=Memory(body);return bond!=null && bond.AwaitingPlacement;}

    static CaelumPlayer Commander(Actor body)
    {
        let bond=Memory(body);
        return bond!=null && bond.Conversion!=null && bond.Conversion.Alive()
            ? CaelumPlayer(bond.Conversion.Owner):null;
    }

    static bool Allied(CaelumPlayer caster,Actor body)
    {
        if(caster==null || body==null)return false;
        if(body==caster)return true;
        let principal=Commander(body);
        if(principal!=null)return principal==caster || !deathmatch || principal.IsTeammate(caster);
        return body.player!=null ? (!deathmatch || body.IsTeammate(caster))
            : body.bIsMonster && body.bFriendly && body.IsFriend(caster);
    }

    static bool AllowsDamage(Actor source,Actor victim,Name mod='None')
    {
        // La protección de ataques aliados no convierte caídas/esfuerzos propios en inmunidad.
        if(source==victim && (mod=='CaelumImpact' || mod=='Crush' || mod=='CaelumWeight'
            || mod=='CaelumPressure' || mod=='Drowning'))return true;
        let caster=Commander(source);return caster==null || CaelumSummoning.Enemy(caster,victim);
    }

    static bool Follow(CaelumCombatActor body)
    {
        let caster=Commander(body);if(caster==null || body.target!=null)return false;
        body.A_Look();if(body.target!=null)return false;
        vector2 delta=caster.Pos.XY-body.Pos.XY;double distance=delta.Length();
        double gap=distance-body.Radius-caster.Radius;
        if(gap<=body.Speed)return true;
        body.Angle=body.AngleTo(caster);
        if(!body.ThermalTryMove(body.Pos.XY+delta/distance*Min(body.Speed,gap)))body.ThermalChase(null,null);
        return true;
    }

    static bool InArea(CaelumRedemptionEffect effect,Actor body)
    {return effect!=null && effect.Alive() && body!=null && !Pending(body)
        && (body.Pos-effect.Owner.Pos).Length()<=effect.Range
        && (body==effect.Owner || effect.Owner.CheckSight(body,SF_IGNOREVISIBILITY));}

    static bool ReceivesToughness(CaelumRedemptionEffect effect,Actor body)
    {
        if(body==null || body.health<=0 || !InArea(effect,body) || effect.Raised(body))return false;
        let summoned=CaelumSummonedZupay(body);
        if(summoned!=null && summoned.AwaitingPlacement)return false;
        return Allied(CaelumPlayer(effect.Owner),body);
    }

    static double ToughnessFactor(Actor body)
    {
        double factor=1;
        let it=ThinkerIterator.Create("CaelumRedemptionEffect");CaelumRedemptionEffect effect;
        while((effect=CaelumRedemptionEffect(it.Next()))!=null)
            if(ReceivesToughness(effect,body))factor=Max(factor,BASE_TOUGHNESS_FACTOR*effect.Power);
        return factor;
    }

    static void Pulse(CaelumRedemptionEffect effect)
    {
        let caster=CaelumPlayer(effect.Owner);
        let it=ThinkerIterator.Create("Actor");Actor body;
        Array<Actor> candidates;
        bool archivedPass=false;
        while(true)
        {
            body=Actor(it.Next());
            if(body==null)
            {
                if(archivedPass)break;
                archivedPass=true;it=ThinkerIterator.Create("Actor",CaelumCorpseArchiveData.DORMANT_STAT);continue;
            }
            if(body.health<=0 && body.bCorpse)candidates.Push(body);
        }
        // Resucitar mueve cuerpo e inventario entre listas nativas. No cambiar
        // esas listas mientras ThinkerIterator todavia las esta recorriendo.
        for(int i=0;i<candidates.Size();i++)
        {
            body=candidates[i];if(body==null)continue;
            if(body.health>0 || !body.bCorpse || effect.Raised(body) || !InArea(effect,body))continue;
            let user=CaelumPlayer(body);
            // No reconstruir cadáveres anteriores de un jugador que ya reapareció.
            if(user!=null && (user.player==null || user.player.mo!=user))continue;
            let place=CaelumResurrection.Placement(caster,body,effect.Range);
            if(!place.Found)continue;
            let bond=Memory(body);
            bool originalFriendly=body.bFriendly;int originalFriendPlayer=body.FriendPlayer;
            Actor originalMaster=body.master;
            // Una conversión anterior nunca cambia la identidad original del cuerpo.
            if(bond!=null)
            {body.bFriendly=bond.OriginalFriendly;body.FriendPlayer=bond.OriginalFriendPlayer;body.master=bond.OriginalMaster;}
            bool enemy=CaelumSleepRules.Enemy(caster,body);
            body.bFriendly=originalFriendly;body.FriendPlayer=originalFriendPlayer;body.master=originalMaster;
            if(!CaelumResurrection.Restore(body,place.Point))continue;
            if(bond==null)
            {
                bond=CaelumRedemptionBody(body.GiveInventoryType("CaelumRedemptionBody"));
                if(bond==null)continue;
                bond.Remember();
            }
            effect.RaisedThisCast.Push(body);
            if(enemy)
            {
                bool alreadyOwned=bond.Conversion==effect;
                bond.Convert(effect);if(!alreadyOwned)effect.Converts.Push(bond);
            }
        }
    }

    static void AdvanceJourney(CaelumPlayer user,int elapsed)
    {
        let effect=Status(user);if(effect==null || elapsed<=0)return;
        effect.RemainingTics=Max(0,effect.RemainingTics-elapsed);
        if(!effect.Alive())effect.Destroy();
    }

    static bool Release(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return false;
        let effect=Status(user);bool renewed=effect!=null && effect.RemainingTics>0;
        if(effect==null)effect=CaelumRedemptionEffect(user.GiveInventoryType("CaelumRedemptionEffect"));
        if(effect==null)return false;
        effect.Revision=REVISION;effect.Power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.Range=CaelumClassAbilityRules.Radius(user);
        effect.RemainingTics=Max(effect.RemainingTics,
            int(CaelumClassAbilityRules.EFFECT_SECONDS*effect.Power*TICRATE+0.5));
        effect.RaisedThisCast.Clear();
        if(!renewed)effect.PulseTics=TICRATE;
        Pulse(effect);
        CaelumNotifications.Notify(user,StringTable.Localize("CA_REDEMPTION_CAST",false));
        return true;
    }
}
