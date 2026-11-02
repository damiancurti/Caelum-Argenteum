class CA440RootBody : CaelumCombatActor
{
    int Actions,Incoming;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {if(mod=='CaelumTarotPiercing')Incoming+=damage;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    action void A_ContinueActing(){let body=CA440RootBody(self);body.Actions++;}
    Default {Health 10000;Radius 12;Height 56;Mass 80;Speed 8;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A 1 A_ContinueActing;Loop;}
}
class CA440RootLedger : Inventory
{
    int Phase,Started,Life,Actions;
    double Power,DamageFraction;
    CA440RootBody Body;
    CaelumTarotRoots Roots;
    CaelumTarotGroundAim Snapshot;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440E %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440RootLedger(user.FindInventory('CA440RootLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440RootLedger(user.GiveInventoryType('CA440RootLedger'));
            let record=user.GetPersistentCharacterState(false);
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.SetOrigin((-300,0,0),false);other.SetOrigin((-300,200,0),false);
            ledger.Body=CA440RootBody(Actor.Spawn('CA440RootBody',(0,0,0),NO_REPLACE));
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            ledger.Body.health=10000;ledger.Body.bFriendly=false;
            vector3 ray=ledger.Body.Pos+(0,0,28)-CaelumTelekinesisRules.Eye(user);
            user.Angle=VectorAngle(ray.X,ray.Y);user.Pitch=-VectorAngle(ray.XY.Length(),ray.Z);
            ledger.Snapshot=CaelumTarotGroundAim.Capture(user);
            CaelumTarotService.Select(user,3);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"native selected sequence casts Empress on its aimed target");
            let holder=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState'));ledger.Roots=holder.Roots;
            Check(ledger.Roots!=null && ledger.Roots.Victim==ledger.Body && ledger.Roots.Binding==ledger.Body.TarotRoots,
                "root creation binds the exact victim and caster");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01,"Empress uses one shared payment");
            Check(ledger.Roots.RemainingTics==4200,"Hermit doubles the plant lifetime");
            Check(Abs(ledger.Roots.DamagePerSecond*60-ledger.Snapshot.Damage)<0.01,"Hermit preserves approved damage per second");
            Check(!ledger.Body.ThermalTryMove((8,0)) && ledger.Body.Pos.X==0,"roots prevent ordinary NPC locomotion");
            let walker=new("CaelumPrisonerEscort");
            Check(walker.Immobilized(ledger.Body) && !walker.MoveTowards(ledger.Body,(80,0),8,-1)
                && ledger.Body.Vel.X==0 && ledger.Body.Vel.Y==0,"companion and escort velocity movement cannot bypass roots");
            Check(ledger.Body.ForcedSleepTics==0 && ledger.Body.tics>=0,"roots do not suspend attack state progression");
            ledger.Power=ledger.Roots.DamagePerSecond;ledger.Actions=ledger.Body.Actions;
            ledger.Started=level.time;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && level.time-ledger.Started>=TICRATE)
        {
            Check(ledger.Body.Actions>ledger.Actions,"native actor actions continue while rooted");
            Check(ledger.Body.Incoming==int(ledger.Power+1e-8),"one native second delivers the approved piercing dose");
            Check(!CaelumArmorRules.IsMagical(ledger.Roots,'CaelumTarotPiercing'),"spikes use normal physical defenses");
            Check(ledger.Roots.RemainingTics<=4200-TICRATE,"world ticks reduce the stored remaining duration");
            let original=ledger.Roots;
            Check(CaelumTarotRoots.Place(user,other,2100,ledger.Snapshot),"another living visible target is valid");
            let holder=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState'));
            Check(original.bDestroyed && !CaelumTarotRooted.Active(ledger.Body),"recast releases only the caster's old victim");
            Check(CaelumTarotRooted.Active(other) && !other.IsPhysicallyImmobilized(),"player roots preserve attack authority without whole-body stun");
            other.player.cmd.forwardmove=6400;other.Vel=(0,0,0);other.MovePlayer();
            Check(other.Vel.X==0 && other.Vel.Y==0,"rooted player movement input adds no locomotion");
            other.player.cmd.forwardmove=0;other.player.cmd.buttons|=BT_JUMP;other.CheckJump();
            Check(other.Vel.Z==0,"rooted player cannot initiate a jump");other.player.cmd.buttons&=~BT_JUMP;
            holder.Roots.Destroy();
            Check(!CaelumTarotRooted.Active(other),"release restores normal player movement eligibility");
            Check(CaelumTarotRoots.Place(user,ledger.Body,2100,ledger.Snapshot)
                && CaelumTarotRoots.Place(other,ledger.Body,2100,ledger.Snapshot),"different casters retain independent creations");
            holder.Roots.Destroy();
            Check(CaelumTarotRooted.Active(ledger.Body) && ledger.Body.TarotRoots.Sources.Size()==1,
                "one caster ending does not release another caster's roots");
            let second=CaelumTarotPlantState(other.FindInventory('CaelumTarotPlantState'));
            second.Roots.Destroy();
            Check(!CaelumTarotRooted.Active(ledger.Body),"last creation ending releases the victim");
            CaelumTarotRoots.Place(user,ledger.Body,2100,ledger.Snapshot);ledger.Roots=holder.Roots;
            ledger.Phase=3;user.PersistCharacterState();Console.Printf("CA440E RESULT capture");return;
        }
        if(ledger.Phase==3 && !Reloaded)
        {ledger.Life=ledger.Roots.RemainingTics;ledger.DamageFraction=ledger.Roots.DamageRemainder;}
        if(ledger.Phase==3 && Reloaded)
        {
            let holder=CaelumTarotPlantState(user.FindInventory('CaelumTarotPlantState'));
            Check(holder.Roots==ledger.Roots && ledger.Roots.Victim==ledger.Body
                && ledger.Roots.Binding==ledger.Body.TarotRoots,"save recovery retains exact reciprocal roots");
            Check(ledger.Roots.RemainingTics<=ledger.Life && ledger.Roots.RemainingTics>=ledger.Life-1,
                "recovery preserves remaining duration without restarting");
            Check(Abs(ledger.Roots.DamageRemainder-ledger.DamageFraction)<=ledger.Power/TICRATE+0.001,
                "recovery retains fractional damage instead of replaying it");
            Check(CaelumTarotRooted.Active(ledger.Body) && !ledger.Body.ThermalTryMove(ledger.Body.Pos.XY+(8,0)),
                "recovered binding still blocks locomotion");
            ledger.Roots.RemainingTics=1;ledger.Roots.Tick();
            Check(holder.Roots==null && !CaelumTarotRooted.Active(ledger.Body),"expiry releases recovered victim and owner");
            ledger.Phase=4;Console.Printf("CA440E RESULT reload");
        }
    }
}
