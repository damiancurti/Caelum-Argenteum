// Native integration checks through production resource, damage and travel paths.
class CA130Effects : StaticEventHandler
{
    CaelumPlayer User;
    CaelumCombatActor Victim;
    int Checks,Failures;
    vector3 MoveStart;
    double MotionStart,JumpStart;
    void Verify(bool passed,String label)
    {Checks++;if(!passed)Failures++;Console.Printf("CA130 %s tic=%d %s",passed?"PASS":"FAIL",level.time,label);}
    bool Near(double a,double b,double epsilon=0.000001){return Abs(a-b)<epsilon;}
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.PersistCharacterState();
            let marker=Actor.Spawn("CaelumClimateRegion",(0,0,0),NO_REPLACE);marker.args[0]=1;marker.args[1]=5;
            Victim=CaelumCombatActor(Actor.Spawn("CaelumBull",(1800,1800,0),NO_REPLACE));
            return;
        }
        if(User==null || User.DerivedStats==null)return;
        User.DerivedStats.HealthRegenerationPerSecond=0;
        if(level.time==44)
        {
            let thermal=CaelumThermalBody.Get(User,true);CaelumThermalBody.Refresh(User,thermal);
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",User.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
            item.ArmorSlot=-1;item.Tier=1;item.EquipmentSize=User.WeaponModel.Size;
            item.SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT;
            item.UnitWeight=User.WeaponModel.GetWeightFor(item.ItemType,item.Tier,item.EquipmentSize);
            item.Durability=User.WeaponModel.GetMaximumDurabilityFor(item.ItemType,item.Tier,item.EquipmentSize);
            item.PickupDataInitialized=true;item.Equipped=true;item.AttachToOwner(User);
            User.EnsureEquipmentItemId(item);User.ActivateExactEquippedWeapon(item);User.EnsureWeaponFamilySelectors();
            User.MovementAccelerationFactor=1;
            double threshold=CaelumThermalRules.ThresholdScale(thermal.Toughness);
            thermal.Exposure=0;User.CurrentThirst=100;
            CaelumPlayerResources.UpdateSurvivalResources(User);
            double thirst=100-User.CurrentThirst;
            thermal.Exposure=11*threshold;User.CurrentThirst=100;
            CaelumPlayerResources.UpdateSurvivalResources(User);
            Verify(thirst>0 && Near(100-User.CurrentThirst,thirst*2),"native heat doubles thirst depletion once");
            let armor=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",User.Pos,NO_REPLACE));
            armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
            armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_BODY;armor.Tier=1;armor.EquipmentSize=User.WeaponModel.Size;
            armor.PickupDataInitialized=true;armor.Equipped=true;armor.Durability=0;armor.AttachToOwner(User);
            User.EnsureEquipmentItemId(armor);User.EquippedArmorItemId[armor.ArmorSlot]=armor.ItemId;
            Verify(CaelumThermalBody.Material(User,armor.ArmorSlot)==CaelumThermalData.LEATHER,"broken worn armor retains physical insulation");
            CaelumThermalBody.SetWater(User,thermal,armor.ArmorSlot,0.1);
            double pieceWater=armor.ThermalWaterKg,baseWater=thermal.BaseWaterKg[armor.ArmorSlot];
            Verify(pieceWater>0 && Near(pieceWater+baseWater,0.1),"wet outfit splits conserved water between actual owners");
            armor.Equipped=false;
            Verify(Near(CaelumThermalBody.Water(User,thermal,armor.ArmorSlot),baseWater),"unequipped wet piece no longer changes worn moisture");
            armor.InMagicBox=true;
            CaelumThermalBody.SetWater(User,thermal,armor.ArmorSlot,0);
            Verify(Near(armor.ThermalWaterKg,pieceWater),"sealed Box piece moisture survives changing exposed base layer");
            User.EquippedArmorItemId[armor.ArmorSlot]=0;
            double jump=CaelumConstants.JUMP_AIR_COST*User.DerivedStats.AirConsumptionMultiplier;
            User.CurrentAir=100000;thermal.Exposure=0;User.ConsumeJumpAir();
            Verify(Near(100000-User.CurrentAir,jump),"native jump nominal Air unchanged");
            for(int tier=1;tier<=3;tier++)
            {
                thermal.Exposure=(tier*10+1)*threshold;User.CurrentAir=100000;User.ConsumeJumpAir();
                Verify(Near(100000-User.CurrentAir,jump*(tier+1)),String.Format("native heat tier %d jump cost once",tier));
            }
            thermal.Exposure=0;double q=thermal.ActionJoules;
            User.CurrentAir=100000;User.PerformDebugSwordAttack(false);
            double nominal=User.LastMeleeAirCost;
            double actionJ=thermal.ActionJoules-q;
            Verify(nominal>0 && actionJ>0,"native melee records effort after successful payment");
            thermal.Exposure=11*threshold;User.CurrentAir=100000;q=thermal.ActionJoules;
            User.PerformDebugSwordAttack(false);
            Verify(Near(User.LastMeleeAirCost,nominal*2),"native melee surcharge once");
            Verify(Near(thermal.ActionJoules-q,actionJ),"thermal surcharge produces no additional action heat");
            thermal.Exposure=0;User.ApplyPhysicalMovement();double speed=User.ForwardMove1;
            double duration=User.GetEquippedAttackDurationTics();
            thermal.Exposure=-11*threshold;User.ApplyPhysicalMovement();
            Verify(Near(User.ForwardMove1/Max(0.00001,speed),0.8),"native cold movement multiplier");
            Verify(Near(User.GetEquippedAttackDurationTics()/Max(0.00001,duration),1.25),"native cold attack duration multiplier");
            thermal.Exposure=0;
            let shield=CaelumEquipmentItem(Actor.Spawn("CaelumShieldPickup",User.Pos,NO_REPLACE));
            shield.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;shield.ItemType=CaelumConstants.SHIELD_TYPE_BUCKLER;
            shield.Tier=1;shield.EquipmentSize=User.WeaponModel.Size;shield.PickupDataInitialized=true;
            shield.Equipped=true;shield.Durability=1;shield.AttachToOwner(User);User.EnsureEquipmentItemId(shield);
            User.EquippedShieldItemId=shield.ItemId;
            User.ShieldModel.ShieldType=shield.ItemType;User.ShieldModel.Tier=1;User.ShieldModel.Size=shield.EquipmentSize;
            User.ShieldModel.Equipped=true;User.ShieldModel.Durability=1;User.DebugShieldBlocking=true;
            User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
            User.ArmorDurabilityDamageMultiplier=1;
            User.Angle=User.AngleTo(Victim);
            let blocked=CaelumActorProjectile(Actor.Spawn("CaelumActorProjectile",User.Pos,NO_REPLACE));
            blocked.StoreCaelumAttackResult(1,true,false,true,1);
            blocked.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,100,100);
            double impactStart=thermal.AbsorbedImpactJoules;
            User.ApplyRealCombatDefense(blocked,Victim,2000,'CaelumMagicTest',0,0);
            Console.Printf("CA130 SHIELD blocked=%d durability=%d loss=%d joules=%.6f",User.LastShieldBlockedAttack,User.ShieldModel.Durability,User.LastShieldDurabilityLoss,thermal.AbsorbedImpactJoules-impactStart);
            Verify(User.LastShieldBlockedAttack && User.ShieldModel.Durability==0,"native intercepted hit can break the shield");
            Verify(Near(thermal.AbsorbedImpactJoules-impactStart,32.5),"native shield and heavy gear absorb joules once before durability commit");
            shield.Equipped=false;User.EquippedShieldItemId=0;User.ShieldModel.Equipped=false;User.DebugShieldBlocking=false;
            for(int slot=0;slot<4;slot++){User.ArmorModel.ArmorType[slot]=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;User.ArmorModel.Durability[slot]=0;}
            User.health=User.CaelumMaximumHealth;User.player.health=User.health;
            Victim.CombatToughness=100;Victim.EffectiveCombatEvasionChance=0;Victim.CombatArmor=null;
            let vt=CaelumThermalBody.Get(Victim,true);vt.Exposure=0;
            let shot=CaelumActorProjectile(Actor.Spawn("CaelumActorProjectile",User.Pos,NO_REPLACE));
            shot.StoreCaelumAttackResult(1,true,false,true,1);
            shot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_FIRE,false,100,100);
            int hp=Victim.health;
            Victim.DamageMobj(shot,User,1,'CaelumMagicTest',0,0);
            Verify(Victim.health==hp,"subtractive Toughness erases direct HP in fixture");
            Verify(Near(vt.AbsorbedImpactJoules,100),"native projectile still transfers 100 J when HP is zero");
            Victim.DamageMobj(shot,User,1,'CaelumMagicTest',0,0);
            Verify(Near(vt.AbsorbedImpactJoules,100),"repeated damage callback cannot repeat projectile joules");
            let ice=CaelumActorProjectile(Actor.Spawn("CaelumActorProjectile",User.Pos,NO_REPLACE));
            ice.StoreCaelumAttackResult(1,true,false,true,51.5);
            ice.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_WATER,true,100,100);
            CaelumThermalMagic.Impact(Victim,ice,1);
            Verify(Near(vt.AbsorbedImpactJoules,-5050),"ice snapshot removes 5150 J once without second Type 1");
            vt.Exposure=-110;User.ThermalBluntDelivery=true;
            Verify(CaelumThermalEffects.Incoming(Victim,User,User,100,'CaelumMeleeTest')==338,"cold blunt classified once");
            Verify(CaelumThermalEffects.Incoming(Victim,User,User,100,'CaelumImpact')==100,"physical hazard does not get cold attack multiplier");
            User.ThermalBluntDelivery=false;
            Verify(CaelumThermalEffects.Incoming(Victim,User,User,100,'CaelumMeleeTest')==219,"cold other attack classified once");
            vt.Exposure=-11*CaelumThermalRules.ThresholdScale(vt.Toughness);
            int priorTics=Victim.tics;Victim.tics=8;Victim.A_CaelumThermalAttackFrame();
            Verify(Victim.tics==10,"natural NPC attack frame uses common cold timing");
            Victim.tics=priorTics;
            vt.Exposure=0;
            double continuous=vt.AbsorbedContinuousJoules;
            for(int i=0;i<35;i++)CaelumThermalMagic.Continuous(Victim,100,1.0/TICRATE);
            Verify(Near(vt.AbsorbedContinuousJoules-continuous,100),"continuous magic one real second equals 100 J");
            thermal.Exposure=0;thermal.ActivityWatts=0;
            double before=thermal.Exposure;CaelumThermalService.Drink(User,true);
            Verify(thermal.Exposure==before && thermal.DrinkRemaining==10,"drink sets forcing without exposure jump");
            CaelumThermalService.Drink(User,false);
            Verify(thermal.DrinkOffset==-10 && thermal.DrinkRemaining==10,"drink refresh replaces signed offset");
            CaelumThermalService.Integrate(thermal,200,0,0,0,0);
            Verify(thermal.DrinkRemaining==10,"accelerated world time cannot expire a real-time drink");
            CaelumThermalService.Integrate(thermal,0,10,0,0,0);
            Verify(thermal.DrinkRemaining==0,"drink expires at ten real simulation seconds");
            thermal.DrinkRemaining=0;
            let forecast=new("CaelumThermalJourney");
            thermal.Exposure=11*threshold;double air=User.CurrentAir;hp=User.health;
            Verify(!forecast.Forecast(User,CaelumJourneyState.MODE_FOOT,6300,5),"unsafe thermal departure blocked");
            Verify(User.CurrentAir==air && User.health==hp && thermal.Exposure==11*threshold,"rejected forecast is side effect free");
            thermal.Exposure=0;
            bool cart=forecast.Forecast(User,CaelumJourneyState.MODE_CART,6300,3);
            Verify(cart && forecast.Result.Roof && forecast.Result.WindSheltered && forecast.Result.WindMps==0,"carriage uses enclosed shelter and resting passenger");
            Verify(forecast.Result.DamageRemainder==thermal.DamageRemainder,"logical journey adds no real damage fraction");
            Verify(thermal.Exposure==0,"successful preview also preserves live exposure");
            Console.Printf("CA130 FORECAST cart=%d E=%.6f nominalMelee=%.6f actionJ=%.6f",cart,forecast.Result.Exposure,nominal,actionJ);
            let fire=CaelumThermalFireSource(Actor.Spawn("CaelumThermalFireSource",User.Pos+(160,0,0),NO_REPLACE));
            fire.args[0]=3;fire.args[1]=8;fire.args[2]=32;
            Verify(fire.Watts()==20000,"declared medium fire maps to 20 kW");
            double absorbed=CaelumThermalFire.Absorbed(User,thermal,fire);
            Verify(absorbed>0 && absorbed<fire.Watts()*0.35,"fire uses visible projected absorption, not total source watts");
            Console.Printf("CA130 FIRE absorbed=%.9f at5m",absorbed);
            fire.args[0]=0;
            User.CurrentAir=User.DerivedStats.MaximumAir;User.ApplyPhysicalMovement();
            thermal.ActivityWatts=0;thermal.PendingActivityJoules=0;thermal.PropelledVelocity=(0,0);
            User.Angle=0;MoveStart=User.Pos;MotionStart=thermal.ActivityJoules;
        }
        if(level.time==80)
        {
            let thermal=CaelumThermalBody.Get(User,true);
            Verify((User.Pos-MoveStart).Length()>0 && thermal.ActivityJoules>MotionStart,"real native voluntary walking generates heat");
            Console.Printf("CA130 MOTION distance=%.6f generatedJ=%.6f",(User.Pos-MoveStart).Length(),thermal.ActivityJoules-MotionStart);
            thermal.ActivityWatts=0;thermal.PendingActivityJoules=0;
            thermal.PropelledVelocity=(0,0);MotionStart=thermal.ActivityJoules;User.Vel=(10,0,0);
        }
        if(level.time==90)
        {
            let thermal=CaelumThermalBody.Get(User,true);
            Verify(Near(thermal.ActivityJoules,MotionStart),"passive horizontal impulse does not generate walking heat");
            User.Vel=(0,0,0);JumpStart=thermal.ActionJoules;
        }
        if(level.time==110)
        {
            let thermal=CaelumThermalBody.Get(User,true);
            Verify(thermal.ActionJoules>JumpStart,"real native jump adds launch energy");
            Console.Printf("CA130 JUMP generatedJ=%.6f",thermal.ActionJoules-JumpStart);
            Console.Printf("CA130 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
