class CA136Integration : CA136Checks
{
    CA136Target LeftTarget,RightTarget;int LeftExpected,RightExpected,HitCount;
    void Launch(CaelumPlayer user,int hits,double total)
    {
        LeftTarget.health=1000000;RightTarget.health=1000000;LeftTarget.Hits=0;RightTarget.Hits=0;
        LeftExpected=0;RightExpected=0;HitCount=hits;
        Check(CaelumShotgunRules.Fire(user,user.WeaponModel,total,false,0,0,0),"native multi-target shot launches");
        let it=ThinkerIterator.Create("CaelumShotgunPellet");CaelumShotgunPellet p;int n=0;
        while((p=CaelumShotgunPellet(it.Next()))!=null)
        {
            // Deterministic trajectories isolate allocation from random accuracy.
            vector3 aim=(n%2==0 ? LeftTarget.Pos : RightTarget.Pos)+(0,0,40);
            if(n>=hits)aim=user.Pos+(-500,0,100);
            else if(n%2==0)LeftExpected+=p.CaelumPreparedDamage;
            else RightExpected+=p.CaelumPreparedDamage;
            p.Vel=(aim-p.Pos).Unit()*80;n++;
        }
        Check(n==12,"distribution retains exactly twelve independently colliding projectiles");
    }
    void AssertHits(String label)
    {
        Console.Printf("CA136 DISTRIBUTION %s hits=%d/%d loss=%d/%d expected=%d/%d",label,LeftTarget.Hits,RightTarget.Hits,1000000-LeftTarget.health,1000000-RightTarget.health,LeftExpected,RightExpected);
        Check(LeftTarget.Hits+RightTarget.Hits==HitCount
            && 1000000-LeftTarget.health==LeftExpected && 1000000-RightTarget.health==RightExpected,label);
        let it=ThinkerIterator.Create("CaelumShotgunPellet");Actor p;
        while((p=Actor(it.Next()))!=null)p.Destroy();
    }
    void Contact(CaelumPlayer user)
    {
        let cannon=Actor.Spawn("CaelumCannonProjectile",(1000,2000,500));
        let npc=CaelumPortDefender(Actor.Spawn("CA136Soldier",(1000,2000,0)));
        npc.InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_HEAVY,3);npc.CombatToughness=18;npc.health=100000;
        user.bINVULNERABLE=true;
        user.ReceiveCaelumImpact(30,CaelumConstants.IMPACT_KIND_CRUSH,cannon,1,80,10,30,2400,0.2,0.9);
        npc.ReceiveCaelumImpact(30,CaelumConstants.IMPACT_KIND_CRUSH,cannon,1,80,10,30,2400,0.2,0.9);
        Check(user.LastImpactPostToughnessPercent>0 && Abs(user.LastImpactWeightedArmorDefensePercent-CaelumArmorRules.InnateDefense(user.CharacterProfile.Race,false))<0.001,"actual player cannon contact solver retains only innate armor after Toughness");
        Check(npc.LastImpactPostToughnessPercent>0 && Abs(npc.LastImpactWeightedArmorDefensePercent-npc.GetInnateArmorDefense())<0.001,"actual NPC cannon contact solver retains only innate armor after Toughness");
        cannon.Destroy();npc.Destroy();
    }
    override void WorldTick()
    {
        if(level.MapName=="MAP02")
        {
            let user=CaelumPlayer(players[0].mo);user.bNOTARGET=true;user.bINVULNERABLE=true;
            if(level.time!=60)return;
            static const int ids[]={47007,47008,47030,47054,47055,47078};
            for(int i=0;i<6;i++)
            {
                let enemy=CaelumCombatActor(ActorIterator.Create(ids[i]).Next());
                Check(enemy!=null && enemy.health>0,String.Format("eligible MAP02 carrier %d exists alive",ids[i]));
                if(enemy!=null){enemy.health=0;enemy.Die(user,user,0,'None');enemy.Die(user,user,0,'None');}
            }
            let it=ThinkerIterator.Create("CaelumShotgunAmmo");CaelumShotgunAmmo shell;int count=0,total=0;
            while((shell=CaelumShotgunAmmo(it.Next()))!=null){if(shell.Owner==null){count++;total+=shell.Amount;}}
            Check(count==6 && total==120,"actual MAP02 deaths release exactly six 20-cartridge bundles with idempotent death handling");
            Console.Printf("CA136 COMPLETE checks=%d failures=%d",Checks,Failures);return;
        }
        if(level.MapName!="CA136")return;
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==50)
        {
            Gun=Equip(user,14);user.Angle=0;user.Pitch=0;
            LeftTarget=CA136Target(Actor.Spawn("CA136Target",user.Pos+(300,-95,0)));
            RightTarget=CA136Target(Actor.Spawn("CA136Target",user.Pos+(300,95,0)));
            Launch(user,12,120.6);
            // In-flight metadata must survive switching the owner's live weapon.
            user.WeaponModel.WeaponType=15;
            let it=ThinkerIterator.Create("CaelumShotgunPellet");let p=CaelumShotgunPellet(it.Next());
            Check(Abs(CaelumArmorRules.EquipmentRetention(p)-0.4)<0.001,"in-flight penetration retains fired weapon metadata after equipment switch");
            user.WeaponModel.WeaponType=14;
        }
        if(level.time==65){AssertHits("non-divisible native shot splits conserved budget across two targets");Check(LeftExpected+RightExpected==121,"combined native split damage rounds to 121");Launch(user,8,120.6);}
        if(level.time==80){AssertHits("four missed pellets do not damage either target");Check(LeftExpected+RightExpected<121,"missed budget is never reassigned to hits");Launch(user,12,0.1);}
        if(level.time==95)
        {
            Check(LeftTarget.health==1000000 && RightTarget.health==1000000,"zero-rounded pellets never fabricate minimum damage");
            let it=ThinkerIterator.Create("CaelumShotgunPellet");Actor p;while((p=Actor(it.Next()))!=null)p.Destroy();
            Contact(user);
            Shells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",user.Pos));Shells.Amount=1;Shells.AttachToOwner(user);
            user.OnNativeInventoryChanged();user.SetRangedMagazineCount(14,0);user.RequestRangedReload(14);
            user.RangedReloadRemainingSeconds=0.001;user.UpdateRangedReload();
            Check(user.GetRangedMagazineCount(14)==1 && Shells.Amount==1,"empty gun with one total cartridge loads exactly one chamber");
            user.CurrentAir=0;user.EquippedWeaponCooldownRemaining=0;user.PerformCarbineAttack();
            Check(!user.LastCarbineFired && Shells.Amount==1,"insufficient Air spends neither shell nor chamber");
            Shells.Amount=2;user.SetRangedMagazineCount(14,0);user.RequestRangedReload(14);
            user.WeaponModel.WeaponType=15;user.UpdateRangedReload();
            Check(!user.RangedReloadActive && user.GetRangedMagazineCount(14)==0 && Shells.Amount==2,"equipment change cancels reload without granting ammo");
            user.WeaponModel.WeaponType=14;
            Check(Gun.Durability==user.WeaponModel.Durability && Gun.Durability<=user.WeaponModel.GetMaximumDurability(),"new merchant equipment is stamped before migration and remains within maximum durability");
            Console.Printf("CA136 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
