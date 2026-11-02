// Ensayo visual aislado: no añade una criatura ni un poder a la campaña.
class CA440AutomatonCamera : Actor
{
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440AutomatonArtLedger : Inventory
{
    int Started;
    int Stage;
    int Recovered;
    CaelumAutomatonModelBody Display;
    Actor View;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Loaded;
    override void WorldLoaded(WorldEvent e){Loaded=e.IsSaveGame;}
    void Check(bool okay,String label){Console.Printf("CA440A %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440AutomatonArtLedger(user.FindInventory('CA440AutomatonArtLedger'));
        if(ledger==null)
        {
            Loaded=false;
            ledger=CA440AutomatonArtLedger(user.GiveInventoryType('CA440AutomatonArtLedger'));
            ledger.Started=level.time;ledger.Stage=-1;
            ledger.Display=CaelumAutomatonModelBody(Actor.Spawn('CaelumAutomatonModelBody',(0,0,0),NO_REPLACE));
            ledger.View=Actor.Spawn('CA440AutomatonCamera',(110,-90,75),NO_REPLACE);
            players[0].camera=ledger.View;players[1].camera=ledger.View;
            user.SetOrigin((-700,-700,0),false);other.SetOrigin((-800,-800,0),false);
            Check(ledger.Display!=null,"model body spawned");
            Check(ledger.Display!=null && abs(ledger.Display.Height-93.333333)<0.001,"Zupay reference height");
            Check(ledger.Display!=null && ledger.Display.bNOINTERACTION,"appearance has no gameplay collision");
        }
        if(Loaded && ledger.Stage==5 && ledger.Recovered==0)
        {
            ledger.Recovered=1;
            Check(ledger.Display!=null && !ledger.Display.bDestroyed,"saved model identity");
            Check(ledger.View!=null && players[0].camera==ledger.View,"saved native camera");
            Check(ledger.Display.FindState('Attack')!=null && ledger.Display.FindState('Walk')!=null,"saved animation states");
            Console.Printf("CA440A RESULT reload");
        }
        int stage=Min(5,(level.time-ledger.Started)/105);
        if(stage!=ledger.Stage)
        {
            ledger.Stage=stage;
            String pose=stage==0?"Idle":stage==1?"Walk":stage==2?"Attack":stage==3?"Guard":stage==4?"Fallen":"Idle";
            State poseState=stage==1?ledger.Display.FindState('Walk'):stage==2?ledger.Display.FindState('Attack'):
                stage==3?ledger.Display.FindState('Guard'):stage==4?ledger.Display.FindState('Fallen'):ledger.Display.FindState('Idle');
            Check(poseState!=null,"native pose "..pose);
            ledger.Display.SetState(poseState);
            if(stage==5)Console.Printf("CA440A RESULT capture");
        }
        if(stage==2 && (level.time-ledger.Started)%14==0)ledger.Display.SetStateLabel('Attack');
        ledger.View.SetOrigin(stage<5?(110,-90,75):(-110,90,75),false);
        ledger.View.Angle=VectorAngle(-ledger.View.Pos.X,-ledger.View.Pos.Y);ledger.View.Pitch=9;
        if(stage==4)
        {
            ledger.View.SetOrigin((155,-120,110),false);
            ledger.View.Angle=VectorAngle(35-ledger.View.Pos.X,-ledger.View.Pos.Y);ledger.View.Pitch=30;
        }
    }
}
