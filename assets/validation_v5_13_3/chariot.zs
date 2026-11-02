class CA440CartVictim : Actor
{
    Default {Health 100;Radius 8;Height 32;Mass 100;+SOLID +SHOOTABLE +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440CartProp : CaelumMovableProp
{
    Default {Health 100;Radius 8;Height 32;Mass 20;+NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440CartFragile : CaelumTarotFragileObstacle
{
    Default {Health 100;Radius 8;Height 32;+NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440CartUnlinked : CA440CartVictim
{Default {+NOBLOCKMAP}}
class CA440CartLedger : Inventory
{
    int Phase,StartTic,CaptureTic,SavedAge,Checks;
    double SavedDistance;
    CaelumTarotChariot Cart;
    CA440CartVictim Victim;
    CA440CartFragile Fragile;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440C %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440CartLedger(user.FindInventory('CA440CartLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            ledger=CA440CartLedger(user.GiveInventoryType('CA440CartLedger'));
            ledger.CaptureTic=level.time+300;
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.SetOrigin((-512,0,0),false);user.Angle=0;other.SetOrigin((-700,-700,0),false);
            ledger.Fragile=CA440CartFragile(Actor.Spawn('CA440CartFragile',user.Pos+(48,0,0),NO_REPLACE));
            vector3 aim=ledger.Fragile.Pos+(0,0,16)-CaelumTelekinesisRules.Eye(user);
            user.Pitch=-VectorAngle(aim.XY.Length(),aim.Z);
            Check(!user.TryPushMovablePropInFront() && !ledger.Fragile.TarotBroken,"unequipped Chariot cannot use a fragile obstacle");
            CaelumTarotService.Select(user,7);double anima=user.CurrentAnima;
            Check(user.TryPushMovablePropInFront() && ledger.Fragile.TarotBroken,"equipped passive breaks a targeted marked obstacle");user.Pitch=0;
            Check(CaelumTarotService.Activate(user),"native activation launches Chariot");
            let state=CaelumTarotChariotState(user.FindInventory('CaelumTarotChariotState'));
            ledger.Cart=state.Projection;
            Check(ledger.Cart!=null && Abs(user.CurrentAnima-anima+1000)<0.01,"launch charges shared sequence once");
            Check(record.TarotRemaining[7]==0,"instant launch is not a repeated sixty-second effect");
            ledger.Victim=CA440CartVictim(Actor.Spawn('CA440CartVictim',user.Pos+(32,0,0),NO_REPLACE));
            ledger.Cart.Touch(ledger.Victim);double push=ledger.Victim.Vel.X;
            Check(push>0 && ledger.Victim.health==100,"contact pushes a body without direct damage");
            ledger.Cart.Touch(ledger.Victim);
            Check(ledger.Victim.Vel.X==push,"same launch never pushes the same body twice");
            ledger.Victim.SetOrigin((-800,700,0),false);ledger.Victim.Vel=(0,0,0);
            let prop=CA440CartProp(Actor.Spawn('CA440CartProp',user.Pos+(32,0,0),NO_REPLACE));prop.args[0]=1;
            Check(ledger.Cart.Touch(prop) && prop.Vel.X>0 && prop.health==100,"movable scenery uses its existing force threshold");prop.Destroy();
            let fixed=CA440CartProp(Actor.Spawn('CA440CartProp',user.Pos+(32,0,0),NO_REPLACE));
            Check(!ledger.Cart.Touch(fixed) && fixed.health==100,"unmarked fixed scenery is not destroyed");fixed.Destroy();
            ledger.Fragile=CA440CartFragile(Actor.Spawn('CA440CartFragile',user.Pos+(32,0,0),NO_REPLACE));
            Check(ledger.Cart.Touch(ledger.Fragile) && ledger.Fragile.TarotBroken && !ledger.Fragile.bSolid,"marked fragile obstacle breaks without harming unrelated actors");
            double normal=ledger.Cart.Power;
            CaelumTarotSequence.ApplyCard(user,record,11,2100);
            let old=ledger.Cart;ledger.Cart=CaelumTarotChariot.Launch(user);
            Check(old.bDestroyed && state.Projection==ledger.Cart,"recast replaces only this caster's previous projection");
            Check(ledger.Cart.Power>normal && ledger.Cart.Power==CaelumTarotObjectMovement.Push(user),"active Strength changes the launched movement force");
            let late=Actor.Spawn('CA440CartUnlinked',user.Pos+(32,0,0),NO_REPLACE);
            CaelumTarotChariot.RegisteredUnlinked(late);ledger.Cart.Contacts();
            Check(late.Vel.X>0 && late.health==100,"late unlinked guard registration enters only local projection contacts");late.Destroy();
            ledger.Cart.Destroy();user.SetOrigin((850,0,0),false);
            ledger.Cart=CaelumTarotChariot.Launch(user);
            Check(ledger.Cart!=null,"wall test begins in valid free space");
            ledger.Phase=1;ledger.StartTic=level.time;return;
        }
        if(ledger.Phase==1 && level.time-ledger.StartTic>40)
        {
            Check(ledger.Cart==null || ledger.Cart.bDestroyed,"native world ticks stop the cart at the map wall");
            user.SetOrigin((-512,0,0),false);ledger.Cart=CaelumTarotChariot.Launch(user);
            ledger.Victim.SetOrigin(user.Pos+(200,0,0),false);ledger.Victim.Vel=(0,0,0);
            ledger.StartTic=level.time;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && level.time-ledger.StartTic==35)
        {
            Check(Abs(ledger.Cart.Travelled-192)<6,"native half-run advances six meters in one second");
            Check(ledger.Cart.QueryCount<=36,"one local contact query per simulation step");
        }
        if(ledger.Phase==2 && level.time-ledger.StartTic>72)
        {
            Check(ledger.Cart==null || ledger.Cart.bDestroyed,"projection expires after its two-second traversal");
            Check(ledger.Victim.Pos.X>user.Pos.X+200 && ledger.Victim.health==100,"native local queries push a newly reached body without damage");
            ledger.Phase=3;return;
        }
        if(ledger.Phase==3 && level.time>=ledger.CaptureTic)
        {
            user.SetOrigin((-512,0,0),false);ledger.Cart=CaelumTarotChariot.Launch(user);
            ledger.Victim.SetOrigin(user.Pos+(32,0,0),false);ledger.Victim.Vel=(0,0,0);
            ledger.Cart.Touch(ledger.Victim);ledger.Victim.SetOrigin((-800,700,0),false);ledger.Victim.Vel=(0,0,0);
            ledger.Phase=4;Console.Printf("CA440C RESULT capture");return;
        }
        if(ledger.Phase==4 && !Reloaded && ledger.Cart!=null)
        {ledger.SavedAge=ledger.Cart.Age;ledger.SavedDistance=ledger.Cart.Travelled;}
        if(ledger.Phase==4 && Reloaded)
        {
            let state=CaelumTarotChariotState(user.FindInventory('CaelumTarotChariotState'));
            Check(ledger.Cart!=null && state.Projection==ledger.Cart,"recovery preserves the exact projection and owner");
            if(ledger.Cart!=null)
            {
                Check(ledger.Cart.Age>=ledger.SavedAge && ledger.Cart.Age<=ledger.SavedAge+1
                    && ledger.Cart.Travelled>=ledger.SavedDistance,"recovery does not restart distance or elapsed time");
                ledger.Victim.SetOrigin(ledger.Cart.Pos+(32,0,0),false);ledger.Victim.Vel=(0,0,0);
                ledger.Cart.Touch(ledger.Victim);
                Check(ledger.Victim.Vel.X==0,"recovery preserves already-contacted actors");
                ledger.Victim.SetOrigin((-800,700,0),false);ledger.Cart.Destroy();
            }
            Check(ledger.Fragile.TarotBroken && !ledger.Fragile.bSolid,"destroyed fragile obstacle stays destroyed after load");
            ledger.Phase=5;Console.Printf("CA440C RESULT reload");
        }
    }
}
