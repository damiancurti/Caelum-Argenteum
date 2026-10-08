class CA133Target : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 24; Height 80; Health 1000000; +SOLID +SHOOTABLE }
    States { Spawn: DOID A -1; Stop; }
}

class CA133Carbine : EventHandler
{
    CaelumPortDefender Body;
    CA133Target Target;
    int Checks,Failures,LastCount,LastShotTic,LastReloadCount,ReloadStart,MinimumInterval;
    bool SawReload,Interrupted,Exhausted;
    void Check(bool result,String label)
    {Checks++;if(!result)Failures++;Console.Printf("CA133 %s %s",result ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        if(level.time==70)
        {
            Body=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(3072,4096,0)));
            Body.HomeRevision=1;Body.Carbine=new("CaelumCityCarbine");Body.Carbine.Initialize(Body);Body.tics=-1;
            Target=CA133Target(Actor.Spawn("CA133Target",(5120,4096,0)));
        }
        if(level.time==75)
        {
            // Valid maximum attribute profile isolates repeated magazines;
            // the earlier default-18 run separately demonstrated Air exhaustion.
            Body.InitializeUniformFolkloreProfile(100);
            Console.Printf("CA133 CARBINE_START health=%d air=%.3f duration=%.3f range=%.1f sight=%d",Body.health,Body.CurrentCombatAir,Body.GetProfileWeaponDuration(CaelumConstants.WEAPON_TYPE_CARBINE),Body.Carbine.Weapon.GetRangedRangeFor(CaelumConstants.WEAPON_TYPE_CARBINE),Body.CheckSight(Target));
            Check(Body.Carbine.Magazine==10 && Body.FindInventory("CaelumCarbineAmmo")==null,"normal ten-shot magazine with no infinite inventory stack");
            Check(!Body.Carbine.Attack(Body,Target) && Body.Carbine.Magazine==10,"carbine refuses targets beyond its authored 60-metre range");
            Target.SetOrigin((3584,4096,0),false);
            double air=Body.CurrentCombatAir;int durability=Body.Carbine.Weapon.Durability;
            Body.Carbine.Attack(Body,Target);
            MinimumInterval=Body.Carbine.NextShotTic-level.time;
            Check(Body.Carbine.ShotCount==1 && Body.Carbine.Magazine==9 && Body.CurrentCombatAir<air,"first live projectile spends one round and physical Air");
            Check(MinimumInterval==int(Ceil(Body.GetProfileWeaponDuration(CaelumConstants.WEAPON_TYPE_CARBINE))),"firing interval uses shared physical duration and load");
            LastCount=1;LastShotTic=level.time;
        }
        if(Body==null)return;
        if(level.time>75 && level.time<2500)
        {
            int count=Body.Carbine.ShotCount;
            if(Body.Carbine.ReloadRemaining>0)
            {
                SawReload=true;
                Body.Carbine.Attack(Body,Target);
                if(Body.Carbine.ShotCount!=count)Check(false,"no shots while reloading");
            }
            else Body.Carbine.Attack(Body,Target);
            if(Body.Carbine.ShotCount>LastCount)
            {
                if(level.time-LastShotTic<MinimumInterval)Check(false,"no faster-than-profile duplicate shot");
                LastCount=Body.Carbine.ShotCount;LastShotTic=level.time;
            }
            if(Body.AttackResourceWaiting)Exhausted=true;
            if(SawReload && !Interrupted && Body.Carbine.ReloadRemaining>0)
            {
                int magazine=Body.Carbine.Magazine;Body.Carbine.Select(false);
                Check(!Body.Carbine.Held && Body.Carbine.ReloadRemaining==0 && Body.Carbine.Magazine==magazine,"melee switch cancels reload without granting rounds");
                Body.Carbine.Select(true);Interrupted=true;
            }
        }
        if(level.time==2500)
        {
            Check(SawReload && Body.Carbine.ReloadCount>=2 && Body.Carbine.ShotCount>20,"repeated live magazines reload from reserve without physical ammunition");
            Check(Target.Hits>0 && Target.health<1000000,"normal native ballistic projectiles reach and damage target");
            Check(Body.Carbine.Weapon.Durability<Body.Carbine.Weapon.GetMaximumDurability(),"carbine suffers ordinary successful-hit wear");
            Check(Body.FindInventory("CaelumCarbineAmmo")==null,"sustained fire never materializes ammunition loot");
            int count=Body.Carbine.ShotCount;
            Body.SetState(Body.FindState("Pain"));Body.Carbine.ReloadRemaining=1;Body.Carbine.Tick(Body);Body.Carbine.Attack(Body,Target);
            Check(Body.Carbine.ReloadRemaining==0 && Body.Carbine.ShotCount==count,"pain cancels reload and prevents shot");
            Body.health=0;Body.Carbine.Attack(Body,Target);
            Check(Body.Carbine.ShotCount==count,"dead soldier cannot fire");
            Console.Printf("CA133 CARBINE shots=%d reloads=%d hits=%d exhausted=%d",Body.Carbine.ShotCount,Body.Carbine.ReloadCount,Target.Hits,Exhausted);
        }
        if(level.time==2510)
        {
            let u=CaelumPlayer(players[0].mo);u.CreationWizardOpen=false;
            let stock=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(2048,2048,0)));
            int size=CaelumEquipmentRules.ResolveAcquisitionSize(u,CaelumEquipmentRules.CHARACTER_DEFAULT,CaelumConstants.EQUIPMENT_SIZE_M);
            stock.SeedEquipment(u,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_CARBINE,0,size,0);
            let item=CaelumEquipmentItem(stock.Inv);stock.RemoveInventory(item);item.AttachToOwner(u);item.AcquisitionResolved=true;
            u.EnsureEquipmentItemId(item);u.EquipmentSelectionItemId=item.ItemId;u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            u.EquipmentSelectionWeaponType=CaelumConstants.WEAPON_TYPE_CARBINE;u.EquipmentSelectionTier=1;u.EquipmentSelectionSize=size;
            u.RefreshEquipmentSelectionPreview();u.EquipSelectedNativeEquipment();
            let ammo=CaelumCarbineAmmo(Actor.Spawn("CaelumCarbineAmmo",u.Pos));ammo.Amount=2;ammo.AttachToOwner(u);
            u.CarbineMagazine=2;u.OnNativeInventoryChanged();u.PerformCarbineAttack();
            Check(u.LastCarbineFired && ammo.Amount==1 && u.CarbineMagazine==1,"shared projectile path preserves finite player ammo");
            ammo.Amount=0;u.CarbineMagazine=0;u.CancelRangedReload();u.RequestRangedReload(CaelumConstants.WEAPON_TYPE_CARBINE);u.PerformCarbineAttack();
            Check(!u.RangedReloadActive && !u.LastCarbineFired && u.CarbineMagazine==0,"empty player reserve cannot reload or fire");
            Console.Printf("CA133 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
