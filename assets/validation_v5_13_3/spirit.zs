// Native dialogue, passive ownership and common-save persistence.
class CA440SpiritLedger : Inventory
{
    int Phase,HealthAfter;
    CaelumTarotExampleSpirit Body,DeadBody;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440SPIRIT %s %s",okay?"PASS":"FAIL",label);}
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
        let ledger=CA440SpiritLedger(user.FindInventory('CA440SpiritLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);user.SetOrigin((0,0,0),false);other.SetOrigin((0,64,0),false);
            user.Angle=0;user.Pitch=0;
            ledger=CA440SpiritLedger(user.GiveInventoryType('CA440SpiritLedger'));
            ledger.Body=CaelumTarotExampleSpirit(Actor.Spawn('CaelumTarotExampleSpirit',(56,0,0),NO_REPLACE));
            ledger.DeadBody=CaelumTarotExampleSpirit(Actor.Spawn('CaelumTarotExampleSpirit',(300,0,0),NO_REPLACE));
            ledger.Phase=1;return;
        }
        let body=ledger.Body,deadBody=ledger.DeadBody;
        if(!Reloaded && ledger.Phase==1)
        {
            Check(body.Revision==1 && body.CombatStrength==CaelumPortData.DEFENDER_ATTRIBUTE
                && body.Mass==CaelumPortData.DEFENDER_MASS_KG,"demonstration reuses actual guard attribute and body references");
            int health=body.health;
            body.DamageMobj(user,user,100000,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            Check(body.health==health && !CaelumTarotSpirit.CanHarm(user),"acquired but unequipped Justice cannot harm immortal spirit");
            Check(body.InteractWithCaelumPlayer(user) && !body.HasConversation() && !body.bInConversation
                && user.player.ConversationNPC==null,"without equipped Judgement no hidden conversation or frozen player");
            CaelumTarotService.Select(user,8);
            Check(CaelumTarotSpirit.CanHarm(user) && !CaelumTarotSpirit.CanHarm(other),"Justice permission is private to the equipped player");
            body.DamageMobj(user,user,100,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            Check(body.health<health && body.health>0,"Justice allows real Health damage without immunity bypass for other players");
            ledger.HealthAfter=body.health;health=body.health;
            body.DamageMobj(other,other,100000,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            body.DamageMobj(null,null,100000,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            Check(body.health==health,"another player and ambient damage cannot inherit Justice");
            deadBody.DamageMobj(user,user,100000000,'CaelumImpact',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
            Check(deadBody.health<=0,"Justice can destroy a demonstration spirit normally");
            bool loot=false;for(Inventory item=deadBody.Inv;item!=null;item=item.Inv)
                if(item is 'CaelumEquipmentItem' || item is 'CaelumConsumableItem')loot=true;
            Check(!loot,"example adds no equipment or consumable reward");
            CaelumTarotService.Select(user,8);
            Check(!CaelumTarotSpirit.CanHarm(user),"removing Justice restores immunity for future hits");
            CaelumTarotService.Select(user,20);
            Check(CaelumTarotSpirit.CanHear(user) && !CaelumTarotSpirit.CanHear(other),"Judgement hearing is private and requires equipped card");
            Check(body.InteractWithCaelumPlayer(user) && body.HasConversation() && body.bInConversation
                && user.player.ConversationNPC==body && user.player.ConversationPC==user,"native localized dialogue opens for the authorized player");
            Check(!deadBody.InteractWithCaelumPlayer(other),"dead example cannot open dialogue");
            ledger.Phase=2;Console.Printf("CA440SPIRIT RESULT capture");
        }
        else if(Reloaded && ledger.Phase==2)
        {
            Check(body!=null && body.Revision==1 && deadBody.health<=0,"common save retains original and destroyed spirit identities");
            Check(CaelumTarotSpirit.CanHear(user) && !CaelumTarotSpirit.CanHear(other),"equipped hearing permission survives recovery");
            Check(body.bInConversation && body.HasConversation() && user.player.ConversationNPC==body,
                "native saved dialogue resumes instead of cursor-only freeze");
            Check(!CaelumTarotSpirit.CanHarm(user),"unequipped damage permission remains disabled after load");
            ledger.Phase=3;Console.Printf("CA440SPIRIT RESULT reload");
        }
    }
}
