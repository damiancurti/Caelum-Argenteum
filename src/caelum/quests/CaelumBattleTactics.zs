// Estado de campaña compartido por el reloj viajero, sin punteros al hub ausente.
class CaelumBattleTactics : Object play
{
    int Revision;
    bool IntelligenceDelivered;
    CaelumCooperativeObjective Delivery,DeliveryPaid;

    static CaelumBattleTactics Get(CaelumPlayer user,bool create=false)
    {
        let clock=user==null?null:CaelumWorldClock(user.FindInventory('CaelumWorldClock'));
        let world=clock==null?null:clock.CampaignQuests;
        if(create)world=CaelumCooperativeQuests.Get(user);
        if(world==null)return null;
        if(create && world.BattleTactics==null)
        {world.BattleTactics=new('CaelumBattleTactics');world.BattleTactics.Revision=CaelumBattleTacticsData.REVISION;}
        return world.BattleTactics;
    }

    static String Prepare(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return "CA_TACTICS_UNAVAILABLE";
        let record=user.GetPersistentCharacterState(false);
        if(record==null || record.PortPrisonerAccountMask==0)return "CA_TACTICS_NO_INTELLIGENCE";
        let tactics=Get(user,true);if(tactics==null)return "CA_TACTICS_UNAVAILABLE";
        if(tactics.IntelligenceDelivered)return "CA_TACTICS_PREPARED";
        let port=CaelumPortSiege.Get();
        if(CaelumCityWorld.SiegeDue() || record.PortSiegeNarrativeStarted
            || (port!=null && port.SiegeStarted))return "CA_TACTICS_TOO_LATE";
        tactics.IntelligenceDelivered=true;
        if(port!=null && port.Reinforcements!=null)ApplyPreparation(port);
        return "CA_TACTICS_PREPARED";
    }

    static void ApplyPreparation(CaelumPortSiege port)
    {
        if(port==null || port.Reinforcements==null)return;
        let reserve=port.Reinforcements;
        if(!reserve.Enabled || reserve.TacticsRevision>=CaelumBattleTacticsData.REVISION)return;
        // Se puede entregar en el cuartel antes de que MAP03 exista en el hub.
        let tactics=Get(CaelumWorldClockTicker.CampaignOwner());
        if(tactics==null || !tactics.IntelligenceDelivered)return;
        if(reserve.Successful==0 && reserve.Pending==0)
        {
            reserve.Withheld=Min(reserve.Remaining,
                CaelumBattleTacticsData.PREPARATION_GROUPS*CaelumReinforcementData.GROUP_SIZE);
            reserve.Remaining-=reserve.Withheld;
        }
        reserve.TacticsRevision=CaelumBattleTacticsData.REVISION;
    }

    static bool Deliverable(CaelumHostileMachine machine)
    {
        if(machine==null)return false;
        machine.EnsureMachine();
        return machine.Captured && machine.CapturedIntact && machine.Operational()
            && machine.OwnerFaction==CaelumMilitaryData.GUARD_FACTION
            && machine.Structure!=null && machine.Structure.health==machine.Structure.StructuralMaximum;
    }

    static String Deliver(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return "CA_TACTICS_UNAVAILABLE";
        let tactics=Get(user,true);if(tactics==null)return "CA_TACTICS_UNAVAILABLE";
        if(tactics.Delivery!=null){Claim(user);return "CA_TACTICS_DELIVERED";}
        let port=CaelumPortSiege.Get();
        if(level.MapName!="MAP03" || port==null)return "CA_TACTICS_CITY_REPORT";
        // Sólo las doce identidades originales; las construcciones no son botín.
        for(int i=0;i<port.Machines.Size();i++)if(Deliverable(port.Machines[i]))
        {
            tactics.Delivery=new('CaelumCooperativeObjective');tactics.Delivery.Capture();
            tactics.DeliveryPaid=new('CaelumCooperativeObjective');tactics.DeliveryPaid.EnsureIdentity();
            for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])Claim(CaelumPlayer(players[p].mo));
            return "CA_TACTICS_DELIVERED";
        }
        return "CA_TACTICS_NO_MACHINE";
    }

    static void Claim(CaelumPlayer user)
    {
        if(!CaelumWorldClockTicker.Ready(user))return;
        let tactics=Get(user);if(tactics==null || tactics.Delivery==null || tactics.DeliveryPaid==null)return;
        let record=user.GetPersistentCharacterState(false);
        if(!tactics.Delivery.Contains(record) || tactics.DeliveryPaid.Contains(record))return;
        // Reclamar primero impide duplicar al repetir diálogo o importar una ficha.
        tactics.DeliveryPaid.EligibleIdentities.Push(record.LawfulIdentity);
        record.ChangeFactionReputation(CaelumMilitaryData.GUARD_FACTION,CaelumBattleTacticsData.DELIVERY_REPUTATION);
        user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
    }
}

class CaelumBattlePreparationAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);if(CaelumPortStory.GuardSpeaker(user)==null)return false;
        CaelumNotifications.Notify(user,StringTable.Localize(CaelumBattleTactics.Prepare(user),false));return true;
    }
}
class CaelumBattleDeliveryAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user=CaelumPlayer(Owner);if(CaelumPortStory.GuardSpeaker(user)==null)return false;
        CaelumNotifications.Notify(user,StringTable.Localize(CaelumBattleTactics.Deliver(user),false));return true;
    }
}
