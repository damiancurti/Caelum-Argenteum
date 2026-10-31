// La casa y su deuda pertenecen al mundo; no se multiplican por participante.
class CaelumCooperativeHouse : Object play
{
    static void Ensure(CaelumPropertyRecord property)
    {
        if(property==null || property.CooperativeRevision>=1)return;
        if(property.Holder==null){property.CooperativeRevision=1;return;}
        // Una restitución anterior no era una compra. Sólo su titular original
        // conserva la elegibilidad; actualizar no añade a los demás jugadores.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(user))continue;
            if(!CaelumLockRules.SameTitle(property.Holder,CaelumLockRules.Character(user)))continue;
            let record=user.GetPersistentCharacterState(false);
            if(property.Purchased && record.HouseRestitutionConfirmed)
            {
                property.Restitution=new("CaelumCooperativeObjective");property.Restitution.Eligible.Push(record);
                property.CoHolders.Push(property.Holder);property.RefundHolder=property.Holder;
                property.RefundCopper=record.HouseRefundPending;
                property.RefundPaid=record.QuestRewardClaimed[CaelumConstants.QUEST_FIND_HOUSE];
            }
            property.CooperativeRevision=1;return;
        }
    }
    static bool Restore(CaelumPlayer user,CaelumPropertyRecord property)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || property==null)return false;
        Ensure(property);if(property.CooperativeRevision<1)return false;
        let world=CaelumCooperativeQuests.Get(user);if(world==null)return false;world.House=property;
        if(property.Restitution!=null)
        {
            if(!CaelumPropertyRules.Holds(user,property))return false;
            Claim(user);return true;
        }
        // Mantiene la protección del contrato: otro presente puede investigar,
        // pero no se reasigna una vivienda cuyo titular está ausente.
        bool holderPresent=property.Holder==null;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let member=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(member))continue;
            let title=CaelumLockRules.Character(member,true);if(title==null)return false;
            if(CaelumLockRules.SameTitle(property.Holder,title))holderPresent=true;
        }
        if(!holderPresent)return false;
        property.RefundHolder=property.Holder;
        property.RefundCopper=property.Holder==null?0:property.RentPayments*CaelumPropertyData.RENT_COPPER
            +(property.Purchased?CaelumPropertyData.PURCHASE_COPPER:0);
        property.RefundPaid=property.RefundCopper==0;
        property.Restitution=new("CaelumCooperativeObjective");property.Restitution.Capture();
        if(property.Holder==null)property.Holder=CaelumLockRules.Character(user,true);
        property.Purchased=true;
        int quest=CaelumConstants.QUEST_FIND_HOUSE;
        for(int i=0;i<property.Restitution.Eligible.Size();i++)
        {
            let record=property.Restitution.Eligible[i];property.CoHolders.Push(record.LawfulIdentity);
            record.HouseRestitutionConfirmed=true;
            record.HouseRefundPending=CaelumLockRules.SameTitle(record.LawfulIdentity,property.RefundHolder)?property.RefundCopper:0;
            CaelumQuestTransitions.ObserveObjective(record,quest,0,1,1);
            CaelumQuestTransitions.ObserveObjective(record,quest,1,1,1);
            CaelumQuestTransitions.ObserveState(record,quest,CaelumConstants.QUEST_STATE_COMPLETED,3);
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let member=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(member))continue;
            Claim(member);member.RefreshSocialJournalSnapshot();CaelumRentalAgent.Sync(member);member.PersistCharacterState();
        }
        return true;
    }
    static bool Claim(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return false;
        let property=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE);Ensure(property);
        if(property==null || property.Restitution==null || !CaelumPropertyRules.Holds(user,property))return false;
        let record=user.GetPersistentCharacterState(false);if(record==null)return false;
        int quest=CaelumConstants.QUEST_FIND_HOUSE;
        bool payer=CaelumLockRules.SameTitle(property.RefundHolder,record.LawfulIdentity);
        bool changed=!record.QuestRewardClaimed[quest];
        record.HouseRestitutionConfirmed=true;
        if(payer && !property.RefundPaid)
        {
            if(!CaelumPortQuests.CreditRefund(user,property.RefundCopper))return false;
            property.RefundPaid=true;changed=true;
        }
        record.HouseRefundPending=0;record.QuestRewardClaimed[quest]=true;
        if(changed){user.RefreshSocialJournalSnapshot();user.PersistCharacterState();}
        return changed;
    }
}
