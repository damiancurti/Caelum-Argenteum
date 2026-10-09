// Focused native checks for the approved energy budgets; no campaign acceptance.
class CA136EnergyChecks : CA136Checks
{
    CaelumCombatActor Specimens[5];
    bool Near(double a,double b,double tolerance=0.000001) {return Abs(a-b)<tolerance;}
    void Ready(CaelumPlayer u,bool high)
    {
        u.DebugAttributesAt100=high;u.ApplyCharacterProfile();
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentAnima=u.DerivedStats.MaximumAnima;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.EquippedWeaponCooldownRemaining=0;u.WeaponChargedStateActive=false;
        let t=CaelumThermalBody.Get(u,true);t.Exposure=0;
        CaelumThermalBody.Refresh(u,t);
    }
    void MathAndMigration(CaelumPlayer u)
    {
        Check(Near(CaelumThermalRules.PositiveWorkHeat(100),300),"100 J work yields 300 J heat at 25 percent efficiency");
        Check(Near(CaelumThermalRules.BodyJumpHeat(133.576),1965.57084),"approved half-metre human jump budget includes carried mass");
        double slow=0;for(int i=0;i<100;i++)slow+=CaelumThermalRules.LocomotionWork(100,0.1,0,false,9.81);
        double fast=CaelumThermalRules.LocomotionWork(100,10,0,false,9.81);
        Check(Near(slow,502.5) && Near(slow,fast),"same walking distance has identical work despite traversal speed and step partition");
        Check(Near(CaelumThermalRules.LocomotionWork(100,10,0,true,9.81),1005),"running work is 1.005 J per kg metre");
        Check(Near(CaelumThermalRules.LocomotionWork(100,10,0.2,false,9.81),502.5+1962),"ascent adds positive gravitational work once");
        Check(CaelumThermalRules.LocomotionWork(100,10,-0.2,false,9.81)>0
            && CaelumThermalRules.LocomotionWork(100,10,-0.2,false,9.81)<fast,"moderate descent retains braking curve without negative heat");
        Check(Near(CaelumThermalEffects.SwimmingWatts(2,false),436.5)
            && Near(CaelumThermalEffects.SwimmingWatts(2,true),785.7),"swimming converts fixed mechanical power to heat");
        Check(Near(CaelumThermalEffects.PushingWatts(2),582)
            && Near(CaelumThermalEffects.BlockingWatts(133.576,6),235.8685008),"isometric pushing and blocking retain metabolic heat without external work");
        for(int rank=0;rank<=100;rank+=50)
        {
            u.Attributes.Resilience=rank;let t=CaelumThermalBody.Get(u,true);CaelumThermalBody.Refresh(u,t);
            double factor=1+rank*(rank+1.0)/10100;
            Check(Near(t.AcclimationMultiplier,factor),String.Format("player Resilience%d uses additive Type 2",rank));
            double shifted=CaelumThermalRules.Acclimation(0,100,22,5*86400,factor);
            Check(Near(shifted,5*factor),"adaptation reaches approved limit in exactly five world days");
        }
        Check(Near(CaelumThermalRules.Threshold(1,100),20)
            && Near(CaelumThermalRules.Threshold(2,100),40)
            && Near(CaelumThermalRules.Threshold(3,100),60),"Toughness comfort thresholds already use Type 2 and remain unchanged");
        Check(Near(CaelumThermalRules.Acclimation(15,100,22,86400,2),13)
            && Near(CaelumThermalRules.Acclimation(15,100,22,2.5*86400,2),10),"old plus-fifteen adaptation returns gradually at new two-degree daily rate");
        let old=new("CaelumThermalState");old.Initialize();old.Revision=7;
        old.Exposure=4;old.Acclimation=15;old.Hydration=42;old.PendingFirearmJoules=123;old.Inertia=14000;
        old.ActionJoules=456;old.BaseWaterKg[0]=0.08;old.Initialize();
        Check(old.Revision==8 && old.Exposure==4 && old.Acclimation==15 && old.Hydration==42
            && old.PendingFirearmJoules==123 && old.ActionJoules==456 && old.BaseWaterKg[0]==0.08,"revision eight preserves prior exposure, adaptation, moisture and measured energy");
        old.ReloadHeatBudget=55;old.Initialize();Check(old.ReloadHeatBudget==55,"energy migration is idempotent");
        let journey=old.CopyForForecast();double original=old.ActivityJoules;
        CaelumThermalService.Integrate(journey,60,0,CaelumThermalRules.LocomotionHeat(100,1,0,false,9.81),0,0,60);
        Check(Near(journey.ActivityJoules-original,9045) && old.ActivityJoules==original,"logical journey counts actual distance once without mutating live state");
    }
    void Melee(CaelumPlayer u)
    {
        for(int weapon=0;weapon<3;weapon++)
        {
            int kind=weapon==0 ? CaelumConstants.WEAPON_TYPE_DAGGER : weapon==1 ? CaelumConstants.WEAPON_TYPE_SWORD : CaelumConstants.WEAPON_TYPE_GREATSWORD;
            Equip(u,kind);
            for(int high=0;high<2;high++)for(int secondary=0;secondary<2;secondary++)
            {
                Ready(u,high==1);let t=CaelumThermalBody.Get(u,true);double before=t.ActionJoules;
                double expected=weapon==0 ? (secondary ? 225 : 150) : weapon==1 ? (secondary ? 600 : 375) : (secondary ? 1350 : 900);
                u.PerformDebugSwordAttack(secondary==1);
                Check(u.LastMeleeHadEnoughAir && Near(t.ActionJoules-before,expected),String.Format("actual weapon%d secondary%d attributes%d has fixed action heat",kind,secondary,high*100));
            }
        }
        Ready(u,true);let t=CaelumThermalBody.Get(u,true);double before=t.ActionJoules;
        u.WeaponChargedStateActive=true;u.PerformDebugSwordAttack(false,true);
        Check(u.LastMeleeHadEnoughAir && Near(t.ActionJoules-before,5400),"charged greatsword sweep applies approved work factors once");
        u.CurrentAir=0;u.WeaponChargedStateActive=false;before=t.ActionJoules;u.PerformDebugSwordAttack(false);
        Check(!u.LastMeleeHadEnoughAir && t.ActionJoules==before,"rejected melee adds no action heat");
        Equip(u,CaelumConstants.WEAPON_TYPE_JAVELIN);
        for(int charged=0;charged<2;charged++)
        {
            Ready(u,true);u.WeaponChargedStateActive=charged==1;before=t.ActionJoules;
            u.PerformJavelinThrow();
            Check(Near(t.ActionJoules-before,charged ? 900 : 450),"actual javelin throw preserves the charged-work factor");
        }
    }
    void Firearms(CaelumPlayer u)
    {
        let ammo=Inventory(Actor.Spawn("CaelumCarbineAmmo",u.Pos));ammo.Amount=100;ammo.AttachToOwner(u);
        Shells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",u.Pos));Shells.Amount=100;Shells.AttachToOwner(u);
        u.OnNativeInventoryChanged();
        for(int weapon=0;weapon<2;weapon++)
        {
            int kind=weapon==0 ? CaelumConstants.WEAPON_TYPE_CARBINE : CaelumConstants.WEAPON_TYPE_SHOTGUN;
            Equip(u,kind);
            for(int high=0;high<2;high++)
            {
                Ready(u,high==1);let t=CaelumThermalBody.Get(u,true);
                u.SetRangedMagazineCount(kind,1);t.PendingFirearmJoules=0;u.PerformCarbineAttack();
                Check(u.LastCarbineFired && Near(t.PendingFirearmJoules,t.SurfaceArea*17.46),String.Format("actual firearm%d attributes%d pays one fixed shot budget",kind,high*100));
                for(int moving=0;moving<2;moving++)
                {
                    u.CancelRangedReload();u.SetRangedMagazineCount(kind,0);u.EquippedWeaponCooldownRemaining=0;
                    u.player.cmd.forwardmove=moving ? 100 : 0;
                    u.RequestRangedReload(kind);double expected=t.SurfaceArea*327.375;
                    double duration=u.RangedReloadTotalSeconds;t.PendingFirearmJoules=0;
                    int steps=0;while(u.RangedReloadActive && steps++<2000)u.UpdateRangedReload();
                    Check(steps>1 && !u.RangedReloadActive && Near(t.PendingFirearmJoules,expected),String.Format("firearm%d full reload attributes%d moving%d fixed heat despite duration %.6f",kind,high*100,moving,duration));
                }
                u.player.cmd.forwardmove=0;u.SetRangedMagazineCount(kind,0);u.RequestRangedReload(kind);
                double fraction=Min(1.0,1.0/TICRATE/u.RangedReloadTotalSeconds);
                t.PendingFirearmJoules=0;u.UpdateRangedReload();double partial=t.PendingFirearmJoules;
                u.CancelRangedReload();u.UpdateRangedReload();
                Check(Near(partial,t.SurfaceArea*327.375*fraction) && t.PendingFirearmJoules==partial,"cancelled reload retains completed work only");
            }
        }
        u.player.cmd.forwardmove=0;
    }
    void NPCs()
    {
        for(int species=0;species<5;species++)
        {
            let npc=Specimens[species];
            let t=CaelumThermalBody.Get(npc,true);Check(t!=null,"species owns supported thermal state");if(t==null)continue;
            npc.CombatResilience=100-npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_RESILIENCE);CaelumThermalBody.Refresh(npc,t);
            Check(Near(t.AcclimationMultiplier,2),"NPC Resilience uses Type 2 including animal physiology");
            for(int high=0;high<2;high++)
            {
                npc.CombatStrength=high*100;npc.CombatAgility=high*100;
                npc.CurrentCombatAir=100000;t.Exposure=0;double before=t.ActionJoules;
                bool spent=npc.SpendPhysicalAttackAir(CaelumAttackRules.NaturalAir());
                Check(spent && Near(t.ActionJoules-before,75),"NPC natural attack has fixed heat independent of attributes");
            }
            npc.CurrentCombatAir=100000;double before=t.ActionJoules;
            npc.SpendPhysicalAttackAir(CaelumAttackRules.SlamAir(),CaelumThermalData.GROUND_SLAM_WORK_JOULES);
            Check(Near(t.ActionJoules-before,2550),"NPC ground-slam work is charged once");
            npc.Destroy();
        }
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1)
        {
            u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;
            for(int i=0;i<5;i++)
            {
                class<Actor> kind=i==0 ? "CaelumBull" : i==1 ? "CaelumGiantRat" : i==2 ? "CaelumMandinga" : i==3 ? "CaelumZupayColossus" : "CaelumPortDefender";
                Specimens[i]=CaelumCombatActor(Actor.Spawn(kind,(1000+i*500,2000,0)));
                if(Specimens[i]!=null){Specimens[i].bDORMANT=true;Specimens[i].target=null;}
            }
        }
        if(level.time!=50)return;
        MathAndMigration(u);Melee(u);Firearms(u);NPCs();
        Console.Printf("CA136 ENERGY COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
