// Diagnóstico aislado sobre los propietarios nativos de música y sonidos.
class CA464AudioPoint : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA464Probe : StaticEventHandler
{
    int Passed,Failed;
    ui int UIPassed,UIFailed;
    CA464AudioPoint Point;

    void Check(bool okay,String message)
    {if(okay)Passed++;else Failed++;Console.Printf("CA464 %s %s",okay?"PASS":"FAIL",message);}
    ui void CheckUI(bool okay,String message)
    {if(okay)UIPassed++;else UIFailed++;Console.Printf("CA464 %s %s",okay?"PASS":"FAIL",message);}

    static clearscope String ExpectedMusic(int id)
    {
        if(id<0)return "sounds/caelum/stock/music/ca_stock_war_drums.ogg";
        if(id==0)return "CA_MUS02";
        if(id==1)return "CA_MUS03_SEWER";
        return "CA_MUS04_PORT";
    }
    static Sound Cue(int id)
    {
        switch(id)
        {
        case 0:return "caelum/ambience/fire";
        case 1:return "caelum/ambience/rio_waves";
        case 2:return "caelum/ambience/sewer_water";
        case 3:return "caelum/weather/rain_steady";
        case 4:return "caelum/weather/thunder_distant";
        case 5:return "caelum/weather/thunder_heavy";
        case 6:return "caelum/weather/thunder_roomy";
        case 7:return "caelum/weather/wind";
        }
        return "caelum/ui/dialogue_open";
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca464_music')
        {
            String expected=ExpectedMusic(e.Args[0]);
            CheckUI(musplaying.name==expected,"approved music assignment");
            CheckUI(musplaying.loop==(e.Args[0]>=0),"approved native loop policy");
            CheckUI(System.MusicEnabled(),"native music backend enabled");
            CheckUI(Abs(CVar.GetCVar("snd_mastervolume").GetFloat()-.05)<.0001,"five-percent master preference retained");
            CheckUI(Abs(CVar.GetCVar("snd_musicvolume").GetFloat()-e.Args[1]/1000.)<.0001,"music preference retained");
            Console.Printf("CA464 MUSIC name=%s loop=%d volume=%.4f",musplaying.name,musplaying.loop,CVar.GetCVar("snd_musicvolume").GetFloat());
        }
        if(e.Name=='ca464_dialogue_check')
            CheckUI((Menu.GetCurrentMenu() is 'CaelumFoolConversationMenu')==(e.Args[0]!=0),"real conversation menu opens/closes");
        if(e.Name=='ca464_close')
            while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=='ca464_done')
            Console.Printf("CA464 RESULT passed=%d failed=%d",Passed+UIPassed,Failed+UIFailed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(e.Name=='ca464_setup')
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            user.bInvulnerable=true;user.CurrentSleep=user.CurrentLucidity=100;
            user.CurrentHunger=user.CurrentThirst=100;
            user.PersistCharacterState();return;
        }
        if(e.Name=='ca464_dialogue')
        {
            let speaker=Actor.Spawn('CaelumM00FoolEssence',user.Pos+(40,0,0));
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,speaker,null,false,0,
                CaelumTarotArt.ConversationId(CaelumConstants.TAROT_THE_FOOL));
            Check(speaker.HasConversation() && speaker.StartConversation(user,true,true),"actual native conversation starts");
        }
        if(e.Name=='ca464_breath')
        {
            user.CurrentAir=user.DerivedStats.MaximumAir*(e.Args[0]?0.49:1.0);
            CaelumBreathing.UpdateSound(user);
            Check(CaelumBreathing.Playing(user)==(e.Args[0]!=0),"native breathing loop follows current Air");
        }
        if(e.Name=='ca464_loaded_breath')
            Check(CaelumBreathing.Playing(user),"native breathing restored after save/load");
        if(e.Name=='ca464_cue')
        {
            if(Point==null)Point=CA464AudioPoint(Actor.Spawn('CA464AudioPoint',user.Pos));
            Point.A_StopSound(CHAN_BODY);Point.A_StartSound(Cue(e.Args[0]),CHAN_BODY,CHANF_LOOP);
            Check(Point.IsActorPlayingSound(CHAN_BODY,Cue(e.Args[0])),"native cue occupies the one diagnostic channel");
        }
        if(e.Name=='ca464_stop' && Point!=null)
        {Point.A_StopSound(CHAN_BODY);Check(!Point.IsActorPlayingSound(CHAN_BODY),"diagnostic loop releases its channel");}
    }
}
