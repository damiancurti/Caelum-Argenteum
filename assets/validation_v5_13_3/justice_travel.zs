class CA440TravelBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;Speed 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440TravelLedger : Inventory
{
    int Phase,Started;
    CaelumTarotJustice Duel;
    CA440TravelBody Body;
    Actor Blocker;
    CaelumHousePortal Portal;
    CaelumCooperativeTravel Vote;
    double Anima;
    String Destination;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440V %s %s",okay?"PASS":"FAIL",label);}
    override void WorldUnloaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440TravelLedger(user.FindInventory('CA440TravelLedger')):null;
        if(ledger==null || ledger.Phase!=4 || level.MapName!="CARING")return;
        Check(!CaelumJusticeLink.Bound(user) && (user.Pos-(64,64,0)).Length()<0.01,
            "native map unload occurs only after the survivor returned");
        Check(ledger.Body!=null && (ledger.Body.Pos-(320,300,0)).Length()<0.01,
            "NPC survivor is restored before the hub snapshot");
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440TravelLedger(user.FindInventory('CA440TravelLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440TravelLedger(user.GiveInventoryType('CA440TravelLedger'));ledger.Phase=1;
            Level.ChangeLevel("CARING",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==1 && level.MapName=="CARING" && level.time>5)
        {
            user.SetOrigin((64,64,0),false);other.SetOrigin((64,300,0),false);user.Angle=other.Angle=0;user.Pitch=other.Pitch=0;
            ledger.Body=CA440TravelBody(Actor.Spawn('CA440TravelBody',(320,300,0),NO_REPLACE));
            ledger.Portal=CaelumHousePortal(Actor.Spawn('CaelumHousePortal',(112,64,0),NO_REPLACE));
            ledger.Destination=ledger.Portal.DestinationMap();
            Check(CaelumTarotJustice.Start(user,ledger.Body,60*TICRATE),"travel fixture starts a real Justice pair");
            ledger.Duel=CaelumJusticeLink.View(user).Duel;
            ledger.Blocker=Actor.Spawn('CaelumSummoningProbe',(320,300,0),NO_REPLACE);ledger.Blocker.A_SetSize(160,120);
            ledger.Duel.ReturnNow();
            Check((user.Pos-(64,64,0)).Length()<0.01 && CaelumJusticeLink.Bound(user),"one survivor can return while its partner remains blocked");
            Check(CaelumCooperativeTravel.ProposeHouse(user,ledger.Portal),"ordinary house travel opens the session vote");
            ledger.Vote=CaelumCooperativeTravel.View(user);if(ledger.Vote==null){ledger.Phase=99;return;}
            Check(ledger.Vote.Request(user,CaelumCooperativeTravel.ACCEPT,ledger.Vote.Serial),"first native travel consent is recorded");
            Check(ledger.Vote.Request(other,CaelumCooperativeTravel.ACCEPT,ledger.Vote.Serial),"second native travel consent reaches the Justice gate");
            Check(ledger.Vote.Opened && ledger.Vote.JusticeWaiting && !ledger.Vote.Committed && level.MapName=="CARING", "unanimity waits before committing the blocked trip");
            ledger.Started=level.time;ledger.Anima=user.CurrentAnima;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && level.time-ledger.Started>15)
        {
            Check(ledger.Vote.Opened && ledger.Vote.JusticeWaiting,"native vote stays pending while the NPC destination is blocked");
            Check(ledger.Vote.Request(other,CaelumCooperativeTravel.CANCEL,ledger.Vote.Serial) && !ledger.Vote.Opened,"either participant can cancel the waiting vote");
            Check(level.MapName=="CARING" && user.CurrentAnima>=ledger.Anima,"cancelled waiting vote charges no Tarot sequence");
            ledger.Blocker.Destroy();ledger.Started=level.time;ledger.Phase=3;return;
        }
        if(ledger.Phase==3 && level.time-ledger.Started>3)
        {
            Check(!CaelumJusticeLink.Bound(user),"cancelled travel does not prevent the pending return from completing");
            Check(CaelumTarotJustice.Start(user,ledger.Body,60*TICRATE),"second travel test starts with an active duel");
            ledger.Portal.SetOrigin((112,300,0),false);
            Check(CaelumCooperativeTravel.ProposeHouse(other,ledger.Portal),"unpaired proposer can request group travel");
            ledger.Vote=CaelumCooperativeTravel.View(other);if(ledger.Vote==null){ledger.Phase=99;return;}
            ledger.Vote.Request(other,CaelumCooperativeTravel.ACCEPT,ledger.Vote.Serial);
            ledger.Phase=4;ledger.Vote.Request(user,CaelumCooperativeTravel.ACCEPT,ledger.Vote.Serial);return;
        }
        if(ledger.Phase==4 && level.MapName==ledger.Destination)
        {
            Check(!CaelumJusticeLink.Bound(user) && !CaelumJusticeTransit.Active(),"both clients reach the destination without stale duel or pending transit");
            Check(!CaelumJusticeLink.Bound(other) && user.health>0 && other.health>0,"travel preserves both living native players");
            ledger.Phase=5;user.PersistCharacterState();Console.Printf("CA440V RESULT capture");return;
        }
        if(ledger.Phase==5 && Reloaded)
        {
            Check(level.MapName==ledger.Destination && !CaelumJusticeTransit.Active(),"recovery does not repeat the completed trip");
            Check(!CaelumJusticeLink.Bound(user) && !CaelumJusticeLink.Bound(other),"recovery keeps completed Justice links released");
            ledger.Phase=6;Console.Printf("CA440V RESULT reload");
        }
    }
}
