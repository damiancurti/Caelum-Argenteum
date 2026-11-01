class CA440MineBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440MineLedger : Inventory
{
    int Phase,Started,Damage,Life;
    CaelumTarotMine Mine;
    CA440MineBody Enemy,Friend;
    CaelumTarotGroundAim Aim;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440P %s %s",ok?"PASS":"FAIL",label);}
    void Aim(CaelumPlayer user,vector3 point)
    {
        vector3 ray=point-CaelumTelekinesisRules.Eye(user);
        user.Angle=VectorAngle(ray.X,ray.Y);user.Pitch=-VectorAngle(ray.XY.Length(),ray.Z);
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440MineLedger(user.FindInventory('CA440MineLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            ledger=CA440MineLedger(user.GiveInventoryType('CA440MineLedger'));
            for(int card=0;card<78;card++)
            {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
            record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
            record.TarotCooldownTics=record.TarotEffectTics=0;
            user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
            user.SetOrigin((-400,0,0),false);other.SetOrigin((-700,-700,0),false);
            user.Angle=0;user.Pitch=0;
            Check(!CaelumTarotGroundAim.Capture(user).Found,"wall aim is not treated as valid ground");
            Aim(user,(0,0,0));ledger.Aim=CaelumTarotGroundAim.Capture(user);
            Check(ledger.Aim.Found && ledger.Aim.Valid(user),"visible floor is captured within magic range");
            CaelumTarotService.Select(user,2);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"native selected sequence places Priestess trap");
            let holder=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));ledger.Mine=holder.Mine;
            Check(ledger.Mine!=null && Abs(user.CurrentAnima-anima+1000)<0.01,"trap charges exactly one shared sequence");
            Check(ledger.Mine.RemainingTics==4200 && record.TarotRemaining[2]==4200,"first trap receives Hermit lifetime without repeated casting");
            Check(ledger.Mine.args[0]==int(ledger.Aim.Damage*2+0.5)
                && ledger.Mine.args[1]==int(128*ledger.Aim.RangeMultiplier+0.5),"trap uses approved T1 staff damage and current magic range");
            ledger.Enemy=CA440MineBody(Actor.Spawn('CA440MineBody',(700,0,0),NO_REPLACE));
            ledger.Friend=CA440MineBody(Actor.Spawn('CA440MineBody',(700,200,0),NO_REPLACE));
            ledger.Started=level.time;ledger.Phase=1;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            ledger.Enemy.bFriendly=false;ledger.Friend.bFriendly=true;
            ledger.Enemy.bNoGravity=false;ledger.Friend.bNoGravity=false;
            ledger.Friend.SetOrigin(ledger.Mine.Pos-(0,0,0.5),false);
            Check(!ledger.Mine.IsPressedBy(ledger.Friend),"friendly contact does not trigger the trap");
            ledger.Friend.TheftTarget=user;
            Check(ledger.Mine.IsPressedBy(ledger.Friend),"actual hostile relation overrides a friendly appearance");
            ledger.Friend.TheftTarget=null;
            let match=new("CaelumArenaMatch");match.Status=CaelumArenaMatch.FIGHTING;
            match.Members[0]=user;match.Members[1]=other;match.Mask=3;
            let a=CaelumArenaState.Get(user),b=CaelumArenaState.Get(other);
            a.MatchState=b.MatchState=match;
            Check(CaelumMajorTargets.Enemy(user,other),"campaign arena opponent is a valid enemy in cooperative engine mode");
            match.Mode=1;match.Teams[0]=match.Teams[1]=0;
            Check(!CaelumMajorTargets.Enemy(user,other),"same arena team does not trigger enemy-only powers");
            match.Teams[1]=1;
            Check(CaelumMajorTargets.Enemy(user,other),"opposing arena team is eligible");
            match.Withdrawn=2;
            Check(!CaelumMajorTargets.Enemy(user,other),"withdrawn arena participant is no longer a target");
            a.MatchState=b.MatchState=null;
            let environmental=CaelumMagicMine(Actor.Spawn('CaelumMagicMine',ledger.Mine.Pos,NO_REPLACE));
            Check(environmental.IsPressedBy(ledger.Friend),"existing environmental mine keeps its original trigger rule");environmental.Destroy();
            ledger.Friend.SetOrigin(ledger.Mine.Pos+(48,0,-0.5),false);
            ledger.Enemy.SetOrigin(ledger.Mine.Pos-(0,0,0.5),false);
            user.SetOrigin(ledger.Mine.Pos+(-64,0,-0.5),false);
            user.health=user.player.health=10000;ledger.Enemy.health=ledger.Friend.health=10000;
            Check(ledger.Mine.IsPressedBy(ledger.Enemy),"grounded enemy contact is eligible");
            Check(ledger.Mine.Trigger(ledger.Enemy) && ledger.Mine.ActivationCount==1,"enemy contact detonates exactly once");
            Check(ledger.Enemy.health<10000,"explosion damages its triggering enemy");
            Check(ledger.Friend.health<10000,"explosion can damage a nearby ally");
            Check(user.health<10000,"explosion can damage its own caster");
            int health=ledger.Enemy.health;
            Check(!ledger.Mine.Trigger(ledger.Enemy) && ledger.Enemy.health==health,"spent trap cannot detonate twice");
            ledger.Enemy.SetOrigin((700,0,0),false);ledger.Friend.SetOrigin((700,200,0),false);
            user.SetOrigin((-400,0,0),false);let old=ledger.Mine;
            Check(CaelumTarotMine.Place(user,ledger.Aim,2100),"same captured ground can be reused while valid");
            let holder=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));ledger.Mine=holder.Mine;
            Check(old.bDestroyed && ledger.Mine!=old,"recasting replaces the previous trap without duplication");
            ledger.Mine.RemainingTics=1;ledger.Mine.Tick();ledger.Mine.Tick();
            Check(holder.Mine==null,"expiration clears the caster's mine reference");
            Check(CaelumTarotMine.Place(user,ledger.Aim,2100),"new trap starts with its own saved timer");ledger.Mine=holder.Mine;
            ledger.Damage=ledger.Mine.args[0];ledger.Phase=2;user.PersistCharacterState();
            Console.Printf("CA440P RESULT capture");return;
        }
        if(ledger.Phase==2 && !Reloaded && ledger.Mine!=null)ledger.Life=ledger.Mine.RemainingTics;
        if(ledger.Phase==2 && Reloaded)
        {
            let holder=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));
            Check(ledger.Mine!=null && holder.Mine==ledger.Mine && ledger.Mine.Ledger==holder,"recovery preserves one exact trap and reciprocal binding");
            Check(ledger.Mine.RemainingTics<=ledger.Life && ledger.Mine.RemainingTics>=ledger.Life-1,"recovery retains elapsed lifetime without restarting it");
            Check(ledger.Mine.args[0]==ledger.Damage && ledger.Mine.target==user,"recovery keeps damage and caster attribution");
            Check(ledger.Aim.Found && ledger.Aim.Valid(user),"saved floor snapshot retains its visible destination");
            ledger.Mine.RemainingTics=1;ledger.Mine.Tick();ledger.Mine.Tick();
            Check(holder.Mine==null,"recovered expiration safely removes the existing trap");
            ledger.Phase=3;Console.Printf("CA440P RESULT reload");
        }
    }
}
