class CA304Observer : EventHandler
{
    Actor View;
    CaelumPortSiege ObservedPort;
    bool Started,Completed,BudgetChecked,PlacementChecked;
    int StartedAt,Passed,Failed,MeasurementRevision;
    double StartMS;
    Array<double> PreviousX,PreviousY,PreviousZ;
    ui bool Flushed;
    ui int LastMeasurementRevision;
    ui double LastMS;
    ui Array<double> Intervals;
    ui Array<int> FrameTics;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA304 %s %s",ok?"PASS":"FAIL",label);}
    override bool InputProcess(InputEvent e){return true;}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca304_measure" || !Started)return;
        StartedAt=level.time;StartMS=MSTimeF();Completed=false;Passed=0;Failed=0;
        MeasurementRevision++;
        Console.Printf("CA304 START tic=%d ms=%.6f total=%d cap=%d period=%d",level.time,StartMS,CaelumReinforcementData.TOTAL,CaelumReinforcementData.LIVING_CAP,CaelumPortData.TARGET_UPDATE_TICS);
    }
    override void WorldTick()
    {
        let port=ObservedPort!=null?ObservedPort:CaelumPortSiege.Get();if(port==null)return;
        if(level.time==70)
        {
            let user=CaelumPlayer(players[0].mo);user.bInvulnerable=true;
            let clock=CaelumWorldClock.Get(user,true);
            let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(!Started && port.SiegeStarted && port.RosterSealed && port.Reinforcements!=null && level.time>75)
        {
            let r=port.Reinforcements;
            // Comprime solamente la llegada inicial del control a poblacion tope.
            for(int i=0;i<20 && r.Successful<CA304Data.LIVING_CAP;i++)
            {r.NextOpportunity=level.time;r.Tick(port);}
            Check(r.Enabled && r.Successful==CA304Data.LIVING_CAP && r.Living==CA304Data.LIVING_CAP,"native capped initial deployment");
            Started=true;StartedAt=level.time;StartMS=MSTimeF();
            ObservedPort=port;
            View=Actor.Spawn("CaelumSiegeRouteNode",CA304Data.Camera());View.Angle=CA304Data.ANGLE;
            players[0].camera=View;
            Console.Printf("CA304 START tic=%d ms=%.6f total=%d cap=%d period=%d",level.time,StartMS,CaelumReinforcementData.TOTAL,CaelumReinforcementData.LIVING_CAP,CaelumPortData.TARGET_UPDATE_TICS);
            if(CVar.GetCVar("ca304_render_control").GetBool())RenderControl(port);
        }
        if(!Started || Completed)return;
        bool budget=CVar.GetCVar("ca304_budget_control").GetBool();
        if(budget && !PlacementChecked)
        {
            PlacementChecked=true;let r=port.Reinforcements;
            let blocker=Actor.Spawn("CaelumSummoningProbe",CaelumPortData.FormationPosition(r.PlacementCursor));
            let shape=GetDefaultByType("CaelumMandinga");blocker.A_SetSize(shape.Radius,shape.Height);blocker.bSolid=true;
            int before=r.Successful,reserve=r.Remaining,pending=r.Pending;
            bool placed=r.Place(port,0);blocker.Destroy();
            Check(!placed && r.Successful==before && r.Remaining==reserve && r.Pending==pending,"failed physical placement preserves budget and pending count");
        }
        if(budget && !BudgetChecked && (level.time-StartedAt)%10==0)
        {
            let r=port.Reinforcements;
            if(r.Remaining>0)
            {
                int removed=0;
                for(int i=0;i<port.Attackers.Size() && removed<CaelumReinforcementData.GROUP_SIZE;i++)
                {
                    let body=port.Attackers[i].Body;
                    if(body==null || !(body is "CaelumMandinga") || body.health<=0)continue;
                    body.health=0;body.Die(null,null,DMG_FORCED,'None');removed++;
                }
                r.NextOpportunity=level.time;r.Tick(port);
                Check(r.Successful+r.Remaining==CA304Data.TOTAL && r.Living<=CA304Data.LIVING_CAP,"forced casualty budget conservation and living cap");
            }
            else
            {
                Check(r.Successful==CA304Data.TOTAL && r.Pending==0 && r.GroupCount==60,"exact 6660 budget and final partial group of 60");
                BudgetChecked=true;Console.Printf("CA304 BUDGET_EXHAUSTED tic=%d total=%d living=%d",level.time,r.Successful,r.Living);
            }
        }
        if(level.time%35==0)
        {
            int alive=0,defenders=0,corpses=0,archived=0,shots=0,moving=0,blocked=0,displaced=0,thermal=0,channels=0;
            int oldSize=PreviousX.Size();PreviousX.Resize(port.Attackers.Size());PreviousY.Resize(port.Attackers.Size());PreviousZ.Resize(port.Attackers.Size());
            for(int i=0;i<port.Attackers.Size();i++)
            {
                let body=port.Attackers[i].Body;
                if(body==null || !(body is "CaelumMandinga") || body.health<=0)continue;
                alive++;if(body.Vel.XY.Length()>0.01)moving++;
                if(i<oldSize && (body.Pos-(PreviousX[i],PreviousY[i],PreviousZ[i])).Length()>0.01)displaced++;
                PreviousX[i]=body.Pos.X;PreviousY[i]=body.Pos.Y;PreviousZ[i]=body.Pos.Z;
                if(CaelumCombatActor(body).ThermalState!=null)thermal++;
                if(body.BlockingMobj!=null || body.MovementBlockingLine!=null)blocked++;
            }
            for(int i=0;i<port.Defenders.Size();i++)if(port.Defenders[i]!=null && port.Defenders[i].health>0)defenders++;
            let it=ThinkerIterator.Create("Actor");Actor body;
            while((body=Actor(it.Next()))!=null){if(body.bCorpse)corpses++;if(body.bMissile)shots++;if(body is "CaelumChannelEffect")channels++;}
            it=ThinkerIterator.Create("Actor",CaelumCorpseArchiveData.DORMANT_STAT);
            while((body=Actor(it.Next()))!=null)if(CaelumCorpseArchive.Suspended(body))archived++;
            let r=port.Reinforcements;
            Console.Printf("CA304 SIM tic=%d elapsed=%d ms=%.6f alive=%d total=%d remaining=%d pending=%d defenders=%d corpses=%d archived=%d projectiles=%d moving=%d blocked=%d groups=%d",level.time,level.time-StartedAt,MSTimeF(),alive,r.Successful,r.Remaining,r.Pending,defenders,corpses,archived,shots,moving,blocked,port.Groups);
            Console.Printf("CA304 DETAIL tic=%d displaced=%d npc_thermal=%d player_thermal=%d channels=%d",level.time,displaced,thermal,CaelumThermalBody.Get(players[0].mo)!=null,channels);
            if(alive>CA304Data.LIVING_CAP)Check(false,"living cap exceeded");
        }
        int duration=CVar.GetCVar("ca304_window").GetInt();if(duration<=0)duration=CA304Data.WINDOW;
        if(level.time-StartedAt>=CA304Data.WARMUP+duration && !Completed)
        {
            if(budget)Check(BudgetChecked,"forced-casualty test reached exact final reserve boundary");
            Completed=true;Console.Printf("CA304 DONE failures=%d passes=%d",Failed,Passed);
        }
    }
    void RenderControl(CaelumPortSiege port)
    {
        // Control de dibujo separado: misma geometria y 600 soldados reales,
        // sin atribuir a combate activo una escena cuya simulacion se congela.
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let body=port.Defenders[i];if(body==null)continue;
            body.SetOrigin(CA304Data.SoldierPosition(i),false);body.FindFloorCeiling();
            body.Angle=90;body.SetState(body.SpawnState);body.Vel=(0,0,0);
        }
        let it=ThinkerIterator.Create("Actor");Actor actor;Array<Actor> frozen;
        while((actor=Actor(it.Next()))!=null)
        {
            if(actor==View || actor==players[0].mo)continue;
            if(actor is "CaelumMandinga" || actor is "CaelumZupayColossus")actor.bInvisible=true;
            frozen.Push(actor);
        }
        for(int i=0;i<frozen.Size();i++)frozen[i].ChangeStatNum(CaelumCorpseArchiveData.DORMANT_STAT);
        View.SetOrigin(CA304Data.RenderCamera(),false);View.Angle=270;View.Pitch=CA304Data.RENDER_PITCH;
        Console.Printf("CA304 RENDER_CONTROL soldiers=%d static scene; no active-battle claim",port.Defenders.Size());
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(LastMeasurementRevision!=MeasurementRevision)
        {
            LastMeasurementRevision=MeasurementRevision;Intervals.Clear();FrameTics.Clear();
            LastMS=0;Flushed=false;
        }
        if(Started && level.time-StartedAt<CA304Data.WARMUP)
        {
            let menu=Menu.GetCurrentMenu();
            if(menu is "ConversationMenu")
            {ConversationMenu.SendConversationReply(-1,0);menu.Close();}
        }
        double now=MSTimeF();
        if(Started && !Completed && level.time-StartedAt>=CA304Data.WARMUP)
        {
            if(LastMS>0){Intervals.Push(now-LastMS);FrameTics.Push(level.time);}
            LastMS=now;
        }
        if(Completed && !Flushed)
        {
            Flushed=true;
            for(int i=0;i<Intervals.Size();i++)Console.Printf("CA304 FRAME tic=%d interval=%.6f",FrameTics[i],Intervals[i]);
            Console.Printf("CA304 FRAMES_END count=%d",Intervals.Size());
        }
    }
}
