    void ExtendedChecks(CaelumCombatActor npc,CaelumPlayer user)
    {
        // Armaduras reales: la ropa base de Mandinga no tiene durabilidad que romper.
        npc.CA318Work.Mode=7;npc.CA318Work.HReady=false;npc.CA318Work.OReady=false;
        for(int kind=CaelumConstants.ARMOR_TYPE_MAGIC;kind<=CaelumConstants.ARMOR_TYPE_HEAVY;kind++)
        {
            npc.CombatArmor.InitializeUniformLoadout(kind,3);
            CheckStats(npc);WeightCheck(npc,"effective armor type weight");
            for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
            {
                int maximum=npc.CombatArmor.GetMaximumDurability(slot);
                double defense=npc.CombatArmor.GetDefense(slot);
                Check(maximum>0 && defense>0,"effective intact armor prerequisite");
                npc.CombatArmor.Durability[slot]=0;
                Check(npc.CombatArmor.GetDefense(slot)==0,"effective broken armor");
                CheckStats(npc);WeightCheck(npc,"broken armor weight");
                npc.CombatArmor.Durability[slot]=maximum;
                Check(npc.CombatArmor.GetDefense(slot)==defense,"effective repaired armor");
                CheckStats(npc);WeightCheck(npc,"repaired armor weight");
                npc.CombatArmor.Tier[slot]=1;CheckStats(npc);WeightCheck(npc,"effective armor tier one");
                npc.CombatArmor.Tier[slot]=3;CheckStats(npc);WeightCheck(npc,"effective armor tier three");
                npc.CombatArmor.Size[slot]=CaelumConstants.EQUIPMENT_SIZE_S;WeightCheck(npc,"effective armor small");
                npc.CombatArmor.Size[slot]=CaelumConstants.EQUIPMENT_SIZE_L;WeightCheck(npc,"effective armor large");
            }
        }
        Check(npc.CA318Work.Failures==0,"effective armor cached reads match originals");
        // La regla de adrenalina elimina penalizaciones, no el gasto de necesidades.
        user.CA318SiegeFocus=true;user.SurvivalResourcesInitialized=true;
        user.CurrentHunger=CaelumConstants.SURVIVAL_MAXIMUM/2;
        user.CurrentThirst=CaelumConstants.SURVIVAL_MAXIMUM/2;
        double hunger=user.CurrentHunger,thirst=user.CurrentThirst;
        Check(!user.IsSubmergedInPotableWater(),"survival consumption dry prerequisite");
        CaelumPlayerResources.UpdateSurvivalResources(user);
        Check(user.CurrentHunger<hunger && user.CurrentThirst<thirst,"hunger and thirst still consumed at maximum adrenaline");
        Check(user.SurvivalPerformanceMultiplier==1 && user.CurrentAdrenaline==user.DerivedStats.MaximumAdrenaline,"consumption retains maximum-adrenaline performance rule");
        user.CA318SiegeFocus=false;
    }
