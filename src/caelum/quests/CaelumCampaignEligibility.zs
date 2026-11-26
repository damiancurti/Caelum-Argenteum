// #457: consulta sin premios ni estado propio. El acceso real conserva su
// escena, padrón y consentimiento; esta condición no autoriza el viaje lunar.
class CaelumCampaignEligibility : Object play
{
    static clearscope bool RecordEligible(CaelumPersistentCharacterState record)
    {
        if(CaelumTarotService.CountTarotCards(record)<CaelumCampaignFinaleData.REQUIRED_ESSENCES)return false;
        for(int i=0;i<CaelumCampaignFinaleData.FACTION_COUNT;i++)
            if(record.FactionReputation[CaelumCampaignFinaleData.Faction(i)]>=CaelumCampaignFinaleData.MINIMUM_REPUTATION)return true;
        return false;
    }

    static bool ParticipantEligible(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete || user.CreationWizardOpen)return false;
        if(CaelumPlayerAuthority.FromNetworkPlayer(user.PlayerNumber(),true)!=user)return false;
        let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        return CaelumPlayerAuthority.OwnsRecord(user,record) && record.ProfileCommitted && RecordEligible(record);
    }

    static int EligibleParticipantMask()
    {
        int mask=0;
        // Consulta puntual del padrón nativo, acotada por MAXPLAYERS; sin actores globales.
        // Cada participante debe satisfacer ambas condiciones con su propio registro.
        for(int i=0;i<MAXPLAYERS;i++)
            if(ParticipantEligible(CaelumPlayerAuthority.FromNetworkPlayer(i,true)))mask|=1<<i;
        return mask;
    }
}
