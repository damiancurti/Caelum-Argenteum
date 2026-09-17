// Zonas expresamente habilitadas por el mapa. Los muebles no convierten por
// sí mismos un combate o una zona desconocida en un lugar seguro.
class CaelumTimeAdvanceZone : Actor
{
    Default { Radius 224; Height 128; +NOBLOCKMAP +NOGRAVITY +NOTARGET RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumTimeAdvanceState : Inventory
{
    bool Active;
    bool Pumping;
    int LastPumpTic;
    int SimulatedTics;
    int PersonalStepSerial;
    String OriginMap;
    String LastReason;
    CaelumRestState Session;
    Actor Station;

    static CaelumTimeAdvanceState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let advance = CaelumTimeAdvanceState(user.FindInventory("CaelumTimeAdvanceState"));
        if (advance == null && create) advance = CaelumTimeAdvanceState(user.GiveInventoryType("CaelumTimeAdvanceState"));
        return advance;
    }

    static void Halt(CaelumPlayer user)
    {
        let advance = Get(user);
        if (advance != null) { advance.Active = false; advance.Session = null; advance.Station = null; }
    }

    static int StepSerial(CaelumPlayer user)
    {let advance=Get(user);return advance!=null?advance.PersonalStepSerial:0;}

    static bool InSafeZone(CaelumPlayer user)
    {
        if(level.MapName=="MAP01")
        {
            let rest=CaelumRestState.Get(user);
            if(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE && rest.Furniture!=null)return true;
            let station=CaelumCraftingStation(user.ActiveCraftingStationActor);
            return station!=null && station.CraftingRoomGroup>=1 && station.CraftingRoomGroup<=5;
        }
        let it = ThinkerIterator.Create("CaelumTimeAdvanceZone"); CaelumTimeAdvanceZone zone;
        while ((zone = CaelumTimeAdvanceZone(it.Next())) != null)
            if (user.Distance2D(zone) <= zone.Radius && Abs(user.Pos.Z-zone.Pos.Z) <= 16
                && user.CheckSight(zone, SF_IGNOREVISIBILITY)) return true;
        return false;
    }

    static String BlockReason(CaelumPlayer user, bool scanWorld = true)
    {
        if (user == null || user.player == null || user.health <= 0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.DerivedStats == null || (user.player.cheats & CF_PREDICTING)) return "CA_FAST_ACTIVITY";
        for (int i=0; i<MAXPLAYERS; i++) if (playeringame[i] && players[i].mo != user) return "CA_M01_RETURN_SOLO";
        if (CaelumScheduleState.SiegeActive(user, level.MapName)) return "CA_EVENT_SIEGE_INTERRUPT";
        bool resting = CaelumRestState.IsActive(user);
        bool crafting = user.CraftingTaskActive && user.CraftingMenuOpen && user.ActiveCraftingStationActor != null;
        if (!resting && !crafting) return "CA_FAST_ACTIVITY";
        if (crafting && !user.RefreshActiveCraftingStationSession()) return "CA_FAST_ACTIVITY";
        if (user.CombatTimeRemaining > 0 || user.HasActiveConversation() || user.ForcedSleepTics > 0
            || user.PalomoMerchantMenuOpen || user.CombatChannelModeActive || user.StaffCastPending
            || user.WeaponChargeActive || user.WeaponChargedStateActive || user.RangedReloadActive
            || user.WaterLevel != 0 || !user.player.onground || user.Vel.Length() > 0.1) return "CA_FAST_UNSAFE";
        if (user.CurrentHunger <= 10 || user.CurrentThirst <= 10
            || (user.CurrentSleep <= 10 && !CaelumRestState.IsSleeping(user))) return "CA_REST_NEEDS";
        let status = user.ElementalStatus;
        if (status != null && (status.BurnRemaining > 0 || status.PoisonRemaining > 0
            || status.CutRemaining > 0 || status.IsLightningStunned())) return "CA_FAST_UNSAFE";
        if (scanWorld)
        {
            if (!InSafeZone(user)) return "CA_FAST_ZONE";
            // Un efecto nativo ajeno carece de adaptador: no se le regalan horas.
            for (Inventory item=user.Inv; item!=null; item=item.Inv)
                if (Powerup(item)!=null && CaelumRegenerationPower(item)==null) return "CA_FAST_EFFECT";
            let it = ThinkerIterator.Create("Actor"); Actor other;
            while ((other=Actor(it.Next()))!=null)
            {
                if (other==user || (Inventory(other)!=null && Inventory(other).Owner!=null) || other.Distance2D(user)>1024) continue;
                let sleeper = CaelumCombatActor(other);
                if (sleeper != null && sleeper.ForcedSleepTics > 0) return "CA_FAST_UNSAFE";
                // Los bloques en movimiento no tienen adaptador de salto temporal.
                let hazard = CaelumHazardRock(other);
                if (hazard != null && hazard.Released && hazard.Vel.Length() > 0.1)
                    return "CA_FAST_UNSAFE";
                let crusher = CaelumCrusherTrap(other);
                if (crusher != null && crusher.IsMoving()) return "CA_FAST_UNSAFE";
                if (other.bMissile || (other.bIsMonster && other.health>0 && !other.bFriendly))
                    return "CA_FAST_UNSAFE";
            }
        }
        return "";
    }

    static bool Toggle(CaelumPlayer user)
    {
        let advance=Get(user,true); if(advance==null)return false;
        if(advance.Active) { Halt(user); user.A_Print(StringTable.Localize("CA_FAST_OFF",false)); return true; }
        String reason=BlockReason(user);
        if(reason.Length()!=0) { advance.LastReason=reason; user.A_Print(StringTable.Localize(reason,false)); return false; }
        advance.Active=true;advance.Pumping=false;advance.LastPumpTic=-1;advance.SimulatedTics=0;
        advance.OriginMap=level.MapName;advance.Session=CaelumRestState.IsActive(user)?CaelumRestState.Get(user):null;
        advance.Station=advance.Session==null?user.ActiveCraftingStationActor:null;advance.LastReason="";
        user.A_Print(StringTable.Localize("CA_FAST_ON",false));return true;
    }

    static void AdvancePowers(CaelumPlayer user)
    {
        Inventory item=user.Inv;
        while(item!=null)
        {
            Inventory next=item.Inv;
            let power=CaelumRegenerationPower(item);
            if(power!=null) { power.DoEffect(); power.Tick(); }
            item=next;
        }
    }

    static void Pump(CaelumPlayer user)
    {
        let advance=Get(user);
        if(advance==null || !advance.Active || advance.Pumping || advance.LastPumpTic==level.maptime) return;
        advance.LastPumpTic=level.maptime;
        String reason=advance.OriginMap!=level.MapName?"CA_REST_MOVED":BlockReason(user);
        if(reason.Length()!=0)
        { advance.LastReason=reason;Halt(user);user.A_Print(StringTable.Localize(reason,false));return; }
        let clock=CaelumWorldClock.Get(user);if(clock==null){Halt(user);return;}
        let calendar=CaelumCalendarState.Get(user);
        advance.Pumping=true;
        // Máximo un minuto de campaña por imagen (105 tics totales a x105).
        // Subpasos de un tic respetan exactamente umbrales y expiraciones;
        // se devuelve el control al motor entre lotes para cancelar/pausar.
        for(int i=1;i<CaelumWorldClock.TicsPerHour()/60 && advance.Active;i++)
        {
            if(advance.Session!=null && (!CaelumRestState.IsActive(user) || CaelumRestState.Get(user)!=advance.Session)) { Halt(user);break; }
            if(advance.Station!=null && (!user.CraftingTaskActive || user.ActiveCraftingStationActor!=advance.Station)) { Halt(user);break; }
            reason=BlockReason(user,false);
            if(reason.Length()!=0) {advance.LastReason=reason;Halt(user);break;}
            // Cada lugar conserva su escala de calendario durante el avance.
            // El serial evita acreditar dos veces un paso de descanso.
            advance.PersonalStepSerial=advance.PersonalStepSerial==2147483647?0:advance.PersonalStepSerial+1;
            clock.AdvanceOnMap(level.MapName);
            CaelumWeatherState.Sync(user,clock,calendar);
            AdvancePowers(user);
            user.UpdateCraftingTask();
            user.AdvancePersonalTimeTic();
            user.HUDAbilitySuccessRemaining=Max(0.0,user.HUDAbilitySuccessRemaining-1.0/TICRATE);
            advance.SimulatedTics++;
            CaelumRestState.Advance(user);
            if(!user.CraftingTaskActive && advance.Station!=null) Halt(user);
        }
        advance.Pumping=false;
    }

    Default
    {
        Inventory.Amount 1; Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
