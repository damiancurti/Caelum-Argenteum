class CA616Probe : StaticEventHandler
{
    Actor Blocker;
    bool Done;
    void Check(bool value,String name){Console.Printf("CA616 %s %s",value?"PASS":"FAIL",name);}
    void Move(CaelumPlayer p,vector3 point){p.SetOrigin(point,false);p.Vel=(0,0,0);p.ClearInterpolation();}
    void Select(CaelumPlayer p,int card)
    {
        let r=p.GetPersistentCharacterState(false);
        for(int i=0;i<78;i++){r.TarotSelected[i]=false;r.TarotActive[i]=false;r.TarotRemaining[i]=0;}
        r.TarotOrderCount=1;r.TarotOrder[0]=card;r.TarotSelected[card]=true;
        r.TarotCooldownTics=0;r.TarotEffectTics=0;p.CurrentAnima=10000;
        p.ApplyCharacterProfile();
    }
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || !m.Started || m.Hunt==null || Done)return;
        let h=m.Hunt;let p=CaelumPlayer(players[1].mo);let victim=CaelumPlayer(players[3].mo);
        let r=p.GetPersistentCharacterState(false);
        if(level.time==110)
        {
            Check(h.Arcana!=null && h.Arcana.Places!=null && CaelumHuntArcanaData.Present(),"current layout owns one saved opportunities registry");
            if(h.Arcana==null || h.Arcana.Places==null){Done=true;return;}
            Check(p.MagicBoxOwned && p.FindInventory('CaelumTarotDeck')!=null,"seeker starts with Box and deck");
            bool markers=true;for(int i=0;i<22;i++)markers=markers && h.Arcana.Places.Markers[i]!=null;
            Check(markers,"22 distributed Arcana locations");
            Check(h.Arcana.Places.Bodies[4]!=null && !h.Arcana.Places.Bodies[4].bDestroyed,"map-owned summoned guardian survives normal ticks");
            h.CapturePlayer(victim);
            for(int card=0;card<22;card++){Move(p,h.Essences[card].Pos);h.Collect(p,card);}
            bool shared=true;for(int slot=1;slot<4;slot++)for(int card=0;card<22;card++)
                shared=shared && CaelumPlayer(players[slot].mo).GetPersistentCharacterState(false).TarotOwned[card];
            Check(shared,"found Major Arcana unlock for all seekers including captive");
            let hunter=CaelumPlayer(players[0].mo).GetPersistentCharacterState(false);
            Check(hunter==null || !hunter.TarotOwned[21],"human Palomo excluded from shared Tarot");
            Move(p,CaelumHuntArcanaData.Marker(9));Select(p,0);
            double anima=p.CurrentAnima;
            Check(!CaelumTarotService.Activate(p) && h.Arcana.Choosing[1] && p.CurrentAnima==anima,"Fool asks for captive before charging");
            h.Arcana.Choose(p,-1);Check(!h.Arcana.Choosing[1] && p.CurrentAnima==anima,"cancelled selection has no charge");
            CaelumTarotService.Activate(p);h.Arcana.Choose(p,3);
            Check(h.Arcana.Pending[1]==4 && r.TarotCooldownTics>0,"Fool queues bounded safe placement and pays one sequence");
        }
        if(level.time==180)
        {
            Check(!h.Captive(3) && h.Arcana.Pending[1]==0,"Fool releases selected captive");
            Check(p.Distance3D(victim)<=CaelumMajorArcanaData.JUSTICE_RETURN_MU && p.CheckSight(victim),"rescued body lies within four metres without crossing a wall");
            Check(victim.GetPersistentCharacterState(false).TarotOwned[21],"rescue preserves captured shared unlocks");
            h.CapturePlayer(victim);Select(p,0);
            Blocker=Actor.Spawn('CaelumTarotRock',p.Pos,NO_REPLACE);Blocker.A_SetSize(256,160);
            CaelumTarotService.Activate(p);h.Arcana.Choose(p,3);
        }
        if(level.time==800)
        {
            Check(h.Captive(3) && h.Arcana.Pending[1]==0,"blocked placement preserves captive without telefrag");
            Blocker.Destroy();Blocker=null;
            let room=h.Arcana.Places.WheelRoom;Move(p,room.Pos);Select(p,10);
            Check(room.Toggle(p,false) && room.Wet,"Wheel activates wet dark state");
            Check(level.Sectors[CaelumHuntArcanaData.WHEEL_WATER].CenterCeiling()==64,"Wheel uses approved two-metre water");
            
            Move(p,CaelumHuntArcanaData.Center(14));Select(p,14);
            let plate=CaelumHuntFreezingPlate(h.Arcana.Places.Bodies[14]);
            p.ElementalStatus.FreezeRemaining=0;
            p.ElementalStatus.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,3,50,p);
            Check(p.ElementalStatus.FreezeRemaining==1.5,"Temperance halves existing freezing duration");
            CaelumTarotService.Activate(p);p.ElementalStatus.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,3,50,p);
            Check(p.ElementalStatus.FreezeRemaining==0,"Temperance active cleanses and prevents freezing");
            Select(p,13);let living=CaelumTarotLivingObstacle(h.Arcana.Places.Bodies[13]);
            Move(p,living.Pos+(-p.Radius-living.Radius,0,0));
            Check(living.DestroyByTarot(p),"Death destroys marked obstacle");
            Check(CaelumMajorTargets.Tower(h.Arcana.Places.Bodies[16]),"Tower destroys real siege machine");
            let fragile=CaelumTarotFragileObstacle(h.Arcana.Places.Bodies[7]);
            Check(fragile.BreakByTarot() && !fragile.bSolid,"Chariot obstacle uses persistent normal break state");
        }
        if(level.time==880)
        {
            let room=h.Arcana.Places.WheelRoom;Move(p,room.Pos);
            Check(room.Toggle(p,false) && !room.Wet,"Wheel returns to dry state after leaves move clear");
            Console.Printf("CA616 RESULT hunt");Done=true;
        }
    }
}
