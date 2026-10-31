// Verificación nativa de borradores: no concede objetos ni modifica atributos.
class CaelumTransferVerification : StaticEventHandler
{
    int Ticks;
    bool Ready,Failed;
    ui bool Saved;
    override void WorldLoaded(WorldEvent e){Ticks=0;Ready=false;Failed=false;}
    override void WorldTick()
    {
        if(Failed)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && players[i].inconsistent!=0)
        {
            Failed=true;Ready=false;
            Console.Printf("CA_PROFILE REJECT native inconsistency peer=%d slot=%d value=%d",consoleplayer,i,players[i].inconsistent);
            return;
        }
        // Dar tiempo al checksum nativo antes de publicar el guardado común.
        if(Ready || ++Ticks<105)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);
            let record=CaelumSessionIdentity.Record(user);
            if(user==null || record==null || user.SessionIdentityPending
                || record.ExternalProfileCampaign.Length()==0
                || user.ProfileDeparted!=record.ProfileDeparted
                || record.ProfileImportApplied<record.ProfileImportSerial)return;
        }
        Ready=true;
        Console.Printf("CA_PROFILE VERIFIED peer=%d",consoleplayer);
    }
    override void UiTick()
    {
        if(!Ready || Saved || consoleplayer!=0)return;
        Saved=true;
        let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
        manager.InsertNewSaveNode();manager.DoSave(0,"Caelum verified profile transfer");manager.RemoveNewSaveNode();
    }
}
