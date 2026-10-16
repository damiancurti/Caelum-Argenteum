// Auditoría aislada: consulta consumidores reales, sin distribuir este fixture.
class CA237Target : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Mass 80; Health 1000000; +SHOOTABLE; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA237Probe : StaticEventHandler
{
    int Passed, Failed;
    void Check(String label, double actual, double expected)
    {
        bool ok = Abs(actual - expected) < 0.000001;
        if (ok) Passed++; else Failed++;
        Console.Printf("CA237 %s %s actual=%.9f expected=%.9f", ok ? "PASS" : "FAIL", label, actual, expected);
    }
    void SetLevel(CaelumAttributes a, double n)
    {
        a.Strength=n; a.Toughness=n; a.Constitution=n;
        a.Agility=n; a.Dexterity=n; a.Resilience=n;
        a.Charisma=n; a.Empathy=n; a.Eloquence=n;
        a.Intelligence=n; a.Patience=n; a.Insight=n;
    }
    double Value(CaelumAttributes a, int index)
    {
        switch(index)
        {
            case 0: return a.Strength; case 1: return a.Toughness; case 2: return a.Constitution;
            case 3: return a.Agility; case 4: return a.Dexterity; case 5: return a.Resilience;
            case 6: return a.Charisma; case 7: return a.Empathy; case 8: return a.Eloquence;
            case 9: return a.Intelligence; case 10: return a.Patience; case 11: return a.Insight;
        }
        return -1;
    }
    override void UiTick() { if (Menu.GetCurrentMenu()!=null) Menu.GetCurrentMenu().Close(); }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name != "c237_audit") return;
        let user=CaelumPlayer(players[e.Player].mo);
        user.CreationWizardOpen=false; user.CharacterCreationComplete=true;
        user.player.ConversationNPC=null; user.player.ConversationPC=null;
        let profile=user.CharacterProfile;
        profile.Race=CaelumConstants.RACE_HUMAN;
        profile.FirstClass=profile.SecondClass=CaelumConstants.CLASS_WARRIOR;
        profile.PersonalityRevision=1;
        for(int i=0;i<3;i++) profile.Personality[i]=0;
        profile.Personality[3]=2;
        let a=new("CaelumAttributes"); let d=new("CaelumDerivedStats");
        let npc=CaelumCombatActor(Actor.Spawn("CA237Target",user.Pos+(256,0,0)));
        npc.CombatPersonality=new("CaelumCharacterProfile"); npc.CombatPersonality.CopyFrom(profile);
        npc.CombatArmor=new("CaelumArmorModel"); npc.CombatArmor.InitializeDefaults();
        double levels[]={0,100,150,25.5};
        double bonus[]={0,100,210,10.302};
        double type2[]={1,4,7.3,1.30906};
        double type3[]={1,8,15.7,1.72114};
        double remaining[]={1,0,0,0.89698};
        int slots[]={30,100,177,37};
        for(int i=0;i<4;i++)
        {
            SetLevel(a,levels[i]); d.Recalculate(a,profile);
            String prefix=String.Format("N%.1f ",levels[i]);
            Check(prefix.."curve bonus",CaelumGrowthRules.Bonus(levels[i]),bonus[i]);
            Check(prefix.."Strength push",d.PhysicalPushMultiplier,type3[i]*d.BaseMass/100.0);
            Check(prefix.."Strength capacity kg",d.CarryCapacity,type2[i]*d.BaseMass);
            Check(prefix.."Toughness physical HP",CaelumToughnessRules.Reduction(80,levels[i]),80*type3[i]);
            Check(prefix.."Toughness magical HP",CaelumToughnessRules.Reduction(80,levels[i],true),40*type3[i]);
            Check(prefix.."Toughness status sign",CaelumToughnessRules.StatusResponse(levels[i]),1-bonus[i]/100);
            Check(prefix.."Constitution health",d.MaximumHealth,1000*type3[i]*d.BaseMass/100.0);
            Check(prefix.."Constitution needs",d.SleepLossMultiplier,1/type2[i]);
            Check(prefix.."Dexterity attack duration",d.AttackDurationMultiplier,1/type2[i]);
            Check(prefix.."Dexterity accuracy",d.PhysicalAccuracyPercent,100*type3[i]);
            Check(prefix.."Dexterity derived critical cap",d.PhysicalCriticalChance,Min(100.0,5+bonus[i]));
            Check(prefix.."Resilience Air",d.MaximumAir,1000*type2[i]);
            Check(prefix.."Resilience Adrenaline",d.MaximumAdrenaline,1000*type2[i]);
            Check(prefix.."Resilience health recovery",d.HealthRegenerationPerSecond,d.MaximumHealth/3600*type2[i]);
            Check(prefix.."Agility base movement",d.BaseMovementPercent,100*type2[i]);
            Check(prefix.."Agility base evasion",d.BaseEvasionChance,bonus[i]);
            Check(prefix.."Agility stealth cap",d.StealthPercent,Min(100.0,bonus[i]));
            Check(prefix.."Charisma stored payload",d.DebuffPowerPercent,100*type2[i]);
            Check(prefix.."Empathy stored factor only",d.BuffPowerPercent,100*type2[i]);
            Check(prefix.."Eloquence cost divisor",d.StaffAnimaCost,CaelumConstants.DEBUG_STAFF_ANIMA_COST/type2[i]);
            Check(prefix.."Eloquence cast duration",d.CastingDurationMultiplier,1/type2[i]);
            Check(prefix.."Eloquence range",d.AbilityRangePercent,100*type2[i]);
            Check(prefix.."Eloquence dialogue",d.DialogueSkillPercent,bonus[i]);
            Check(prefix.."Intelligence magic power",d.MagicalPowerMultiplier,type3[i]);
            Check(prefix.."Intelligence Box integer",d.MagicBoxCapacity,slots[i]);
            Check(prefix.."Patience Anima",d.MaximumAnima,1000*type3[i]);
            Check(prefix.."Patience recovery",d.AnimaRegenerationPerSecond,d.MaximumAnima/480*type2[i]);
            Check(prefix.."Patience injury complement",d.HealthPenaltyMultiplier,remaining[i]);
            Check(prefix.."Patience interruption cap",d.InterruptionResistancePercent,Min(100.0,bonus[i]));
            Check(prefix.."Insight accuracy",d.MagicalAccuracyPercent,100*type3[i]);
            Check(prefix.."Insight derived critical cap",d.MagicalCriticalChance,Min(100.0,5+bonus[i]));
            if(i<3)
            {
                npc.CombatDexterity=int(levels[i]); npc.CombatInsight=int(levels[i]);
                npc.CombatIntelligence=int(levels[i]); npc.CombatEloquence=int(levels[i]);
                npc.UpdateActorOffensiveStatistics();
                Check(prefix.."NPC precision",npc.CombatPhysicalAccuracyPercent,100*type3[i]);
                Check(prefix.."NPC critical personality and cap",npc.CombatPhysicalCriticalChancePercent,Min(100.0,(5+bonus[i])*1.5));
                Check(prefix.."NPC actual Anima price",npc.GetMagicAnimaCost(100),100/type2[i]);
            }
        }
        // Reconstrucción desde identidad/equipo, menores aditivos y colección al final.
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        { let equipment=CaelumEquipmentItem(item); if(equipment!=null) equipment.Equipped=false; }
        user.DebugAttributesAt100=false; user.DebugAttributesAt75=false;
        user.CharacterAllocation.Recommend(profile);
        user.ArmorModel=new("CaelumArmorModel"); user.ArmorModel.InitializeDefaults();
        let record=user.GetPersistentCharacterState(true); record.TarotEffectTics=0;
        for(int card=0;card<78;card++) record.TarotOwned[card]=false;
        user.ApplyCharacterProfile();
        double baseline[12];
        for(int i=0;i<12;i++) baseline[i]=Value(user.Attributes,i);
        user.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_LIGHT,3);
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup"));
        seal.AttachToOwner(user); seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;
        seal.Tier=1; seal.Equipped=true;
        for(int card=0;card<78;card++) record.TarotOwned[card]=true;
        user.ApplyCharacterProfile();
        for(int i=0;i<12;i++)
        {
            double armor=(i==3 || i==4) ? 20 : 0;
            Check(String.Format("pipeline attribute %d",i),Value(user.Attributes,i),(baseline[i]+armor+3+3)*2);
        }
        double first=user.Attributes.GetTotalPrimaryLevels(); user.ApplyCharacterProfile();
        Check("rebuild never compounds Tarot",user.Attributes.GetTotalPrimaryLevels(),first);
        seal.Equipped=false; user.ArmorModel=new("CaelumArmorModel"); user.ArmorModel.InitializeDefaults();
        for(int card=0;card<78;card++) record.TarotOwned[card]=false;
        user.ApplyCharacterProfile();
        for(int i=0;i<12;i++) Check(String.Format("equipment Tarot removal %d",i),Value(user.Attributes,i),baseline[i]);
        for(int i=0;i<3;i++) profile.Personality[i]=2;
        user.ApplyCharacterProfile();
        Check("personality magic x3.375",user.DerivedStats.MagicalPowerMultiplier,
            CaelumGrowthRules.Multiplier(user.Attributes.Intelligence,3)*3.375);
        Check("personality does not rewrite attributes",user.Attributes.Strength,baseline[0]);
        Console.Printf("CA237 DONE failures=%d passes=%d",Failed,Passed);
    }
}
