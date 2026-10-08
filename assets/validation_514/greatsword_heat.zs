class CA140GreatswordTarget : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 20;Height 80;Health 1000000;Mass 1000000;+SOLID +SHOOTABLE }
    States { Spawn:DOID A -1;Stop; }
}
class CA140MagicTarget : CA140GreatswordTarget
{
    Default { Radius 160;Height 160; }
}
class CA140GreatswordHeat : EventHandler
{
    CaelumPlayer User;
    CaelumThermalState Thermal;
    CA140GreatswordTarget Target;
    double Peak,Minimum,LastAction,FirstAction,InitialAction,LastAnima;
    int Swings,Casts;
    bool Finished;
    override void WorldTick()
    {
        int pool=CVar.GetCVar("ca140_pool").GetInt();
        int magic=CVar.GetCVar("ca140_magic").GetInt();
        int armorType=CVar.GetCVar("ca140_armor").GetInt();
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.CreationWizardOpen=false;
            if(magic>0){User.CharacterProfile.FirstClass=CaelumConstants.CLASS_MAGE;User.CharacterProfile.SecondClass=CaelumConstants.CLASS_MAGE;User.ApplyCharacterProfile();}
            User.SetOrigin((3072,4096,0),false);User.Angle=0;
            let climate=Actor.Spawn("CaelumClimateRegion",(0,0,0));climate.args[0]=1;climate.args[1]=5;
            for(int slot=0;slot<4;slot++)
            {
                let armor=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",User.Pos,NO_REPLACE));
                armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=armorType;
                armor.ArmorSlot=slot;armor.Tier=1;armor.EquipmentSize=User.WeaponModel.Size;armor.PickupDataInitialized=true;
                armor.UnitWeight=User.ArmorModel.GetWeightFor(slot,armor.ItemType,1,armor.EquipmentSize);
                armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(armor.ItemType,1,armor.EquipmentSize);
                armor.Equipped=true;armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
                User.EquippedArmorItemId[slot]=armor.ItemId;
                User.ArmorModel.ArmorType[slot]=armor.ItemType;User.ArmorModel.Tier[slot]=1;
                User.ArmorModel.Size[slot]=armor.EquipmentSize;User.ArmorModel.Durability[slot]=armor.Durability;
            }
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",User.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=magic>0 ? CaelumConstants.WEAPON_TYPE_STAFF : CaelumConstants.WEAPON_TYPE_GREATSWORD;
            item.EssenceType=magic==2 ? CaelumConstants.ESSENCE_WATER : CaelumConstants.ESSENCE_FIRE;
            item.ArmorSlot=-1;item.Tier=1;item.EquipmentSize=User.WeaponModel.Size;item.PickupDataInitialized=true;
            item.UnitWeight=User.WeaponModel.GetWeightFor(item.ItemType,1,item.EquipmentSize);
            item.Durability=User.WeaponModel.GetMaximumDurabilityFor(item.ItemType,1,item.EquipmentSize);
            item.AcquisitionResolved=true;item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
            User.EquipmentSelectionItemId=item.ItemId;User.EquipmentSelectionKind=item.EquipmentKind;
            User.EquipmentSelectionWeaponType=item.ItemType;User.EquipmentSelectionTier=1;
            User.EquipmentSelectionSize=item.EquipmentSize;User.RefreshEquipmentSelectionPreview();User.EquipSelectedNativeEquipment();
            Target=CA140GreatswordTarget(Actor.Spawn(magic>0 ? "CA140MagicTarget" : "CA140GreatswordTarget",
                (magic>0 ? 3584 : 3136,4096,0)));
            if(pool>0)User.SetOrigin((-14000,-4000,0),false);
        }
        if(User==null || Finished)return;
        let s=CaelumThermalBody.Get(User,true);if(s==null)return;Thermal=s;
        if(magic>0 && level.time==35)
        {User.CurrentAnima=User.DerivedStats.MaximumAnima;User.CurrentAir=User.DerivedStats.MaximumAir;
            User.health=User.CaelumMaximumHealth;User.player.health=User.health;User.CurrentHunger=100;User.CurrentThirst=100;LastAnima=User.CurrentAnima;}
        if(level.time==70)
        {
            InitialAction=s.ActionJoules;LastAction=s.ActionJoules;
            Console.Printf("CA140 GREATSWORD_PROFILE hp=%d mass=%.6f totalKg=%.6f armorKg=%.6f weaponKg=%.6f type=%d threshold=%.6f maxAir=%.6f",
                User.health,User.DerivedStats.BaseMass,User.DerivedStats.TotalMass,User.ArmorModel.GetTotalWeight(),User.WeaponModel.GetWeight(),
                User.WeaponModel.WeaponType,10*CaelumThermalRules.ThresholdScale(s.Toughness),User.DerivedStats.MaximumAir);
            Console.Printf("CA140 MAGIC_PROFILE mode=%d armor=%d maxAnima=%.6f constitution=%.6f toughness=%.6f",magic,armorType,User.DerivedStats.MaximumAnima,User.Attributes.Constitution,User.Attributes.Toughness);
            if(pool==1){User.bNOGRAVITY=true;User.SetOrigin((14000,0,40),false);User.Vel=(0,0,0);}
        }
        if(pool>0 && level.time==105)
        {
            Console.Printf("CA140 POOL_EXIT mode=%d waterLevel=%d E=%.9f waterC=%.6f hp=%d",pool,User.WaterLevel,s.Exposure,s.WaterC,User.health);
            User.SetOrigin((-14000,-4000,0),false);User.Vel=(0,0,0);User.bNOGRAVITY=false;
        }
        // Solicitar ataques normales: la animación, el Aire y los tiempos siguen siendo los del juego.
        bool paced=CVar.GetCVar("ca140_paced").GetBool();
        double beforeAnima=User.CurrentAnima;
        if(magic>0 && level.time>70 && beforeAnima<LastAnima-0.001)Casts++;
        if(pool==0 && level.time>=70 && level.time<4270 && User.health>0
            && (!paced || User.CurrentAir>User.DerivedStats.MaximumAir*0.5))
        {if(magic==2)User.PerformEquippedWeaponSecondaryAttack();else User.PerformEquippedWeaponPrimaryAttack();}
        if(magic>0 && User.CurrentAnima<beforeAnima-0.001)Casts++;
        LastAnima=User.CurrentAnima;
        if(s.ActionJoules>LastAction)
        {if(Swings==0)FirstAction=s.ActionJoules-LastAction;Swings++;LastAction=s.ActionJoules;}
        Peak=Max(Peak,s.Exposure);Minimum=Min(Minimum,s.Exposure);
        if(level.time%350==0)
        {
            Console.Printf("CA140 GREATSWORD seconds=%.3f hp=%d air=%.6f thirst=%.6f E=%.6f swings=%d hits=%d sweatMl=%.6f actionJ=%.6f thermalHP=%.6f ambient=%.6f",
                (level.time-70)/35.0,User.health,User.CurrentAir,User.CurrentThirst,s.Exposure,Swings,Target.Hits,s.SweatKg*1000,
                s.ActionJoules-InitialAction,s.AppliedDamageHP,s.AirC);
            double retained=0,capacity=0;
            for(int i=0;i<4;i++){retained+=CaelumThermalBody.Water(User,s,i);capacity+=s.Coefficients.Capacity[i];}
            Console.Printf("CA140 SWEAT seconds=%.3f retainedMl=%.6f capacityMl=%.6f evaporatedMl=%.6f evaporationJ=%.6f runoffMl=%.6f rateKgHour=%.6f inertia=%.6f area=%.6f wind=%.6f humidity=%.6f worldPerReal=%.6f",
                (level.time-70)/35.0,retained*1000,capacity*1000,s.EvaporatedKg*1000,s.EvaporationJoules,s.SweatRunoffKg*1000,s.SweatRateKgHour,s.Inertia,s.SurfaceArea,s.WindMps,s.Humidity,CaelumThermalRuntime.WorldTicSeconds()*35);
            Console.Printf("CA140 SHIVER seconds=%.3f joules=%.6f hunger=%.6f extraMet=%.6f paced=%d",(level.time-70)/35.0,s.ShiveringJoules,User.CurrentHunger,CaelumThermalRules.ShiveringExtraMet(s.Exposure),paced);
            if(magic>0)Console.Printf("CA140 MAGIC seconds=%.3f casts=%d anima=%.6f absorbedJ=%.6f continuousJ=%.6f",(level.time-70)/35.0,Casts,User.CurrentAnima,s.AbsorbedImpactJoules,s.AbsorbedContinuousJoules);
        }
        if(level.time==6370 || User.health<=0)
        {
            Console.Printf("CA140 GREATSWORD_COMPLETE seconds=%.6f alive=%d hp=%d swings=%d hits=%d firstActionJ=%.6f peak=%.6f minimum=%.6f thirst=%.6f sweatMl=%.6f thermalHP=%.6f",
                (level.time-70)/35.0,User.health>0,User.health,Swings,Target.Hits,FirstAction,Peak,Minimum,User.CurrentThirst,s.SweatKg*1000,s.AppliedDamageHP);
            Finished=true;
            if(magic>0)Console.Printf("CA140 MAGIC_COMPLETE mode=%d armor=%d casts=%d hits=%d hp=%d thermalHP=%.6f hunger=%.6f thirst=%.6f anima=%.6f",magic,armorType,Casts,Target.Hits,User.health,s.AppliedDamageHP,User.CurrentHunger,User.CurrentThirst,User.CurrentAnima);
        }
    }
    override void RenderOverlay(RenderEvent event)
    {
        if(User==null || Thermal==null)return;
        let s=Thermal;let font=Font.GetFont("CaelumMono");
        Screen.DrawText(font,Font.CR_WHITE,12,12,String.Format("Salud %d/%d | Golpes %d | Hechizos %d",User.health,User.CaelumMaximumHealth,Swings,Casts),DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_SHADOW,true);
        Screen.DrawText(font,Font.CR_WHITE,12,25,String.Format("Aire %.1f%% | Sed %.1f | Sudor %.1f ml",100*User.CurrentAir/User.DerivedStats.MaximumAir,User.CurrentThirst,s.SweatKg*1000),DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_SHADOW,true);
        Screen.DrawText(font,Font.CR_WHITE,12,38,String.Format("Exposicion %+.2f | Umbral %.2f | Dano termico %.0f HP",s.Exposure,10*CaelumThermalRules.ThresholdScale(s.Toughness),s.AppliedDamageHP),DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_SHADOW,true);
    }
}
