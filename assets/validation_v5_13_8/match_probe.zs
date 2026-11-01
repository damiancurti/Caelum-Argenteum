class CA601MatchProbe : StaticEventHandler
{
    bool Done,Restart;int SavedLife;double SavedAir;
    void Check(bool ok,String label){Console.Printf("CA601 %s %s",ok?"PASS":"FAIL",label);}
    void Move(CaelumPlayer p,vector3 point)
    {p.Vel=(0,0,0);p.SetOrigin(point,false);p.TryMove(point.XY+(0.1,0),false);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(Done || m==null || m.Hunt==null)return;
        let h=m.Hunt;h.Hunter.bDormant=true;
        let a=CaelumStandalonePlayer(players[0].mo);let b=CaelumStandalonePlayer(players[1].mo);
        if(Restart)
        {
            if(m.Finished)return;
            Check(h.Collected==0 && h.CaptiveMask==0 && m.Mode==4,"unanimous rematch resets hunt state");
            Check(a.health>0 && b.health>0 && m.Members==15,"rematch restores four resident presets");
            Console.Printf("CA601 RESULT hunt");Done=true;return;
        }
        if(level.time==100)
        {
            Check(level.MapName=="CAHUNT" && m.Mode==4 && m.Members==15,"four clients enter exclusive hunt map");
            Check(h.Collected==0 && h.Hunter.CombatStrength==100 && h.Hunter.Mass==700,"Palomo retains actual profile and body");
            Check(CaelumJusticeGeometry.Get()!=null,"new maze contains Justice arena");
            int old=a.health;a.DamageMobj(b,b,100000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(a.health==old,"native damage between teammates is prevented");
            Move(a,h.Essences[0].Pos);
        }
        if(level.time==105)
        {
            Check(h.Collected==1 && h.Found[0],"native contact collects first distinct essence");
            Move(b,h.Essences[0].Pos);h.Collect(b,0);h.Collect(a,0);
            Check(h.Collected==1 && m.Score[0]==1 && m.Score[1]==0,"duplicate simultaneous contacts cannot duplicate essence");
            Move(b,h.Essences[1].Pos);
        }
        if(level.time==110)
        {
            Check(h.Collected==2 && m.Score[1]==1,"split collection shares the same counter");
            a.CurrentAir=123;a.health=321;a.player.health=321;
            SavedLife=a.health;SavedAir=a.CurrentAir;h.CapturePlayer(a);
            Check(h.Captive(0) && a.health==SavedLife,"contact capture retains live body and resources");
            Check(!CaelumPlayerAuthority.CanMutate(a),"captive cannot perform material actions");
            Move(b,a.Pos+(48,0,0));
        }
        if(level.time==115)
        {
            Check(a.health==SavedLife && a.CurrentAir==SavedAir,"captive resources remain unchanged");
            Check(!m.Finished,"free teammates keep round alive");
            h.RescueTarget[1]=0;h.RescueProgress[1]=80;
        }
        if(level.time==117)Check(h.RescueProgress[1]==0 && h.Captive(0),"releasing Use cancels incomplete rescue");
        if(level.time==230)
        {
            Check(h.Captive(0) && h.Collected==2,"common save has captive and collected cards");
            h.Rescue(0);Check(!h.Captive(0) && a.health==321 && a.CurrentAir==123,"rescue restores captured resources");
            // Crear el antecedente antes del golpe letal, como al entrar a la trampa.
            Move(a,h.Traps[2].Pos-(0,0,0.5));a.health=777;a.player.health=777;a.CurrentAir=111;
            h.BeginTrap(2);a.DamageMobj(null,null,10000000,'Crush',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(h.Captive(0) && a.health==777 && a.CurrentAir==111,"lethal trap captures with pre-trap resources");
            Check(!a.bCorpse && m.RespawnAt[0]==0,"trap capture creates neither corpse nor respawn debt");
            h.Rescue(0);
        }
        if(level.time==250)
        {
            for(int i=2;i<78;i++){let p=CaelumPlayer(players[i%4].mo);Move(p,h.Essences[i].Pos);h.Collect(p,i);}
        }
        if(level.time==255)
        {
            Check(h.Collected==78 && m.Finished && m.Winner==0,"last distinct essence wins once for everyone");
            h.Collect(a,77);Check(h.Collected==78,"finished collection cannot award again");
            m.VoteRematch(0);m.VoteRematch(1);m.VoteRematch(2);Check(!m.Restarting,"rematch waits for all four votes");
        }
        if(level.time==280){Restart=true;m.VoteRematch(3);}
    }
}
