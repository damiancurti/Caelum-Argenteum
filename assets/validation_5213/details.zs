// Face/hair extension: native texture, persistence and editor contract checks.
class CA148Details : StaticEventHandler
{
    int Failures;
    ui int UIFailures;
    ui bool Covered;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label);}
    ui void UCheck(bool ok,String label)
    {if(!ok)UIFailures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(Covered)return;Covered=true;
        int total=0,missing=0;
        let state=GetDefaultByType("CaelumPlayer").SpawnState;
        for(int race=1;race<4;race++)for(int sex=0;sex<2;sex++)for(int tone=0;tone<3;tone++)
        for(int face=0;face<4;face++)for(int hair=0;hair<4;hair++)for(int color=0;color<6;color++)
        for(int group=0;group<7;group++)for(int view=0;view<8;view++)
        {
            int sprite=CaelumAppearance.HeadSprite(race,sex,tone,face,hair,color);
            TextureID tex;bool flip;Vector2 scale;
            [tex,flip,scale]=state.GetSpriteTexture(view*2,0,(1,1),sprite,group);
            if(sprite<0 || !tex.IsValid())missing++;
            total++;
        }
        UCheck(total==96768 && missing==0,"all 96,768 head textures resolve in GZDoom");
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="d148_camera" && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=="d148_begin" || e.Name=="d148_verify" || e.Name=="d148_camera"
            || e.Name=="d148_teleport" || e.Name=="d148_death" || e.Name=="d148_revone" || e.Name=="d148_sort")
            EventHandler.SendNetworkEvent(e.Name,e.Args[0],e.Args[1],e.Args[2]);
        if(e.Name=="d148_cancel" || e.Name=="d148_confirm")
        {
            Menu.SetMenu("CaelumAppearanceMenu");
            let menu=CaelumAppearanceMenu(Menu.GetCurrentMenu());
            UCheck(menu!=null,"native editor opens");if(menu==null)return;
            UCheck(menu.Face==3 && menu.HairStyle==3 && menu.HairColor==5,"editor loads saved face/hair");
            menu.Face=1;menu.HairStyle=2;menu.HairColor=3;menu.SkinTone=2;
            UCheck(menu.EditProfile.Face==3 && menu.EditProfile.HairStyle==3 && menu.EditProfile.HairColor==5,"head draft cannot change live profile");
            menu.MenuEvent(e.Name=="d148_cancel"?Menu.MKEY_Back:Menu.MKEY_Enter,false);
        }
        if(e.Name=="d148_invalid")EventHandler.SendNetworkEvent("ca_appearance_commit",0,384,1);
        if(e.Name=="d148_stale")EventHandler.SendNetworkEvent("ca_appearance_commit",0,0,0);
        if(e.Name=="d148_menu")
        {
            Menu.SetMenu("CaelumNewCharacterMenu");
            let menu=CaelumCharacterCreationMenu(Menu.GetCurrentMenu());
            menu.Page=CaelumAppearance.PAGE;menu.Race=e.Args[0];menu.Sex=e.Args[1];
            menu.Face=3;menu.HairStyle=3;menu.HairColor=5;menu.SkinTone=2;
        }
        if(e.Name=="d148_done")Console.Printf("CA148 DONE failures=%d",Failures+UIFailures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);
        let p=CaelumCharacterIdentity.Profile(user);
        if(e.Name=="d148_sort" || e.Name=="d148_verify")
            Check((level.compatflags&COMPATF_SPRITESORT)==0,"map keeps native sprite order despite global compatibility preference");
        if(e.Name=="d148_begin")
        {
            p.Race=CaelumConstants.RACE_HUMAN;p.Sex=1;p.SkinTone=1;p.Face=3;p.HairStyle=3;p.HairColor=5;
            p.AppearanceEditSerial=0;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            user.RecordMainM00UnknownVoiceHeard();
        }
        if(e.Name=="d148_verify")
        {
            bool edited=e.Args[0]!=0;
            Check(p.Face==(edited?1:3) && p.HairStyle==(edited?2:3) && p.HairColor==(edited?3:5)
                && p.SkinTone==(edited?2:1),"cancel/confirm/save/restart/travel preserve expected face/hair");
            Check(p.Race==CaelumConstants.RACE_HUMAN && p.Sex==1 && p.AppearanceEditSerial==int(edited),"cosmetic commit preserves identity; exactly one serial");
            Check(p.AppearanceRevision==2,"revision two saved profile");
            let head=user.AppearanceHead;
            Check(head!=null && head.Master==user && head.sprite==CaelumAppearance.HeadSprite(p.Race,p.Sex,p.SkinTone,p.Face,p.HairStyle,p.HairColor),"world head agrees with authoritative profile");
            int count=0;let it=ThinkerIterator.Create('CaelumAppearanceHead');Actor part;
            while((part=Actor(it.Next()))!=null)if(part.Master==user)count++;
            Check(count==1,"one head per pawn after repeated updates/load/travel");
            Check(CaelumAppearance.ValidDetails(3,3,5) && !CaelumAppearance.ValidDetails(4,3,5)
                && !CaelumAppearance.ValidDetails(0,-1,0) && !CaelumAppearance.ValidDetails(0,0,6)
                && !CaelumAppearance.ValidPacked(0,384) && !CaelumAppearance.ValidPacked(0,-1),"new-choice bounds reject malformed data");
        }
        if(e.Name=="d148_camera")
        {
            if(user.player.camera==user)user.player.camera=Actor.Spawn('CA148DetailsCamera',user.Pos+(120,0,28));
            user.player.camera.Angle=180;user.Angle=e.Args[0]*45;
            if(e.Args[1]>=0){p.Race=e.Args[1];p.Sex=e.Args[2];user.ApplyCharacterProfile();}
        }
        if(e.Name=="d148_teleport")
        {
            user.SetOrigin(user.Pos+(0,12,0),false);user.ClearInterpolation();user.AppearanceHead.UpdateVisual();
            Check(user.AppearanceHead.Pos==user.Pos && user.AppearanceHead.Prev==user.Prev,"teleport clears body/head interpolation together");
            double clip=user.FloorClip;user.FloorClip=8;user.AppearanceHead.UpdateVisual();
            Check(user.AppearanceHead.FloorClip==8,"head copies native floor clipping");
            user.FloorClip=clip;user.AppearanceHead.UpdateVisual();
        }
        if(e.Name=="d148_revone")
            Check(p.AppearanceRevision==2 && p.SkinTone==1 && p.BeastForm==0 && p.Face==0 && p.HairStyle==0 && p.HairColor==0,
                "actual revision-one save keeps tone/form and initializes face/hair once");
        if(e.Name=="d148_death")
        {
            int face=p.Face,hair=p.HairStyle,color=p.HairColor;
            user.health=0;user.Die(null,null);
            p.Face=0;p.HairStyle=0;p.HairColor=0;
            user.UpdateWorldCarbineVisual();
            Check(user.AppearanceDeathProfile.Face==face && user.AppearanceDeathProfile.HairStyle==hair
                && user.AppearanceDeathProfile.HairColor==color,"corpse snapshot preserves face and hair independently");
        }
    }
}
class CA148DetailsCamera : Actor
{
    Default{+NOBLOCKMAP +NOINTERACTION +NOGRAVITY}
    States{Spawn: TNT1 A -1;Stop;}
}
