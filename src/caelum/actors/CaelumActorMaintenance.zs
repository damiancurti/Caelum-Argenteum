// #353: cachés derivadas por dueño; nunca sustituyen salud, inventario o recursos.
// La referencia del actor es transient: al cargar se reconstruye, sin migrar valores reales.
class CaelumActorMaintenance : Object play
{
    const REVISION=1;
    int Phase,HealthDue,OffenseDue,WeightDue,ResourceDue;
    bool HealthReady,OffenseReady,WeightReady;
    double HealthInputs[32],OffenseInputs[24],WeightInputs[12];
    double HealthOutputs[6],OffenseOutputs[9];
    double Weight;
    Inventory InventoryHead;

    int NextDue()
    {
        int period=CaelumConstants.ACTOR_MAINTENANCE_TICS;
        return level.maptime+1+(Phase-(level.maptime+1)%period+period)%period;
    }

    void Invalidate() { HealthReady=false;OffenseReady=false;WeightReady=false; }

    static void InventoryChanged(Actor owner)
    {
        let body=CaelumCombatActor(owner);
        if(body!=null && body.Maintenance!=null)body.Maintenance.WeightReady=false;
    }

    bool HealthChanged(CaelumCombatActor body)
    {
        bool changed=!HealthReady || level.maptime>=HealthDue;
        double input0=body.Mass;
        if(HealthInputs[0]!=input0)changed=true;
        double input1=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[0] : -1);
        if(HealthInputs[1]!=input1)changed=true;
        double input2=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[1] : -1);
        if(HealthInputs[2]!=input2)changed=true;
        double input3=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[2] : -1);
        if(HealthInputs[3]!=input3)changed=true;
        double input4=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[3] : -1);
        if(HealthInputs[4]!=input4)changed=true;
        double input5=(body.CombatArmor!=null ? body.CombatArmor.Tier[0] : -1);
        if(HealthInputs[5]!=input5)changed=true;
        double input6=(body.CombatArmor!=null ? body.CombatArmor.Tier[1] : -1);
        if(HealthInputs[6]!=input6)changed=true;
        double input7=(body.CombatArmor!=null ? body.CombatArmor.Tier[2] : -1);
        if(HealthInputs[7]!=input7)changed=true;
        double input8=(body.CombatArmor!=null ? body.CombatArmor.Tier[3] : -1);
        if(HealthInputs[8]!=input8)changed=true;
        double input9=(body.CombatArmor!=null ? body.CombatArmor.Durability[0] : -1);
        if(HealthInputs[9]!=input9)changed=true;
        double input10=(body.CombatArmor!=null ? body.CombatArmor.Durability[1] : -1);
        if(HealthInputs[10]!=input10)changed=true;
        double input11=(body.CombatArmor!=null ? body.CombatArmor.Durability[2] : -1);
        if(HealthInputs[11]!=input11)changed=true;
        double input12=(body.CombatArmor!=null ? body.CombatArmor.Durability[3] : -1);
        if(HealthInputs[12]!=input12)changed=true;
        double input13=(body.CombatPersonality!=null ? body.CombatPersonality.PersonalityRevision : -1);
        if(HealthInputs[13]!=input13)changed=true;
        double input14=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[0] : -1);
        if(HealthInputs[14]!=input14)changed=true;
        double input15=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[1] : -1);
        if(HealthInputs[15]!=input15)changed=true;
        double input16=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[2] : -1);
        if(HealthInputs[16]!=input16)changed=true;
        double input17=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[3] : -1);
        if(HealthInputs[17]!=input17)changed=true;
        double input18=body.health;
        if(HealthInputs[18]!=input18)changed=true;
        double input19=body.CombatMaximumHealth;
        if(HealthInputs[19]!=input19)changed=true;
        double input20=body.CombatPatience;
        if(HealthInputs[20]!=input20)changed=true;
        double input21=body.CombatAgility;
        if(HealthInputs[21]!=input21)changed=true;
        double input22=body.CurrentCombatAdrenaline;
        if(HealthInputs[22]!=input22)changed=true;
        double input23=body.MaximumCombatAdrenaline;
        if(HealthInputs[23]!=input23)changed=true;
        double input24=body.CombatBaseSpeed;
        if(HealthInputs[24]!=input24)changed=true;
        double input25=CaelumThermalEffects.Speed(body);
        if(HealthInputs[25]!=input25)changed=true;
        double input26=(body.ElementalStatus!=null ? body.ElementalStatus.GetMovementMultiplier() : 1.0);
        if(HealthInputs[26]!=input26)changed=true;
        if(changed)
        {
            HealthInputs[0]=input0;
            HealthInputs[1]=input1;
            HealthInputs[2]=input2;
            HealthInputs[3]=input3;
            HealthInputs[4]=input4;
            HealthInputs[5]=input5;
            HealthInputs[6]=input6;
            HealthInputs[7]=input7;
            HealthInputs[8]=input8;
            HealthInputs[9]=input9;
            HealthInputs[10]=input10;
            HealthInputs[11]=input11;
            HealthInputs[12]=input12;
            HealthInputs[13]=input13;
            HealthInputs[14]=input14;
            HealthInputs[15]=input15;
            HealthInputs[16]=input16;
            HealthInputs[17]=input17;
            HealthInputs[18]=input18;
            HealthInputs[19]=input19;
            HealthInputs[20]=input20;
            HealthInputs[21]=input21;
            HealthInputs[22]=input22;
            HealthInputs[23]=input23;
            HealthInputs[24]=input24;
            HealthInputs[25]=input25;
            HealthInputs[26]=input26;
        }
        return changed;
    }
    void StoreHealth(CaelumCombatActor body)
    {
        HealthOutputs[0]=body.CombatHealthState;
        HealthOutputs[1]=body.CombatHealthPerformanceMultiplier;
        HealthOutputs[2]=body.CombatHealthPainMultiplier;
        HealthOutputs[3]=body.CombatAdrenalineGainMultiplier;
        HealthOutputs[4]=body.EffectiveCombatEvasionChance;
        HealthOutputs[5]=body.Speed;
        HealthReady=true;HealthDue=NextDue();
    }
    void RestoreHealth(CaelumCombatActor body)
    {
        body.CombatHealthState=int(HealthOutputs[0]);
        body.CombatHealthPerformanceMultiplier=double(HealthOutputs[1]);
        body.CombatHealthPainMultiplier=double(HealthOutputs[2]);
        body.CombatAdrenalineGainMultiplier=double(HealthOutputs[3]);
        body.EffectiveCombatEvasionChance=double(HealthOutputs[4]);
        body.Speed=double(HealthOutputs[5]);
    }
    bool OffenseChanged(CaelumCombatActor body)
    {
        bool changed=!OffenseReady || level.maptime>=OffenseDue;
        double input0=body.Mass;
        if(OffenseInputs[0]!=input0)changed=true;
        double input1=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[0] : -1);
        if(OffenseInputs[1]!=input1)changed=true;
        double input2=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[1] : -1);
        if(OffenseInputs[2]!=input2)changed=true;
        double input3=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[2] : -1);
        if(OffenseInputs[3]!=input3)changed=true;
        double input4=(body.CombatArmor!=null ? body.CombatArmor.ArmorType[3] : -1);
        if(OffenseInputs[4]!=input4)changed=true;
        double input5=(body.CombatArmor!=null ? body.CombatArmor.Tier[0] : -1);
        if(OffenseInputs[5]!=input5)changed=true;
        double input6=(body.CombatArmor!=null ? body.CombatArmor.Tier[1] : -1);
        if(OffenseInputs[6]!=input6)changed=true;
        double input7=(body.CombatArmor!=null ? body.CombatArmor.Tier[2] : -1);
        if(OffenseInputs[7]!=input7)changed=true;
        double input8=(body.CombatArmor!=null ? body.CombatArmor.Tier[3] : -1);
        if(OffenseInputs[8]!=input8)changed=true;
        double input9=(body.CombatArmor!=null ? body.CombatArmor.Durability[0] : -1);
        if(OffenseInputs[9]!=input9)changed=true;
        double input10=(body.CombatArmor!=null ? body.CombatArmor.Durability[1] : -1);
        if(OffenseInputs[10]!=input10)changed=true;
        double input11=(body.CombatArmor!=null ? body.CombatArmor.Durability[2] : -1);
        if(OffenseInputs[11]!=input11)changed=true;
        double input12=(body.CombatArmor!=null ? body.CombatArmor.Durability[3] : -1);
        if(OffenseInputs[12]!=input12)changed=true;
        double input13=(body.CombatPersonality!=null ? body.CombatPersonality.PersonalityRevision : -1);
        if(OffenseInputs[13]!=input13)changed=true;
        double input14=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[0] : -1);
        if(OffenseInputs[14]!=input14)changed=true;
        double input15=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[1] : -1);
        if(OffenseInputs[15]!=input15)changed=true;
        double input16=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[2] : -1);
        if(OffenseInputs[16]!=input16)changed=true;
        double input17=(body.CombatPersonality!=null ? body.CombatPersonality.Personality[3] : -1);
        if(OffenseInputs[17]!=input17)changed=true;
        double input18=body.CombatDexterity;
        if(OffenseInputs[18]!=input18)changed=true;
        double input19=body.CombatInsight;
        if(OffenseInputs[19]!=input19)changed=true;
        double input20=body.CombatIntelligence;
        if(OffenseInputs[20]!=input20)changed=true;
        double input21=body.CombatStrength;
        if(OffenseInputs[21]!=input21)changed=true;
        if(changed)
        {
            OffenseInputs[0]=input0;
            OffenseInputs[1]=input1;
            OffenseInputs[2]=input2;
            OffenseInputs[3]=input3;
            OffenseInputs[4]=input4;
            OffenseInputs[5]=input5;
            OffenseInputs[6]=input6;
            OffenseInputs[7]=input7;
            OffenseInputs[8]=input8;
            OffenseInputs[9]=input9;
            OffenseInputs[10]=input10;
            OffenseInputs[11]=input11;
            OffenseInputs[12]=input12;
            OffenseInputs[13]=input13;
            OffenseInputs[14]=input14;
            OffenseInputs[15]=input15;
            OffenseInputs[16]=input16;
            OffenseInputs[17]=input17;
            OffenseInputs[18]=input18;
            OffenseInputs[19]=input19;
            OffenseInputs[20]=input20;
            OffenseInputs[21]=input21;
        }
        return changed;
    }
    void StoreOffense(CaelumCombatActor body)
    {
        OffenseOutputs[0]=body.CombatEffectiveDexterity;
        OffenseOutputs[1]=body.CombatEffectiveInsight;
        OffenseOutputs[2]=body.CombatEffectiveIntelligence;
        OffenseOutputs[3]=body.CombatPhysicalAccuracyPercent;
        OffenseOutputs[4]=body.CombatMagicalAccuracyPercent;
        OffenseOutputs[5]=body.CombatPhysicalCriticalChancePercent;
        OffenseOutputs[6]=body.CombatMagicalCriticalChancePercent;
        OffenseOutputs[7]=body.CombatPhysicalPushMultiplier;
        OffenseOutputs[8]=body.CombatMagicalPushMultiplier;
        OffenseReady=true;OffenseDue=NextDue();
    }
    void RestoreOffense(CaelumCombatActor body)
    {
        body.CombatEffectiveDexterity=int(OffenseOutputs[0]);
        body.CombatEffectiveInsight=int(OffenseOutputs[1]);
        body.CombatEffectiveIntelligence=int(OffenseOutputs[2]);
        body.CombatPhysicalAccuracyPercent=double(OffenseOutputs[3]);
        body.CombatMagicalAccuracyPercent=double(OffenseOutputs[4]);
        body.CombatPhysicalCriticalChancePercent=double(OffenseOutputs[5]);
        body.CombatMagicalCriticalChancePercent=double(OffenseOutputs[6]);
        body.CombatPhysicalPushMultiplier=double(OffenseOutputs[7]);
        body.CombatMagicalPushMultiplier=double(OffenseOutputs[8]);
    }
    bool WeightChanged(CaelumCombatActor body)
    {
        bool changed=!WeightReady || level.maptime>=WeightDue || InventoryHead!=body.Inv;
        double input0=body.CombatArmor!=null ? body.CombatArmor.ArmorType[0] : -1;
        if(WeightInputs[0]!=input0)changed=true;
        double input1=body.CombatArmor!=null ? body.CombatArmor.ArmorType[1] : -1;
        if(WeightInputs[1]!=input1)changed=true;
        double input2=body.CombatArmor!=null ? body.CombatArmor.ArmorType[2] : -1;
        if(WeightInputs[2]!=input2)changed=true;
        double input3=body.CombatArmor!=null ? body.CombatArmor.ArmorType[3] : -1;
        if(WeightInputs[3]!=input3)changed=true;
        double input4=body.CombatArmor!=null ? body.CombatArmor.Tier[0] : -1;
        if(WeightInputs[4]!=input4)changed=true;
        double input5=body.CombatArmor!=null ? body.CombatArmor.Tier[1] : -1;
        if(WeightInputs[5]!=input5)changed=true;
        double input6=body.CombatArmor!=null ? body.CombatArmor.Tier[2] : -1;
        if(WeightInputs[6]!=input6)changed=true;
        double input7=body.CombatArmor!=null ? body.CombatArmor.Tier[3] : -1;
        if(WeightInputs[7]!=input7)changed=true;
        double input8=body.CombatArmor!=null ? body.CombatArmor.Size[0] : -1;
        if(WeightInputs[8]!=input8)changed=true;
        double input9=body.CombatArmor!=null ? body.CombatArmor.Size[1] : -1;
        if(WeightInputs[9]!=input9)changed=true;
        double input10=body.CombatArmor!=null ? body.CombatArmor.Size[2] : -1;
        if(WeightInputs[10]!=input10)changed=true;
        double input11=body.CombatArmor!=null ? body.CombatArmor.Size[3] : -1;
        if(WeightInputs[11]!=input11)changed=true;
        if(changed)
        {
            WeightInputs[0]=input0;
            WeightInputs[1]=input1;
            WeightInputs[2]=input2;
            WeightInputs[3]=input3;
            WeightInputs[4]=input4;
            WeightInputs[5]=input5;
            WeightInputs[6]=input6;
            WeightInputs[7]=input7;
            WeightInputs[8]=input8;
            WeightInputs[9]=input9;
            WeightInputs[10]=input10;
            WeightInputs[11]=input11;
        }
        return changed;
    }
}
