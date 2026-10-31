// Salida narrativa atómica: comprobar todos los inventarios antes de modificar uno.
class CaelumCooperativeReturn : Object play
{
    static bool Completed(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        return record!=null && record.QuestState[0]==CaelumConstants.QUEST_STATE_COMPLETED
            && record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMPLETE);
    }
    static bool Prepare(CaelumCooperativeTravel vote)
    {
        if(vote==null || vote.Kind!=CaelumCooperativeTravel.TUTORIAL || level.MapName!="MAP01")return false;
        for(int i=0;i<MAXPLAYERS;i++)if((vote.AliveMask&(1<<i))!=0)
        {
            let member=vote.Members[i];if(!CaelumCooperativeTravel.BodyReady(member))return false;
            if(Completed(member))continue;
            if(!CaelumMainM00Return.IsReady(member))return false;
            if(member.GetPersistentCharacterState(false).HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_INVENTORY_SANITIZED))return false;
            member.SyncActiveModelsToNativeInventory();CaelumMainM00Loadout.EnsureMigration(member);
            if(!CaelumOnboarding.PackDeparture(member,true))return false;
        }
        return true;
    }
    static bool Propose(CaelumPlayer user,CaelumM00ReturnDoor door)
    {
        if(!CaelumMainM00Return.CanApproach(user,door) || !LevelInfo.MapExists("MAP02"))return false;
        let vote=CaelumCooperativeTravel.Draft(user);if(vote==null)return false;
        vote.Kind=CaelumCooperativeTravel.TUTORIAL;vote.TutorialDoor=door;
        vote.Destination="MAP02";vote.Entry=0;
        return Prepare(vote) && vote.Publish();
    }
    static bool Commit(CaelumCooperativeTravel vote)
    {
        if(!Prepare(vote))return false;
        // Sin tics ni inventario compartido entre esta comprobación y el
        // empaquetado: cada transacción ya verificó todos sus requisitos.
        for(int i=0;i<MAXPLAYERS;i++)if((vote.AliveMask&(1<<i))!=0)
        {
            let member=vote.Members[i];
            if(!Completed(member))
            {
                let record=member.GetPersistentCharacterState(false);
                record.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED;
                record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED);
                if(!CaelumMainM00Return.Commit(member,true))return false;
            }
            CaelumWorldProgress.RecordReturnDeparture(member);
            member.PendingTravelWipe=2;
            member.PersistCharacterState();
        }
        return true;
    }
}
