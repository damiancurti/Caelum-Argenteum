// #250: restauración del mismo cuerpo, sin recrear perfil, equipo ni suministros.
class CaelumResurrection : Object play
{
    static vector2 Dimensions(Actor body)
    {
        let user=CaelumPlayer(body);
        if(user!=null && user.DerivedStats!=null)
            return (user.DerivedStats.ActorRadius,user.DerivedStats.ActorHeight);
        let shape=GetDefaultByType(body.GetClass());return (shape.Radius,shape.Height);
    }

    static CaelumSummoningPlace Placement(CaelumPlayer caster,Actor body,double range)
    {
        vector2 size=Dimensions(body);
        bool noBlock=body.bNOBLOCKMAP,noSector=body.bNOSECTOR;
        body.A_ChangeLinkFlags(1,1);
        let place=CaelumSummoning.FindPlace(caster,body.Pos,range,size.X,size.Y);
        body.A_ChangeLinkFlags(noBlock?1:0,noSector?1:0);
        return place;
    }

    static void ClearNegative(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        let old=user!=null?user.ElementalStatus:npc!=null?npc.ElementalStatus:null;
        if(old!=null)
        {
            if(old.BurnVisual!=null)old.BurnVisual.Destroy();
            if(old.PoisonVisual!=null)old.PoisonVisual.Destroy();
            if(old.FreezeVisual!=null)old.FreezeVisual.Destroy();
            if(old.LightningVisual!=null)old.LightningVisual.Destroy();
        }
        if(old==null)old=new("CaelumElementalStatus");
        old.RefreshResistance(body);
        // Dureza puede convertir una dosis en curación: conservar ese beneficio.
        for(int i=0;i<3;i++)if(old.ResponseFactors[i]>=0)
        {old.BaseRemaining[i]=0;old.HealthFraction[i]=0;old.PulseSeconds[i]=0;old.SetRemaining(i,0);}
        old.BurnVisual=old.PoisonVisual=old.FreezeVisual=old.LightningVisual=null;
        old.BurnVisualRemaining=old.PoisonVisualRemaining=0;
        old.ClearBurnHeat();
        old.CutRemaining=old.FreezeRemaining=old.DazzleRemaining=0;
        old.EarthPenaltyRemaining=old.LightningStunRemaining=0;
        let cry=CaelumBattleCry.Status(body);if(cry!=null)cry.Destroy();
        let bolas=CaelumBolas.Binding(body);if(bolas!=null)bolas.Resolve(false);
        let hold=CaelumTelekinesisRules.Binding(body);
        if(hold!=null && hold.Body==body && hold.Caster!=null && hold.Caster.RacialAbility==hold)
            CaelumRacialAbilityRules.Deactivate(hold.Caster);
        CaelumUtilityStaff.EndEmission(body);
        CaelumSleepRules.Wake(body);
        let thermal=CaelumThermalBody.Get(body);
        if(thermal!=null)
        {
            thermal.Exposure=0;thermal.DamageRemainder=0;thermal.Severity=0;
            // NPCStep no simula cuerpos muertos. Resucitar nunca debe cobrar
            // de golpe ese intervalo, estuviera el cadaver archivado o visible.
            if(npc!=null)
            {
                thermal.RuntimeReady=false;thermal.SourceMap="";
                thermal.PendingActivityJoules=0;thermal.PendingFirearmJoules=0;
                thermal.PropelledVelocity=(0,0);thermal.LocalMotionMps=0;
            }
        }
        if(user!=null)
        {
            user.ElementalStatus=old;
            user.ForcedSleepTics=0;user.SpellSleep=null;
            user.LucidityPhysicalStunRemaining=0;user.PainImmobilizationRemaining=0;
            user.RestPeriodicPainRemaining=user.RestNonPeriodicPainRemaining=0;
            user.SurvivalDamageAccumulator=0;
            CaelumClassAbilityRules.Cancel(user);CaelumRacialAbilityRules.Deactivate(user);
            user.CancelCombatBlockMode();user.CancelRangedAim();user.CancelRangedReload();
            user.CancelWeaponCharge();user.StopSealChannel(true,false);
            user.PhysicalAttackPending=false;user.CancelPendingStaffCast(false);
        }
        if(npc!=null)
        {
            npc.ElementalStatus=old;
            npc.ForcedSleepTics=0;npc.SpellSleep=null;npc.CombatLucidityPhysicalStunRemaining=0;
            npc.EndResourceRecovery();npc.AttackResourceWaiting=false;
            CaelumDemonService.StopBreath(npc,false,false);
            let bull=CaelumBull(npc);if(bull!=null)bull.StopBullCharge();
            let boss=CaelumZupayColossus(npc);
            if(boss!=null)
            {
                boss.SewerFleeing=false;
                if(boss.SewerEscapeTarget!=null){boss.SewerEscapeTarget.Destroy();boss.SewerEscapeTarget=null;}
            }
        }
    }

    static bool Restore(Actor body,vector3 point)
    {
        if(body==null || body.health>0 || !body.bCorpse)return false;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        // El jugador actual usa la API nativa que restaura control y cámara.
        if(user!=null && (user.player==null || user.player.mo!=user))return false;
        if(user!=null)
        {
            // Una resurrección en el mismo tic no debe esquivar la limpieza
            // que estos beneficios realizan al observar la muerte del dueño.
            Inventory effect=CaelumSummoning.Status(user);if(effect!=null)effect.Destroy();
            effect=CaelumMiracle.Status(user);if(effect!=null)effect.Destroy();
            effect=CaelumRally.Status(user);if(effect!=null)effect.Destroy();
            effect=CaelumSurvivalInstinct.Status(user);if(effect!=null)effect.Destroy();
            effect=CaelumFormationBreaker.Status(user);
            if(effect!=null){CaelumFormationBreaker.EndDash(user);effect.Destroy();}
        }
        int monsters=level.total_monsters;
        bool friendly=body.bFriendly;int friendPlayer=body.FriendPlayer;
        Actor master=body.master;
        CaelumCorpseArchive.Recall(body);
        body.SetOrigin(point,false);
        if(user!=null){if(!user.player.Resurrect())return false;}
        else body.Revive();
        level.total_monsters=monsters;
        body.bFriendly=friendly;body.FriendPlayer=friendPlayer;body.master=master;
        // No repetir el recuento de una muerte ya registrada.
        body.bCountKill=false;
        vector2 size=Dimensions(body);body.A_SetSize(size.X,size.Y);
        body.FindFloorCeiling();body.ClearInterpolation();body.Vel=(0,0,0);
        ClearNegative(body);
        if(user!=null)
        {
            user.health=user.player.health=user.CaelumMaximumHealth;
            user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.CurrentAir=user.DerivedStats.MaximumAir;
            user.CurrentLucidity=CaelumConstants.MAXIMUM_LUCIDITY;
            user.UpdateHealthStateEffects();user.UpdateLucidityState();
            user.PersistCharacterState();
        }
        else if(npc!=null)
        {
            npc.health=npc.CombatMaximumHealth;
            npc.CurrentCombatAnima=npc.MaximumCombatAnima;
            npc.CurrentCombatAir=npc.MaximumCombatAir;
            npc.CurrentCombatLucidity=CaelumConstants.MAXIMUM_LUCIDITY;
            npc.UpdateCombatHealthEffects();npc.UpdateActorLucidityState();
        }
        body.target=null;body.LastEnemy=null;body.SetState(body.SpawnState);
        return true;
    }
}
