class CA616Probe : StaticEventHandler
{
    bool Done;
    int Cooldown;
    CaelumTarotJustice Duel;
    void Check(bool value,String name){Console.Printf("CA616 %s %s",value?"PASS":"FAIL",name);}
    void Move(CaelumPlayer p,vector3 point){CaelumTarotJustice.Move(p,point,0);}
    void Own(CaelumPlayer p,int card)
    {let r=p.GetPersistentCharacterState(false);r.TarotOwned[card]=true;r.TarotSelected[card]=true;}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started || m.Hunt==null || Done)return;
        let h=m.Hunt;let p=CaelumPlayer(players[1].mo),q=CaelumPlayer(players[2].mo),v=CaelumPlayer(players[3].mo);
        let r=p.GetPersistentCharacterState(false);
        if(level.time==110)
        {
            let places=h.Arcana.Places;
            for(int card=0;card<22;card++){Move(p,h.Essences[card].Pos);h.Collect(p,card);}
            Move(p,CaelumHuntArcanaData.Marker(9));Move(q,p.Pos+(60,0,0));
            Check(CaelumTarotJustice.Start(p,q,1000),"Justice starts in the hunt arena");Duel=CaelumJusticeLink.View(p).Duel;
            h.CapturePlayer(v);let vr=v.GetPersistentCharacterState(false);vr.TarotCooldownTics=500;Cooldown=500;
            Check(!CaelumTarotJustice.Eligible(v),"captive cannot enter another Justice duel");
            h.Arcana.Armed[1]=true;h.Arcana.Selected[1]=3;CaelumHuntArcana.Fool(p);h.Arcana.Armed[1]=false;
            let rock=places.Bodies[11];vector3 moved=CaelumHuntArcanaData.Marker(18);
            rock.SetOrigin(moved,false);places.BuildNavigation(16,56);
            Check(places.Blocks(moved.XY),"navigation includes moved obstacle outside its original room");
            rock.bSolid=false;places.BuildNavigation(16,56);
            Check(!places.Blocks(moved.XY),"navigation drops non-solid moved obstacle");rock.bSolid=true;
            rock.SetOrigin(moved+(32,0,0),false);places.BuildNavigation(16,56);
            Check(places.Blocks(moved.XY) || places.Blocks(moved.XY+(64,0)),"navigation covers mid-edge obstacle between grid centers");
            let giant=CaelumRestFurnitureItem(Actor.Spawn('CaelumLuxuryBedItem',p.Pos,NO_REPLACE));
            bool all=true;for(int slot=1;slot<4;slot++)all=all && CaelumTarotStar.Giant(CaelumPlayer(players[slot].mo),giant);
            Check(all,"Star bed is giant for every seeker preset");
            Check(!CaelumTarotStar.CanBox(p,giant),"giant furniture rejects Box without Star");Own(p,17);
            Check(CaelumTarotStar.CanBox(p,giant),"Star unlocks existing giant furniture rule");giant.Destroy();
            let guardian=places.Bodies[4];let status=CaelumTarotEmperorBody.Get(guardian);status.Apply(q,30,null);
            Check(CaelumTarotEmperor.Commander(guardian)==q,"Emperor controls map-owned invocation");
            bool objectives=true;for(int i=22;i<78;i++)objectives=objectives && CaelumTarotJustice.Fits(p,h.Essences[i].Pos);
            Check(objectives,"all remaining essence positions fit a seeker");
            bool points=true;for(int i=0;i<CaelumPowerupData.PointCount();i++)points=points && CaelumTarotJustice.Fits(p,CaelumPowerupData.Point(i));
            Check(points,"power-up positions remain accessible after geometry extension");
            bool signs=true;for(int i=0;i<22;i++)signs=signs && CaelumTarotJustice.Fits(p,CaelumHuntArcanaData.Marker(i));
            Check(signs,"all opportunity signs occupy walkable cells");
        }
        if(level.time==150)
        {
            Check(h.Captive(3) && h.Arcana.Pending[1]==4 && h.Arcana.WaitingJustice[1],"Fool defers rescue until caster exits Justice");
            Check(v.GetPersistentCharacterState(false).TarotCooldownTics<Cooldown,"captivity advances Tarot cooldown normally");
            Check(CaelumTarotEmperor.Commander(h.Arcana.Places.Bodies[4])==null && !h.Arcana.Places.Bodies[4].bFriendly,"invocation restores original allegiance after control");
            Duel.ReturnNow();
        }
        if(level.time==250)
        {
            Check(!h.Captive(3) && !CaelumJusticeLink.Bound(p) && p.Distance3D(v)<=128,"deferred Fool returns captive to the labyrinth");
            Move(q,p.Pos+(60,0,0));Check(CaelumTarotJustice.Start(p,q,1000),"second Justice duel starts");
            h.CapturePlayer(q);
            Check(h.Captive(2) && !CaelumJusticeLink.Bound(q) && !CaelumJusticeLink.Bound(p),"capture inside Justice releases pair and retains captivity");
            Move(p,CaelumHuntArcanaData.Marker(4));Move(v,CaelumHuntArcanaData.Marker(17));
            v.Angle=v.AngleTo(h.Arcana.Places.Bodies[17]);
            Console.Printf("CA616 RESULT hunt");Done=true;
        }
    }
}
