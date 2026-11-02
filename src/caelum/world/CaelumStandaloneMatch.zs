// Estado de la partida separado de los cuerpos reemplazables y de la campaña.
class CaelumStandaloneMatch : Object play
{
    int Revision,Mode,Members,Elapsed,Winner,RematchVotes;
    int Score[MAXPLAYERS],Deaths[MAXPLAYERS],RespawnAt[MAXPLAYERS],Preset[MAXPLAYERS];
    bool Started,Finished,Restarting;

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
        return first!=second && match.Mode==CaelumStandaloneData.DEATHMATCH?1:0;
    }
    clearscope bool Member(int slot){return slot>=0 && slot<MAXPLAYERS && (Members&(1<<slot))!=0;}
    clearscope bool RespawnAllowed(int slot)
    {return Member(slot) && (Restarting || (Started && !Finished && RespawnAt[slot]>0 && level.time>=RespawnAt[slot]));}

    void Tick()
    {
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
        Elapsed++;Evaluate();
    }
    void RecordDeath(CaelumStandalonePlayer victim,Actor source)
    {
        if(!Started || Finished || victim==null || victim.StandaloneDeathRecorded)return;
        int slot=victim.PlayerNumber();if(!Member(slot))return;
        victim.StandaloneDeathRecorded=true;Deaths[slot]++;
        RespawnAt[slot]=level.time+CaelumStandaloneData.RESPAWN_TICS;
        let killer=CaelumStandalonePlayer(source);
        int credit=killer!=null?killer.PlayerNumber():-1;
        if(credit!=slot && Member(credit))Score[credit]++;
        else Score[slot]--;
        String line=credit!=slot && Member(credit)
            ?String.Format(StringTable.Localize("CA_MATCH_KILL",false),players[credit].GetUserName(),players[slot].GetUserName())
            :String.Format(StringTable.Localize("CA_MATCH_SELF_DEATH",false),players[slot].GetUserName());
        Console.Printf("%s",line);
        // Evaluar al terminar el tic permite resolver bajas simultáneas.
    }
    void Evaluate()
    {
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
        // Nueva instancia del mapa: elimina proyectiles y estado de la ronda.
        for(int i=0;i<MAXPLAYERS;i++)if(Member(i))
        {
            let body=CaelumStandalonePlayer(players[i].mo);if(body==null)continue;
            body.StandaloneRevision=0;body.StandaloneDeathRecorded=false;body.StandaloneInventoryCleared=false;
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
            if(CVar.GetCVar('ca_standalone_mode').GetInt()!=CaelumStandaloneData.DEATHMATCH
                || !(players[0].mo is 'CaelumStandalonePlayer'))return;
            Store=CaelumStandaloneMatchStore(Actor.Spawn('CaelumStandaloneMatchStore',(0,0,0),NO_REPLACE));
            Store.Match=new('CaelumStandaloneMatch');Store.Match.Revision=1;
            Store.Match.Mode=CaelumStandaloneData.DEATHMATCH;
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
        String line=match.Finished?String.Format(StringTable.Localize('CA_MATCH_WINNER',false),players[match.Winner].GetUserName())
            :seconds>0?String.Format("%02d:%02d",seconds/60,seconds%60):StringTable.Localize('CA_MATCH_OVERTIME',false);
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
        int shown=0;
        for(int row=0;row<MAXPLAYERS;row++)
        {
            int best=-1;
            for(int i=0;i<MAXPLAYERS;i++)if(match.Member(i) && !(shown&(1<<i)) && (best<0 || match.Score[i]>match.Score[best]))best=i;
            if(best<0)break;shown|=1<<best;
            CaelumTrucoMenu.Text(22,75+row*30,String.Format("%d. %s: %d",row+1,players[best].GetUserName(),match.Score[best]));
        }
        if(match.Finished)
        {
            CaelumTrucoMenu.Text(22,340,String.Format(L('CA_MATCH_WINNER'),players[match.Winner].GetUserName()),Font.CR_GOLD);
            CaelumTrucoMenu.Wrap(22,380,730,L('CA_MATCH_REMATCH'));
            CaelumTrucoMenu.Text(22,450,(match.RematchVotes&(1<<consoleplayer))?L('CA_MATCH_WAIT_VOTES'):L('CA_MATCH_ENTER_REMATCH'));
        }
    }
}
