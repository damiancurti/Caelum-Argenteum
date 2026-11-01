// Real two-peer ownership, private equipment, combat and recovery.
class CA440AutomatonTarget : CaelumCombatActor
{
    Default {Health 1000000;Radius 16;Height 80;Mass 80;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440AutomatonLedger : Inventory
{
    int Phase,Started,SavedHealth,SavedDuration,VictimHealth;
    CaelumTarotAutomaton Body,Second;
    CA440AutomatonTarget Victim;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440AUTO %s %s",okay?"PASS":"FAIL",label);}
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
        let ledger=CA440AutomatonLedger(user.FindInventory('CA440AutomatonLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);user.SetOrigin((0,0,0),false);other.SetOrigin((0,160,0),false);
            user.Angle=0;user.Pitch=0;
            ledger=CA440AutomatonLedger(user.GiveInventoryType('CA440AutomatonLedger'));
            ledger.Body=CaelumTarotAutomaton(Actor.Spawn('CaelumTarotAutomaton',(96,0,0),NO_REPLACE));
            ledger.Second=CaelumTarotAutomaton(Actor.Spawn('CaelumTarotAutomaton',(96,320,0),NO_REPLACE));
            ledger.Victim=CA440AutomatonTarget(Actor.Spawn('CA440AutomatonTarget',(320,0,0),NO_REPLACE));
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        let body=ledger.Body,second=ledger.Second;let victim=ledger.Victim;
        if(!Reloaded && ledger.Phase==1 && level.time-ledger.Started>2)
        {
            Check(body.Caster==null && body.bDormant && body.RemainingTics==0,"dormant model does not awaken by proximity");
            Check(body.Mass==1000 && body.CombatStrength==30 && body.CombatDexterity==30 && body.CombatInsight==30
                && body.CombatToughness==30,"body mass and authored attributes");
            Check(Abs(body.CombatArmor.GetTotalWeight()-60)<0.001 && body.Shield.GetWeight()==24
                && body.Mace.GetWeight()==12 && body.GetAttackCarriedWeight()==96,"full XL loadout weighs 96 kg separately from body");
            Check(body.Mace.GetDamage()==130 && body.MeleeRange==80 && body.Mace.GetBaseCriticalChanceFor(0)==5,"authored mace damage reach and critical base");
            Check(body.Look!=null && body.Look.master==body && body.Look.CurState==body.Look.FindState("F0"),"inactive owned 3D presentation");
            Check(CaelumTarotService.Select(user,1),"Magician equips");
            Check(body.Caster==null,"passive alone does not wake a machine");
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"normal Tarot sequence wakes aimed automaton");
            Check(body.Caster==user && body.Binding.Owner==user && body.RemainingTics==60*TICRATE,"single shared sixty-second control");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01,"awakening charged once through sequence");
            Check(!CaelumTarotAutomata.Start(user,second,6000) && !CaelumTarotAutomata.Start(other,body,6000),"one machine per caster and one caster per machine");
            Check(CaelumTarotAutomata.Start(other,second,6000),"independent second caster can control another machine");
            Check(!CaelumTarotAutomata.Command(other,victim) || second.Caster==other,"command cannot steal ownership");
            Check(CaelumTarotAutomata.Command(user,victim) && body.VisualEvidence.GetMemory().Focus==victim,"order stores visible target and observed position");
            Check(!CaelumVisualPerception.Opponent(body,user) && CaelumVisualPerception.Opponent(body,victim),"real caster allegiance protects caster and selects hostile target");
            Check(!CaelumTarotAutomata.Command(user,other),"friendly player is not an order target");
            user.CraftingTaskActive=true;
            Check(!CaelumTarotAutomata.Command(user,victim),"busy caster cannot issue a combat order");
            user.CraftingTaskActive=false;
            body.SetOrigin((96,0,0),false);body.Angle=0;victim.SetOrigin((160,0,0),false);body.target=victim;
            double air=body.CurrentCombatAir;int before=victim.health;
            for(int trial=0;trial<6 && victim.health==before;trial++)body.Strike();
            Check(victim.health<before && body.CurrentCombatAir<air,"real mace uses Air and deals physical damage through native defenses");
            Check(body.Mace.Durability==body.Mace.GetMaximumDurability(),"mace does not wear after striking");
            int armor=body.CombatArmor.Durability[1],shield=body.Shield.Durability;
            double blocked=CaelumActorShield.Resolve(body,body.Shield,false,victim,victim,10000,'Melee',0);
            Check(blocked<10000 && body.Shield.Durability==shield,"normal tower block with no shield wear");
            body.Angle=180;int health=body.health;
            body.DamageMobj(victim,victim,1000,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            Check(body.health<health && body.health>0,"body remains vulnerable to already-resolved physical damage");
            Check(body.CombatArmor.Durability[1]==armor && body.LastCombatArmorDurabilityLoss==0,"incoming damage preserves armor durability");
            bool removable=false;for(Inventory item=body.Inv;item!=null;item=item.Inv)if(item is 'CaelumEquipmentItem')removable=true;
            Check(!removable && body.Companion==null,"mechanical equipment has no removable inventory or companion slots");
            int remaining=body.RemainingTics;CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(body.RemainingTics==remaining-1,"shared acceleration advances automaton once");
            body.Sleep();second.Sleep();victim.SetOrigin((1000,0,0),false);
            Check(body.Caster==null && body.Binding==null && body.bDormant && CaelumTarotAutomata.View(user).Body==null,"expiry/departure primitive frees owner without deleting body");
            Check(body.Wake(user,6000),"same original machine can awaken again");
            ledger.SavedHealth=body.health;ledger.SavedDuration=body.RemainingTics;ledger.Phase=2;
            ledger.Started=level.time;ledger.VictimHealth=victim.health;
            CaelumTarotAutomata.Command(user,victim);
        }
        else if(!Reloaded && ledger.Phase==2 && level.time-ledger.Started>280)
        {
            Check(body.LastMotionTic>ledger.Started,"native chase displaces body and advances walking animation");
            Check(victim.health<ledger.VictimHealth,"native attack state damages the ordered enemy");
            ledger.Phase=3;Console.Printf("CA440AUTO RESULT capture");
        }
        else if(Reloaded && ledger.Phase==3)
        {
            Check(body!=null && body.Revision==1 && body.Caster==user && body.Binding==CaelumTarotAutomata.View(user),"native common-save restores ownership and original actor");
            Check(body.RemainingTics>0 && body.RemainingTics<ledger.SavedDuration,"saved active time is not restarted");
            Check(body.Look!=null && body.Look.master==body && body.Mace.GetWeight()==12,"visual and private mechanical models survive recovery");
            Check(body.health>0 && body.health<=body.CombatMaximumHealth,"saved body remains alive without equipment replacement");
            body.RemainingTics=1;body.AdvanceEffect();
            Check(body.bDormant && body.Caster==null && body.RemainingTics==0 && body.Look!=null,"expiry returns inactive original model");
            Check(body.Wake(user,1000),"expired machine reawakens");
            CaelumTarotAutomata.View(user).PreTravelled();
            Check(body.Caster==null && body.bDormant && !body.bDestroyed,"travel leaves machine inactive in origin");
            Check(!body.Wake(user,0),"zero-duration control is rejected");
            second.Wake(other,1000);int shield=second.Shield.Durability;
            second.DamageMobj(user,user,100000000,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            Check(second.health<=0 && second.Caster==null && CaelumTarotAutomata.View(other).Body==null,"destruction of body frees control slot");
            Check(second.Shield.Durability==shield && second.Mace.Durability==second.Mace.GetMaximumDurability(),"body death does not destroy mechanical equipment");
            Check(!second.Wake(other,1000),"dead machine cannot be awakened");
            ledger.Phase=4;Console.Printf("CA440AUTO RESULT reload");
        }
    }
}
