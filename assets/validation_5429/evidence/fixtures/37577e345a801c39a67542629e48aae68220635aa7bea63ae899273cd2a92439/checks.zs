// Isolated #327 checks; never included in the normal PK3.
class CA327Checks : CA318CeilingChecks
{
    Array<Actor> Blocks;
    bool BudgetRun;
    int PeakLiving, SavedSuccess, SavedRemaining, SavedPending, SavedDeadline;

    void Kill(CaelumPortSiege p,int count)
    {
        for(int i=0;i<p.Attackers.Size() && count>0;i++)
        {
            let b=p.Attackers[i].Body;
            if(b==null || !(b is "CaelumMandinga") || b.health<=0)continue;
            b.DamageMobj(null,null,1000000000,'None',DMG_FORCED);count--;
        }
    }
    void ClearDead(CaelumPortSiege p)
    {
        // Budget fixture only: retain encounter records, remove dead test bodies.
        // This is not evidence of production corpse retention or natural combat FPS.
        for(int i=0;i<p.Attackers.Size();i++)
            if(p.Attackers[i].Body!=null && p.Attackers[i].Body.health<=0)p.Attackers[i].Body.Destroy();
    }
    void Opportunity(CaelumPortSiege p)
    {
        p.Reinforcements.NextOpportunity=level.time;
        p.Reinforcements.Tick(p);
        PeakLiving=Max(PeakLiving,p.Reinforcements.Living);
        Check(p.Reinforcements.Living<=CaelumReinforcementData.LIVING_CAP,"reinforcement opportunity respects live cap");
    }
    override void WorldTick()
    {
        Super.WorldTick();
        if(!BudgetRun)return;
        let p=CaelumPortSiege.Get();let r=p.Reinforcements;
        Kill(p,CaelumReinforcementData.LIVING_CAP);ClearDead(p);
        Opportunity(p);
        if(r.Remaining>0)return;
        Check(r.Successful==6600 && r.Pending==0 && p.Attackers.Size()==6601,"all 6600 cumulative Mandingas plus one Zupay registered");
        Check(PeakLiving<=1000,"complete budget never creates over 1000 simultaneous live Mandingas");
        int before=r.Successful;Opportunity(p);
        Check(r.Successful==before,"exhausted reserve does not spawn again");
        Check(r.PlacementCursor<CaelumReinforcementData.FORMATION_SLOTS,"late arrivals reuse authored formation bounds");
        Console.Printf("CA327 BUDGET success=%d remaining=%d peak=%d records=%d",r.Successful,r.Remaining,PeakLiving,p.Attackers.Size());
        BudgetRun=false;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        let p=CaelumPortSiege.Get();let user=CaelumPlayer(players[0].mo);
        if(e.Name=="maps_check")
        {
            Check(CaelumWorldCatalogue.LocationForMap(level.MapName)==e.Args[0],"map has correct stable location ID");
            Check(LevelInfo.MapExists("TACTORS"),"retained actor stress map is registered without launching it");
            Check((p!=null)==(e.Args[0]==CaelumWorldCatalogue.LOCATION_PORT),"siege controller exists only in city");
            if(p!=null)
            {
                Check(p.Attackers.Size()==0 && !p.SiegeStarted,"peaceful city does not deploy attackers");
                Check(p.Reinforcements.Enabled,"normal city enables reinforcements with diagnostic CVar false");
                let cannon=Inventory(Actor.Spawn("CaelumDebugCannonTrial",user.Pos,NO_REPLACE));cannon.AttachToOwner(user);
                let ram=Inventory(Actor.Spawn("CaelumDebugRamTrial",user.Pos,NO_REPLACE));ram.AttachToOwner(user);
                Check(!cannon.Use(false) && !ram.Use(false),"reservoir combat trials reject city");
                cannon.Destroy();ram.Destroy();
            }
        }
        if(e.Name=="siege_start")
        {
            p.Deploy(true);let r=p.Reinforcements;
            p.Boss.Body.bInvulnerable=true;
            Check(r.Enabled && r.Successful==100 && r.Pending==0,"first normal group contains 100 including crew");
            Check(r.InitialCrew.Size()==74 && p.Attackers.Size()==101,"74 operators included; Zupay separate");
            Check(r.Remaining==6500 && r.NextOpportunity==level.time+350,"6600 budget and inherited 350-tic cadence");
            Check(p.Machines.Size()==12 && p.Guns.Size()==42,"authored machines and guns retained");
            SavedSuccess=r.Successful;SavedDeadline=r.NextOpportunity;
        }
        if(e.Name=="siege_before_due")
            Check(p.Reinforcements.Successful==SavedSuccess && p.Reinforcements.NextOpportunity==SavedDeadline,"no early opportunity or banking");
        if(e.Name=="siege_policy")
        {
            let r=p.Reinforcements;int before=r.Successful;
            CaelumCombatActor dead;
            for(int i=0;i<p.Attackers.Size();i++)
                if(p.Attackers[i].Body!=null && p.Attackers[i].Body.health<=0){dead=p.Attackers[i].Body;break;}
            Check(dead!=null && CaelumResurrection.Restore(dead,dead.Pos),"existing native resurrection remains available at cap");
            r.NextOpportunity=level.time;r.Tick(p);
            Check(r.Living==1001 && r.Successful==before,"resurrection can exceed cap; further reinforcement waits");
            let legacy=new("CaelumSiegeReinforcements");
            legacy.Revision=1;legacy.Enabled=true;legacy.Successful=150;legacy.Pending=50;
            legacy.GroupStart=100;legacy.NextOpportunity=r.NextOpportunity;legacy.Placed[0]=true;
            legacy.Initialize(p,false);
            Check(legacy.Revision==2 && legacy.Successful==150 && legacy.Remaining==6450,"revision one updates cumulative budget without respawn");
            Check(legacy.Pending==50 && legacy.GroupStart==100 && legacy.Placed[0]
                && legacy.NextOpportunity==r.NextOpportunity,"migration retains partial identities and deadline");
            legacy.Initialize(p,false);
            Check(legacy.Successful==150 && legacy.Remaining==6450 && legacy.Pending==50,"migration is idempotent");
        }
        if(e.Name=="route_depart")
        {
            let record=user.GetPersistentCharacterState(true);
            record.SewerZupayDefeated=true;record.TarotOwned[CaelumConstants.TAROT_CUPS_ACE]=true;
            Check(CaelumTravelService.Begin(user,CaelumWorldCatalogue.CONNECTION_MAZE_TO_PORT,CaelumJourneyState.MODE_FOOT),"actual MAP02 route opens current city travel plan");
            Check(CaelumJourneyPlan.Confirm(user),"normal travel transaction commits to current city");
        }
        if(e.Name=="route_arrived")
        {
            let journey=CaelumJourneyState.Get(user);
            Check(level.MapName=="MAP03" && CaelumHouseHub.IsCity(),"campaign travel arrives in low-sky city");
            Check(journey!=null && journey.Status==CaelumJourneyState.STATUS_ARRIVED,"normal journey arrival recorded");
            Check(user.GetPersistentCharacterState(false).HasTarotCard(CaelumConstants.TAROT_CUPS_ACE),"travel retains sewer quest card");
        }
        if(e.Name=="siege_cap")
        {
            let r=p.Reinforcements;
            while(r.Successful<1000)Opportunity(p);
            Check(r.Living==1000 && r.Successful==1000,"1000 live cap reached");
            Opportunity(p);Check(r.Successful==1000 && r.Pending==0,"full cap blocks new group");
            Kill(p,99);Opportunity(p);Check(r.Living==901 && r.Successful==1000,"99 vacancies do not start a group");
            Kill(p,1);Opportunity(p);Check(r.Living==1000 && r.Successful==1100,"100 vacancies admit exactly one group");
            r.Tick(p);Check(r.Successful==1100,"same-tic repeat does not bank opportunity");
        }
        if(e.Name=="siege_block")
        {
            let r=p.Reinforcements;Kill(p,1000);ClearDead(p);
            for(int i=5000;i<5100;i++)Blocks.Push(Actor.Spawn("CA327Block",CaelumPortData.FormationPosition(i)));
            int before=r.Successful, nativeBefore=level.total_monsters;
            r.PlacementCursor=5000;Opportunity(p);
            Check(r.Pending==100 && r.Successful==before,"blocked placements keep pending slots and budget");
            Check(level.total_monsters==nativeBefore,"rejected bodies do not inflate native monster count");
            for(int i=0;i<50;i++)Blocks[i].Destroy();
            r.PlacementCursor=5000;Opportunity(p);
            Check(r.Pending==50 && r.Successful==before+50,"partial group counts only successful arrivals");
            SavedSuccess=r.Successful;SavedRemaining=r.Remaining;SavedPending=r.Pending;SavedDeadline=r.NextOpportunity;
        }
        if(e.Name=="siege_saved")
        {
            let r=p.Reinforcements;
            Check(r.Successful==SavedSuccess && r.Remaining==SavedRemaining && r.Pending==SavedPending,"saved counters and pending bitmap survive reload/hub");
            Check(r.NextOpportunity==SavedDeadline,"saved deadline retained");
            Check(r.Placed[49] && !r.Placed[50],"individual pending identities retained");
        }
        if(e.Name=="siege_unblock")
        {
            let r=p.Reinforcements;for(int i=50;i<100;i++)Blocks[i].Destroy();
            r.PlacementCursor=5050;Opportunity(p);
            Check(r.Pending==0 && r.Successful==SavedSuccess+50,"retry completes exact pending group without duplication");
        }
        if(e.Name=="siege_budget")BudgetRun=true;
        if(e.Name=="siege_victory")
        {
            let r=p.Reinforcements;int before=r.Successful;
            p.Boss.Body.SetOrigin(p.Boss.ExitNode.Pos,false);p.ConfirmBossRetreat(p.Boss);
            for(int i=0;i<p.Machines.Size();i++)p.Machines[i].Neutralized=true;
            r.NextOpportunity=level.time;p.Tick();
            Check(p.Victory && p.BossRetreated && r.Stopped && r.Successful==before,"legitimate victory stops reserves before opportunity");
        }
    }
}
class CA327Block : Actor
{
    Default { Radius 64; Height 128; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
