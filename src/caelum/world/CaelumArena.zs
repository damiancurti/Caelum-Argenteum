// #438: la partida conserva cuerpos e inventarios; sólo administra consentimiento y resultado.
class CaelumArenaMatch : Object play
{
    enum Stage { ARRIVING, FIGHTING, FINISHED, RETURNING, RETURNED }
    int Revision,Serial,Venue,Mode,Status,Mask,Arrived,Withdrawn,Winner;
    CaelumPlayer Members[MAXPLAYERS];
    int Teams[MAXPLAYERS];
    vector3 Origins[MAXPLAYERS];
    double Angles[MAXPLAYERS];
    bool Froze[MAXPLAYERS];
    String OriginMap;

    void ReleaseControls()
    {
        for(int i=0;i<MAXPLAYERS;i++)if(Froze[i] && Members[i]!=null && Members[i].player!=null)
        {Members[i].player.cheats&=~CF_TOTALLYFROZEN;Froze[i]=false;}
    }
    void Evaluate()
    {
        if(Status!=FIGHTING || level.MapName!=CaelumArenaData.Map(Venue))return;
        int last=-1,count=0,team=-1;bool severalTeams=false;
        for(int i=0;i<MAXPLAYERS;i++)if((Mask&(1<<i))!=0)
        {
            let user=Members[i];
            if(!playeringame[i] || players[i].mo!=user)Withdrawn|=1<<i;
            if(user==null || user.health<=0 || (Withdrawn&(1<<i))!=0)continue;
            last=i;count++;
            if(team<0)team=Teams[i];else if(team!=Teams[i])severalTeams=true;
        }
        if(count>1 && (Mode==0 || severalTeams))return;
        Winner=count==0?-1:Mode==0?last:team;Status=FINISHED;ReleaseControls();
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {let session=CaelumArenaState.View(Members[i]);if(session!=null)session.Open=true;}
    }
    bool Surrender(CaelumPlayer user)
    {
        int n=user!=null?user.PlayerNumber():-1;
        if(Status!=FIGHTING || n<0 || n>=MAXPLAYERS || Members[n]!=user
            || (Withdrawn&(1<<n))!=0 || user.health<=0)return false;
        Withdrawn|=1<<n;
        // Retirarse no concede invulnerabilidad ni devuelve consumos.
        if(!(user.player.cheats&CF_TOTALLYFROZEN))
        {user.player.cheats|=CF_TOTALLYFROZEN;Froze[n]=true;user.Vel=(0,0,0);}
        Evaluate();return true;
    }
}

class CaelumArenaState : Inventory
{
    int Revision,Venue,Mode;
    bool Open,Pending;
    Actor Organizer;
    CaelumArenaMatch MatchState;
    static clearscope CaelumArenaState View(CaelumPlayer user)
    {return user==null?null:CaelumArenaState(user.FindInventory('CaelumArenaState'));}
    static CaelumArenaState Get(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let session=View(user);
        if(session==null)session=CaelumArenaState(user.GiveInventoryType('CaelumArenaState'));
        if(session!=null)session.Revision=CaelumArenaData.REVISION;
        return session;
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        if(Pending && user!=null && !user.HasActiveConversation()){Pending=false;Open=true;}
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumArena : Object play
{
    enum Operation { CLOSE, VENUE, MODE, INVITE, SURRENDER, GO_BACK, TEAM }
    static bool OrganizerValid(CaelumPlayer user,Actor speaker)
    {
        return CaelumPlayerAuthority.CanRead(user) && user.health>0 && speaker!=null && !speaker.bDestroyed
            && (speaker is 'CaelumPalomo' || speaker is 'CaelumArenaOrganizer')
            && user.Distance2D(speaker)<=CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            && Abs(user.Pos.Z-speaker.Pos.Z)<=48 && user.CheckSight(speaker);
    }
    static bool Open(CaelumPlayer user,Actor speaker)
    {
        if(!OrganizerValid(user,speaker))return false;
        let session=CaelumArenaState.Get(user);if(session==null)return false;
        session.Organizer=speaker;session.Pending=user.HasActiveConversation();session.Open=!session.Pending;return true;
    }
    static bool Valid(CaelumCooperativeTravel vote)
    {
        let user=CaelumPlayer(vote.Owner);let session=CaelumArenaState.View(user);
        if(session==null)return false;
        if(vote.Kind==CaelumCooperativeTravel.ARENA_RETURN)
        {
            let match=session.MatchState;
            return match!=null && match.Status==CaelumArenaMatch.FINISHED
                && level.MapName==CaelumArenaData.Map(match.Venue) && vote.Destination==match.OriginMap;
        }
        return OrganizerValid(user,vote.ArenaOrganizer) && vote.ArenaVenue>=0 && vote.ArenaVenue<2
            && vote.ArenaMode>=0 && vote.ArenaMode<=1 && vote.Destination==CaelumArenaData.Map(vote.ArenaVenue);
    }
    static bool Propose(CaelumPlayer user)
    {
        let session=CaelumArenaState.View(user);
        if(session==null || !OrganizerValid(user,session.Organizer) || !multiplayer)return false;
        if(session.MatchState!=null && session.MatchState.Status!=CaelumArenaMatch.RETURNED)return false;
        let vote=CaelumCooperativeTravel.Draft(user);if(vote==null)return false;
        int count=0;
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            if(!CaelumCooperativeTime.Living(vote.Members[i]))return false;
            let other=CaelumArenaState.View(vote.Members[i]);
            if(other!=null && other.MatchState!=null && other.MatchState.Status!=CaelumArenaMatch.RETURNED)return false;
            vote.ArenaTeams[i]=count%2;count++;
        }
        if(count<2)return false;
        vote.Kind=CaelumCooperativeTravel.ARENA;vote.ArenaVenue=session.Venue;vote.ArenaMode=session.Mode;
        vote.ArenaOrganizer=session.Organizer;vote.Destination=CaelumArenaData.Map(session.Venue);vote.Entry=0;
        if(!vote.Publish())return false;session.Open=false;return true;
    }
    static bool ChangeTeam(CaelumCooperativeTravel vote,CaelumPlayer user,int expected)
    {
        int n=vote!=null?vote.Slot(user):-1;
        if(vote==null || !vote.Opened || vote.Kind!=CaelumCooperativeTravel.ARENA || vote.ArenaMode!=1
            || vote.Serial!=expected || n<0 || !vote.RosterValid())return false;
        vote.ArenaTeams[n]=1-vote.ArenaTeams[n];vote.Accepted=0;
        return vote.NextSerial();
    }
    static bool ProposeReturn(CaelumPlayer user)
    {
        let session=CaelumArenaState.View(user);let match=session!=null?session.MatchState:null;
        if(match==null || match.Status!=CaelumArenaMatch.FINISHED || level.MapName!=CaelumArenaData.Map(match.Venue))return false;
        let vote=CaelumCooperativeTravel.Draft(user,true,true);if(vote==null)return false;
        vote.Kind=CaelumCooperativeTravel.ARENA_RETURN;vote.Destination=match.OriginMap;vote.Entry=0;
        if(!vote.Publish())return false;session.Open=false;
        if(!multiplayer)vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial);
        return true;
    }
    static bool Commit(CaelumCooperativeTravel vote)
    {
        if(!Valid(vote))return false;
        if(vote.Kind==CaelumCooperativeTravel.ARENA_RETURN)
        {
            let match=CaelumArenaState.View(CaelumPlayer(vote.Owner)).MatchState;
            for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null && match.Members[i]!=vote.Members[i])return false;
            match.ReleaseControls();match.Status=CaelumArenaMatch.RETURNING;match.Arrived=0;
            for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
            {
                // El regreso transporta el cadáver original, sin resucitar ni copiar su equipo.
                if(vote.Members[i].health<=0)CaelumDeadTraveler.Prepare(vote.Members[i]);
                let body=CaelumDeadTraveler.View(vote.Members[i]);
                if(body!=null && body.Stored && vote.Members[i].health<=0 && match.OriginMap!="MAP01")
                {body.BodyMap=match.OriginMap;body.BodyPosition=match.Origins[i];body.BodyAngle=match.Angles[i];}
            }
            return true;
        }
        int sizes[2];int count=0;
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            if(vote.Members[i].health<=0 || vote.ArenaTeams[i]<0 || vote.ArenaTeams[i]>1)return false;
            count++;sizes[vote.ArenaTeams[i]]++;
            if(CaelumArenaState.Get(vote.Members[i])==null)return false;
        }
        if(count<2 || (vote.ArenaMode==1 && (sizes[0]<1 || sizes[1]<1 || sizes[0]>4 || sizes[1]>4)))return false;
        let match=CaelumArenaMatch(new('CaelumArenaMatch'));
        match.Revision=CaelumArenaData.REVISION;match.Serial=vote.Serial;match.OriginMap=level.MapName;
        match.Venue=vote.ArenaVenue;match.Mode=vote.ArenaMode;match.Mask=vote.Mask;match.Winner=-1;
        for(int i=0;i<MAXPLAYERS;i++)if(vote.Members[i]!=null)
        {
            let user=vote.Members[i];match.Members[i]=user;match.Teams[i]=vote.ArenaTeams[i];
            match.Origins[i]=user.Pos;match.Angles[i]=user.Angle;
            let session=CaelumArenaState.Get(user);session.MatchState=match;session.Open=false;
            CaelumTransportTrip.CloseActivities(user);user.PersistCharacterState();
        }
        return true;
    }
    static void Arrive(CaelumPlayer user)
    {
        let session=CaelumArenaState.View(user);let match=session!=null?session.MatchState:null;
        if(match==null)return;int n=user.PlayerNumber();
        if(n<0 || n>=MAXPLAYERS || match.Members[n]!=user)return;
        if(match.Status==CaelumArenaMatch.ARRIVING && level.MapName==CaelumArenaData.Map(match.Venue))
        {
            user.SetOrigin(CaelumArenaData.Start(match.Venue,n),false);user.Angle=CaelumArenaData.Facing(match.Venue,n);
            user.Vel=(0,0,0);user.FindFloorCeiling();user.ClearInterpolation();match.Arrived|=1<<n;
            if(match.Arrived==match.Mask)match.Status=CaelumArenaMatch.FIGHTING;
        }
        if(match.Status==CaelumArenaMatch.RETURNING && level.MapName==match.OriginMap)
        {
            user.SetOrigin(match.Origins[n],false);user.Angle=match.Angles[n];user.Vel=(0,0,0);
            user.FindFloorCeiling();user.ClearInterpolation();match.Arrived|=1<<n;session.Open=false;
            int present=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && match.Members[i]!=null)present|=1<<i;
            if((match.Arrived&present)==present)match.Status=CaelumArenaMatch.RETURNED;
        }
    }
}

class CaelumArenaOpenAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {let user=CaelumPlayer(Owner);return user!=null && user.player!=null && CaelumArena.Open(user,user.player.ConversationNPC);}
}
class CaelumArenaUnavailableToken : CaelumPalomoDialogueMarker {}

// Postes y cuerdas decorativos: la geometría del mapa mantiene el límite de 12 m.
class CaelumArenaRingFrame : Actor
{
    Default {+NOBLOCKMAP +NOINTERACTION +NOGRAVITY}
    States {Spawn:CPTN A -1;Stop;}
}

class CaelumArenaOrganizer : Actor
{
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || user.player==null || !CaelumUseGeometry.AimedAt(user,self))return false;
        if((user.player.cmd.buttons&BT_USE)==0 || user.FolkloreInteractionUseLatched)return true;
        user.FolkloreInteractionUseLatched=true;user.FolkloreInteractionReleaseGuardTics=0;
        return CaelumArena.Open(user,self);
    }
    Default
    {
        Radius 16;Height 57.6;Health 100;Scale 0.409091;
        +SOLID +USESPECIAL +INVULNERABLE +NOTARGET
        Tag "$CA_ARENA_ORGANIZER";
    }
    States {Spawn:DOID A -1;Stop;}
}
