// Real input/physics control: ten requested jumps during twenty seconds of running,
// then forty seconds standing. Equipment and all resources keep production rules.
class CA140HeavyEffort : StaticEventHandler
{
    CaelumPlayer User;
    double Peak,StartSweat,StartThermalDamage,StartAction,LastAction,Distance;
    vector3 Previous;
    int RunningTics,AirborneTics,ActualJumps,Failures;
    bool Finished,AirExhausted;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA140 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();
            let climate=Actor.Spawn("CaelumClimateRegion",(0,0,0));climate.args[0]=1;climate.args[1]=5;
            for(int slot=0;slot<4;slot++)
            {
                let item=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",User.Pos,NO_REPLACE));
                item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;item.ItemType=CaelumConstants.ARMOR_TYPE_HEAVY;
                item.ArmorSlot=slot;item.Tier=1;item.EquipmentSize=User.WeaponModel.Size;item.PickupDataInitialized=true;
                item.UnitWeight=User.ArmorModel.GetWeightFor(slot,item.ItemType,1,item.EquipmentSize);
                item.Durability=User.ArmorModel.GetMaximumDurabilityFor(item.ItemType,1,item.EquipmentSize);
                item.Equipped=true;item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
                User.EquippedArmorItemId[slot]=item.ItemId;
                User.ArmorModel.ArmorType[slot]=item.ItemType;User.ArmorModel.Tier[slot]=1;
                User.ArmorModel.Size[slot]=item.EquipmentSize;User.ArmorModel.Durability[slot]=item.Durability;
            }
            User.ApplyCharacterProfile();User.PersistCharacterState();
        }
        if(User==null)return;
        let s=CaelumThermalBody.Get(User,true);if(s==null)return;
        if(Finished)return;
        bool endurance=CVar.GetCVar("ca140_endurance").GetBool();
        if(level.time==35)
        {
            s.Exposure=0;User.CurrentHunger=100;User.CurrentThirst=100;User.CurrentSleep=100;
            User.CurrentAir=User.DerivedStats.MaximumAir;User.health=User.CaelumMaximumHealth;User.player.health=User.health;
            StartSweat=s.SweatKg;StartThermalDamage=s.AppliedDamageHP;StartAction=s.ActionJoules;LastAction=StartAction;
            Previous=User.Pos;
            Console.Printf("CA140 HEAVY_PROFILE race=%d bodyKg=%.6f totalKg=%.6f armorKg=%.6f constitution=%.6f toughness=%.6f threshold=%.6f maxHP=%d maxAir=%.6f",
                User.CharacterProfile.Race,User.DerivedStats.BaseMass,User.DerivedStats.TotalMass,User.ArmorModel.GetTotalWeight(),
                User.Attributes.Constitution,User.Attributes.Toughness,10*CaelumThermalRules.ThresholdScale(s.Toughness),User.CaelumMaximumHealth,User.DerivedStats.MaximumAir);
            Console.Printf("CA140 FOOT_SPEED kmh=%.9f walkMU=%.9f acceleration=%.9f multiplier=%.9f",
                CaelumJourneyRules.SpeedForMode(User,CaelumJourneyState.MODE_FOOT),CaelumJourneyRules.WalkingMUPerTic(User),
                User.MovementAccelerationFactor,User.Speed);
        }
        if(level.time<35)return;
        int elapsed=level.time-35;
        if((endurance || elapsed<700) && elapsed%70==0)User.Angle=(elapsed/70%4)*90;
        Peak=Max(Peak,s.Exposure);vector3 delta=User.Pos-Previous;
        Distance+=Sqrt(delta.X*delta.X+delta.Y*delta.Y);Previous=User.Pos;
        if(s.ActionJoules>LastAction)ActualJumps++;LastAction=s.ActionJoules;
        RunningTics+=int(User.IsSpendingRunningAir);AirborneTics+=int(!User.player.onground);
        if(!AirExhausted && User.CurrentAir<=0)
        {AirExhausted=true;Console.Printf("CA140 ENDURANCE_AIR_EMPTY seconds=%.6f thirst=%.6f E=%.6f hp=%d",elapsed/35.0,User.CurrentThirst,s.Exposure,User.health);}
        if(elapsed%(endurance ? 1050 : 350)==0)
            Console.Printf("CA140 HEAVY seconds=%d hp=%d air=%.6f thirst=%.6f E=%.6f peak=%.6f thermalHP=%.6f sweatMl=%.6f actionJ=%.6f activityJ=%.6f ambient=%.6f humidity=%.6f wind=%.6f",
                elapsed/35,User.health,User.CurrentAir,User.CurrentThirst,s.Exposure,Peak,s.AppliedDamageHP-StartThermalDamage,
                (s.SweatKg-StartSweat)*1000,s.ActionJoules-StartAction,s.ActivityJoules,s.AirC,s.Humidity,s.WindMps);
        if((!endurance && elapsed==2100) || (endurance && (User.CurrentThirst<=0 || User.health<=0)))
        {
            Check(RunningTics>0 && ActualJumps>0 && Distance>0,"real heavy-armored running and jumping occurred");
            Check(User.WaterLevel==0,"heavy effort control never required immersion");
            Console.Printf("CA140 HEAVY_COMPLETE failures=%d hp=%d peak=%.6f final=%.6f thermalHP=%.6f jumps=%d runningTics=%d airborneTics=%d distanceMU=%.6f",
                Failures,User.health,Peak,s.Exposure,s.AppliedDamageHP-StartThermalDamage,ActualJumps,RunningTics,AirborneTics,Distance);
            if(endurance)Console.Printf("CA140 ENDURANCE_COMPLETE seconds=%.6f thirst=%.9f hunger=%.9f hp=%d E=%.6f thermalHP=%.6f sweatMl=%.6f failures=%d",
                elapsed/35.0,User.CurrentThirst,User.CurrentHunger,User.health,s.Exposure,s.AppliedDamageHP-StartThermalDamage,(s.SweatKg-StartSweat)*1000,Failures);
            Finished=true;User.CreationWizardOpen=true;User.Vel=(0,0,0);
        }
    }
}
