// Descanso y avance comparten seguridad y contabilidad del daño periódico.
class CaelumRestSafety : Object play
{
    const DAMAGE_REVISION=1;

    static void EnsureDamageState(CaelumPlayer user)
    {
        if(user==null || user.RestDamageRevision>=DAMAGE_REVISION)return;
        // Una partida anterior no identifica el origen del dolor pendiente.
        // Conservarlo como bloqueo hasta vencer su propio reloj no periódico.
        user.RestPeriodicPainRemaining=0;
        user.RestNonPeriodicPainRemaining=Max(0.0,user.PainImmobilizationRemaining);
        user.RestDamageRevision=DAMAGE_REVISION;
    }

    static bool PeriodicPainOnly(CaelumPlayer user)
    {
        EnsureDamageState(user);
        return user!=null && user.PainImmobilizationRemaining>0
            && user.RestNonPeriodicPainRemaining<=0
            && user.RestPeriodicPainRemaining>=user.PainImmobilizationRemaining;
    }

    static void RecordPain(CaelumPlayer user,double duration,bool periodic)
    {
        EnsureDamageState(user);
        // Una dosis periódica más larga no reclasifica el dolor de un golpe
        // o una caída que todavía no terminó. Ambos conservan su propio reloj.
        if(periodic)user.RestPeriodicPainRemaining=Max(user.RestPeriodicPainRemaining,duration);
        else user.RestNonPeriodicPainRemaining=Max(user.RestNonPeriodicPainRemaining,duration);
    }

    static void PeriodicLoss(CaelumPlayer user,int lost)
    {
        if(user==null || lost<=0)return;
        // Restar sólo esta pérdida conserva cualquier daño ajeno pendiente
        // de validar. Curación posterior no convierte un ataque en daño DOT.
        let rest=CaelumRestState.Get(user);
        if(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE)rest.LastHealth-=lost;
        let skip=CaelumTimeSkipState.Get(user);
        if(skip!=null && skip.Active)skip.LastHealth-=lost;
    }

    static void Interrupt(CaelumPlayer user,String reason)
    {
        if(user==null)return;
        CaelumTimeAdvanceState.Halt(user);
        CaelumRestState.Interrupt(user,reason);
        if(CaelumTimeSkipState.IsActive(user))CaelumTimeSkipState.FinishSkip(user,reason);
    }

    static bool EnemyNear(CaelumPlayer user,Actor anchor)
    {
        if(user==null || anchor==null)return false;
        let nearby=BlockThingsIterator.Create(anchor,CaelumConstants.REST_HOSTILE_RADIUS);
        while(nearby.Next())
        {
            let other=nearby.thing;
            if(CaelumSummoning.Enemy(user,other)
                && anchor.Distance2D(other)<=CaelumConstants.REST_HOSTILE_RADIUS
                && anchor.CheckSight(other,SF_IGNOREVISIBILITY))return true;
        }
        let population=CaelumPopulationState.Get();
        if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)
        {
            let entry=population.UnlinkedGuards[i];
            let other=entry!=null?entry.Body:null;
            if(CaelumSummoning.Enemy(user,other)
                && anchor.Distance2D(other)<=CaelumConstants.REST_HOSTILE_RADIUS
                && anchor.CheckSight(other,SF_IGNOREVISIBILITY))return true;
        }
        return false;
    }

    static bool PersonalSubstep(CaelumPlayer user)
    {
        let advance=CaelumTimeAdvanceState.Get(user);
        let skip=CaelumTimeSkipState.Get(user);
        return (advance!=null && advance.Pumping) || (skip!=null && skip.Pumping);
    }
    static String BlockReason(CaelumPlayer user,bool allowTimelessFurniture=false,bool crafting=false,bool scan=true)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.player.playerstate != PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)) return "CA_REST_UNAVAILABLE";
        if(!CaelumPropertyRules.ResidenceAllowed(user))return "CA_PROPERTY_NO_RESIDENCE";
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo != user) return "CA_M01_RETURN_SOLO";
        let active=CaelumRestState.Get(user);
        let skip=CaelumTimeSkipState.Get(user);
        bool anchored=skip!=null && skip.Open && skip.OriginMap==level.MapName
            && skip.AnchorFurniture!=null && skip.AnchorFurniture.CanReach(user);
        let station=CaelumCraftingStation(user.ActiveCraftingStationActor);
        bool timelessCraft=crafting && level.MapName=="MAP01" && station!=null
            && ((station.CraftingRoomGroup>=1 && station.CraftingRoomGroup<=5) || station is 'CaelumKitchenStation')
            && station.CanReachFrom(user) && (user.Pos-station.Pos).Length()<=CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE;
        bool timelessReading=level.MapName=="MAP01" && (CaelumRecipeSession.Working(user)
            || (skip!=null && skip.Open && skip.OriginMap==level.MapName
                && CaelumRecipeSession.CanReach(user,skip.Station)));
        if (CaelumWorldCatalogue.IsLimboMap(level.MapName) && !allowTimelessFurniture && !anchored && !timelessCraft && !timelessReading && !CaelumCampTask.Attended(user) && !CaelumCampCooking.Attended(user)
            && !(active!=null && active.Status==CaelumRestRules.STATUS_ACTIVE && active.Untimed && active.Furniture!=null))
            return "CA_REST_TIMELESS";
        // La nube activa impide tanto descansar como acelerar; decisión #325.
        if(CaelumArcaneCloud.Active(user))return "CA_REST_CLOUD";
        if (user.CombatTimeRemaining > 0.0) return "CA_REST_COMBAT";
        if (CaelumScheduleState.SiegeActive(user, level.MapName)) return "CA_EVENT_SIEGE_INTERRUPT";
        if (user.HasActiveConversation() || user.PalomoMerchantMenuOpen || (!crafting && (user.CraftingMenuOpen || user.CraftingTaskActive || CaelumHygienePose.Active(user))) || user.EquipmentMenuOpen || user.CombatChannelModeActive
            || user.StaffCastPending || user.WeaponChargeActive || user.WeaponChargedStateActive
            || user.RangedReloadActive || user.CombatBlockModeActive || user.DebugShieldBlocking
            || (user.IsPhysicallyImmobilized(PeriodicPainOnly(user)) && !((CaelumRestState.IsSleeping(user) || (skip!=null && skip.Open && skip.Sleeping
                && skip.OriginMap==level.MapName && (user.Pos-skip.OriginPosition).Length()<=4))
                && (user.PainImmobilizationRemaining <= 0 || PeriodicPainOnly(user))
                && (user.ElementalStatus == null || !user.ElementalStatus.IsLightningStunned())))
            || (user.player.cheats & (CF_TOTALLYFROZEN | CF_FROZEN)))
            return "CA_REST_BUSY";
        if (!user.player.onground || user.WaterLevel != 0
            || user.Vel.X * user.Vel.X + user.Vel.Y * user.Vel.Y > 0.01
            || Abs(user.Vel.Z) > 0.01) return "CA_REST_GROUND";
        if (!user.SurvivalResourcesInitialized || user.DerivedStats == null) return "CA_REST_UNAVAILABLE";
        let record = user.GetPersistentCharacterState(false);
        let clock = CaelumWorldClock.Get(user);
        let journey = CaelumJourneyState.Get(user);
        if (record == null || !record.ProfileCommitted || record.WorldPendingConnection != 0
            || clock == null || (journey != null && journey.Status == CaelumJourneyState.STATUS_DEPARTED))
            return "CA_REST_BUSY";
        if (user.CurrentHunger <= CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD
            || user.CurrentThirst <= CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD)
            return "CA_REST_NEEDS";
        if(scan && EnemyNear(user,user))return "CA_REST_ENEMY";
        if(scan)for(Inventory item=user.Inv;item!=null;item=item.Inv)
            if(Powerup(item)!=null && CaelumRegenerationPower(item)==null
                && CaelumTarotFlight(item)==null && CaelumArcaneCloudFlight(item)==null)return "CA_REST_EFFECT";
        return "";
    }

}
