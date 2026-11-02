// Native two-peer pulse, existing control ownership and common-save recovery.
class CA440JudgeBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440JudgeUnlinked : CA440JudgeBody
{Default {+NOBLOCKMAP}}
class CA440JudgeLedger : Inventory
{
    int Phase,Started,OriginalFriend;
    CA440JudgeBody Near,Far,SceneBody,Ordinary;
    CA440JudgeUnlinked UnlinkedBody;
    CaelumSummonedZupay Summon;
    CaelumTarotClone CloseClone,FarClone;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440JUDGE %s %s",okay?"PASS":"FAIL",label);}
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
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440JudgeLedger(user.FindInventory('CA440JudgeLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);user.SetOrigin((0,0,0),false);other.SetOrigin((0,80,0),false);
            ledger=CA440JudgeLedger(user.GiveInventoryType('CA440JudgeLedger'));
            ledger.Near=CA440JudgeBody(Actor.Spawn('CA440JudgeBody',(64,0,0),NO_REPLACE));
            ledger.Far=CA440JudgeBody(Actor.Spawn('CA440JudgeBody',(4000,0,0),NO_REPLACE));
            ledger.SceneBody=CA440JudgeBody(Actor.Spawn('CA440JudgeBody',(0,-80,0),NO_REPLACE));
            ledger.Ordinary=CA440JudgeBody(Actor.Spawn('CA440JudgeBody',(-64,0,0),NO_REPLACE));
            ledger.Ordinary.bFriendly=true;ledger.Ordinary.master=other;
            ledger.UnlinkedBody=CA440JudgeUnlinked(Actor.Spawn('CA440JudgeUnlinked',(-64,-64,0),NO_REPLACE));
            let binding=CaelumSummoningEffect(other.GiveInventoryType('CaelumSummoningEffect'));
            binding.Revision=1;binding.RemainingTics=6000;binding.Power=1;binding.Range=512;
            ledger.Summon=CaelumSummonedZupay(Actor.Spawn('CaelumSummonedZupay',(64,64,0),NO_REPLACE));
            binding.Body=ledger.Summon;ledger.Summon.Binding=binding;ledger.Summon.SummonPower=1;
            ledger.Summon.master=other;ledger.Summon.SetFriendPlayer(other.player);
            ledger.OriginalFriend=ledger.Summon.FriendPlayer;
            Check(CaelumTarotMoon.Start(other,6000),"existing Moon supplies real illusions");
            let moon=CaelumTarotMoon.View(other);
            ledger.CloseClone=moon.Bodies[0];ledger.FarClone=moon.Bodies[1];
            ledger.CloseClone.SetOrigin((64,-64,0),false);ledger.FarClone.SetOrigin((4000,200,0),false);
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>2)
        {
            CaelumTarotEmperorBody.Get(ledger.Near).Apply(other,6000,null);
            CaelumTarotEmperorBody.Get(ledger.Far).Apply(other,6000,null);
            CaelumTarotEmperorBody.Get(ledger.SceneBody).Apply(other,6000,null);
            CaelumTarotEmperorBody.Get(ledger.UnlinkedBody).Apply(other,6000,null);
            CaelumTarotEmperorBody.Get(user).Apply(other,6000,null);
            CaelumTarotEmperorBody.Get(ledger.Summon).Apply(user,6000,null);
            ledger.SceneBody.bDormant=true;
            Check(ledger.Summon.Commander()==user,"real summon has temporary control before dispelling");
            Check(ledger.UnlinkedBody.bNoBlockmap && CaelumContaminationContacts.Get(ledger.UnlinkedBody).Grid!=null,"unlinked recipient is in the existing local contact grid");
            ledger.Near.ElementalStatus.DiseaseRemaining=30;
            int health=ledger.Near.health;
            CaelumTarotService.Select(user,20);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"Judgement sequence activates");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01,"one shared sequence payment");
            Check(ledger.Near.TarotEmperor.Remaining[1]==0 && user.TarotEmperor.Remaining[1]==0,"pulse clears nearby and caster pacification");
            Check(ledger.UnlinkedBody.TarotEmperor.Remaining[1]==0,"pulse reaches locally indexed unlinked recipient");
            Check(ledger.Summon.Commander()==other && ledger.Summon.master==other
                && ledger.Summon.FriendPlayer==ledger.OriginalFriend,"pulse restores original summon allegiance");
            Check(ledger.Summon.health>0 && ledger.Summon.Binding.Owner==other,"dispelling does not kill summon or replace its lifetime owner");
            Check(ledger.CloseClone==null || ledger.CloseClone.bDestroyed,"pulse destroys nearby native illusion");
            Check(ledger.FarClone!=null && !ledger.FarClone.bDestroyed && ledger.Far.TarotEmperor.Remaining[1]>0,"outside-radius bodies and illusions are unchanged");
            Check(ledger.SceneBody.TarotEmperor.Remaining[1]>0,"protected scene retains its control state");
            Check(ledger.Ordinary.bFriendly && ledger.Ordinary.master==other && ledger.Ordinary.TarotEmperor==null,"ordinary allegiance is not treated as mind control");
            Check(ledger.Near.health==health && ledger.Near.ElementalStatus.DiseaseRemaining==30,"pulse does not heal or cleanse unrelated disease");
            let record=user.GetPersistentCharacterState(false);
            Check(record.TarotRemaining[20]==0 && !record.TarotActive[20],"Judgement remains instantaneous with Hermit");
            CaelumTarotEmperorBody.Get(ledger.Near).Apply(other,6000,null);
            CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(ledger.Near.TarotEmperor.Remaining[1]==5999,"instant pulse is not repeated during accelerated time");
            Check(CaelumTarotJudgement.Pulse(user)==1 && CaelumTarotJudgement.Pulse(user)==0,"repeat pulse affects only newly applied control and deduplicates recipients");
            ledger.Phase=2;Console.Printf("CA440JUDGE RESULT capture");
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(ledger.Near.TarotEmperor.Remaining[1]==0 && ledger.UnlinkedBody.TarotEmperor.Remaining[1]==0,"common save retains dispelled states");
            Check(ledger.CloseClone==null && ledger.FarClone!=null,"common save retains only the unaffected illusion");
            Check(ledger.Summon.master==other && ledger.Summon.TarotEmperor.Controller==null,"common recovery preserves original allegiance");
            Check(ledger.SceneBody.TarotEmperor.Remaining[1]>0 && ledger.Far.TarotEmperor.Remaining[1]>0,"protected and distant effects survive recovery");
            let record=user.GetPersistentCharacterState(false);
            Check(record.TarotRemaining[20]==0 && record.TarotCooldownTics>0,"paid cooldown survives without repeating the pulse");
            ledger.Phase=3;Console.Printf("CA440JUDGE RESULT reload");
        }
    }
}
