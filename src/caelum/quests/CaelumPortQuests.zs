class CaelumPortQuests : Object play
{
    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record==null)return;
        record.EnsureQuestStateInitialized();
        if(record.PortQuestRevision<CaelumPortQuestData.REVISION)record.PortQuestRevision=CaelumPortQuestData.REVISION;
    }
    static bool Begin(CaelumPlayer user,int quest)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || !CaelumPortQuestData.Defined(quest))return false;
        let record=user.GetPersistentCharacterState(false);if(record==null)return false;Ensure(record);
        int state=record.QuestState[quest];
        if(state!=CaelumConstants.QUEST_STATE_UNDISCOVERED && state!=CaelumConstants.QUEST_STATE_ABANDONED)return false;
        CaelumQuestTransitions.ObserveState(record,quest,CaelumConstants.QUEST_STATE_ACTIVE,Max(1,record.QuestStage[quest]));
        Observe(user);return true;
    }
    static bool Abandon(CaelumPersistentCharacterState record,int quest)
    {
        return CaelumPortQuestData.Defined(quest) && CaelumQuestTransitions.TryState(record,quest,
            CaelumConstants.QUEST_STATE_ACTIVE,CaelumConstants.QUEST_STATE_ABANDONED,record==null?0:record.QuestStage[quest]);
    }
    static void Observe(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let record=user.GetPersistentCharacterState(false);if(record==null)return;Ensure(record);
        bool changed=false;
        int house=CaelumConstants.QUEST_FIND_HOUSE;
        if(record.QuestState[house]==CaelumConstants.QUEST_STATE_ACTIVE)
        {
            bool recognized=CaelumQuestRequirements.Matches(record,CaelumQuestRequirements.QUEST_STATE,
                CaelumConstants.QUEST_GUARD_CAPTAIN,CaelumConstants.QUEST_STATE_COMPLETED);
            changed=CaelumQuestTransitions.ObserveObjective(record,house,0,recognized?1:0,1)||changed;
            changed=CaelumQuestTransitions.ObserveObjective(record,house,1,record.HouseRestitutionConfirmed?1:0,1)||changed;
            changed=CaelumQuestTransitions.ObserveState(record,house,
                record.HouseRestitutionConfirmed?CaelumConstants.QUEST_STATE_COMPLETED:CaelumConstants.QUEST_STATE_ACTIVE,
                record.HouseRestitutionConfirmed?3:recognized?2:1)||changed;
        }
        int siege=CaelumConstants.QUEST_INVESTIGATE_SIEGE;
        if(record.QuestState[siege]==CaelumConstants.QUEST_STATE_ACTIVE)
        {
            int required=record.PortSurvivorsMask;
            int target=1+CaelumPortQuestData.Count(required);
            int progress=(record.PortGuardAccountHeard?1:0)+CaelumPortQuestData.Count(record.PortPrisonerAccountMask&required);
            changed=CaelumQuestTransitions.ObserveObjective(record,siege,0,progress,target)||changed;
            if(progress==target)
            {
                record.PortInvestigationRequiredMask=required;
                record.QuestRewardClaimed[siege]=true; // La recompensa es la información ya registrada.
                changed=CaelumQuestTransitions.ObserveState(record,siege,CaelumConstants.QUEST_STATE_COMPLETED,2)||changed;
            }
        }
        if(changed)user.RefreshSocialJournalSnapshot();
    }
    static void AccountHeard(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        if(record.QuestState[CaelumConstants.QUEST_INVESTIGATE_SIEGE]==CaelumConstants.QUEST_STATE_UNDISCOVERED)
            Begin(user,CaelumConstants.QUEST_INVESTIGATE_SIEGE);
        else Observe(user);
    }
    static bool VerifyHouse(CaelumPlayer user)
    {
        if(!CaelumRentalAgent.ValidSpeaker(user))return false;
        let record=user.GetPersistentCharacterState(false);if(record==null)return false;Ensure(record);
        int quest=CaelumConstants.QUEST_FIND_HOUSE;
        if(record.QuestState[quest]!=CaelumConstants.QUEST_STATE_ACTIVE && record.QuestState[quest]!=CaelumConstants.QUEST_STATE_COMPLETED)return false;
        if(!CaelumQuestRequirements.Matches(record,CaelumQuestRequirements.QUEST_STATE,
            CaelumConstants.QUEST_GUARD_CAPTAIN,CaelumConstants.QUEST_STATE_COMPLETED))return false;
        let property=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE,true);if(property==null)return false;
        if(property.Holder!=null && !CaelumPropertyRules.Holds(user,property))return false;
        if(!record.HouseRestitutionConfirmed)
        {
            let title=CaelumLockRules.Character(user,true);if(title==null)return false;
            // El registro antiguo conserva compra y cantidad real de alquileres.
            record.HouseRefundPending=property.RentPayments*CaelumPropertyData.RENT_COPPER
                +(property.Purchased?CaelumPropertyData.PURCHASE_COPPER:0);
            property.Holder=title;property.Purchased=true;
            record.HouseRestitutionConfirmed=true;
        }
        ClaimRefund(user);Observe(user);CaelumRentalAgent.Sync(user);user.PersistCharacterState();return true;
    }
    static bool ClaimRefund(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return false;
        let record=user.GetPersistentCharacterState(false);int quest=CaelumConstants.QUEST_FIND_HOUSE;
        if(record==null || !record.HouseRestitutionConfirmed || record.QuestRewardClaimed[quest])return false;
        if(record.HouseRefundPending>0)
        {
            bool credited=false;
            for(int route=0;route<2;route++)
            {
                if(!user.BuildPalomoCurrencyCreditPlan(record.HouseRefundPending))return false;
                if(route==1){if(!user.MagicBoxOwned)continue;user.RoutePalomoCurrencyGainsToMagicBox();}
                if(!user.PalomoTransactionCapacityFits(user.GetPalomoCurrencyPlanPersonalWeightDelta(),
                    user.GetPalomoCurrencyPlanBoxRawWeightDelta(),user.GetPalomoCurrencyPlanBoxSlotDelta()))continue;
                if(!user.ApplyPalomoCurrencyPlan())return false;credited=true;break;
            }
            if(!credited)return false;
        }
        record.HouseRefundPending=0;record.QuestRewardClaimed[quest]=true;
        user.RefreshSocialJournalSnapshot();user.PersistCharacterState();return true;
    }
    static bool Activate(CaelumPlayer user,int quest)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || !CaelumPortQuestData.Defined(quest))return false;
        let record=user.GetPersistentCharacterState(false);if(record==null)return false;
        bool changed=record.QuestState[quest]==CaelumConstants.QUEST_STATE_ABANDONED && Begin(user,quest);
        if(quest==CaelumConstants.QUEST_FIND_HOUSE)changed=ClaimRefund(user)||changed;
        Observe(user);user.RefreshSocialJournalSnapshot();return changed;
    }
}
