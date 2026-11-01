class CA440LoversBody : CaelumCombatActor
{
    override void Tick(){}
    Default {Health 4000;Radius 12;Height 56;Mass 80;Speed 0;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440LoversLedger : Inventory
{
    int Phase;
    CA440LoversBody Friend,Outsider;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440L %s %s",okay?"PASS":"FAIL",label);}
    void Reset(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int i=0;i<78;i++)
        {record.TarotOwned[i]=true;record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotCooldownTics=record.TarotEffectTics=0;user.ApplyCharacterProfile();
        user.DerivedStats.AbilityRangePercent=100;user.CurrentAnima=user.DerivedStats.MaximumAnima;
        user.health=user.player.health=user.CaelumMaximumHealth;
        user.ElementalStatus=new('CaelumElementalStatus');CaelumFoodIllness.Get(user).Contamination=0;
    }
    void ClearRemainder(Actor body)
    {let rest=CaelumLoversRemainder(body.FindInventory('CaelumLoversRemainder'));if(rest!=null)rest.DamageFraction=rest.HealingFraction=0;}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440LoversLedger(user.FindInventory('CA440LoversLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440LoversLedger(user.GiveInventoryType('CA440LoversLedger'));ledger.Phase=1;
            Level.ChangeLevel("CARING",0,CHANGELEVEL_NOINTERMISSION);return;
        }
        if(ledger.Phase==1 && level.MapName=="CARING" && level.time>5)
        {
            Reset(user);Reset(other);user.SetOrigin((64,64,0),false);other.SetOrigin((104,64,0),false);
            int before=user.health,peerBefore=other.health;
            user.ApplyNativeHealthDamage(null,null,120,'None',DMG_NO_ARMOR,0);
            int resolved=before-user.health;
            Check(resolved>0 && other.health==peerBefore,"ownership without equipment does not share native damage");
            CaelumTarotService.Select(user,6);user.health=user.player.health=before;
            user.ApplyNativeHealthDamage(null,null,120,'None',DMG_NO_ARMOR,0);
            Check(before-user.health==resolved/2 && peerBefore-other.health==resolved/2,"equipped Lovers splits the actual native post-defense hit");
            CaelumTarotService.Select(other,6);before=user.health;peerBefore=other.health;
            user.ApplyNativeHealthDamage(null,null,120,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(before-user.health==60 && peerBefore-other.health==60,"overlapping passive auras neither duplicate nor recurse forced damage");
            user.player.cheats|=CF_GODMODE;before=user.health;peerBefore=other.health;
            user.ApplyNativeHealthDamage(null,null,120,'None',DMG_NO_ARMOR,0);
            Check(user.health==before && other.health==peerBefore,"native God immunity does not leak damage through the aura");
            user.player.cheats&=~CF_GODMODE;
            ledger.Friend=CA440LoversBody(Actor.Spawn('CA440LoversBody',(140,64,0),NO_REPLACE));
            ledger.Outsider=CA440LoversBody(Actor.Spawn('CA440LoversBody',(64,112,0),NO_REPLACE));
            ledger.Friend.CombatMaximumHealth=ledger.Outsider.CombatMaximumHealth=4000;
            ledger.Friend.bFriendly=ledger.Outsider.bFriendly=true;
            let party=CaelumCompanionParty.Get(user,true);party.Roster.Clear();
            let bond=new('CaelumCompanionBond');bond.Body=ledger.Friend;bond.Party=party;
            bond.Enlisted=true;bond.Identity=0;party.Roster.Push(bond);ledger.Friend.Companion=bond;
            let members=CaelumTarotLovers.Recipients(user,false);
            Check(members!=null && members.Bodies.Size()==3,"only real enlisted companions join the cooperative player group");
            before=user.health;peerBefore=other.health;int friendBefore=ledger.Friend.health;
            user.ApplyNativeHealthDamage(null,null,120,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(before-user.health==40 && peerBefore-other.health==40 && friendBefore-ledger.Friend.health==40,
                "players and companion receive one equal Health share");
            Check(ledger.Outsider.health==4000,"nearby friendly nonmember is not part of Lovers");
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            user.RallyDamageFactor=0.5;other.RallyDamageFactor=ledger.Friend.RallyDamageFactor=0.25;
            user.ApplyNativeHealthDamage(null,null,120,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(before-user.health==20 && peerBefore-other.health==20 && friendBefore-ledger.Friend.health==20,
                "original defense is applied once and recipient defense is not repeated");
            user.RallyDamageFactor=other.RallyDamageFactor=ledger.Friend.RallyDamageFactor=1;
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            ledger.Friend.ApplyNativeHealthDamage(null,null,90,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(before-user.health==30 && peerBefore-other.health==30 && friendBefore-ledger.Friend.health==30,
                "a companion can be the original damaged group member");
            ledger.Friend.SetOrigin((500,64,0),false);
            Check(CaelumTarotLovers.Recipients(user,false).Bodies.Size()==2,"leaving the aura immediately removes the companion");
            ledger.Friend.SetOrigin(CaelumJusticeGeometry.Center(level.MapName),false);
            user.DerivedStats.AbilityRangePercent=other.DerivedStats.AbilityRangePercent=100000;
            Check(CaelumTarotLovers.Recipients(user,false).Bodies.Size()==2,"separate room walls block the aura even with sufficient range");
            user.DerivedStats.AbilityRangePercent=other.DerivedStats.AbilityRangePercent=100;
            ledger.Friend.SetOrigin((225,64,0),false);
            CaelumTarotService.Select(other,6);
            Check(CaelumTarotLovers.Recipients(user,false).Bodies.Size()==2,"a secondary recipient does not propagate the original caster aura");
            CaelumTarotService.Select(other,6);
            Check(CaelumTarotLovers.Recipients(user,false).Bodies.Size()==3,"another aura reaching the original receiver contributes its own eligible members");
            ledger.Friend.SetOrigin((140,64,0),false);
            ClearRemainder(user);ClearRemainder(other);ClearRemainder(ledger.Friend);
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            for(int i=0;i<3;i++)user.ApplyNativeHealthDamage(null,null,1,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(before-user.health==1 && peerBefore-other.health==1 && friendBefore-ledger.Friend.health==1,"fractional damage conserves three one-point hits without minimum-hit inflation");
            user.health=user.player.health=user.CaelumMaximumHealth-200;
            other.health=other.player.health=other.CaelumMaximumHealth-200;ledger.Friend.health=3800;
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            CaelumSupportMagic.Heal(user,90);
            Check(user.health-before==90 && other.health==peerBefore && ledger.Friend.health==friendBefore,"equipped passive alone does not share healing");
            user.CurrentAnima=user.DerivedStats.MaximumAnima;double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user) && abs(user.CurrentAnima-(anima-1000))<0.01,"active Lovers uses the ordinary single sequence payment");
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            CaelumSupportMagic.Heal(user,90);
            Check(user.health-before==30 && other.health-peerBefore==30 && ledger.Friend.health-friendBefore==30,"support healing shares once through the active aura");
            other.health=other.player.health=other.CaelumMaximumHealth;
            before=user.health;friendBefore=ledger.Friend.health;CaelumSupportMagic.Heal(user,30);
            Check(user.health-before==10 && ledger.Friend.health-friendBefore==10 && other.health==other.CaelumMaximumHealth,"full recipient caps discard excess instead of redirecting it");
            ClearRemainder(other);CaelumSupportMagic.Heal(user,1);
            Check(CaelumLoversRemainder(other.FindInventory('CaelumLoversRemainder')).HealingFraction==0,
                "full recipients discard even sub-point excess healing");
            other.bInvulnerable=true;ClearRemainder(other);
            user.ApplyNativeHealthDamage(null,null,1,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(CaelumLoversRemainder(other.FindInventory('CaelumLoversRemainder')).DamageFraction==0,
                "immune recipients do not accrue delayed fractional damage");other.bInvulnerable=false;
            ledger.Friend.health=0;members=CaelumTarotLovers.Recipients(user,true);
            Check(members!=null && members.Bodies.Size()==2,"dead companion cannot receive healing or be resurrected by sharing");
            ledger.Friend.health=3800;other.health=other.player.health=other.CaelumMaximumHealth-200;
            user.health=user.player.health=user.CaelumMaximumHealth-200;
            ClearRemainder(user);ClearRemainder(other);ClearRemainder(ledger.Friend);
            let potion=CaelumRegenerationPower(user.GiveInventoryType('CaelumLifeRegeneration'));
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            potion.ApplyPotionPulse(CaelumConstants.CONSUMABLE_LIFE_POTION,90.0/user.CaelumMaximumHealth);
            Check(user.health-before==30 && other.health-peerBefore==30 && ledger.Friend.health-friendBefore==30,"real medkit pulse uses the same healing boundary");
            potion.Destroy();
            before=user.health;peerBefore=other.health;friendBefore=ledger.Friend.health;
            CaelumPlayerResources.ApplyMiraclePulse(user,90.0/user.CaelumMaximumHealth);
            Check(user.health-before==30 && other.health-peerBefore==30 && ledger.Friend.health-friendBefore==30,"real miracle pulse shares Health without redistributing its other resources");
            CaelumTarotService.Select(user,6);CaelumTarotService.Select(other,6);
            Check(!user.GetPersistentCharacterState(false).TarotSelected[6]
                && CaelumTarotLovers.Recipients(user,false).Bodies.Size()==3,
                "active Lovers still shares damage without an equipped passive");
            let raw=Actor.Spawn('CaelumSummoningProbe',(500,500,0),NO_REPLACE);
            raw.health=raw.GetMaxHealth()-20;int rawBefore=raw.health;
            CaelumTarotLovers.Heal(raw,10);
            Check(raw.health==rawBefore+10,"generic existing healing retains native maximum Health");raw.Destroy();
            user.GetPersistentCharacterState(false).TarotRemaining[6]=0;
            user.GetPersistentCharacterState(false).TarotActive[6]=false;
            ledger.Friend.A_ChangeLinkFlags(1,0);ledger.Friend.SetFriendPlayer(user.player);
            CaelumContaminationWorld.Get().ContactGrid().Track(ledger.Friend);
            ledger.Friend.health=3000;
            let miracle=CaelumMiracleEffect(user.GiveInventoryType('CaelumMiracleEffect'));
            miracle.Revision=CaelumMiracle.REVISION;miracle.RemainingTics=35;
            miracle.Range=128;miracle.RecoveryRatio=0.01;
            CaelumMiracle.Pulse(miracle);
            Check(ledger.Friend.health==3040,"local Miracle pulse reaches an unlinked body exactly once");
            Check(CaelumMiracle.Affected(ledger.Friend),"fixed-player Miracle lookup preserves unlinked eligibility");
            let stronger=CaelumMiracleEffect(other.GiveInventoryType('CaelumMiracleEffect'));
            stronger.Revision=CaelumMiracle.REVISION;stronger.RemainingTics=35;
            stronger.Range=128;stronger.RecoveryRatio=0.02;
            Check(!CaelumMiracle.Strongest(miracle,user) && CaelumMiracle.Strongest(stronger,user),
                "fixed-player lookup preserves strongest Miracle precedence");
            miracle.Destroy();stronger.Destroy();
            CaelumTarotService.Select(user,6);CaelumTarotService.Select(other,6);
            user.GetPersistentCharacterState(false).TarotRemaining[6]=60*TICRATE;
            user.GetPersistentCharacterState(false).TarotActive[6]=true;
            ClearRemainder(user);ClearRemainder(other);ClearRemainder(ledger.Friend);
            user.ApplyNativeHealthDamage(null,null,1,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(abs(CaelumLoversRemainder(user.FindInventory('CaelumLoversRemainder')).DamageFraction-1.0/3)<0.0001,"fractional share is retained as persistent inventory state");
            user.health=user.player.health=user.CaelumMaximumHealth;
            other.health=other.player.health=other.CaelumMaximumHealth;ledger.Friend.health=4000;
            ledger.Phase=2;user.PersistCharacterState();Console.Printf("CA440L RESULT capture");return;
        }
        if(ledger.Phase==2 && Reloaded)
        {
            Check(CaelumTarotService.IsActive(user.GetPersistentCharacterState(false),6),"recovery preserves the paid active aura");
            let rest=CaelumLoversRemainder(user.FindInventory('CaelumLoversRemainder'));
            Check(rest!=null && abs(rest.DamageFraction-1.0/3)<0.0001,"common recovery preserves fractional damage");
            int before=user.health,peerBefore=other.health,friendBefore=ledger.Friend.health;
            for(int i=0;i<2;i++)user.ApplyNativeHealthDamage(null,null,1,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            Check(before-user.health==1 && peerBefore-other.health==1 && friendBefore-ledger.Friend.health==1,"recovered remainder completes equally without replaying prior hits");
            CaelumTarotSequence.Advance(user,user.GetPersistentCharacterState(false),TICRATE*120);
            Check(CaelumTarotLovers.Recipients(user,true)==null,"active expiry stops shared healing while keeping equipped damage sharing");
            Check(CaelumTarotLovers.Recipients(user,false)!=null,"equipped passive survives active expiry and save recovery");
            ledger.Phase=3;Console.Printf("CA440L RESULT reload");
        }
    }
}
