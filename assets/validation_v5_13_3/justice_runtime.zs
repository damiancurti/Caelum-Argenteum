class CA440DuelBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;Speed 0;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440DuelLedger : Inventory
{
    int Phase,Started,Remaining;
    CaelumTarotJustice First,Second;
    CA440DuelBody A,B;
    Actor Blocker;
    vector3 Home;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440D %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440DuelLedger(user.FindInventory('CA440DuelLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Check(CaelumJusticeGeometry.Get()==null && !CaelumTarotJustice.Start(user,other,60*TICRATE),"legacy map omits Justice without teleporting");
            ledger=CA440DuelLedger(user.GiveInventoryType('CA440DuelLedger'));ledger.Phase=1;
            Level.ChangeLevel("CARING",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(level.MapName!="CARING")return;
        if(ledger.Phase==1 && level.time>5)
        {
            user.SetOrigin((64,64,0),false);other.SetOrigin((64,300,0),false);
            user.Angle=0;user.Pitch=0;ledger.Home=user.Pos;
            let record=user.GetPersistentCharacterState(false);
            for(int i=0;i<78;i++){record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
            record.TarotOwned[8]=record.TarotOwned[9]=true;
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=2000;
            CaelumTarotService.Select(user,8);CaelumTarotService.Select(user,9);
            ledger.A=CA440DuelBody(Actor.Spawn('CA440DuelBody',(160,64,0),NO_REPLACE));
            ledger.B=CA440DuelBody(Actor.Spawn('CA440DuelBody',(160,300,0),NO_REPLACE));
            ledger.Phase=2;return;
        }
        if(ledger.Phase==2)
        {
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"native Tarot service dispatches Justice");
            let link=CaelumJusticeLink.View(user);ledger.First=link!=null?link.Duel:null;
            Check(ledger.First!=null && ledger.First.Bodies[1]==ledger.A,"aimed native body becomes the paired target");
            if(ledger.First==null){ledger.Phase=99;return;}
            Check(Abs(user.CurrentAnima-(anima-1000))<0.01 && ledger.First.RemainingTics==120*TICRATE,"single payment and first-card Hermit duration");
            Check(user.CurSector==CaelumJusticeGeometry.Get() && ledger.A.CurSector==user.CurSector,"only paired bodies enter the shared room");
            Check((other.Pos-(64,300,0)).Length()<1,"unpaired player remains in the original scene");
            Check(!CaelumTarotJustice.Start(other,ledger.A,60*TICRATE),"already paired target rejects a second duel");
            Check(CaelumTarotJustice.Start(other,ledger.B,60*TICRATE),"another caster creates an independent pair in the same arena");
            ledger.Second=CaelumJusticeLink.View(other).Duel;
            Check(ledger.Second!=ledger.First && other.CurSector==user.CurSector && user.Distance2D(other)>user.Radius+other.Radius,"pair placement reserves free physical positions");
            ledger.First.RemainingTics=1;ledger.Started=level.time;ledger.Phase=3;return;
        }
        if(ledger.Phase==3 && level.time-ledger.Started>2)
        {
            Check(!CaelumJusticeLink.Bound(user) && (user.Pos-ledger.Home).Length()<0.01,"expiry returns the first survivor to the original position");
            Check(CaelumJusticeLink.Bound(other) && other.CurSector==CaelumJusticeGeometry.Get(),"first expiry does not terminate the other pair");
            Check(CaelumTarotJustice.Start(user,ledger.A,60*TICRATE),"returned bodies can enter a later pair");
            ledger.First=CaelumJusticeLink.View(user).Duel;
            ledger.Blocker=Actor.Spawn('CaelumSummoningProbe',ledger.Home,NO_REPLACE);ledger.Blocker.A_SetSize(250,120);
            Check(!ledger.First.ReturnNow() && CaelumJusticeLink.Bound(user),"occupied origin keeps return pending without telefragging");
            CaelumDeadTraveler.ChangeMap("TCOAST",0,CHANGELEVEL_NOINTERMISSION);
            Check(CaelumJusticeTransit.Active() && level.MapName=="CARING","map change waits for the blocked Justice return");
            ledger.Started=level.time;ledger.Phase=4;return;
        }
        if(ledger.Phase==4 && level.time-ledger.Started>200)
        {
            Check(CaelumJusticeLink.Bound(user) && user.health>0 && ledger.Blocker!=null,"blocked search preserves bodies and obstruction");
            Check(CaelumJusticeTransit.Active(),"pending travel remains available while its return is blocked");
            CaelumJusticeTransit.View().Cancel();
            Check(!CaelumJusticeTransit.Active() && level.MapName=="CARING","pending map change remains cancellable");
            ledger.Blocker.A_ChangeLinkFlags(1,0);CaelumContaminationWorld.Get().ContactGrid().Track(ledger.Blocker);
            Check(!CaelumTarotJustice.Fits(user,ledger.Home),"local physical registry also blocks unlinked bodies");
            ledger.Blocker.Destroy();ledger.Started=level.time;ledger.Phase=5;return;
        }
        if(ledger.Phase==5 && level.time-ledger.Started>3)
        {
            Check(!CaelumJusticeLink.Bound(user) && (user.Pos-ledger.Home).Length()<0.01,"clearing the obstruction resolves the saved return");
            Check(CaelumTarotJustice.Start(user,ledger.A,60*TICRATE),"alternate-point test creates a fresh pair");
            ledger.First=CaelumJusticeLink.View(user).Duel;
            ledger.Blocker=Actor.Spawn('CaelumSummoningProbe',ledger.Home,NO_REPLACE);ledger.Blocker.A_SetSize(20,100);
            ledger.First.ReturnNow();ledger.Started=level.time;ledger.Phase=6;return;
        }
        if(ledger.Phase==6 && level.time-ledger.Started>100)
        {
            Check(!CaelumJusticeLink.Bound(user) && (user.Pos-ledger.Home).Length()>0 && (user.Pos-ledger.Home).Length()<=128,"nearby unobstructed point is used inside the approved four metres");
            Check(user.health>0 && ledger.Blocker!=null,"alternate return causes no telefrag or destruction");
            ledger.Blocker.Destroy();CaelumTarotJustice.Move(user,ledger.Home,0);
            Check(CaelumTarotJustice.Start(user,ledger.A,60*TICRATE),"save fixture retains an active pair");
            ledger.First=CaelumJusticeLink.View(user).Duel;ledger.Remaining=ledger.First.RemainingTics;
            vector3 oldOrigin=ledger.First.Origins[0];ledger.First.Origins[0]=(-20,64,0);
            Check(!ledger.First.Reachable(0,(32,64,0)),"fallback cannot cross the solid arena boundary");
            ledger.First.Origins[0]=oldOrigin;
            ledger.Phase=9;user.PersistCharacterState();Console.Printf("CA440D RESULT capture");return;
        }
        if(ledger.Phase==9 && Reloaded)
        {
            Check(ledger.First!=null && CaelumJusticeLink.View(user).Duel==ledger.First && CaelumJusticeLink.View(ledger.A).Duel==ledger.First,"recovery retains exact paired actors and links");
            Check(ledger.First.RemainingTics>0 && ledger.First.RemainingTics<ledger.Remaining,"recovery does not restart the pair timer");
            Check((ledger.First.Origins[0]-ledger.Home).Length()<0.01 && user.CurSector==CaelumJusticeGeometry.Get(),"recovery preserves original destination and arena position");
            ledger.A.health=0;ledger.Started=level.time;ledger.Phase=10;return;
        }
        if(ledger.Phase==10 && level.time-ledger.Started>2)
        {
            Check(!CaelumJusticeLink.Bound(user) && (user.Pos-ledger.Home).Length()<0.01,"death ends the pair and returns the survivor");
            Check(ledger.A.CurSector==CaelumJusticeGeometry.Get() && ledger.A.health<=0,"dead body is not resurrected or duplicated by return");
            ledger.Phase=11;Console.Printf("CA440D RESULT reload");
        }
    }
}
