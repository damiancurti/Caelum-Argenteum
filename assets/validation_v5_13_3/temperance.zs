class CA440TemperanceLedger : Inventory
{
    int Phase;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    ui bool Saved;
    void Check(bool ok,String label){Console.Printf("CA440T %s %s",ok?"PASS":"FAIL",label);}
    void Reset(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotEffectTics=0;record.TarotCooldownTics=0;record.TarotOrderCount=0;record.TarotLoadoutRevision=1;
        user.ElementalStatus=new('CaelumElementalStatus');CaelumSleepRules.Wake(user);
        user.ApplyCharacterProfile();user.CurrentAnima=user.DerivedStats.MaximumAnima;
    }
    void ApplyAll(CaelumPlayer user)
    {
        let s=user.ElementalStatus;
        s.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,20,1,10,user,user);
        s.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_POISON,20,1,10,user,user);
        s.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_DISEASE,20,1,10,user,user);
        s.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_CUT,20,1,10,user,user);
        s.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,20,50,user);
        s.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_DAZZLE,20,50,user);
        s.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_LIGHTNING_STUN,20,1,user);
        s.ApplyBurnHeat(20,1,200,user);
    }
    bool Empty(CaelumElementalStatus s)
    {
        return s.BurnRemaining==0 && s.CutRemaining==0 && s.PoisonRemaining==0
            && s.DiseaseRemaining==0 && s.FreezeRemaining==0 && s.DazzleRemaining==0
            && s.LightningStunRemaining==0 && !s.HasBurnHeat();
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(consoleplayer!=0 || Saved)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440TemperanceLedger(user.FindInventory('CA440TemperanceLedger')):null;
        if(ledger==null || ledger.Phase!=5 || !CaelumNarrativeCheckpoint.Ready())return;
        for(int i=0;i<2;i++)
        {let checkpoint=CaelumNarrativeCheckpoint.Read(i);if(checkpoint!=null && checkpoint.Serial>checkpoint.Queued)return;}
        Saved=true;let manager=SavegameManager.GetManager();
        manager.ReadSaveStrings();manager.InsertNewSaveNode();
        manager.DoSave(0,"CA440 Temperance native lifecycle");manager.RemoveNewSaveNode();
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440TemperanceLedger(user.FindInventory('CA440TemperanceLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(Reloaded)
        {
            if(ledger.Phase!=5)return;
            Check(CaelumTarotService.IsActive(record,14),"load preserves paid protection");
            Check(record.TarotRemaining[14]>60*TICRATE,"load preserves Hermit extension");
            ApplyAll(user);Check(Empty(user.ElementalStatus),"load rejects renewed negative states");
            Check(!CaelumSleepRules.Apply(user,350,true),"load rejects magical sleep");
            CaelumTarotService.Advance(user,record.TarotRemaining[14]);
            Check(!CaelumTarotService.IsActive(record,14),"expiry removes active protection");
            user.ElementalStatus.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,20,50,user);
            Check(user.ElementalStatus.FreezeRemaining==10,"equipped passive remains after active expiry");
            CaelumTarotService.Select(user,14);user.ElementalStatus.ClearTemporaryStates(user);
            user.ElementalStatus.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_FREEZE,20,50,user);
            Check(user.ElementalStatus.FreezeRemaining==20,"unequip removes passive for new applications");
            user.ElementalStatus.ClearTemporaryStates(user);
            ledger.Phase=6;Console.Printf("CA440T RESULT reload");return;
        }
        if(ledger!=null)return;
        ledger=CA440TemperanceLedger(user.GiveInventoryType('CA440TemperanceLedger'));
        Reset(user);Reset(other);user.Attributes.Toughness=0;
        ApplyAll(user);Check(user.ElementalStatus.CutRemaining==20 && user.ElementalStatus.FreezeRemaining==20,"ownership alone does not shorten statuses");
        user.ElementalStatus.ClearTemporaryStates(user);
        Check(CaelumTarotService.Select(user,14),"native equip enables Temperance");user.Attributes.Toughness=0;
        ApplyAll(user);let s=user.ElementalStatus;
        Check(s.BurnRemaining==10 && s.PoisonRemaining==10 && s.DiseaseRemaining==10,"passive halves damaging biological durations");
        Check(s.CutRemaining==10,"passive halves cut duration");
        Check(s.FreezeRemaining==10 && s.DazzleRemaining==10 && s.LightningStunRemaining==10,"passive halves temporary control durations");
        Check(s.BurnHeatRemaining==10,"passive halves stored burn heat duration");
        s.Advance(user,1);Check(s.CutRemaining==9 && s.FreezeRemaining==9,"ticking does not repeatedly halve remaining time");
        Check(CaelumSleepRules.Apply(user,350,true) && user.ForcedSleepTics==175,"passive halves magical sleep");
        s.ApplyEarthPenalty(30,20);
        let illness=CaelumFoodIllness.Get(user);illness.Contamination=45;
        user.CurrentHunger=75;user.CurrentThirst=65;user.CurrentSleep=55;
        double anima=user.CurrentAnima;
        Check(CaelumTarotService.Activate(user),"Temperance sequence can cleanse existing magical sleep");
        Check(Empty(s) && user.ForcedSleepTics==0 && user.SpellSleep==null,"activation clears approved statuses and sleep");
        Check(s.EarthPenaltyRemaining==30,"mechanical Earth seal penalty remains");
        Check(illness.Contamination==45 && user.CurrentHunger==75 && user.CurrentThirst==65 && user.CurrentSleep==55,"body contamination and needs remain unchanged");
        Check(abs(user.CurrentAnima-(anima-1000))<0.0001,"cleanse charges one normal sequence");
        ApplyAll(user);Check(Empty(s),"active immunity rejects renewed negative statuses");
        Check(!CaelumSleepRules.Apply(user,350,true) && user.ForcedSleepTics==0,"active immunity rejects magical sleep");
        Check(!CaelumTarotService.Activate(user),"repeat input does not bypass cooldown");
        other.Attributes.Toughness=0;ApplyAll(other);
        Check(other.ElementalStatus.CutRemaining==20 && other.ElementalStatus.FreezeRemaining==20,"other player does not inherit protection");
        other.ElementalStatus.ClearTemporaryStates(other);
        user.Attributes.Toughness=150;
        s.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_POISON,20,1,10,user,user);
        Check(s.ResponseFactors[1]<0 && s.BaseRemaining[1]==20,"beneficial Toughness inversion remains applicable");
        CaelumTemperance.Cleanse(user);
        Check(s.BaseRemaining[1]==20,"cleanse retains beneficial inverted dose");
        Reset(user);CaelumTarotService.Select(user,14);CaelumTarotService.Select(user,9);
        user.CurrentAnima=user.DerivedStats.MaximumAnima;
        Check(CaelumTarotService.Activate(user) && record.TarotRemaining[14]==120*TICRATE,"Hermit extends Temperance once");
        ledger.Phase=5;user.PersistCharacterState();Console.Printf("CA440T RESULT capture");
    }
}
