// Adaptadores de datos: la fisiología térmica no posee inventario ni estadísticas.
class CaelumThermalBody : Object play
{
    static clearscope bool FurryAnimal(Actor body)
    { return body is 'CaelumBull' || body is 'CaelumGiantRat'; }

    static clearscope bool Supported(Actor body)
    {
        return body is 'CaelumPlayer' || body is 'CaelumAnchoredResident'
            || body is 'CaelumFolkloreCombatActor' || FurryAnimal(body);
    }

    static CaelumThermalState Get(Actor body,bool create=false)
    {
        if(body==null)return null;
        let existingNPC=CaelumCombatActor(body);
        if(existingNPC!=null && existingNPC.ThermalState!=null
            && existingNPC.ThermalState.Revision>=CaelumThermalData.REVISION)return existingNPC.ThermalState;
        if(!Supported(body))return null;
        let user=CaelumPlayer(body);
        CaelumThermalState thermal;
        if(user!=null)
        {
            if(!CaelumPlayerAuthority.CanMutate(user))return null;
            let record=user.GetPersistentCharacterState(create);
            if(record==null)return null;
            if(record.ThermalState==null && create)record.ThermalState=new("CaelumThermalState");
            thermal=record.ThermalState;
        }
        else
        {
            let npc=CaelumCombatActor(body);
            if(npc==null || !npc.CombatProfileInitialized)return null;
            if(npc.ThermalState==null && create)npc.ThermalState=new("CaelumThermalState");
            thermal=npc.ThermalState;
        }
        if(thermal!=null && create)thermal.Initialize();
        return thermal;
    }

    static void Refresh(Actor body,CaelumThermalState thermal)
    {
        double priorMass=thermal.BodyMassKg,priorHeight=thermal.HeightMeters;
        let user=CaelumPlayer(body);
        let npc=CaelumCombatActor(body);
        int race;
        if(user!=null)
        {
            if(user.DerivedStats==null || user.CharacterProfile==null || user.Attributes==null)return;
            thermal.BodyMassKg=user.DerivedStats.BaseMass;
            thermal.HeightMeters=user.DerivedStats.BodyHeightMeters;
            thermal.MovedMassKg=user.DerivedStats.TotalMass;
            thermal.Toughness=user.Attributes.Toughness;
            thermal.AcclimationMultiplier=user.DerivedStats.CalculateType4Percent(Max(0.0,user.Attributes.Resilience))/100.0;
            race=user.CharacterProfile.Race;
            thermal.ReferenceJumpHeat=CaelumThermalRules.JumpHeat(thermal.MovedMassKg,0,
                user.JumpZ*TICRATE/CaelumJourneyRules.MAP_UNITS_PER_METER);
        }
        else if(npc!=null)
        {
            thermal.BodyMassKg=Max(0.001,npc.Mass);
            thermal.HeightMeters=npc.Height/CaelumJourneyRules.MAP_UNITS_PER_METER;
            thermal.MovedMassKg=thermal.BodyMassKg+npc.GetAttackCarriedWeight();
            thermal.Toughness=npc.CombatToughness+npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_TOUGHNESS);
            thermal.AcclimationMultiplier=npc.CalculateActorType4Percent(Max(0,npc.CombatResilience
                +npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_RESILIENCE)))/100.0;
            race=FurryAnimal(npc) ? CaelumConstants.RACE_BEAST_MAN : npc.GetArmorRace();
            // Los NPC actuales no tienen lanzamiento de salto propio: la
            // referencia compartida usa el salto base autorizado del motor.
            thermal.ReferenceJumpHeat=CaelumThermalRules.JumpHeat(thermal.MovedMassKg,0,
                CaelumConstants.GZDOOM_BASE_JUMP_Z*TICRATE/CaelumJourneyRules.MAP_UNITS_PER_METER);
        }
        thermal.ComfortC=CaelumThermalRules.Comfort(race,
            body is 'CaelumMandinga' || body is 'CaelumZupayColossus');
        if(thermal.Inertia<=0 || priorMass!=thermal.BodyMassKg)thermal.Inertia=CaelumThermalRules.Inertia(thermal.BodyMassKg);
        if(thermal.SurfaceArea<=0 || priorMass!=thermal.BodyMassKg || priorHeight!=thermal.HeightMeters
            || thermal.LastBodyRadius!=body.Radius)
        {
            if(FurryAnimal(body))
            {
                // Cilindro de colisión: aproximación, sin otro bono de pelaje.
                double radius=body.Radius/CaelumJourneyRules.MAP_UNITS_PER_METER;
                thermal.SurfaceArea=2*CaelumThermalData.CIRCLE_PI*radius*(radius+thermal.HeightMeters);
            }
            else thermal.SurfaceArea=CaelumThermalRules.Area(thermal.BodyMassKg,thermal.HeightMeters);
            thermal.LastBodyRadius=body.Radius;
        }
    }

    static CaelumEquipmentItem EquippedPiece(Actor body,int slot)
    {
        let user=CaelumPlayer(body);
        let piece=user!=null ? user.FindNativeEquipmentItemById(user.EquippedArmorItemId[slot]) : null;
        return piece!=null && piece.Equipped && !piece.InMagicBox ? piece : null;
    }

    static int Material(Actor body,int slot)
    {
        if(FurryAnimal(body))return -1;
        let piece=EquippedPiece(body,slot);
        if(piece!=null && piece.Equipped && !piece.InMagicBox)
            return CaelumThermalData.MaterialForArmor(piece.ItemType);
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.CombatArmor!=null)
            return CaelumThermalData.MaterialForArmor(npc.CombatArmor.ArmorType[slot]);
        return CaelumThermalData.LIGHT_CLOTH;
    }

    static double Water(Actor body,CaelumThermalState thermal,int slot)
    {
        let piece=EquippedPiece(body,slot);
        if(piece!=null)return piece.ThermalWaterKg+thermal.BaseWaterKg[slot];
        return CaelumPlayer(body)!=null ? thermal.BaseWaterKg[slot] : thermal.ActorWaterKg[slot];
    }

    static void SetWater(Actor body,CaelumThermalState thermal,int slot,double kg)
    {
        kg=Max(0.0,kg);
        let piece=EquippedPiece(body,slot);
        if(piece!=null)
        {
            // La capacidad aprobada pertenece al conjunto. Separar sus dueños
            // conserva la ropa base al cambiar de pieza sin duplicar agua/calor.
            double baseCapacity=CaelumThermalMoisture.CapacityPerArea(CaelumThermalData.LIGHT_CLOTH);
            double totalCapacity=Max(baseCapacity,CaelumThermalMoisture.CapacityPerArea(Material(body,slot)));
            thermal.BaseWaterKg[slot]=kg*baseCapacity/totalCapacity;
            piece.ThermalWaterKg=kg-thermal.BaseWaterKg[slot];
        }
        else if(CaelumPlayer(body)!=null)thermal.BaseWaterKg[slot]=kg;
        else thermal.ActorWaterKg[slot]=kg;
    }

    static void SampleCoverage(Actor body,CaelumThermalState thermal,double waterHeight,int rowMask=-1)
    {
        if(waterHeight<=0 && rowMask<=0 && thermal.LastSubmergedFraction==waterHeight && thermal.LastWaterRowMask==rowMask
            && thermal.Coverage[0]+thermal.Coverage[1]+thermal.Coverage[2]+thermal.Coverage[3]>0)return;
        thermal.LastSubmergedFraction=waterHeight;thermal.LastWaterRowMask=rowMask;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        let anatomy=user!=null ? user.AnatomyProfile : npc!=null ? npc.AnatomyProfile : null;
        for(int slot=0;slot<4;slot++){thermal.Coverage[slot]=0;thermal.SubmergedCoverage[slot]=0;thermal.SubmergedTemperatureC[slot]=0;}
        int count=CaelumThermalData.SURFACE_SAMPLES;
        double weight=1.0/(count*count);
        for(int z=0;z<count;z++)for(int side=0;side<count;side++)
        {
            double height=(z+0.5)/count,lateral=(side+0.5)/count;
            int region=anatomy!=null ? anatomy.FindRegion(height,lateral) : -1;
            int slot=region>=0 ? Clamp(anatomy.RegionLocation[region]-1,0,3) : CaelumConstants.ARMOR_SLOT_BODY;
            thermal.Coverage[slot]+=weight;
            if(rowMask>=0 ? (rowMask & (1<<z))!=0 : height<=waterHeight)
            {
                thermal.SubmergedCoverage[slot]+=weight;
                thermal.SubmergedTemperatureC[slot]+=weight*(rowMask>=0 ? thermal.WaterRowC[z] : thermal.WaterC);
            }
        }
        for(int slot=0;slot<4;slot++)
            if(thermal.SubmergedCoverage[slot]>0)thermal.SubmergedTemperatureC[slot]/=thermal.SubmergedCoverage[slot];
    }
}
