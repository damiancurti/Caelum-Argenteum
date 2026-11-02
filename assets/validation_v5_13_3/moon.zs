// Native two-peer lifecycle, perception, independent resources and persistence.
class CA440MoonTarget : CaelumCombatActor
{
    Default {Health 100000;Radius 12;Height 56;Mass 80;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440MoonDamage : Actor
{
    Default {Health 100000;Radius 12;Height 56;+SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440MoonLedger : Inventory
{
    int Phase,Started,AmmoBefore;
    double SourceAnima,PreviousAir;
    bool UnarmedStarted,AirSpent;
    CaelumEquipmentItem Weapon;
    Inventory Ammo;
    CA440MoonTarget Victim;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440MOON %s %s",okay?"PASS":"FAIL",label);}
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
        let ledger=CA440MoonLedger(user.FindInventory('CA440MoonLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            Prepare(user);Prepare(other);user.SetOrigin((0,0,0),false);other.SetOrigin((-512,-512,0),false);
            user.Angle=user.Pitch=0;
            ledger=CA440MoonLedger(user.GiveInventoryType('CA440MoonLedger'));
            let weapon=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',user.Pos,NO_REPLACE));
            weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            weapon.ItemType=CaelumConstants.WEAPON_TYPE_CARBINE;weapon.Tier=1;weapon.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
            weapon.Durability=100000;weapon.Amount=1;weapon.Equipped=true;weapon.ItemId=9910;
            weapon.PickupDataInitialized=weapon.AcquisitionResolved=true;
            weapon.UnitWeight=user.WeaponModel.GetWeightFor(weapon.ItemType,1,weapon.EquipmentSize);
            weapon.AttachToOwner(user);ledger.Weapon=weapon;
            weapon.AwakeningRevision=1;weapon.AwakeningCard=0;weapon.AwakeningOwner=user;weapon.AwakeningHalfWear=1;
            user.WeaponModel.WeaponType=weapon.ItemType;user.WeaponModel.Tier=1;user.WeaponModel.Size=weapon.EquipmentSize;
            user.WeaponModel.Durability=weapon.Durability;user.WeaponModel.Equipped=true;user.ActiveWeaponItemId=weapon.ItemId;
            ledger.Ammo=user.GiveInventoryType('CaelumCarbineAmmo');ledger.Ammo.Amount=20;user.CarbineMagazine=5;
            ledger.AmmoBefore=20;
            CaelumTarotService.Select(user,18);CaelumTarotService.Select(user,9);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"Moon sequence activates");
            let binding=CaelumTarotMoon.View(user);
            Check(binding!=null && binding.Bodies[0]!=null && binding.Bodies[1]!=null,"two bodies occupy free positions");
            if(binding==null || binding.Bodies[0]==null || binding.Bodies[1]==null){ledger.Phase=99;return;}
            let a=binding.Bodies[0],b=binding.Bodies[1];
            Check(a.RemainingTics==4200 && b.RemainingTics==4200,"Hermit extends each clone once");
            Check(Abs(user.CurrentAnima-anima+1000)<0.01,"one shared Anima payment");
            Check(a.Look!=user.CharacterProfile && a.Look.Sex==user.CharacterProfile.Sex
                && a.Look.Face==user.CharacterProfile.Face && a.Look.HairStyle==user.CharacterProfile.HairStyle,"appearance is an independent snapshot");
            Check(a.Head!=null && a.Head.master==a && a.sprite==CaelumAppearance.SpriteFor(a.Look.Race,a.Look.Sex,
                a.Look.BeastForm,a.Look.SkinTone,a.VisualPose,a.Gloves),"existing body and head sprites are registered");
            Check(a.CombatStrength==user.Attributes.Strength && a.CombatInsight==user.Attributes.Insight,"caster attributes copied");
            Check(a.CombatMaximumHealth==int(user.DerivedStats.MaximumHealth*0.25),"quarter maximum Health");
            Check(a.DamageMultiply==user.DamageMultiply*0.25,"quarter outgoing native damage multiplier");
            Check(a.Companion.Loadout.SelectedWeapon!=weapon && a.Companion.Loadout.SelectedWeapon!=b.Companion.Loadout.SelectedWeapon
                && a.Companion.Loadout.SelectedWeapon.ItemType==weapon.ItemType,"independent selected weapons");
            Check(a.Companion.Loadout.Ranged.Ammunition()!=ledger.Ammo && a.Companion.Loadout.Ranged.Ammunition().Amount==20
                && b.Companion.Loadout.Ranged.Ammunition().Amount==20,"ammunition copied without consuming source");
            Check(CaelumAwakening.Factor(a.Companion.Loadout.SelectedWeapon)==1.25
                && CaelumAwakening.Card(a.Companion.Loadout.SelectedWeapon)==-1,"copied awakening has power without binding an essence");
            Check(CaelumAwakening.Wear(a.Companion.Loadout.SelectedWeapon,1)==1 && weapon.AwakeningHalfWear==1,"copied wear remainder is independent");
            Check(a.CurrentCombatAir==user.CurrentAir && a.CurrentCombatAnima==user.CurrentAnima,"independent current Air and Anima snapshot");
            Check(!CaelumVisualPerception.Opponent(a,user) && !CaelumVisualPerception.Opponent(a,b),"caster and sibling are allies");
            Check(!CaelumTarotMoon.Swap(other,a),"other player cannot swap this clone");
            vector3 original=user.Pos,image=a.Pos;
            Check(CaelumTarotMoon.Swap(user,a) && user.Pos==image && a.Pos==original,"safe native swap succeeds");
            user.SetOrigin((-300,-300,0),false);a.SetOrigin((0,0,0),false);a.Angle=0;
            b.SetOrigin((-300,300,0),false);
            ledger.Victim=CA440MoonTarget(Actor.Spawn('CA440MoonTarget',(128,0,0),NO_REPLACE));
            ledger.Victim.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
            ledger.Victim.health=ledger.Victim.CombatMaximumHealth=100000;
            Check(CaelumVisualPerception.Opponent(a,ledger.Victim),"hostile recipient remains a perceived candidate");
            let damage=Actor.Spawn('CA440MoonDamage',(500,500,0),NO_REPLACE);int before=damage.health;
            damage.DamageMobj(a,a,100,'None',0,0);
            Check(before-damage.health==25,"native impact applies quarter damage exactly once");damage.Destroy();
            ledger.Phase=1;ledger.Started=level.time;return;
        }
        let binding=CaelumTarotMoon.View(user);let a=binding!=null?binding.Bodies[0]:null;
        if(ledger.Phase==1 && level.time-ledger.Started>=110)
        {
            Check(a!=null && a.Companion.Loadout.Ranged.Shots>0,"clone sees and fires through native combat");
            Check(a!=null && a.Companion.Loadout.Ranged.Ammunition().Amount<20 && ledger.Ammo.Amount==ledger.AmmoBefore,"shots spend only clone ammunition");
            Check(a!=null && a.Companion.Loadout.SelectedWeapon.Durability<=ledger.Weapon.Durability,"wear belongs to copied weapon");
            if(ledger.Victim!=null)ledger.Victim.Destroy();
            let b=binding!=null?binding.Bodies[1]:null;Inventory piece=b!=null?b.Companion.Loadout.SelectedWeapon:null;
            if(b!=null)b.Die(user,user,0,'None');
            Check(binding.Bodies[1]==null && (piece==null || piece.bDestroyed),"death removes clone and copied loot");
            int remaining=a!=null?a.RemainingTics:0;CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(a!=null && a.RemainingTics==remaining-1,"shared accelerated clock advances clone once");
            // An independent magic snapshot reuses the surviving player's inventory identity.
            ledger.Weapon.ItemType=CaelumConstants.WEAPON_TYPE_STAFF;ledger.Weapon.EssenceType=CaelumConstants.ESSENCE_FIRE;
            user.WeaponModel.WeaponType=ledger.Weapon.ItemType;user.WeaponModel.EssenceType=ledger.Weapon.EssenceType;
            user.CurrentAnima=user.DerivedStats.MaximumAnima;ledger.SourceAnima=user.CurrentAnima;
            let mage=CaelumTarotClone(Actor.Spawn('CaelumTarotClone',(0,80,0),NO_REPLACE));
            mage.Initialize(user,binding,4200);binding.Bodies[1]=mage;mage.Angle=0;
            a.SetOrigin((-500,500,0),false);a.bDormant=true;
            ledger.Victim=CA440MoonTarget(Actor.Spawn('CA440MoonTarget',(128,80,0),NO_REPLACE));
            ledger.Victim.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
            ledger.Victim.health=ledger.Victim.CombatMaximumHealth=100000;
            ledger.Phase=5;ledger.Started=level.time;
        }
        if(ledger.Phase==5 && level.time-ledger.Started>=110)
        {
            let mage=binding.Bodies[1];
            Check(mage!=null && mage.Companion.Loadout.Magic!=null && mage.Companion.Loadout.Magic.Releases>0,"clone casts through native magic preparation");
            Check(mage!=null && mage.CurrentCombatAnima<ledger.SourceAnima && user.CurrentAnima>=ledger.SourceAnima,"casting spends clone Anima only");
            let shot=CaelumActorProjectile(Actor.Spawn('CaelumCarbineProjectile',(800,0,0),NO_REPLACE));
            shot.Target=mage;shot.StoreCaelumAttackResult(100,true,false,false,1);
            Check(mage!=null && mage.Shots.Find(shot)<mage.Shots.Size(),"projectiles have a local clone-owned registry");
            if(mage!=null)mage.Destroy();
            Check(shot==null || shot.bDestroyed,"illusion expiry removes its outstanding projectile");
            if(ledger.Victim!=null)ledger.Victim.Destroy();
            ledger.Weapon.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;ledger.Weapon.EssenceType=CaelumConstants.ESSENCE_FIRE;
            user.WeaponModel.WeaponType=ledger.Weapon.ItemType;
            let fighter=CaelumTarotClone(Actor.Spawn('CaelumTarotClone',(0,0,0),NO_REPLACE));
            fighter.Initialize(user,binding,4200);binding.Bodies[1]=fighter;fighter.Angle=0;
            other.SetOrigin((48,0,0),false);other.EffectiveStealthPercent=0;other.bInvulnerable=false;
            other.ShieldModel.Equipped=false;
            for(int slot=0;slot<4;slot++){other.ArmorModel.ArmorType[slot]=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;other.ArmorModel.Durability[slot]=0;}
            let match=new('CaelumArenaMatch');match.Status=CaelumArenaMatch.FIGHTING;match.Mode=0;match.Mask=3;
            match.Members[0]=user;match.Members[1]=other;
            CaelumArenaState.Get(user).MatchState=match;CaelumArenaState.Get(other).MatchState=match;
            Check(CaelumVisualPerception.Opponent(fighter,other),"clone uses caster's PvP relation");
            ledger.Phase=6;ledger.Started=level.time;
        }
        if(ledger.Phase==6)
        {
            other.Vel=(0,0,0);other.SetOrigin((48,0,0),false);
        }
        if(ledger.Phase==6 && level.time-ledger.Started>=160)
        {
            let fighter=binding.Bodies[1];
            Check(fighter!=null && fighter.Companion.Loadout.Tools.MeleeUses>0,"copied melee weapon attacks a perceived player");
            Check(fighter!=null && fighter.Companion.Loadout.Tools.LastStrikeDamage>0,"native melee damage reaches player defenses");
            if(fighter!=null)fighter.Destroy();
            ledger.Weapon.Equipped=false;user.WeaponModel.Equipped=false;user.ActiveWeaponItemId=0;
            let unarmed=CaelumTarotClone(Actor.Spawn('CaelumTarotClone',(0,0,0),NO_REPLACE));
            unarmed.Initialize(user,binding,4200);binding.Bodies[1]=unarmed;unarmed.Angle=0;
            other.SetOrigin((-512,-512,0),false);
            ledger.Victim=CA440MoonTarget(Actor.Spawn('CA440MoonTarget',(48,0,0),NO_REPLACE));
            ledger.Victim.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
            ledger.Victim.health=ledger.Victim.CombatMaximumHealth=100000;
            ledger.PreviousAir=unarmed.CurrentCombatAir;
            ledger.Phase=7;ledger.Started=level.time;
        }
        if(ledger.Phase==7)
        {
            let body=binding.Bodies[1];
            if(body!=null)
            {
                ledger.UnarmedStarted|=body.InStateSequence(body.CurState,body.MeleeState);
                ledger.AirSpent|=body.CurrentCombatAir<ledger.PreviousAir;
                ledger.PreviousAir=body.CurrentCombatAir;
            }
            if(level.time-ledger.Started>=110)
            {
                Check(body!=null && body.Companion.Loadout.SelectedWeapon==null && ledger.UnarmedStarted,"unarmed clone uses the existing fist cycle");
                Check(ledger.AirSpent,"unarmed clone pays its own Air");
                if(body!=null)body.Destroy();
                if(ledger.Victim!=null)ledger.Victim.Destroy();
                CaelumArenaState.Get(user).MatchState=null;CaelumArenaState.Get(other).MatchState=null;
                other.SetOrigin((-512,-512,0),false);
                a.SetOrigin((0,64,0),false);a.Angle=270;
                user.SetOrigin((0,-96,0),false);user.Angle=90;user.Pitch=0;
                ledger.Phase=2;Console.Printf("CA440MOON RESULT capture");
            }
        }
        if(Reloaded && ledger.Phase==2)
        {
            Check(binding!=null && binding.Revision==1 && a!=null && a.Caster==user,"common save restores caster and clone");
            Check(a!=null && a.Companion.Loadout.SelectedWeapon.Owner==a && a.Companion.Loadout.Ranged.Ammunition().Owner==a,"save retains independent equipment and ammo ownership");
            Check(a!=null && a.Look!=user.CharacterProfile && a.Head!=null && a.Head.master==a,"save retains private appearance and head");
            int old=a!=null?a.RemainingTics:0;CaelumMajorWorldEvents.AdvanceSkippedTic();
            Check(a!=null && a.RemainingTics==old-1,"owner index rebuilds after recovery");
            if(a!=null){a.RemainingTics=1;a.AdvanceEffect();}
            Check(binding.Bodies[0]==null,"expiry removes remaining clone");
            Check(CaelumTarotMoon.Start(user,2100),"new cast after expiry");
            let oldBody=binding.Bodies[0];CaelumTarotMoon.Start(user,2100);
            Check(oldBody==null || oldBody.bDestroyed,"recast replaces previous bodies");
            ledger.Phase=3;CaelumDeadTraveler.ChangeMap("CARING",0,CHANGELEVEL_NOINTERMISSION);
        }
        if(Reloaded && ledger.Phase==3 && level.MapName=="CARING")
        {
            binding=CaelumTarotMoon.View(user);let record=user.GetPersistentCharacterState(false);
            Check(binding!=null && binding.Bodies[0]==null && binding.Bodies[1]==null,"travel removes all origin-map clones");
            Check(record.TarotRemaining[18]==0 && record.TarotCooldownTics>0,"travel ends effect while preserving cooldown");
            ledger.Phase=4;Console.Printf("CA440MOON RESULT reload");
        }
    }
}
