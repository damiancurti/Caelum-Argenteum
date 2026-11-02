// Estado de la partida separado de los cuerpos reemplazables y de la campaña.
class CaelumStandaloneMatch : Object play
{
    int Revision,Mode,Members,Elapsed,Winner,RematchVotes;
    int Score[MAXPLAYERS],Deaths[MAXPLAYERS],RespawnAt[MAXPLAYERS],Preset[MAXPLAYERS];
    int Team[MAXPLAYERS];
    int PlayerPalomo; // 0 = NPC; 1..8 = puesto humano, guardado por partida.
    bool Started,Finished,Restarting;
    CaelumCaptureArcana Capture;
    CaelumTarotHunt Hunt;
    CaelumLabyrinthPowerups Powerups;

    static clearscope CaelumStandaloneMatch View()
    {
        let events=CaelumStandaloneMatchEvents(StaticEventHandler.Find('CaelumStandaloneMatchEvents'));
        return events!=null && events.Store!=null?events.Store.Match:null;
    }
    // -1 delega en las relaciones habituales; 0 aliado, 1 rival de la partida.
    static clearscope int Relation(CaelumPlayer first,CaelumPlayer second)
    {
        if(!(first is 'CaelumStandalonePlayer') || !(second is 'CaelumStandalonePlayer'))return -1;
        let match=View();if(match==null || !match.Started || match.Finished)return 0;
        if(!match.Member(first.PlayerNumber()) || !match.Member(second.PlayerNumber()))return 0;
        if(first==second)return 0;
        if(match.Mode==CaelumStandaloneData.TAROT_HUNT)return match.HunterPlayer(first.PlayerNumber())!=match.HunterPlayer(second.PlayerNumber())?1:0;
        return !match.TeamsEnabled() || match.Team[first.PlayerNumber()]!=match.Team[second.PlayerNumber()]?1:0;
    }
    clearscope bool TeamsEnabled(){return Mode==CaelumStandaloneData.TEAM_DEATHMATCH || Mode==CaelumStandaloneData.CAPTURE_ARCANA;}
    clearscope int TeamScore(int teamId)
    {
        int result=0;for(int i=0;i<MAXPLAYERS;i++)if(Member(i) && Team[i]==teamId)result+=Score[i];
        return result;
    }
    static clearscope String TeamName(int team)
    {return StringTable.Localize(team==0?'CA_MATCH_TEAM_RED':'CA_MATCH_TEAM_BLUE',false);}
    clearscope String WinnerName(){if(Hunt!=null)return StringTable.Localize(Winner==0?'CA_HUNT_TEAM':'CA_HUNT_PALOMO',false);return TeamsEnabled()?TeamName(Winner):players[Winner].GetUserName();}
    void AssignTeams()
    {
        int order=0;for(int i=0;i<MAXPLAYERS;i++)if(Member(i)){Team[i]=order%2;order++;}
    }
    clearscope bool Member(int slot){return slot>=0 && slot<MAXPLAYERS && (Members&(1<<slot))!=0;}
    clearscope bool HunterPlayer(int slot){return Mode==CaelumStandaloneData.TAROT_HUNT && PlayerPalomo>0 && slot==PlayerPalomo-1;}
    clearscope bool Seeker(int slot){return Member(slot) && !HunterPlayer(slot);}
    clearscope int Seekers(){return PlayerPalomo>0?Members&~(1<<(PlayerPalomo-1)):Members;}
    clearscope bool RespawnAllowed(int slot)
    {return Member(slot) && (Restarting || (Started && !Finished && RespawnAt[slot]>0 && level.time>=RespawnAt[slot]));}

    void Tick()
    {
        // Los guardados individuales de revisión 1 conservan todos sus puntos.
        if(Revision<2){AssignTeams();Revision=2;}
        if(!Started)
        {
            int mask=0,count=0;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let body=CaelumStandalonePlayer(players[i].mo);
                if(body==null || body.StandaloneRevision<CaelumStandaloneData.REVISION)return;
                mask|=1<<i;count++;Preset[i]=body.StandalonePreset;
            }
            if(count<2)return;
            Members=mask;Started=true;Winner=-1;
            AssignTeams();
        }
        for(int i=0;i<MAXPLAYERS;i++)if(Member(i))
        {
            let body=CaelumStandalonePlayer(players[i].mo);
            if(body==null)continue;
            // No hay inventario recuperable en los cadáveres de este modo.
            if(body.health<=0 && !body.StandaloneInventoryCleared)
                body.ClearMatchInventory();
            if(Finished)body.player.cheats|=CF_TOTALLYFROZEN;
        }
        if(Finished)return;
        if(Powerups==null && CaelumPowerupData.PointCount()>0)
        {Powerups=new('CaelumLabyrinthPowerups');Powerups.Initialize();}
        if(Powerups!=null)Powerups.Tick(self);
        if(Mode==CaelumStandaloneData.CAPTURE_ARCANA)
        {
            if(Capture==null){Capture=new('CaelumCaptureArcana');Capture.Initialize(self);}
            Capture.Tick(self);
        }
        Elapsed++;
        if(Mode==CaelumStandaloneData.TAROT_HUNT)
        {if(Hunt==null){Hunt=new('CaelumTarotHunt');Hunt.Initialize();}Hunt.Tick(self);return;}
        Evaluate();
    }
    void RecordDeath(CaelumStandalonePlayer victim,Actor source)
    {
        if(!Started || Finished || victim==null || victim.StandaloneDeathRecorded)return;
        int slot=victim.PlayerNumber();if(!Member(slot))return;
        victim.StandaloneDeathRecorded=true;Deaths[slot]++;
        RespawnAt[slot]=level.time+CaelumStandaloneData.RESPAWN_TICS;
        if(Mode==CaelumStandaloneData.CAPTURE_ARCANA)
        {if(Capture!=null)Capture.Drop(self,slot,victim.Pos);return;}
        let killer=CaelumStandalonePlayer(source);
        int credit=killer!=null?killer.PlayerNumber():-1;
        bool credited=credit!=slot && Member(credit);
        bool teamkill=credited && TeamsEnabled() && Team[credit]==Team[slot];
        if(credited)Score[credit]+=teamkill?-1:1;
        else Score[slot]--;
        String line=credited
            ?String.Format(StringTable.Localize(teamkill?"CA_MATCH_TEAM_KILL":"CA_MATCH_KILL",false),players[credit].GetUserName(),players[slot].GetUserName())
            :String.Format(StringTable.Localize("CA_MATCH_SELF_DEATH",false),players[slot].GetUserName());
        Console.Printf("%s",line);
        // Evaluar al terminar el tic permite resolver bajas simultáneas.
    }
    void Evaluate()
    {
        if(TeamsEnabled())
        {
            int red=TeamScore(0),blue=TeamScore(1);
            int limit=Mode==CaelumStandaloneData.CAPTURE_ARCANA?CaelumStandaloneData.CAPTURE_LIMIT:CaelumStandaloneData.FRAG_LIMIT;
            if(red==blue || (Max(red,blue)<limit && Elapsed<CaelumStandaloneData.TIME_LIMIT_TICS))return;
            Finished=true;Winner=red>blue?0:1;
            Console.Printf("CA_MATCH RESULT mode=%d team=%d score=%d",Mode,Winner,TeamScore(Winner));
            return;
        }
        int best=-1;bool tied=false;
        for(int i=0;i<MAXPLAYERS;i++)if(Member(i))
        {
            if(best<0 || Score[i]>Score[best]){best=i;tied=false;}
            else if(Score[i]==Score[best])tied=true;
        }
        if(best<0 || tied)return;
        if(Score[best]<CaelumStandaloneData.FRAG_LIMIT && Elapsed<CaelumStandaloneData.TIME_LIMIT_TICS)return;
        Finished=true;Winner=best;
        Console.Printf("CA_MATCH RESULT mode=%d winner=%d score=%d",Mode,Winner,Score[Winner]);
    }
    void VoteRematch(int slot)
    {
        if(!Finished || !Member(slot) || !playeringame[slot])return;
        RematchVotes|=1<<slot;
        if((RematchVotes&Members)!=Members)return;
        Restarting=true;
        // El modo guardado manda también tras recuperar con un CVar diferente.
        let events=CaelumStandaloneMatchEvents(StaticEventHandler.Find('CaelumStandaloneMatchEvents'));
        if(events!=null){events.NextMode=Mode;events.NextPalomo=PlayerPalomo;}
        // Nueva instancia del mapa: elimina proyectiles y estado de la ronda.
        for(int i=0;i<MAXPLAYERS;i++)if(Member(i))
        {
            let body=CaelumStandalonePlayer(players[i].mo);if(body==null)continue;
            body.StandaloneRevision=0;body.StandaloneHunter=false;body.StandaloneDeathRecorded=false;body.StandaloneInventoryCleared=false;
            body.player.cheats&=~CF_TOTALLYFROZEN;
        }
        Level.ChangeLevel(level.MapName,0,CHANGELEVEL_NOINTERMISSION|CHANGELEVEL_RESETINVENTORY|CHANGELEVEL_RESETHEALTH);
    }
}

class CaelumStandaloneMatchStore : Actor
{
    CaelumStandaloneMatch Match;
    Default {+NOINTERACTION +NOSECTOR +NOBLOCKMAP +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumStandaloneMatchEvents : StaticEventHandler
{
    CaelumStandaloneMatchStore Store;
    bool Located;
    int NextMode,NextPalomo;
    override void WorldLoaded(WorldEvent e){Store=null;Located=false;}
    override void WorldTick()
    {
        // Una consulta tipada por carga, de población máxima uno; luego O(8).
        if(!Located)
        {
            Located=true;
            let it=ThinkerIterator.Create('CaelumStandaloneMatchStore');Store=CaelumStandaloneMatchStore(it.Next());
        }
        if(Store==null)
        {
            int mode=NextMode>0?NextMode:CVar.GetCVar('ca_standalone_mode').GetInt();
            if((mode!=CaelumStandaloneData.DEATHMATCH && mode!=CaelumStandaloneData.TEAM_DEATHMATCH && mode!=CaelumStandaloneData.CAPTURE_ARCANA && mode!=CaelumStandaloneData.TAROT_HUNT)
                || !(players[0].mo is 'CaelumStandalonePlayer'))return;
            Store=CaelumStandaloneMatchStore(Actor.Spawn('CaelumStandaloneMatchStore',(0,0,0),NO_REPLACE));
            Store.Match=new('CaelumStandaloneMatch');Store.Match.Revision=1;
            Store.Match.Mode=mode;
            int selected=NextMode>0?NextPalomo:CVar.GetCVar('ca_standalone_palomo').GetInt();
            int count=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])count++;
            if(mode==CaelumStandaloneData.TAROT_HUNT && count>=CaelumStandaloneData.HUMAN_PALOMO_MIN_PLAYERS
                && selected>0 && selected<=MAXPLAYERS && playeringame[selected-1])Store.Match.PlayerPalomo=selected;
            NextMode=0;NextPalomo=0;
        }
        Store.Match.Tick();
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=='ca_match_rematch' && Store!=null)Store.Match.VoteRematch(e.Player);}
    override void PlayerRespawned(PlayerEvent e)
    {if(Store!=null && Store.Match.Member(e.PlayerNumber))Store.Match.RespawnAt[e.PlayerNumber]=0;}
}

class CaelumStandaloneScoreHUD : Object ui
{
    static double Draw(Font font)
    {
        let match=CaelumStandaloneMatch.View();if(match==null || !match.Started)return 0;
        int seconds=Max(0,(CaelumStandaloneData.TIME_LIMIT_TICS-match.Elapsed+TICRATE-1)/TICRATE);
        String line=match.Finished?String.Format(StringTable.Localize('CA_MATCH_WINNER',false),match.WinnerName())
            :seconds>0?String.Format("%02d:%02d",seconds/60,seconds%60):StringTable.Localize('CA_MATCH_OVERTIME',false);
        if(match.Hunt!=null && !match.Finished)
            line=String.Format(StringTable.Localize('CA_HUNT_COUNT',false),match.Hunt.Collected) .. " | " .. StringTable.Localize(match.Hunt.Captive(consoleplayer)?'CA_HUNT_WAIT_RESCUE':'CA_HUNT_HELP',false);
        if(match.Hunt!=null && match.HunterPlayer(consoleplayer) && !match.Finished)
            line=String.Format(StringTable.Localize('CA_HUNT_COUNT',false),match.Hunt.Collected).." | "..StringTable.Localize('CA_HUNT_PLAYER_HELP',false);
        if(match.TeamsEnabled() && match.Member(consoleplayer))
            line=String.Format("%s | %s: %d - %s: %d | %s",CaelumStandaloneMatch.TeamName(match.Team[consoleplayer]),CaelumStandaloneMatch.TeamName(0),match.TeamScore(0),CaelumStandaloneMatch.TeamName(1),match.TeamScore(1),line);
        if(match.Capture!=null && match.Capture.Carrying(consoleplayer)>=0)
            line=StringTable.Localize('CA_CAPTURE_CARRYING',false).." | "..line;
        return CaelumPresentation.CenterMessage(font,Font.CR_GOLD,line,12)+CaelumTargetPanelData.PADDING;
    }
}

class CaelumStandaloneScoreMenu : ListMenu
{
    static String L(String key){return StringTable.Localize(key,false);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;}
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Back){Close();return true;}
        let match=CaelumStandaloneMatch.View();
        if(key==MKEY_Enter && match!=null && match.Finished)EventHandler.SendNetworkEvent('ca_match_rematch');
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L('CA_MATCH_STANDINGS'),Font.CR_GOLD);
        let match=CaelumStandaloneMatch.View();
        if(match==null || !match.Started){CaelumTrucoMenu.Text(22,80,L('CA_MATCH_NOT_ACTIVE'));return;}
        if(match.TeamsEnabled())CaelumTrucoMenu.Text(22,65,String.Format("%s: %d - %s: %d",CaelumStandaloneMatch.TeamName(0),match.TeamScore(0),CaelumStandaloneMatch.TeamName(1),match.TeamScore(1)),Font.CR_GOLD);
        int shown=0;
        for(int row=0;row<MAXPLAYERS;row++)
        {
            int best=-1;
            for(int i=0;i<MAXPLAYERS;i++)if(match.Member(i) && !(shown&(1<<i)) && (best<0 || match.Score[i]>match.Score[best]))best=i;
            if(best<0)break;shown|=1<<best;
            String participantLabel=players[best].GetUserName();
            if(match.HunterPlayer(best))participantLabel=StringTable.Localize('CA_HUNT_PALOMO',false).." - "..participantLabel;
            if(match.TeamsEnabled())participantLabel=CaelumStandaloneMatch.TeamName(match.Team[best]).." - "..participantLabel;
            CaelumTrucoMenu.Text(22,(match.TeamsEnabled()?105:75)+row*30,String.Format("%d. %s: %d",row+1,participantLabel,match.Score[best]),match.TeamsEnabled()?(match.Team[best]==0?Font.CR_RED:Font.CR_LIGHTBLUE):Font.CR_WHITE);
        }
        if(match.Finished)
        {
            CaelumTrucoMenu.Text(22,350,String.Format(L('CA_MATCH_WINNER'),match.WinnerName()),Font.CR_GOLD);
            CaelumTrucoMenu.Wrap(22,380,730,L('CA_MATCH_REMATCH'));
            CaelumTrucoMenu.Text(22,450,(match.RematchVotes&(1<<consoleplayer))?L('CA_MATCH_WAIT_VOTES'):L('CA_MATCH_ENTER_REMATCH'));
        }
    }
}
