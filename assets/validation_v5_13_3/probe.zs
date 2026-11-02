class CA440Ledger : Inventory
{
    int Phase,At;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    ui bool Saved;
    void Check(bool ok,String label){Console.Printf("CA440 %s %s",ok?"PASS":"FAIL",label);}
    void Reset(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotEffectTics=0;record.TarotCooldownTics=0;record.TarotOrderCount=0;record.TarotLoadoutRevision=1;
        user.CurrentAnima=user.DerivedStats.MaximumAnima;
        user.ApplyCharacterProfile();
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(consoleplayer!=0 || Saved)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440Ledger(user.FindInventory('CA440Ledger')):null;
        if(ledger==null || ledger.Phase!=5)return;
        if(!CaelumNarrativeCheckpoint.Ready())return;
        for(int i=0;i<2;i++)
        {let checkpoint=CaelumNarrativeCheckpoint.Read(i);if(checkpoint!=null && checkpoint.Serial>checkpoint.Queued)return;}
        Saved=true;let manager=SavegameManager.GetManager();
        manager.ReadSaveStrings();manager.InsertNewSaveNode();
        manager.DoSave(0,"CA440 Major order and individual timers");manager.RemoveNewSaveNode();
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440Ledger(user.FindInventory('CA440Ledger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(Reloaded)
        {
            if(ledger.Phase!=5)return;
            Check(record.TarotOrderCount==3 && record.TarotOrder[0]==23 && record.TarotOrder[1]==9 && record.TarotOrder[2]==22,"reload preserves chosen activation order");
            Check(record.TarotRemaining[23]>record.TarotRemaining[22] && record.TarotRemaining[22]>0,"reload preserves distinct durations");
            Check(CaelumTarotLoadout.Capacity(record)==5,"reload does not duplicate Hermit capacity");
            Check(CaelumTarotService.IsActive(record,22) && CaelumTarotService.IsActive(record,23),"reload retains paid Minor effects");
            Check(record.TarotCooldownTics>0,"reload retains shared cooldown");
            ledger.Phase=6;Console.Printf("CA440 RESULT reload");return;
        }
        if(ledger==null)
        {
            ledger=CA440Ledger(user.GiveInventoryType('CA440Ledger'));
            Reset(user);
            record.TarotLoadoutRevision=0;record.TarotSelected[23]=true;record.TarotSelected[22]=true;
            record.TarotActive[22]=true;record.TarotEffectTics=700;
            CaelumTarotLoadout.Ensure(record);
            Check(record.TarotOrderCount==2 && record.TarotOrder[0]==22 && record.TarotOrder[1]==23,"legacy selection migrates in previous ID order");
            Check(record.TarotRemaining[22]==700,"legacy paid duration preserved");
            CaelumTarotLoadout.Ensure(record);Check(record.TarotOrderCount==2,"migration is idempotent");
            Reset(user);
            Check(CaelumTarotService.Select(user,22) && CaelumTarotService.Select(user,23) && CaelumTarotService.Select(user,24),"base three slots accept three cards");
            Check(!CaelumTarotService.Select(user,25),"ordinary fourth card rejected");
            Check(CaelumTarotService.Select(user,9) && CaelumTarotLoadout.Capacity(record)==5,"Hermit equips into its own extra capacity");
            Check(CaelumTarotService.Select(user,25),"fifth card accepted");
            Check(CaelumTarotService.Select(user,15) && CaelumTarotLoadout.Capacity(record)==7,"Devil adds capacity even at previous limit");
            Check(CaelumTarotService.Select(user,26),"seventh card accepted");
            Check(!CaelumTarotService.Select(user,9),"cannot remove capacity with overflowing cards");
            Check(CaelumTarotService.Select(user,26) && CaelumTarotService.Select(user,25) && CaelumTarotService.Select(user,9),"free slots then remove Hermit");
            Reset(user);
            int base=CaelumEquipmentRules.MagicBoxSlots(user.Attributes.Intelligence);
            Check(CaelumTarotService.Select(user,17) && CaelumTarotService.Select(user,19),"Star and Sun can be equipped together");
            Check(user.DerivedStats.MagicBoxCapacity==base+20,"both Box capacities add once");
            user.ApplyCharacterProfile();Check(user.DerivedStats.MagicBoxCapacity==base+20,"profile recalculation is idempotent");
            user.GrantMagicBoxFromPalomo(false);
            while(user.CountNativeMagicBoxSlots()<=base+10)
            {
                let piece=CaelumArmorPickup(Actor.Spawn('CaelumArmorPickup'));
                piece.AttachToOwner(user);piece.InMagicBox=true;
            }
            Check(!CaelumTarotService.Select(user,19),"cannot remove Sun while ordinary Box contents overflow");
            for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            {
                let piece=CaelumEquipmentItem(cursor);if(piece!=null)piece.InMagicBox=false;
            }
            Check(CaelumTarotService.Select(user,19) && user.DerivedStats.MagicBoxCapacity==base+10,"removal restores capacity after freeing contents");
            record.TarotCooldownTics=0;user.CurrentAnima=user.DerivedStats.MaximumAnima;
            Check(CaelumTarotService.Activate(user),"Star activation accepted");
            Check(user.CalculateMagicBoxReducedContentWeight(200)==0 && user.CalculateMagicBoxTotalWeight(200)==CaelumConstants.MAGIC_BOX_BASE_WEIGHT,"Star makes only contents weightless");
            CaelumTarotService.Advance(user,60*TICRATE);
            Check(user.CalculateMagicBoxReducedContentWeight(200)>0,"Star expiry restores contents weight");
            Reset(user);
            CaelumTarotService.Select(user,22);CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,23);
            user.CurrentAnima=user.DerivedStats.MaximumAnima;
            double expectedAnima=user.CurrentAnima-CaelumConstants.TAROT_ACTIVATION_ANIMA;
            Check(CaelumTarotService.Activate(user),"ordered sequence activates");
            Check(record.TarotRemaining[22]==120*TICRATE && record.TarotRemaining[23]==60*TICRATE,"later Hermit doubles only first duration");
            Check(record.TarotRemaining[9]==0,"instant Hermit is not repeated or timed");
            Check(abs(user.CurrentAnima-expectedAnima)<0.0001 && record.TarotCooldownTics==600*TICRATE,"whole sequence charges once");
            Check(!CaelumTarotService.Activate(user) && abs(user.CurrentAnima-expectedAnima)<0.0001,"repeat input cannot charge ordinary sequence twice");
            CaelumTarotService.Advance(user,60*TICRATE);
            Check(CaelumTarotService.IsActive(record,22) && !CaelumTarotService.IsActive(record,23),"individual expiry leaves only extended first effect");
            Reset(user);
            CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,22);user.CurrentAnima=user.DerivedStats.MaximumAnima;
            CaelumTarotService.Activate(user);
            Check(record.TarotRemaining[22]==60*TICRATE,"instantaneous first card does not transfer Hermit bonus");
            Reset(user);
            let weapon=CaelumWeaponPickup(Actor.Spawn('CaelumWeaponPickup'));weapon.AttachToOwner(user);user.EnsureEquipmentItemId(weapon);
            Check(CaelumAwakening.Associate(user,weapon.ItemId,22),"prepare bound acquired essence for World");
            CaelumTarotService.Select(user,21);user.CurrentAnima=user.DerivedStats.MaximumAnima;
            expectedAnima=user.CurrentAnima-CaelumConstants.TAROT_ACTIVATION_ANIMA;
            Check(CaelumTarotService.Activate(user),"World activation accepted");
            Check(CaelumTarotService.IsActive(record,22) && CaelumAwakening.Card(weapon)==22,"World activates a bound essence without releasing equipment");
            Check(abs(user.CurrentAnima-expectedAnima)<0.0001 && CaelumTarotLoadout.Capacity(record)==3,"World fan-out charges once and does not equip passives");
            int minors=0;for(int card=22;card<78;card++)if(CaelumTarotService.IsActive(record,card))minors++;
            Check(minors==56,"World visits every acquired unequipped Minor once");
            Reset(other);let second=other.GetPersistentCharacterState(false);
            CaelumTarotService.Select(other,15);CaelumTarotService.Select(other,22);second.TarotCooldownTics=100;
            other.health=500;other.player.health=500;other.CurrentAnima=0;
            Check(CaelumTarotService.Activate(other),"Devil allows lethal health-only cooldown bypass");
            Check(other.health<=0 && other.player.playerstate==PST_DEAD && other.CurrentAnima==0,"Devil uses normal death without Anima payment");
            Check(second.TarotRemaining[22]==60*TICRATE,"sequence continues after lethal payment");
            Reset(user);CaelumAwakening.Clear(weapon);
            CaelumTarotService.Select(user,23);CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,22);
            user.CurrentAnima=user.DerivedStats.MaximumAnima;CaelumTarotService.Activate(user);
            ledger.Phase=5;user.PersistCharacterState();Console.Printf("CA440 RESULT capture");
        }
    }
}
