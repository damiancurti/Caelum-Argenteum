class CA617Probe : StaticEventHandler
{
    bool Checked,Contact,Ending,Done;
    int Human,Victim;
    void Check(bool value,String name){Console.Printf("CA617 %s %s",value?"PASS":"FAIL",name);}
    void Move(CaelumPlayer p,vector3 point){p.SetOrigin(point,false);p.Vel=(0,0,0);p.ClearInterpolation();}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started || m.Hunt==null || Done)return;
        if(Ending)
        {
            Check(m.PlayerPalomo==Human+1,"rematch preserves human role");
            Check(m.Hunt.Hunter==null && m.Hunt.CaptiveMask==0 && m.Hunt.Collected==0,"rematch resets seekers without a duplicate NPC");
            Check(CaelumTarotHunt.HumanHunter(CaelumPlayer(players[Human].mo)),"rematch reapplies Palomo body");
            Console.Printf("CA617 RESULT hunter");Done=true;return;
        }
        if(level.time==110)
        {
            Human=m.PlayerPalomo-1;Victim=(Human+1)%4;
            Check(Human>=0 && Human<4,"one human role selected by host");if(Human<0){Done=true;return;}
            let p=CaelumStandalonePlayer(players[Human].mo);let h=m.Hunt;
            Check(h.Hunter==null && p.StandaloneHunter,"human replaces NPC hunter");
            Check(p.Mass==GetDefaultByType('CaelumPalomo').Mass && p.Radius==16 && p.Height==56,"native Palomo body dimensions and mass");
            Check(p.Attributes.Strength==100 && p.Attributes.Insight==100 && p.Attributes.Patience==100,"native Palomo attributes");
            Check(!CaelumPlayerAuthority.CanMutate(p) && !p.bPickup && p.player.ReadyWeapon==null,"hunter cannot act as a seeker or acquire inventory");
            Check(!CaelumTarotService.Activate(p) && !CaelumLabyrinthPowerups.Apply(p,1),"Tarot and power-ups rejected");
            int life=p.health;p.DamageMobj(players[Victim].mo,players[Victim].mo,1000000,'Normal',DMG_FORCED,0);
            Check(p.health==life,"normal damage retains divine immunity");
            p.player.cmd.forwardmove=6400;p.player.cmd.sidemove=6400;p.MovePlayer();
            Check(Abs(p.Vel.XY.Length()-p.HunterSpeed)<0.0001,"diagonal movement matches NPC speed without extra run multiplier");
            p.player.cmd.forwardmove=p.player.cmd.sidemove=0;p.MovePlayer();
            Move(p,h.Essences[0].Pos);h.Collect(p,0);
            Check(!h.Found[0],"hunter cannot collect a quest essence");
            Move(p,CaelumHuntData.HunterStart());
            let victim=CaelumPlayer(players[Victim].mo);Move(victim,p.Pos+(p.Radius+victim.Radius,0,0));
            Checked=true;
        }
        if(Checked && level.time==114)
        {
            let p=CaelumPlayer(players[Human].mo);let h=m.Hunt;
            Check(h.Captive(Victim) && !h.Captive(Human),"native touching captures only a seeker");
            Move(p,CaelumHuntData.HunterStart());
            h.CapturePlayer(p,true);Check(!h.Captive(Human),"hunter cannot be captured by a fatal trap callback");
            p.player.cmd.buttons|=BT_USE;h.Tick(m);
            Check(h.RescueProgress[Human]==0,"hunter cannot perform a rescue");
            p.player.cmd.buttons=0;Contact=true;
            let observer=CaelumPlayer(players[(Human+2)%4].mo);
            Move(observer,p.Pos+(-112,-112,0));observer.Angle=45;observer.Pitch=0;
        }
        if(Contact && level.time==245)
        {
            let h=m.Hunt;h.Collected=78;h.Tick(m);
            Check(m.Finished && m.Winner==0,"seekers win at 78 without counting hunter");
            Ending=true;
            for(int i=0;i<MAXPLAYERS;i++)if(m.Member(i))m.VoteRematch(i);
        }
    }
}
