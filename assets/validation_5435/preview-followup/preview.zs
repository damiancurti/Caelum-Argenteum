// Sólo el escenario manual: recrear su población tras reiniciar el mapa.
class CA322Preview : CA322Probe
{
    bool PendingSeed,PendingRestore;
    override void WorldLoaded(WorldEvent e)
    {
        Manual=true;PendingSeed=!e.IsSaveGame;PendingRestore=e.IsSaveGame;
    }
    override void WorldTick()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        if(User==null || level.MapName!="MAP97")return;
        if(PendingSeed && level.maptime>=3)
        {
            PendingSeed=false;Followers.Clear();Body=null;
            Setup();User.SetOrigin((-300,0,0),false);User.Vel=(0,0,0);User.Angle=180;
            for(int i=0;i<4;i++)
            {
                User.SetPlayerPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_CAPTIVE);
                let follower=CaelumAnchoredResident(Actor.Spawn(Kind(i),(-400-i*50,0,0),NO_REPLACE));
                follower.ChangeTid(322+i);Followers.Push(follower);follower.ReleaseEscortPrisoner(User);
            }
            Body=Followers[0];Console.Printf("CA322 PREVIEW_READY count=%d map=%s",Followers.Size(),level.MapName);
        }
        if(PendingRestore)
        {
            PendingRestore=false;Followers.Clear();
            for(int i=0;i<4;i++)Followers.Push(CaelumAnchoredResident(ActorIterator.Create(322+i).Next()));
            Body=Followers[0];
        }
        // No dejar morir al observador por hambre durante la espera del autor.
        User.CurrentHunger=User.CurrentThirst=User.CurrentSleep=100;
        User.bInvulnerable=true;
        Super.WorldTick();
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(level.MapName!="MAP97" || automapactive || menuactive!=Menu.Off)return;
        let font=Font.GetFont("CaelumText");if(font==null)return;
        for(int i=0;i<3;i++)
            Screen.DrawText(font,Font.CR_WHITE,16,8+i*(font.GetHeight()+2),
                StringTable.Localize(String.Format("CA322_PREVIEW_%d",i),false),DTA_SHADOW,true);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c322_previewcheck")
        {
            Check(Followers.Size()==4,"manual preview has four original companions after map start/restart");
            for(int i=0;i<4;i++)
            {
                let body=CaelumAnchoredResident(ActorIterator.Create(322+i).Next());
                Check(body!=null && body.health>0 && body==Followers[i],"manual preview companion remains live and unique");
            }
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
        }
    }
}
