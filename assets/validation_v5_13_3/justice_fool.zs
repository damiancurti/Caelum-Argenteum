class CA440JusticeFoolBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;Speed 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440JusticeFoolLedger : Inventory
{
    int Phase,Started;
    Actor Body,Blocker;
    double Anima;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440J %s %s",okay?"PASS":"FAIL",label);}
    override void WorldUnloaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440JusticeFoolLedger(user.FindInventory('CA440JusticeFoolLedger')):null;
        if(ledger==null || ledger.Phase!=4 || level.MapName!="CARING")return;
        let visit=CaelumFoolJourney.View(user);
        Check(!CaelumJusticeLink.Bound(user) && (user.Pos-(64,64,0)).Length()<0.01,"Fool resolves Justice before unloading the origin");
        Check(ledger.Body!=null && (ledger.Body.Pos-(320,64,0)).Length()<0.01,"Fool restores the target before its hub snapshot");
        Check(visit!=null && (visit.OriginPosition-(64,64,0)).Length()<0.01,"Fool stores the real origin instead of the Justice arena");
        Check(CaelumTarotService.IsActive(user.GetPersistentCharacterState(false),14),"later power still executes before the Fool transfer");
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440JusticeFoolLedger(user.FindInventory('CA440JusticeFoolLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440JusticeFoolLedger(user.GiveInventoryType('CA440JusticeFoolLedger'));ledger.Phase=1;
            Level.ChangeLevel("CARING",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==1 && level.MapName=="CARING" && level.time>5)
        {
            user.SetOrigin((64,64,0),false);other.SetOrigin((64,300,0),false);user.Angle=0;user.Pitch=0;
            ledger.Body=Actor.Spawn('CA440JusticeFoolBody',(320,64,0),NO_REPLACE);
            Check(CaelumTarotJustice.Start(user,ledger.Body,60*TICRATE),"central pending-travel fixture starts a duel");
            ledger.Blocker=Actor.Spawn('CaelumSummoningProbe',(320,64,0),NO_REPLACE);ledger.Blocker.A_SetSize(160,120);
            CaelumDeadTraveler.ChangeMap("MAP01",0,CHANGELEVEL_NOINTERMISSION);
            Check(CaelumJusticeTransit.Active() && level.MapName=="CARING","central dispatcher queues a blocked return without changing maps");
            ledger.Started=level.time;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && !CaelumJusticeTransit.Active())
        {
            Check(level.MapName=="CARING" && level.time-ledger.Started>=250,"native UI cancellation retains the origin after a visible wait");
            ledger.Blocker.Destroy();ledger.Started=level.time;ledger.Phase=3;return;
        }
        if(ledger.Phase==3 && level.time-ledger.Started>5)
        {
            Check(!CaelumJusticeLink.Bound(user),"cancelled central trip still releases its completed duel");
            other.health=other.player.health=0;other.Die(null,null,0,'None');
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<78;i++)
            {record.TarotOwned[i]=true;record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=0;record.TarotEffectTics=0;
            CaelumTarotService.Select(user,8);CaelumTarotService.Select(user,0);CaelumTarotService.Select(user,14);
            user.CurrentAnima=user.DerivedStats.MaximumAnima;ledger.Anima=user.CurrentAnima;
            user.Angle=0;user.Pitch=0;
            Check(CaelumTarotService.Activate(user),"Justice then Fool creates a real consent request");
            let vote=CaelumCooperativeTravel.View(user);
            if(vote==null){ledger.Phase=99;return;}
            Check(vote.TarotTarget==ledger.Body && !CaelumJusticeLink.Bound(user),"consent captures the target without executing Justice early");
            ledger.Phase=4;vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial);return;
        }
        if(ledger.Phase==4 && level.MapName=="MAP01")
        {
            let record=user.GetPersistentCharacterState(false);let visit=CaelumFoolJourney.View(user);
            Check(user.health>0 && CaelumSpirit.Active(other),"Fool arrival keeps the living caster and dead spiritual traveller");
            Check(abs(user.CurrentAnima-(ledger.Anima-1000))<1 && record.TarotCooldownTics>0,"combined sequence spends Anima and cooldown exactly once");
            Check(!CaelumJusticeTransit.Active() && !CaelumJusticeLink.Bound(user),"arrival has no stale Justice transit or pair");
            Check(visit!=null && visit.Active && (visit.OriginPosition-(64,64,0)).Length()<0.01,"saved Fool return points to the campaign location");
            ledger.Phase=5;user.PersistCharacterState();Console.Printf("CA440J RESULT capture");return;
        }
        if(ledger.Phase==5 && Reloaded)
        {
            let visit=CaelumFoolJourney.View(user);
            Check(level.MapName=="MAP01" && !CaelumJusticeTransit.Active(),"common recovery does not replay the combined trip");
            Check(visit!=null && visit.Active && (visit.OriginPosition-(64,64,0)).Length()<0.01,"common recovery preserves the safe campaign return");
            Check(user.health>0 && CaelumSpirit.Active(other),"common recovery preserves living and spiritual participants");
            ledger.Phase=6;Console.Printf("CA440J RESULT reload");
        }
    }
}
class CA440JusticeFoolUI : StaticEventHandler
{
    ui bool Sent;
    override void UiTick()
    {
        if(consoleplayer!=1 || gamestate!=GS_LEVEL || Sent)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440JusticeFoolLedger(user.FindInventory('CA440JusticeFoolLedger')):null;
        if(ledger==null || ledger.Phase!=2 || level.time-ledger.Started<300)return;
        Sent=true;EventHandler.SendNetworkEvent("ca_justice_cancel");
    }
}
