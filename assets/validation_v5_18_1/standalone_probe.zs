// Prueba aislada: no se distribuye con el juego.
class CA467Probe : StaticEventHandler
{
    ui bool Gallery;
    override void OnRegister(){SetOrder(1000);}
    override void RenderOverlay(RenderEvent e)
    {
        if(!Gallery)return;
        Screen.Dim(0x292929,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        String names[]={"PUFFA0","PUFFB0","PUFFC0","PUFFD0","BLUDC0","BLUDB0","BLUDA0","FAXEI0","SW1EXIT","SW2EXIT","ARM1A0","ARM2A0"};
        double scale=Screen.GetHeight()/720.;
        for(int i=0;i<12;i++)
        {
            double x=(90+(i%4)*300)*scale,y=(70+(i/4)*150)*scale;
            let texture=TexMan.CheckForTexture(names[i]);let size=TexMan.GetScaledSize(texture);
            double zoom=Min(120./size.X,110./size.Y)*scale;
            Screen.DrawTexture(texture,false,x+60*scale,y+55*scale,DTA_DestWidthF,size.X*zoom,DTA_DestHeightF,size.Y*zoom,DTA_CenterOffset,true);
            Screen.DrawText(Font.GetFont("CaelumText"),Font.CR_WHITE,x,y+120*scale,names[i],DTA_ScaleX,scale,DTA_ScaleY,scale);
        }
    }
    static clearscope void Check(bool okay,String label)
    {Console.Printf("CA467 %s %s",okay?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca467_title')
        {
            CA467Textures.Run();
            Check(gameinfo.normforwardmove[0]==25 && gameinfo.normforwardmove[1]==50,"retained native forward input");
            Check(gameinfo.normsidemove[0]==24 && gameinfo.normsidemove[1]==40,"retained native sideways input");
            Check(Wads.CheckNumForFullName("maps/MAP01.wad")>=0 && Wads.CheckNumForFullName("maps/MAP02.wad")>=0 && Wads.CheckNumForFullName("maps/MAP03.wad")>=0,"prologue maps included");
            Check(Wads.CheckNumForFullName("maps/TACTORS.wad")<0 && Wads.CheckNumForFullName("maps/THAZARD.wad")<0 && Wads.CheckNumForFullName("maps/TMAINT.wad")<0 && Wads.CheckNumForFullName("maps/TRESERV.wad")<0 && Wads.CheckNumForFullName("maps/TTAROT.wad")<0,"five development maps excluded");
            Check(CaelumCreditsData.COUNT==30,"all thirty notices indexed");
            Menu.SetMenu('MainMenu');
        }
        if(e.Name=='ca467_done')Console.Printf("CA467 COMPLETE");
        if(e.Name=='ca467_gallery')Gallery=e.Args[0]!=0;
        if(e.Name=='ca467_close')while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca467_world')return;
        let user=CaelumPlayer(players[e.Player].mo);
        Check(user!=null,"native project player");if(user==null)return;
        Check(user.FindInventory('Pistol')==null && user.FindInventory('Fist')==null && user.FindInventory('Clip')==null,"no inherited Doom starting inventory");
        Check(user.BloodType=='Blood' && user.BloodType2=='BloodSplatter' && user.BloodType3=='AxeBlood',"native blood ownership retained");
        let puff=Actor.Spawn('BulletPuff',user.Pos+(0,0,user.Height));
        let blood=Actor.Spawn('Blood',user.Pos+(0,0,user.Height));
        let axe=Actor.Spawn('AxeBlood',user.Pos+(0,0,user.Height));
        Check(puff!=null && TexMan.CheckForTexture("PUFFA0").isValid(),"native impact actor starts with owned resource");
        Check(blood!=null && TexMan.CheckForTexture("BLUDC0").isValid(),"native blood actor starts with owned resource");
        Check(axe!=null && TexMan.CheckForTexture("FAXEF0").isValid(),"native axe blood actor starts with owned resource");
        let profile=CaelumCharacterIdentity.Profile(user);Check(profile!=null,"character identity available");if(profile==null)return;
        int original=profile.Sex;
        profile.Sex=CaelumConstants.SEX_MALE;user.UpdateNativeVoiceClass();
        Check(user.SoundClass=='caelum_male',"male profile native voice class");
        user.A_StartSound("*death",CHAN_VOICE);
        Console.Printf("CA467 SOUND male any=%d alias=%d concrete=%d",user.IsActorPlayingSound(CHAN_VOICE),user.IsActorPlayingSound(CHAN_VOICE,"*death"),user.IsActorPlayingSound(CHAN_VOICE,"caelum/player/pain_male"));
        Check(user.IsActorPlayingSound(CHAN_VOICE,"*death"),"male native death alias starts voice channel");
        user.A_StopSound(CHAN_VOICE);
        profile.Sex=CaelumConstants.SEX_FEMALE;user.UpdateNativeVoiceClass();
        Check(user.SoundClass=='caelum_female',"female profile native voice class");
        user.A_StartSound("*death",CHAN_VOICE);
        Console.Printf("CA467 SOUND female any=%d alias=%d concrete=%d",user.IsActorPlayingSound(CHAN_VOICE),user.IsActorPlayingSound(CHAN_VOICE,"*death"),user.IsActorPlayingSound(CHAN_VOICE,"caelum/player/pain_female"));
        Check(user.IsActorPlayingSound(CHAN_VOICE,"*death"),"female native death alias starts voice channel");
        user.A_StopSound(CHAN_VOICE);profile.Sex=original;user.UpdateNativeVoiceClass();
        Name expected=user.SoundClass;user.SoundClass='player';user.UpdateNativeVoiceClass();
        Check(user.SoundClass==expected,"legacy native voice class repaired");
        user.UpdateNativeVoiceClass();Check(user.SoundClass==expected,"voice repair idempotent");
        Check(level.MapName~==(e.Args[0]==2?"MAP02":"MAP01"),"requested native map loaded");
        Check(level.Time>=105,"world advances unpaused");
        Console.Printf("CA467 WORLD COMPLETE");
    }
}
