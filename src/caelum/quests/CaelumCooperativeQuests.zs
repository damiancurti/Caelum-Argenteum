// La elegibilidad pertenece al acontecimiento del mundo, no a la plaza reutilizable.
class CaelumCooperativeObjective : Object play
{
    Array<CaelumPersistentCharacterState> Eligible;
    clearscope bool Contains(CaelumPersistentCharacterState record) const
    {
        if(record==null)return false;
        for(int i=0;i<Eligible.Size();i++)if(Eligible[i]==record)return true;
        return false;
    }
    void Capture(int legacyPrisoner=-1)
    {
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);
            if(!CaelumWorldClockTicker.Ready(user))continue;
            let record=user.GetPersistentCharacterState(false);
            if(legacyPrisoner>=0 && record.GetPrisonerRescueState(legacyPrisoner)!=CaelumConstants.PRISONER_STATE_EXTRACTED)continue;
            if(!Contains(record))Eligible.Push(record);
        }
    }
}
// Se comparte por las réplicas del reloj; no se exporta con un perfil personal.
class CaelumCooperativeQuests : Object play
{
    int Revision;
    int PrisonerState[CaelumConstants.PRISONER_COUNT];
    CaelumCooperativeObjective Rescue[CaelumConstants.PRISONER_COUNT];
    CaelumPropertyRecord House;

    static clearscope bool Unavailable(CaelumPlayer user,int quest)
    {
        if(!multiplayer || user==null)return false;
        let clock=CaelumWorldClock(user.FindInventory('CaelumWorldClock'));
        let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        if(clock==null || clock.CampaignQuests==null || record==null)return false;
        if(quest==CaelumConstants.QUEST_FIND_HOUSE)
        {
            let house=clock.CampaignQuests.House;
            return !record.HouseRestitutionConfirmed && house!=null && house.Restitution!=null
                && !house.Restitution.Contains(record);
        }
        if(!CaelumQuestCatalogue.IsRescue(quest))return false;
        int prisoner=quest-CaelumConstants.QUEST_RESCUE_FIRST;
        if(record.PrisonerRewardClaimed[prisoner] || record.PrisonerRescueState[prisoner]==CaelumConstants.PRISONER_STATE_EXTRACTED)return false;
        let world=clock.CampaignQuests;
        return world.PrisonerState[prisoner]==CaelumConstants.PRISONER_STATE_DEAD
            || (world.PrisonerState[prisoner]==CaelumConstants.PRISONER_STATE_EXTRACTED
                && (world.Rescue[prisoner]==null || !world.Rescue[prisoner].Contains(record)));
    }

    static CaelumCooperativeQuests Get(CaelumPlayer user)
    {
        if(!multiplayer || !CaelumPlayerAuthority.CanMutate(user))return null;
        let owner=CaelumWorldClockTicker.CampaignOwner();if(owner==null)return null;
        let clock=CaelumWorldClock.Get(owner,true);
        if(clock.CampaignQuests==null)
        {
            let world=new("CaelumCooperativeQuests");
            // Migración única de campañas anteriores: no adjudica rescates
            // retroactivos a quienes no los tenían registrados.
            let old=owner.GetPersistentCharacterState(false);
            for(int i=0;i<CaelumConstants.PRISONER_COUNT;i++)
            {
                world.PrisonerState[i]=old.GetPrisonerRescueState(i);
                if(world.PrisonerState[i]==CaelumConstants.PRISONER_STATE_EXTRACTED)
                {world.Rescue[i]=new("CaelumCooperativeObjective");world.Rescue[i].Capture(i);}
            }
            world.House=CaelumPropertyRules.Find(CaelumPropertyData.CENTRAL_HOUSE);
            CaelumCooperativeHouse.Ensure(world.House);
            world.Revision=1;clock.CampaignQuests=world;CaelumWorldClockTicker.Mirror(owner);
        }
        return clock.CampaignQuests;
    }
    static bool CanClaim(CaelumPlayer user,int prisoner)
    {
        if(!multiplayer)return true;
        if(prisoner<0 || prisoner>=CaelumConstants.PRISONER_COUNT)return false;
        let world=Get(user);let record=user!=null?user.GetPersistentCharacterState(false):null;
        return world!=null && world.PrisonerState[prisoner]==CaelumConstants.PRISONER_STATE_EXTRACTED
            && world.Rescue[prisoner]!=null && world.Rescue[prisoner].Contains(record);
    }
    bool Transition(CaelumPlayer source,int prisoner,int next)
    {
        if(!CaelumPlayerAuthority.CanMutate(source))return false;
        if(prisoner<0 || prisoner>=CaelumConstants.PRISONER_COUNT)return false;
        int previous=PrisonerState[prisoner];
        if(previous==next || previous==CaelumConstants.PRISONER_STATE_DEAD
            || previous==CaelumConstants.PRISONER_STATE_EXTRACTED)return false;
        if(next==CaelumConstants.PRISONER_STATE_DEAD)
        {if(previous!=CaelumConstants.PRISONER_STATE_FOLLOWING)return false;}
        else if(next<previous || next>CaelumConstants.PRISONER_STATE_EXTRACTED)return false;
        PrisonerState[prisoner]=next;
        if(next==CaelumConstants.PRISONER_STATE_EXTRACTED)
        {Rescue[prisoner]=new("CaelumCooperativeObjective");Rescue[prisoner].Capture();}
        // Sólo este objetivo público: nunca copia diálogos privados, emociones
        // ni misiones personales independientes de los demás participantes.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let member=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(member))continue;
            let record=member.GetPersistentCharacterState(false);
            CaelumDemoNarrative.EnsureRevision(record);
            record.SetPrisonerRescueState(prisoner,next);
            member.RefreshSocialJournalSnapshot();member.PersistCharacterState();
        }
        return true;
    }
}
