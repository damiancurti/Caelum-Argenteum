// Isolated fixture: native two-client effects, lifecycle and common-save recovery.
class CA440EmpireBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440EmpireLedger : Inventory
{
    int Phase,Started,OriginalFriend;
    CA440EmpireBody Near,Far,SceneBody;
    CaelumSummonedZupay Summon;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440EMP %s %s",ok?"PASS":"FAIL",label);}
    void Prepare(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotCooldownTics=record.TarotEffectTics=0;
        user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440EmpireLedger(user.FindInventory('CA440EmpireLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);
            user.SetOrigin((0,0,0),false);user.Angle=0;user.Pitch=0;
            other.SetOrigin((0,80,0),false);
            ledger=CA440EmpireLedger(user.GiveInventoryType('CA440EmpireLedger'));
            ledger.Near=CA440EmpireBody(Actor.Spawn('CA440EmpireBody',(64,0,0),NO_REPLACE));
            ledger.Far=CA440EmpireBody(Actor.Spawn('CA440EmpireBody',(4000,0,0),NO_REPLACE));
            ledger.SceneBody=CA440EmpireBody(Actor.Spawn('CA440EmpireBody',(0,-80,0),NO_REPLACE));
            ledger.SceneBody.bDormant=true;
            let binding=CaelumSummoningEffect(other.GiveInventoryType('CaelumSummoningEffect'));
            binding.Revision=1;binding.RemainingTics=60*TICRATE;binding.Power=1;binding.Range=512;
            ledger.Summon=CaelumSummonedZupay(Actor.Spawn('CaelumSummonedZupay',(64,64,0),NO_REPLACE));
            binding.Body=ledger.Summon;ledger.Summon.Binding=binding;ledger.Summon.SummonPower=1;
            ledger.Summon.master=other;ledger.Summon.SetFriendPlayer(other.player);
            ledger.OriginalFriend=ledger.Summon.FriendPlayer;ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(ledger.Phase==1 && level.time-ledger.Started>2)
        {
            ledger.Near.bFriendly=false;ledger.Near.target=user;
            Check(CaelumVisualPerception.Opponent(ledger.Near,user),"enemy is hostile before the spell");
            Check(ledger.Near.TarotEmperor==null,"legacy body starts without new effects");
            vector3 ray=ledger.Near.Pos+(0,0,28)-CaelumTelekinesisRules.Eye(user);
            user.Angle=VectorAngle(ray.X,ray.Y);user.Pitch=-VectorAngle(ray.XY.Length(),ray.Z);
            CaelumTarotService.Select(user,4);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"selected Emperor sequence activates");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01,"one shared sequence payment");
            Check(ledger.Near.TarotEmperor!=null && ledger.Near.TarotEmperor.Remaining[0]==4200,"Hermit extends native recipient duration");
            Check(ledger.Near.target==null && !CaelumVisualPerception.Opponent(ledger.Near,user),"hostility and existing target stop toward the caster");
            Check(CaelumVisualPerception.Opponent(ledger.Near,other),"pacification does not protect unrelated players");
            Check(ledger.Far.TarotEmperor==null && ledger.SceneBody.TarotEmperor==null,"range and protected scene eligibility exclude bodies");
            Check(ledger.Summon.Commander()==user && ledger.Summon.master==user,"summon changes current allegiance");
            Check(ledger.Summon.Binding.Owner==other && ledger.Summon.TarotEmperor.OriginalMaster==other,"original lifetime owner and allegiance are preserved");
            Check(ledger.Summon.TarotEmperor.CommandTarget==ledger.Near,"native aimed sequence captures its command target");
            Check(CaelumCommunication.Principal(ledger.Summon)==user,"communication uses the current controller");
            int life=user.health;
            user.DamageMobj(ledger.Near,ledger.Near,100,'CaelumDiseaseDOT',0,0);
            Check(user.health==life,"attacks from pacified actors cannot damage the caster");
            Check(CaelumRedemption.AllowsDamage(ledger.Near,ledger.Near,'CaelumDiseaseDOT'),"self disease and physiology are not made immune");
            let status=ledger.Summon.TarotEmperor;
            status.Apply(other,10,ledger.Near);
            Check(status.Controller==other && status.OriginalMaster==other,"last valid cast replaces control without overwriting original allegiance");
            for(int i=0;i<10;i++)CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(status.Controller==null && ledger.Summon.master==other && ledger.Summon.FriendPlayer==ledger.OriginalFriend,"latest expiry restores original owner instead of the earlier controller");
            Check(status.Remaining[0]==4190 && status.Remaining[1]==0,"shared accelerated steps advance each source exactly once");
            let second=other.GetPersistentCharacterState(false);other.TarotEmperor.Cleanse();
            second.TarotSelected[14]=true;
            CaelumTarotEmperor.Pulse(user,100,ledger.Near);
            Check(other.TarotEmperor.Remaining[0]==50,"equipped Temperance halves mind-control duration");
            second.TarotActive[14]=true;second.TarotRemaining[14]=100;
            CaelumTemperance.Cleanse(other);
            CaelumTarotEmperor.Pulse(user,100,ledger.Near);
            Check(other.TarotEmperor.Remaining[0]==0,"active Temperance cleanses and prevents renewed pacification");
            second.TarotSelected[14]=false;second.TarotActive[14]=false;second.TarotRemaining[14]=0;
            let cast=CaelumTarotEmperorCast(user.FindInventory('CaelumTarotEmperorCast'));
            int count=cast.Bodies.Size();CaelumTarotEmperor.Pulse(user,100,ledger.Near);
            Check(cast.Bodies.Size()<=count+1,"repeated pulse does not duplicate recipient ownership");
            cast.Bodies.Insert(0,null);ledger.Near.TarotEmperor.Remaining[0]=1;
            CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(!CaelumTarotEmperor.Blocks(ledger.Near,user),"expiry tolerates stale null entries while removing recipients");
            status.Cleanse();
            Check(status.Controller==null && ledger.Summon.health>0 && ledger.Summon.master==other,"cleansing restores the living summon without killing it");
            status.Apply(user,100,ledger.Near);status.Controller=null;status.Sources[0]=null;
            status.AdvanceSource(0);
            Check(ledger.Summon.master==other && status.OriginalMaster==null,"lost native controller references restore original allegiance");
            status.Apply(user,2100,ledger.Near);
            ledger.Started=level.time;ledger.Phase=2;return;
        }
        if(ledger.Phase==2 && !Reloaded && level.time-ledger.Started>=3*TICRATE)
        {
            Check(ledger.Summon.TarotEmperor.Remaining[0]<=2100-TICRATE,"native world ticks advance stored control duration");
            Check(ledger.Summon.target==ledger.Near || ledger.Near.health<10000,"summon engages the commanded enemy through native perception");
            // Freeze only the diagnostic body to inspect exact saved affiliation later.
            ledger.Summon.bDormant=true;ledger.Phase=3;
            user.PersistCharacterState();other.PersistCharacterState();Console.Printf("CA440EMP RESULT capture");return;
        }
        if(ledger.Phase==3 && Reloaded)
        {
            let status=ledger.Summon.TarotEmperor;
            Check(status!=null && status.Revision==1 && status.Controller==user,"common save restores exact current controller");
            Check(status.OriginalMaster==other && ledger.Summon.Binding.Owner==other,"common save preserves original ownership separately");
            Check(status.Remaining[0]>0 && status.Remaining[0]<2100,"loading does not renew the effect duration");
            let cast=CaelumTarotEmperorCast(user.FindInventory('CaelumTarotEmperorCast'));
            Check(cast!=null && cast.Bodies.Find(status)<cast.Bodies.Size(),"saved recipient index reconnects to the same body");
            int cooldown=user.GetPersistentCharacterState(false).TarotCooldownTics;
            cast.PreTravelled();
            Check(status.Controller==null && ledger.Summon.master==other && cast.Bodies.Size()==0,"departure restores original allegiance and removes source effects");
            Check(user.GetPersistentCharacterState(false).TarotCooldownTics==cooldown,"departure does not refund the paid cooldown");
            cast.PreTravelled();Check(ledger.Summon.health>0 && ledger.Summon.master==other,"repeated departure cleanup is idempotent and nonlethal");
            ledger.Summon.bDormant=false;status.Apply(user,2100,ledger.Near);
            ledger.Phase=4;CaelumDeadTraveler.ChangeMap("CARING",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==4 && level.MapName=="CARING")
        {
            let cast=CaelumTarotEmperorCast(user.FindInventory('CaelumTarotEmperorCast'));
            let binding=CaelumSummoning.Status(other);let body=binding!=null?binding.Body:null;
            Check(body!=null && body.health>0 && body.Commander()==other && body.master==other,"actual map travel keeps the summon with its original lifetime owner");
            Check(body!=null && CaelumTarotEmperor.Commander(body)==null && cast.Bodies.Size()==0,"actual departure leaves no control or pacification references");
            let record=user.GetPersistentCharacterState(false);
            Check(!record.TarotActive[4] && record.TarotRemaining[4]==0 && record.TarotCooldownTics>0,"actual travel ends Emperor duration while retaining cooldown");
            ledger.Phase=5;Console.Printf("CA440EMP RESULT reload");
        }
    }
}
