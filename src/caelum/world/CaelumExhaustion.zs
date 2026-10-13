// Agotamiento fisiológico: dueño serializado en RestState, independiente del hechizo.
class CaelumExhaustion : Object play
{
    const RELEASE_ABOVE = CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD;
    static clearscope bool Active(CaelumPlayer user)
    {
        let rest=user==null?null:CaelumRestState(user.FindInventory("CaelumRestState"));
        return user!=null && user.health>0 && rest!=null && rest.Exhaustion
            && rest.Status==CaelumRestRules.STATUS_ACTIVE;
    }
    static clearscope bool Locked(CaelumPlayer user)
    {return Active(user) && user.CurrentSleep<=RELEASE_ABOVE;}

    static void DropSupport(CaelumPlayer user,CaelumRestState rest)
    {
        if(user.WorldOffset==rest.AppliedWorldOffset)user.WorldOffset=rest.OriginalWorldOffset;
        let furniture=rest.Furniture;
        if(furniture!=null && furniture.Occupant==user)
        {
            // No usar Release: busca una posición de salida y trasladaría al cuerpo.
            furniture.Occupant=null;furniture.RestoreSolid();
        }
        rest.Furniture=null;rest.UsesFurniture=false;
        rest.AppliedWorldOffset=user.WorldOffset;
    }
    static void Sync(CaelumPlayer user)
    {
        if(user==null || user.player==null || (user.player.cheats&CF_PREDICTING)
            || user.health<=0 || user.player.playerstate!=PST_LIVE
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || !user.SurvivalResourcesInitialized)return;
        let rest=CaelumRestState.Get(user,true);
        // Los campos ausentes valen cero; no se reinician reservas ni sesiones.
        if(rest.ExhaustionRevision<1)rest.ExhaustionRevision=1;
        if(!rest.Exhaustion && user.CurrentSleep<=0)Begin(user,rest);
        if(!Active(user))return;
        if(rest.OriginMap!=level.MapName)
        {
            DropSupport(user,rest);rest.ReleaseView(user);rest.ViewInitialized=false;
            rest.OriginMap=level.MapName;rest.LastUntimedTic=level.maptime-1;
            rest.LastUntimedStepSerial=CaelumTimeAdvanceState.StepSerial(user);
            rest.ProvisionContext=-1;rest.ProvisionBlocked=0;
        }
        if(rest.Furniture!=null && (!rest.Furniture.SupportsRest(user)
            || (rest.Furniture.Pos-user.Pos).Length()>4))DropSupport(user,rest);
        rest.OriginPosition=user.Pos;
        rest.LastHealth=user.health;
        if(!Locked(user))rest.ExhaustionLockNoticeShown=false;
    }
    static void Begin(CaelumPlayer user,CaelumRestState rest)
    {
        bool supported=rest.Status==CaelumRestRules.STATUS_ACTIVE && rest.Mode==CaelumRestRules.MODE_SLEEP
            && rest.OriginMap==level.MapName && rest.Furniture!=null
            && rest.Furniture.SupportsRest(user) && (rest.Furniture.Pos-user.Pos).Length()<=4;
        if(!supported)DropSupport(user,rest);
        CaelumTimeAdvanceState.Halt(user);
        CaelumTimeSkipState.FinishSkip(user,"CA_SKIP_CANCELLED",true);
        CaelumJourneyPlan.Cancel(user);
        user.CloseCraftingStationSession();user.EquipmentMenuOpen=false;user.PalomoMerchantMenuOpen=false;
        let preview=CaelumChestPreviewState.Get(user);if(preview!=null)preview.Close();
        user.StopSealChannel(true);user.CancelCombatBlockMode();user.CancelRangedReload();user.CancelWeaponCharge();
        if(user.StaffCastPending)user.CancelPendingStaffCast(false);
        rest.Exhaustion=true;rest.ExhaustionRevision=1;rest.ExhaustionLockNoticeShown=false;
        rest.Status=CaelumRestRules.STATUS_ACTIVE;rest.Mode=CaelumRestRules.MODE_SLEEP;
        rest.Untimed=true;rest.RequestedTics=0;rest.ElapsedTics=0;
        rest.OriginMap=level.MapName;rest.OriginPosition=user.Pos;rest.LastHealth=user.health;
        rest.InputArmed=false;rest.ResultKey="";
        if(!supported)
        {
            rest.EntryPosition=user.Pos;rest.EntryAngle=user.Angle;rest.EntryPitch=user.Pitch;
            rest.HasEntryView=true;rest.OriginalWorldOffset=user.WorldOffset;rest.AppliedWorldOffset=user.WorldOffset;
        }
        rest.FacingAngle=user.Angle;rest.PoseFacingFixed=true;
        rest.AutoEating=true;rest.AutoDrinking=true;rest.ProvisionRevision=1;rest.ProvisionContext=-1;
        rest.ProvisionBlocked=0;rest.DiningTable=null;
        let clock=CaelumWorldClock.Get(user);
        if(clock!=null){rest.LastClockDays=clock.CompletedDays;rest.LastClockDayTics=clock.DayTics;}
        rest.LastUntimedTic=level.maptime;rest.LastUntimedStepSerial=CaelumTimeAdvanceState.StepSerial(user);
        // La pose cambia ya; ni posición, velocidad, colisión, gravedad ni agua.
        user.SetState(user.FindState("RestLying"));rest.EnsureView(user);
        CaelumNotifications.Notify(user,StringTable.Localize("CA_EXHAUSTION_START",false));
        user.PersistCharacterState();
    }
    static void NotifyLocked(CaelumPlayer user)
    {
        let rest=CaelumRestState.Get(user);if(rest==null || rest.ExhaustionLockNoticeShown)return;
        rest.ExhaustionLockNoticeShown=true;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_EXHAUSTION_LOCK",false));
    }
}
