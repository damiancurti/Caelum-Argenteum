// Prueba aislada de #259: límites y consumidores de ataques reales.
class CA259Target : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Health 1000000; Mass 100; +SHOOTABLE; +SOLID; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA259Caster : CaelumMandinga
{
    override void Tick() {}
    States
    {
    ProbeMelee:
        TNT1 A 0 A_CaelumProfiledMeleeAttack(CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE);
        TNT1 A -1;
        Stop;
    ProbeFire:
        TNT1 A 0 A_CaelumSpawnTierOneMagicProjectile("CaelumActorSimpleElementalProjectile",0.65,CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.ESSENCE_FIRE,false);
        TNT1 A -1;
        Stop;
    }
}
class CA259Soldier : CaelumPortDefender { override void Tick() {} }
class CA259Probe : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    { if(ok)Passed++;else Failed++;Console.Printf("CA259 %s %s",ok?"PASS":"FAIL",label); }
    bool Near(double a,double b) { return Abs(a-b)<0.00001; }
    bool InRange(double value,double low,double high)
    { return Abs(value)+0.00001>=low && Abs(value)<=high+0.00001; }
    void ClearShots()
    {
        let it=ThinkerIterator.Create("CaelumPlayerMagicProjectile");Actor shot;
        while((shot=Actor(it.Next()))!=null)shot.Destroy();
    }
    override void UiTick() { if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c259_audit")return;
        let user=CaelumPlayer(players[e.Player].mo);
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
        user.player.ConversationNPC=null;user.player.ConversationPC=null;
        user.Attributes.Dexterity=0;user.Attributes.Insight=0;user.Attributes.Strength=100;
        user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
        user.ElementalStatus=new("CaelumElementalStatus");user.ArmorModel=new("CaelumArmorModel");user.ArmorModel.InitializeDefaults();
        user.WeaponModel=new("CaelumWeaponModel");user.WeaponModel.InitializeDefaults();
        user.WeaponModel.Equipped=true;user.WeaponModel.Durability=100000;
        user.EquipmentMenuOpen=false;user.CraftingMenuOpen=false;user.LucidityPhysicalStunRemaining=0;
        user.CurrentAir=1000000;user.CurrentAnima=1000000;user.player.crouchfactor=1;
        double lucid[]={50.001,50,49.999,10.001,10,9.999};
        int penalty[]={0,0,1,1,1,2};
        int magic[]={CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.WEAPON_TYPE_BOOK,
            CaelumConstants.WEAPON_TYPE_STATUETTE,CaelumConstants.WEAPON_TYPE_BELL};
        int bases[]={1,1,2,4};
        for(int t=1;t<=3;t++)for(int l=0;l<6;l++)
        {
            user.WeaponModel.Tier=t;user.CurrentLucidity=lucid[l];
            for(int w=0;w<CaelumConstants.CATALOGUE_PHYSICAL_WEAPON_COUNT;w++)
            {
                bool tool=w==CaelumConstants.CATALOGUE_WEAPON_PICKAXE || w==CaelumConstants.CATALOGUE_WEAPON_UTILITY_STAFF || w==CaelumConstants.CATALOGUE_WEAPON_BOLAS;
                int b=tool?6:w==CaelumConstants.CATALOGUE_WEAPON_SHOTGUN?4
                    :w==CaelumConstants.CATALOGUE_WEAPON_CARBINE || w==CaelumConstants.CATALOGUE_WEAPON_CROSSBOW || w==CaelumConstants.CATALOGUE_WEAPON_LONGBOW?1:3;
                int k=Min(7,b+(tool?0:t-1)+penalty[l]);
                Check(Near(CaelumWeaponCatalogue.GetMinimumSpread(w,t,lucid[l]),k)
                    && Near(CaelumWeaponCatalogue.GetMaximumSpread(w,t,lucid[l]),10*k),String.Format("physical %d T%d lucidity %.3f",w,t,lucid[l]));
            }
            for(int m=0;m<4;m++)
            {
                int k=Min(7,bases[m]+t-1+penalty[l]);
                user.WeaponModel.WeaponType=magic[m];
                Check(Near(user.WeaponModel.GetMinimumSpreadFor(magic[m],lucid[l]),k)
                    && Near(user.WeaponModel.GetMaximumSpreadFor(magic[m],lucid[l]),k*10),String.Format("magic %d T%d lucidity %.3f",m,t,lucid[l]));
                for(int secondary=0;secondary<2;secondary++)
                {
                    user.ReleasePendingStaffAttack(secondary!=0,magic[m],CaelumConstants.ESSENCE_FIRE,false);
                    Check(Near(user.LastStaffAccuracyPercent,100)
                        && InRange(user.LastStaffYawOffset,k,k*10) && InRange(user.LastStaffPitchOffset,k,k*10),
                        String.Format("actual magic %d T%d L%.3f secondary%d",m,t,lucid[l],secondary));
                    ClearShots();
                }
            }
            user.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;
            for(int secondary=0;secondary<2;secondary++)
            {
                user.PerformDebugSwordAttack(secondary!=0);
                int k=Min(7,3+t-1+penalty[l]);
                Check(Near(user.LastMeleeAccuracyPercent,100) && InRange(user.LastMeleeYawOffset,k,k*10)
                    && InRange(user.LastMeleePitchOffset,k,k*10),String.Format("actual melee T%d L%.3f secondary%d",t,lucid[l],secondary));
            }
            int ranged[]={CaelumConstants.WEAPON_TYPE_CARBINE,CaelumConstants.WEAPON_TYPE_SHOTGUN,CaelumConstants.WEAPON_TYPE_LONGBOW,CaelumConstants.WEAPON_TYPE_CROSSBOW};
            for(int r=0;r<4;r++)
            {
                user.WeaponModel.WeaponType=ranged[r];user.SetRangedMagazineCount(ranged[r],1);
                user.RangedReloadActive=false;user.RangedAimModeActive=false;
                user.PerformCarbineAttack();int k=Min(7,(r==1?4:1)+t-1+penalty[l]);
                Check(user.LastCarbineFired && Near(user.LastCarbineAccuracyPercent,100)
                    && Near(user.LastCarbineMinimumSpread,k) && Near(user.LastCarbineMaximumSpread,k*10),String.Format("actual ranged%d T%d L%.3f",r,t,lucid[l]));
            }
        }
        // Se conserva Tipo 3 y la postura; Lucidez no añade un divisor oculto.
        user.Attributes.Insight=100;user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
        user.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_STAFF;user.WeaponModel.Tier=3;
        user.CurrentLucidity=9.999;user.ReleasePendingStaffAttack(false,CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.ESSENCE_FIRE,false);
        Check(Near(user.LastStaffAccuracyPercent,800) && InRange(user.LastStaffYawOffset,5.0/8,50.0/8),"actual staff preserves Type-3 precision without Lucidity division");ClearShots();
        Check(Near(CaelumBolasRules.Spread(0,100),60) && Near(CaelumBolasRules.Spread(TICRATE,100),6)
            && Near(CaelumBolasRules.Spread(TICRATE,9),7),"single-tier bolas retains preparation geometry and old base category");
        let npc=CA259Caster(Actor.Spawn("CA259Caster",user.Pos+(96,0,0)));
        let target=CA259Target(Actor.Spawn("CA259Target",user.Pos+(256,0,0)));
        // Tick está detenido: completar la inicialización nativa antes de atacar.
        npc.PostBeginPlay();target.PostBeginPlay();
        npc.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);npc.Target=target;
        npc.CurrentCombatAnima=100000;npc.CurrentCombatLucidity=9;npc.UpdateActorLucidityState();npc.CombatLucidityPhysicalStunRemaining=0;
        int before=npc.ImpactDiagnosticProjectilesSpawned;npc.SetState(npc.FindState("ProbeFire"));
        Check(npc.ImpactDiagnosticProjectilesSpawned==before+1 && Near(npc.LastCombatAttackAccuracyChancePercent,100),"actual NPC staff launches at low Lucidity without old accuracy penalty");
        let it=ThinkerIterator.Create("CaelumActorSimpleElementalProjectile");CaelumActorProjectile shot;int shots=0;
        while((shot=CaelumActorProjectile(it.Next()))!=null)
        {
            if(shot.Target!=npc)continue;shots++;
            double aim=npc.AngleTo(target);double difference=Abs(shot.Angle-aim);if(difference>180)difference=360-difference;
            Check(InRange(difference,3,30),"actual NPC staff angular dispersion contains Lucidity tiers");shot.Destroy();
        }
        Check(shots==1,"one NPC projectile checked");
        target.SetOrigin(npc.Pos+(40,0,0),false);target.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        target.CombatArmor=new("CaelumArmorModel");target.CombatArmor.InitializeDefaults();
        npc.CurrentCombatAir=100000;npc.CombatAirSpending=false;npc.CombatStrength=100;
        for(int t=1;t<=3;t+=2)
        {
            npc.GetPossessedSidearm().Tier=t;int hits=0;target.health=1000000;
            for(int attempt=0;attempt<40;attempt++)
            {
                int hp=target.health;npc.SetState(npc.FindState("ProbeMelee"));
                if(target.health<hp)hits++;
                target.Vel=(0,0,0);
            }
            Check(hits>0 && hits<40 && Near(npc.LastCombatAttackAccuracyChancePercent,100),
                String.Format("actual NPC machete T%d geometric hits/misses, no Lucidity divisor (%d/40 raw%d accuracy%.1f)",t,hits,npc.LastCombatAttackBaseDamage,npc.LastCombatAttackAccuracyChancePercent));
        }
        target.SetOrigin(user.Pos+(256,0,0),false);
        npc.Destroy();
        let soldier=CA259Soldier(Actor.Spawn("CA259Soldier",user.Pos+(96,0,0)));
        soldier.PostBeginPlay();
        soldier.CombatArmor=new("CaelumArmorModel");soldier.CombatArmor.InitializeDefaults();
        soldier.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        soldier.CurrentCombatAir=100000;soldier.CurrentCombatLucidity=9;
        soldier.UpdateActorLucidityState();soldier.CombatLucidityPhysicalStunRemaining=0;
        soldier.Carbine=new("CaelumCityCarbine");soldier.Carbine.Initialize(soldier);
        for(int t=1;t<=3;t++)
        {
            soldier.Carbine.Weapon.Tier=t;soldier.Carbine.NextShotTic=0;
            soldier.Carbine.Magazine=1;soldier.Carbine.ReloadRemaining=0;
            int count=soldier.Carbine.ShotCount;soldier.Carbine.Attack(soldier,target);
            double accuracy=soldier.Carbine.LastAccuracyPercent;
            Check(soldier.Carbine.ShotCount==count+1 && Near(accuracy,100*CaelumConstants.CROUCH_ACCURACY_MULTIPLIER*CaelumConstants.RANGED_AIM_ACCURACY_MULTIPLIER)
                && Near(soldier.Carbine.LastMinimumSpread,(t+2)*100/accuracy),String.Format("actual NPC carbine T%d low Lucidity retains crouch/ADS",t));
        }
        soldier.Destroy();
        target.bCountKill=true;user.Angle=user.AngleTo(target);
        vector3 seekDelta=target.Pos-user.Pos;
        user.Pitch=VectorAngle(seekDelta.XY.Length(),-(target.Pos.Z+target.Height/2-user.Pos.Z-user.Height/2));
        user.WeaponModel.WeaponType=CaelumConstants.WEAPON_TYPE_BOOK;
        user.ReleasePendingStaffAttack(false,CaelumConstants.WEAPON_TYPE_BOOK,CaelumConstants.ESSENCE_FIRE,false);
        let books=ThinkerIterator.Create("CaelumHomingMagicProjectile");CaelumHomingMagicProjectile book;int homing=0;
        while((book=CaelumHomingMagicProjectile(books.Next()))!=null)
            if(book.Target==user && book.Tracer==target)homing++;
        Check(homing==1,"actual book preserves target acquisition and homing");ClearShots();
        Console.Printf("CA259 DONE failures=%d passes=%d",Failed,Passed);
    }
}
