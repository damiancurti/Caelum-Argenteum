    // Valores de esfuerzo exclusivos de la sonda; no son reglas de juego.
    int ArmorLife(CaelumCombatActor npc)
    {int value=0;for(int i=0;i<4;i++)value+=npc.CombatArmor.Durability[i];return value;}
    void ResearchChecks()
    {
        let population=CaelumPopulationState.Get();population.HighDensity=true;
        let npc=CheckBody;let cache=npc.GetActorMaintenance();
        npc.InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MAGIC,3);CheckStats(npc);
        npc.ClearCombatArmorToBaseClothing();CheckStats(npc);
        npc.InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MAGIC,3);CheckStats(npc);
        npc.CombatPersonalityRevision=0;
        if(npc.CombatPersonality!=null)npc.CombatPersonality.Personality[0]=(npc.CombatPersonality.Personality[0]+1)%3;
        CaelumActorMaintenance.StructureChanged(npc);CheckStats(npc);
        npc.EnsureCombatPersonality();CheckStats(npc);

        // Control negativo: una escritura ajena al contrato queda pendiente hasta el respaldo.
        cache.HealthDue=level.maptime+100;cache.OffenseDue=level.maptime+100;
        npc.CombatArmor.Durability[0]=0;
        Check(!cache.HealthChanged(npc) && !cache.OffenseChanged(npc),"unnotified structural write is deliberately not detected immediately");
        cache.HealthDue=cache.OffenseDue=level.maptime;
        Check(cache.HealthChanged(npc) && cache.OffenseChanged(npc),"fallback detects unnotified write by deadline");
        CheckStats(npc);
        npc.CombatArmor.Durability[0]=npc.CombatArmor.GetMaximumDurability(0);
        CaelumActorMaintenance.StructureChanged(npc);
        Check(!cache.HealthReady && !cache.OffenseReady,"local structural notification invalidates both caches");
        CheckStats(npc);

        // Tres escritores de desgaste: la Dureza anula HP pero no el desgaste previo.
        int oldMass=npc.Mass;int oldToughness=npc.CombatToughness;
        npc.Mass=1000000;npc.CombatToughness=20;npc.health=npc.CombatMaximumHealth;npc.bInvulnerable=false;
        for(int writer=0;writer<3;writer++)
        {
            npc.InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_HEAVY,3);CheckStats(npc);
            int before=ArmorLife(npc);int hp=npc.health;
            if(writer==0)npc.ResolveActorArmorImpact(10000,false);
            else if(writer==1)
            {
                let user=players[0].mo;vector3 old=user.Pos;user.SetOrigin(npc.Pos+(8,0,0),false);
                npc.ApplyActorExplosionDefense(user,user,10000,'Explosion',0,0);user.SetOrigin(old,false);
            }
            else npc.ReceiveCaelumImpact(100,CaelumConstants.IMPACT_KIND_ENVIRONMENT,null,1,1000000,0,100,100,0,1,true,10000,null,(1,0,0),10000);
            Check(ArmorLife(npc)<before,"native armor writer causes wear");
            Check(npc.health==hp,"wear with no health loss");
            Check(!cache.OffenseReady,"native armor writer invalidates offense before early return");
            CheckStats(npc);
        }
        npc.Mass=oldMass;npc.CombatToughness=oldToughness;CheckStats(npc);
        ResearchRulo.InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_LIGHT,3);
        ResearchRulo.CombatArmor.Durability[CaelumConstants.ARMOR_SLOT_HANDS]=0;
        ResearchRulo.CombatArmor.Durability[CaelumConstants.ARMOR_SLOT_FEET]=0;
        CaelumActorMaintenance.StructureChanged(ResearchRulo);CheckStats(ResearchRulo);
        double brokenDexterity=ResearchRulo.CombatEffectiveDexterity;
        ResearchRulo.RestoreRuloPartyHealth();CheckStats(ResearchRulo);
        Check(ResearchRulo.CombatEffectiveDexterity>brokenDexterity,"real Rulo repair refreshes armor bonus immediately");
        Console.Printf("CA354 CHECKS passes=%d failures=%d",CheckPasses,CheckFailures);
        if(CheckFailures==0)Console.Printf("CA282 DONE passes=%d failures=0",CheckPasses);
    }
