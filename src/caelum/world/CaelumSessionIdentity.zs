// #435: el número asignado por la red debe coincidir con el perfil del lanzador.
// La comprobación usa como máximo ocho registros; no recorre actores del mapa.
class CaelumSessionIdentity : StaticEventHandler
{
    bool Accepted[MAXPLAYERS],Inspect,Failed;
    int Nonces[MAXPLAYERS];
    ui bool Sent;
    override void WorldLoaded(WorldEvent e)
    {
        Inspect=true;Failed=false;
        for(int i=0;i<MAXPLAYERS;i++){Accepted[i]=false;Nonces[i]=0;}
        if(consoleplayer>=0)EventHandler.SendInterfaceEvent(consoleplayer,"ca_session_identity_reset");
    }
    override void InterfaceProcess(ConsoleEvent e)
    {if(e.Name=="ca_session_identity_reset")Sent=false;}
    static clearscope CaelumPersistentCharacterState Record(CaelumPlayer user)
    {return user==null?null:CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));}
    void Reject()
    {
        if(Failed)return;
        Failed=true;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            user.SessionIdentityPending=true;
            CaelumNotifications.Notify(user,StringTable.Localize("CA_SESSION_IDENTITY_REJECT",false));
        }
    }
    override void WorldTick()
    {
        if(!Inspect)return;
        bool pending=false;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(user==null){pending=true;continue;}
            let record=Record(user);
            bool required=record!=null && record.ExternalProfileCampaign.Length()>0;
            if(required && !user.SessionIdentityPending)
                CaelumNotifications.Notify(user,StringTable.Localize("CA_SESSION_IDENTITY_WAIT",false));
            user.SessionIdentityPending=required;
        }
        Inspect=pending;
    }
    override void UiTick()
    {
        if(Sent || gamestate!=GS_LEVEL || consoleplayer<0 || Inspect)return;
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        let id=CVar.GetCVar("ca_session_profile");
        let slot=CVar.GetCVar("ca_session_slot");
        let nonce=CVar.GetCVar("ca_session_nonce");
        if(id==null || id.GetString().Length()==0)return;
        Sent=true;
        EventHandler.SendNetworkEvent("ca_session_identity:"..id.GetString(),slot.GetInt(),nonce.GetInt(),1);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        String prefix="ca_session_identity:";
        if(e.Name.Left(prefix.Length())!=prefix)return;
        if(e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let user=CaelumPlayer(players[e.Player].mo);let record=Record(user);
        String expected=record==null?"":record.ProfileDeparted?String.Format("vacant:%d",e.Player):record.ExternalProfileId;
        if(Failed || record==null || record.ExternalProfileCampaign.Length()==0
            || e.Args[0]!=e.Player || e.Args[1]<=0 || e.Args[2]!=1
            || e.Name.Mid(prefix.Length())!=expected)
        {Reject();Console.Printf("CA_SESSION REJECT peer=%d sender=%d identity",consoleplayer,e.Player);return;}
        if(Accepted[e.Player])
        {
            if(Nonces[e.Player]!=e.Args[1]){Reject();Console.Printf("CA_SESSION REJECT peer=%d sender=%d nonce",consoleplayer,e.Player);}
            return;
        }
        Accepted[e.Player]=true;Nonces[e.Player]=e.Args[1];
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && !Accepted[i])return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && Nonces[i]!=Nonces[e.Player])
        {Reject();Console.Printf("CA_SESSION REJECT peer=%d nonce disagreement",consoleplayer);return;}
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let member=CaelumPlayer(players[i].mo);if(member!=null)member.SessionIdentityPending=false;
        }
        CaelumSessionLifecycle.CancelConsent();
        Console.Printf("CA_SESSION READY peer=%d nonce=%d",consoleplayer,Nonces[e.Player]);
    }
}
