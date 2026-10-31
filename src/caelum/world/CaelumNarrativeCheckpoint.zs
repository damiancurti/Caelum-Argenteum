// #434: observar sólo la transacción personal que acaba de persistirse.
// No se consulta el mapa ni se buscan actores desde el guardado narrativo.
class CaelumNarrativeCheckpoint : Object play
{
    int Revision,Serial,Queued;
    String Snapshot;

    static String Signature(CaelumPersistentCharacterState record)
    {
        String key="";
        for(int i=0;i<CaelumConstants.QUEST_DEFINED_COUNT;i++)
            key=key..String.Format("%d%d",record.QuestState[i]==CaelumConstants.QUEST_STATE_COMPLETED,record.QuestRewardClaimed[i]);
        for(int i=0;i<CaelumConstants.PRISONER_COUNT;i++)key=key..String.Format("%d",record.PrisonerRewardClaimed[i]);
        key=key..String.Format("/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d",
            record.MainM00StarterChosen,record.MainM00StarterOption,record.MainM00StarterSize,
            record.MainM00SealChoice,record.MainM00AmuletChoice,record.MainM00ArmorChosen,
            record.MainM00ArmorType,record.MainM00ArmorSize,record.MainM00ShieldChoice,
            record.TarotDeckGranted,record.MagicBoxOwned,record.MainM00GoldRewardStarted,
            record.SpiritDeckPending,record.SpiritBoxPending,record.SpiritSilverKeyPending);
        int flags[7]={CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE,CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE,
            CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE,CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE,
            CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED,CaelumConstants.MAIN_M00_FLAG_COMPLETE,
            CaelumConstants.MAIN_M00_FLAG_SECRET_PASSAGE_OPEN};
        for(int i=0;i<7;i++)key=key..String.Format("%d",record.MainM00Flag[flags[i]]);
        for(int i=0;i<CaelumConstants.FACTION_COUNT;i++)key=key..String.Format("/%d",record.FactionMembershipEpoch[i]);
        return key;
    }

    static void Observe(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let record=user.GetPersistentCharacterState(false);if(record==null || !record.ProfileCommitted)return;
        if(record.NarrativeCheckpoint==null)record.NarrativeCheckpoint=new("CaelumNarrativeCheckpoint");
        let checkpoint=record.NarrativeCheckpoint;String current=Signature(record);
        // Una partida anterior empieza con su estado presente como referencia,
        // sin reentregar recompensas ni generar guardados retroactivos.
        if(checkpoint.Revision==0){checkpoint.Revision=1;checkpoint.Snapshot=current;return;}
        if(checkpoint.Snapshot==current)return;
        checkpoint.Snapshot=current;checkpoint.Serial++;
    }

    static void Request(CaelumPlayer user)
    {
        Observe(user);let record=user==null?null:user.GetPersistentCharacterState(false);
        if(record!=null && record.NarrativeCheckpoint!=null)record.NarrativeCheckpoint.Serial++;
    }

    static clearscope CaelumNarrativeCheckpoint Read(int slot)
    {
        if(slot<0 || slot>=MAXPLAYERS || !playeringame[slot])return null;
        let user=CaelumPlayer(players[slot].mo);if(!CaelumPlayerAuthority.CanRead(user) || user.ProfileDeparted)return null;
        let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        return record==null?null:record.NarrativeCheckpoint;
    }

    static clearscope bool Ready()
    {
        if(gamestate!=GS_LEVEL || gameaction!=CaelumSaveRules.NATIVE_ACTION_IDLE || demoplayback)return false;
        bool present=false;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(!CaelumPlayerAuthority.CanRead(user))return false;
            if(user.ProfileDeparted)continue;
            if(!user.CharacterCreationComplete || user.CreationWizardOpen || user.CraftingTaskCompleting
                || (user.player.ConversationNPC!=null && user.player.ConversationNPC.bInConversation))return false;
            present=true;
        }
        return present;
    }
}
