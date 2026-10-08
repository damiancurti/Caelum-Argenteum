// Native probes compare the final solver with frozen 5.1.3 source, not itself.
class CA140Checks : EventHandler
{
    CaelumPlayer User;
    CaelumCombatActor Bodies[8];
    int Checks,Failures;
    double MaxExposureError,MaxWaterError,MaxDoseError;
    double NPCAir,NPCHydration,NPCGain;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA140 %s %s",ok ? "PASS" : "FAIL",label);}
    bool Near(double a,double b,double tolerance=0.00000001){return Abs(a-b)<=tolerance;}
    CaelumThermalState Sample(int index)
    {
        let s=new("CaelumThermalState");s.Initialize();s.CanBreathe=false;s.CanShiver=false;s.Sweats=index%7!=0;s.Bare=!s.Sweats;s.Available=true;
        s.BodyMassKg=40+40*(index%5);s.HeightMeters=1.2+0.2*(index%5);
        s.SurfaceArea=CA140ReferenceRules.Area(s.BodyMassKg,s.HeightMeters);s.Inertia=CA140ReferenceRules.Inertia(s.BodyMassKg);
        s.ComfortC=index%3==0 ? 17 : index%3==1 ? 22 : 32;s.ClimateC=s.ComfortC+index%11-5;
        s.AirC=-10+index%61;s.WindMps=(index%6)*1.3;s.Humidity=(index%6)*20;
        s.RainMmHour=index%4;s.Roof=index%2==0;s.Exposure=-35+index%71;s.Toughness=index%101;
        s.Hydration=index%5==0 ? 5 : 100;s.ActivityWatts=index%4*223.333333333;
        s.Coverage[0]=0.125;s.Coverage[1]=0.375;s.Coverage[2]=0.25;s.Coverage[3]=0.25;
        for(int i=0;i<4;i++)
        {
            s.Material[i]=index%7==0 ? -1 : (index+i)%5;
            s.WorkWaterKg[i]=(index%4)*0.02;
            s.SubmergedCoverage[i]=index%3==0 ? s.Coverage[i]*0.5 : 0;
            s.SubmergedTemperatureC[i]=index%30;
        }
        return s;
    }
    void Matrix()
    {
        int bad=0;double t0=MSTimeF();
        for(int n=0;n<140;n++)
        {
            let s=Sample(n);let r=s.CopyForForecast();
            for(int step=0;step<32;step++)
            {
                if(step%8==3){s.AirC+=4;r.AirC+=4;s.Humidity=100-s.Humidity;r.Humidity=s.Humidity;}
                if(step%8==5){s.WindMps+=0.3;r.WindMps=s.WindMps;s.Material[1]=(s.Material[1]+1)%5;r.Material[1]=s.Material[1];}
                if(step==20)
                {
                    s.BodyMassKg+=10;r.BodyMassKg=s.BodyMassKg;
                    s.SurfaceArea=CA140ReferenceRules.Area(s.BodyMassKg,s.HeightMeters);r.SurfaceArea=s.SurfaceArea;
                    s.Inertia=CA140ReferenceRules.Inertia(s.BodyMassKg);r.Inertia=s.Inertia;
                    s.SubmergedCoverage[0]=s.Coverage[0];r.SubmergedCoverage[0]=s.SubmergedCoverage[0];
                }
                double dw=step%9==0 ? 0 : n%3==0 ? 20 : n%3==1 ? 1 : 0.5;
                double dr=step%7==0 ? 0 : dw/20.0;
                double activity=step<12 ? (n%4)*223.333333333 : 0;
                double magic=step%5==0 ? -200 : 0,fire=step%6==0 ? 800 : 0;
                double a=CaelumThermalService.Integrate(s,dw,dr,activity,magic,fire);
                double b=CA140ReferenceService.Integrate(r,dw,dr,activity,magic,fire);
                MaxExposureError=Max(MaxExposureError,Abs(s.Exposure-r.Exposure));
                MaxWaterError=Max(MaxWaterError,Max(Abs(s.SweatKg-r.SweatKg),Abs(s.EvaporatedKg-r.EvaporatedKg)));
                MaxDoseError=Max(MaxDoseError,Abs(a-b));
                for(int i=0;i<4;i++)MaxWaterError=Max(MaxWaterError,Abs(s.WorkWaterKg[i]-r.WorkWaterKg[i]));
                if(!Near(s.Exposure,r.Exposure) || !Near(s.Hydration,r.Hydration) || !Near(a,b,0.0000001))bad++;
            }
        }
        Console.Printf("CA140 MATRIX cases=140 intervals=4480 exposureError=%.12f waterError=%.12f doseError=%.12f ms=%.5f",MaxExposureError,MaxWaterError,MaxDoseError,MSTimeF()-t0);
        Check(bad==0 && MaxWaterError<1e-9,"cached solver agrees with frozen reference across sizes, materials, weather, immersion and effort");
        let s=Sample(11);s.Sweats=false;s.WorkWaterKg[0]=0;
        CaelumThermalService.Integrate(s,1,0);let c=s.Coefficients;
        int geometry=c.GeometryBuilds,film=c.FilmBuilds,material=c.MaterialBuilds;
        s.Exposure+=9;CaelumThermalService.Integrate(s,1,0);
        Check(c.GeometryBuilds==geometry && c.FilmBuilds==film && c.MaterialBuilds==material && c.Hits>0,"temperature-only update reuses geometry and coefficients");
        double conductance=s.Conductance;s.WindMps+=4;CaelumThermalService.Integrate(s,1,0);
        Check(c.GeometryBuilds==geometry && c.FilmBuilds==film+1 && s.Conductance!=conductance,"wind changes flux without rebuilding body geometry");
        int ambient=c.AmbientBuilds;s.AirC+=7;s.Humidity=100;CaelumThermalService.Integrate(s,1,0);
        Check(c.AmbientBuilds==ambient+1 && c.GeometryBuilds==geometry,"ambient temperature and humidity invalidate vapor input independently");
        material=c.MaterialBuilds;s.Material[2]=(s.Material[2]+1)%5;CaelumThermalService.Integrate(s,1,0);
        Check(c.MaterialBuilds==material+1 && c.GeometryBuilds==geometry,"one changed armor region invalidates only its coefficients");
        material=c.MaterialBuilds;s.WorkWaterKg[0]+=0.01;CaelumThermalService.Integrate(s,1,0);
        Check(c.MaterialBuilds==material && c.GeometryBuilds==geometry,"wetness remains live without rebuilding dry geometry");
        s.BodyMassKg*=2;s.SurfaceArea*=1.2;CaelumThermalService.Integrate(s,1,0);
        Check(c.GeometryBuilds==geometry+1,"body mass and dimensions rebuild geometric coefficients");
        let forecast=s.CopyForForecast();double retained=s.Exposure;CaelumThermalService.Integrate(forecast,60,0);
        Check(forecast.Coefficients!=c && s.Exposure==retained,"forecasts own disposable caches and never mutate live energy");
        s.Revision=3;s.Exposure=4;s.Hydration=39;s.SweatKg=0.123;s.Initialize();s.Initialize();
        Check(s.Revision==CaelumThermalData.REVISION && s.Coefficients==null && s.Exposure==4 && s.Hydration==39 && s.SweatKg==0.123,"current migration invalidates caches without resetting physiology");
    }
    void Dose()
    {
        int bad=0;
        for(int i=0;i<200;i++)
        {
            double before=-60+i*0.6,forcing=(i%9-4)*1000,conductance=i%5*7;
            double dw=i%7==0 ? 0 : 1+i%200,dr=i%4==0 ? 0 : 1.7;
            double a=CaelumThermalRules.SeveritySeconds(before,forcing,conductance,1000,dw,dr,i%101,300);
            double b=CA140ReferenceRules.SeveritySeconds(before,forcing,conductance,1000,dw,dr,i%101,300);
            if(!Near(a,b,1e-8))bad++;
        }
        Check(bad==0,"analytical dose matches original across cold/heat thresholds, opposite signs and time domains");
    }
    void Resources()
    {
        User.CreationWizardOpen=true;User.CurrentSleep=100;
        User.IsSpendingRunningAir=false;User.DebugShieldBlocking=false;
        User.UnderwaterAirRecoveryDebt=0;User.UnderwaterAirRecoveryTicsRemaining=0;User.UnderwaterAirRecoveryAppliedThisTick=false;
        User.AirResourceInitialized=true;User.AnimaResourceInitialized=true;
        int bad=0;
        for(int race=0;race<4;race++)for(int constitution=0;constitution<=100;constitution+=50)
        {
            User.CharacterProfile.Race=race;User.Attributes.Constitution=constitution;
            User.DerivedStats.Recalculate(User.Attributes,User.CharacterProfile);
            User.health=User.CaelumMaximumHealth;User.player.health=User.health;User.HealthPerformanceMultiplier=1;
            double divisor=User.DerivedStats.GetHungerThirstConsumptionMultiplier(User.Attributes);
            User.DerivedStats.AirRegenerationPerSecond=User.DerivedStats.MaximumAir*TICRATE;
            User.DerivedStats.AnimaRegenerationPerSecond=User.DerivedStats.MaximumAnima*TICRATE;
            User.CurrentAir=0;User.CurrentAnima=0;User.CurrentHunger=100;User.CurrentThirst=100;
            CaelumPlayerResources.ApplyAirRegeneration(User);
            if(!Near(User.CurrentAir,User.DerivedStats.MaximumAir) || !Near(User.CurrentHunger,100-25*divisor) || !Near(User.CurrentThirst,100-12.5*divisor))bad++;
            User.CurrentHunger=100;User.CurrentThirst=100;CaelumPlayerResources.ApplyAnimaRegeneration(User);
            if(!Near(User.CurrentAnima,User.DerivedStats.MaximumAnima) || !Near(User.CurrentHunger,100-25*divisor) || !Near(User.CurrentThirst,100-12.5*divisor))bad++;
        }
        Check(bad==0,"native player Air and Anima charge quarter-Health bars across four races and Constitution 0/50/100");
        User.CurrentAir=0;User.CurrentAnima=0;User.CurrentHunger=100;User.CurrentThirst=0;
        CaelumPlayerResources.ApplyAirRegeneration(User);CaelumPlayerResources.ApplyAnimaRegeneration(User);
        Check(User.CurrentAir==0 && User.CurrentAnima==0 && User.CurrentHunger==100,"empty water reserve blocks recovery without charging food");
        User.CurrentThirst=0.01;double before=User.CurrentHunger;CaelumPlayerResources.ApplyAirRegeneration(User);
        Check(User.CurrentThirst==0 && Near(before-User.CurrentHunger,0.02) && User.CurrentAir>0,"partial recovery respects scarce water and charges only recovered amount");
        User.CurrentAir=0;User.CurrentAnima=0;User.CurrentHunger=0;User.CurrentThirst=100;
        CaelumPlayerResources.ApplyAirRegeneration(User);CaelumPlayerResources.ApplyAnimaRegeneration(User);
        Check(User.CurrentAir==0 && User.CurrentAnima==0 && User.CurrentThirst==100,"empty food reserve blocks both without spending water");
        let live=CaelumThermalBody.Get(User,true);double h=0,t=0;
        for(int i=0;i<3;i++)
        {
            live.Exposure=(i-1)*100;User.CurrentHunger=100;User.CurrentThirst=100;User.CurrentSleep=100;
            CaelumPlayerResources.UpdateSurvivalResources(User);
            if(i==0){h=User.CurrentHunger;t=User.CurrentThirst;}
            else Check(Near(User.CurrentHunger,h) && Near(User.CurrentThirst,t),"passive Hunger/Thirst have no cold or heat multiplier");
        }
        User.CurrentHunger=100;User.CurrentThirst=100;User.CurrentAir=0;User.CurrentAnima=0;
        let model=new("CaelumJourneyModel");model.Capture(User,false);
        model.HungerLoss=0;model.ThirstLoss=0;model.SleepLoss=0;model.Health=User.CaelumMaximumHealth;model.MaxHealth=User.CaelumMaximumHealth;
        double cost=User.DerivedStats.GetHungerThirstConsumptionMultiplier(User.Attributes);
        model.Step(false);
        Check(Near(model.Air,model.MaxAir) && Near(model.Anima,model.MaxAnima) && Near(model.Hunger,100-50*cost) && Near(model.Thirst,100-25*cost),"journey projection charges both reserves with the shared recovery rule");
    }
    void NativeBodies()
    {
        String types[8]={"CaelumArgento","CaelumCaella","CaelumPortDefender","CaelumMandinga","CaelumZupayColossus","CaelumBull","CaelumGiantRat","CaelumRulo"};
        for(int i=0;i<8;i++)
        {
            let body=Bodies[i];
            let thermal=CaelumThermalBody.Get(body,true);
            if(thermal==null){Check(false,String.Format("native thermal state for %s",types[i]));continue;}
            body.tics=-1;CaelumThermalBody.Refresh(body,thermal);
            thermal.WaterC=9;CaelumThermalBody.SampleCoverage(body,thermal,0.5);
            double total=0,wet=0;for(int j=0;j<4;j++){total+=thermal.Coverage[j];wet+=thermal.SubmergedCoverage[j];}
            int builds=thermal.Coefficients.CoverageBuilds;CaelumThermalBody.SampleCoverage(body,thermal,0.25);
            Check(Near(total,1) && Near(wet,0.5) && thermal.Coefficients.CoverageBuilds==builds,String.Format("native %s anatomy coverage and changing immersion reuse",types[i]));
            thermal.Available=true;thermal.AirC=thermal.ComfortC+8;thermal.ClimateC=thermal.ComfortC;thermal.WindMps=1;thermal.Humidity=40;
            thermal.Exposure=5;thermal.Hydration=100;thermal.Roof=true;double water=thermal.Hydration;
            CaelumThermalService.Advance(body,2,0,223,0,0);
            Check(thermal.Sweats && thermal.Hydration<water
                && (!CaelumThermalBody.FurryAnimal(body) || thermal.ComfortC==17),String.Format("native %s keeps approved sweat scope and individual hydration",types[i]));
        }
    }
    void Breathing()
    {
        Check(CaelumBreathing.Factor(0.5,0,0)==1 && CaelumBreathing.Factor(0.499,0,0)==1.5,
            "fatigue starts strictly below fifty percent Air");
        Check(CaelumBreathing.Factor(0.1,0,0)==1.5 && CaelumBreathing.Factor(0.099,0,0)==2,
            "high ventilation starts strictly below ten percent Air");
        Check(CaelumBreathing.Factor(1,11,0)==1.5 && CaelumBreathing.Factor(1,21,0)==2
            && CaelumBreathing.Factor(0.01,40,0)==2,"heat and fatigue select their maximum without stacking");
        Check(CaelumBreathing.Factor(0.01,40,0,false)==1,"no increased respiratory flow without breathable air");
        let s=Sample(1);s.Sweats=false;s.CanBreathe=true;s.BreathingAirRatio=0.05;
        s.BodyMassKg=80;s.SurfaceArea=CA140ReferenceRules.Area(80,1.75);s.Inertia=CA140ReferenceRules.Inertia(80);
        s.ComfortC=22;s.ClimateC=22;s.Exposure=0;s.AirC=10;s.ActivityWatts=0;s.RainMmHour=0;
        for(int i=0;i<4;i++){s.Material[i]=0;s.WorkWaterKg[i]=0;s.SubmergedCoverage[i]=0;}
        let r=s.CopyForForecast();CA140ReferenceService.Integrate(r,2,0);
        double g=6.0/1000/60*1.2*1005;
        double center=22+s.SurfaceArea*58.2/CA140ReferenceRules.ReferenceConductance(s.SurfaceArea);
        double b=r.Imbalance+g*(10-center),total=r.Conductance+g;
        double expected=CA140ReferenceRules.Advance(0,b,total,s.Inertia,2,0);
        double equilibrium=b/total,k=total/s.Inertia;
        double integral=equilibrium*2-equilibrium*(1-Exp(-k*2))/k;
        CaelumThermalService.Integrate(s,2,0);
        Check(Near(s.Exposure,expected) && Near(s.RespirationJoules,g*((10-center)*2-integral)),
            "respiratory sensible heat matches independent analytic ventilation and signed energy");
        Check(s.RespirationJoules<0 && s.Exposure<r.Exposure,"fatigue ventilation cools into a colder environment");
        s.AirC=80;s.Exposure=0;s.RespirationJoules=0;CaelumThermalService.Integrate(s,2,0);
        Check(s.RespirationJoules>0,"hotter inhaled air warms instead of creating impossible cooling");
        s.CanBreathe=false;s.RespirationJoules=0;CaelumThermalService.Integrate(s,2,0);
        Check(s.RespirationJoules==0,"blocked breathing adds no respiratory transfer");
        let live=CaelumThermalBody.Get(User,true);live.Exposure=0;
        User.CurrentHunger=100;User.CurrentThirst=100;User.DerivedStats.AirRegenerationPerSecond=10;
        User.CurrentAir=User.DerivedStats.MaximumAir*0.49;double before=User.CurrentAir;
        CaelumPlayerResources.ApplyAirRegeneration(User);
        Check(Near(User.CurrentAir-before,15.0/TICRATE),"native moderate panting accelerates Air recovery to 150 percent");
        User.CurrentAir=User.DerivedStats.MaximumAir*0.09;before=User.CurrentAir;
        CaelumPlayerResources.ApplyAirRegeneration(User);
        Check(Near(User.CurrentAir-before,20.0/TICRATE),"native high panting accelerates Air recovery to 200 percent");
        User.IsSpendingRunningAir=true;before=User.CurrentAir;CaelumPlayerResources.ApplyAirRegeneration(User);
        Check(User.CurrentAir==before,"panting does not bypass the running recovery exclusion");User.IsSpendingRunningAir=false;
    }
    void Gear()
    {
        let thermal=CaelumThermalBody.Get(User,true);thermal.Exposure=0;User.CurrentThirst=100;
        CaelumThermalBody.Refresh(User,thermal);CaelumThermalBody.SampleCoverage(User,thermal,0);
        thermal.Available=true;thermal.AirC=22;thermal.ClimateC=22;thermal.Humidity=100;thermal.Roof=true;thermal.WindMps=1;
        for(int type=0;type<5;type++)
        {
            let armor=CaelumEquipmentItem(Actor.Spawn("CaelumArmorPickup",User.Pos,NO_REPLACE));
            armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=type;
            armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_BODY;armor.Tier=1;armor.EquipmentSize=User.WeaponModel.Size;
            armor.PickupDataInitialized=true;armor.Equipped=true;armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
            User.EquippedArmorItemId[armor.ArmorSlot]=armor.ItemId;
            CaelumThermalService.Advance(User,0,0);int builds=thermal.Coefficients.GeometryBuilds;
            CaelumThermalBody.SetWater(User,thermal,armor.ArmorSlot,0.05);
            CaelumThermalService.Advance(User,0,0);
            Check(thermal.Material[armor.ArmorSlot]==CaelumThermalData.MaterialForArmor(type)
                && Near(CaelumThermalBody.Water(User,thermal,armor.ArmorSlot),0.05)
                && thermal.Coefficients.GeometryBuilds==builds,"native worn material and moisture share authoritative equipment without geometry rebuild");
            double retained=armor.ThermalWaterKg;armor.Equipped=false;User.EquippedArmorItemId[armor.ArmorSlot]=0;
            CaelumThermalService.Advance(User,0,0);
            Check(armor.ThermalWaterKg==retained && thermal.Material[armor.ArmorSlot]==CaelumThermalData.LIGHT_CLOTH,
                "unequipping preserves stored item water and invalidates worn material");
        }
        let c=thermal.Coefficients;int builds=c.CoverageBuilds;
        User.AnatomyProfile.InitializeBullQuadruped();CaelumThermalBody.SampleCoverage(User,thermal,0);
        Check(c.CoverageBuilds==builds+1,"same anatomy object rebuilt through native API invalidates cached rows");
        User.AnatomyProfile.InitializeHumanoid();CaelumThermalBody.SampleCoverage(User,thermal,0);
    }
    void RestAndJourney()
    {
        let live=CaelumThermalBody.Get(User,true);live.Exposure=0;
        User.CurrentHunger=100;User.CurrentThirst=100;User.CurrentSleep=100;
        let chair=CaelumRestFurniture(Actor.Spawn("CaelumRestChair",User.Pos+(40,0,0),NO_REPLACE));
        vector3 before=User.Pos;bool seated=chair.Seat(User);
        let rest=CaelumRestState.Get(User,true);rest.Status=CaelumRestRules.STATUS_ACTIVE;
        rest.Mode=CaelumRestRules.MODE_WAIT;rest.OriginMap=level.MapName;rest.UsesFurniture=true;rest.Furniture=chair;
        double factor=chair.ComfortFactor(),cost=User.DerivedStats.GetHungerThirstConsumptionMultiplier(User.Attributes)/(factor*factor);
        Check(seated && CaelumRestState.IsSeated(User) && CaelumRestState.ResourceFactor(User)==factor,"native chair activates its existing recovery factor");
        User.CurrentAir=User.DerivedStats.MaximumAir*0.4;User.CurrentAnima=0;
        User.DerivedStats.AnimaRegenerationPerSecond=10;
        double air=User.CurrentAir;
        CaelumPlayerResources.ApplyAirRegeneration(User);
        double gain=User.CurrentAir-air;
        Check(Near(gain,User.DerivedStats.AirRegenerationPerSecond*factor*1.5/TICRATE)
            && Near(100-User.CurrentThirst,gain*12.5/User.DerivedStats.MaximumAir*cost),"seated Air combines panting speed with preserved squared comfort cost reduction");
        double water=User.CurrentThirst,food=User.CurrentHunger;
        CaelumPlayerResources.ApplyAnimaRegeneration(User);
        Check(Near(User.CurrentAnima,User.DerivedStats.AnimaRegenerationPerSecond*factor/TICRATE)
            && Near(food-User.CurrentHunger,User.CurrentAnima*25/User.DerivedStats.MaximumAnima*cost)
            && Near(water-User.CurrentThirst,User.CurrentAnima*12.5/User.DerivedStats.MaximumAnima*cost),"seated Anima retains comfort speed and charges quarter-bar supplies");
        rest.Status=CaelumRestRules.STATUS_COMPLETE;chair.Release(User,before);
        User.CurrentHunger=100;User.CurrentThirst=100;User.CurrentSleep=100;live.Exposure=0;live.ActivityWatts=0;
        let marker=Actor.Spawn("CaelumClimateRegion",(0,0,0),NO_REPLACE);marker.args[0]=1;marker.args[1]=5;
        let clock=CaelumWorldClock.Get(User,true);let calendar=CaelumCalendarState.Get(User,true);
        calendar.EnsureCampaign(clock);CaelumWeatherState.Sync(User,clock,calendar);
        User.CurrentAir=User.DerivedStats.MaximumAir*0.05;User.CurrentAnima=0;
        let model=new("CaelumJourneyModel");model.Capture(User,true);
        let travel=new("CaelumThermalJourney");int duration=CaelumWorldClock.TicsPerHour();
        double sweat=live.SweatKg,exposure=live.Exposure,damage=live.DamageRemainder;int hp=User.health;
        bool safe=travel.Forecast(User,CaelumJourneyState.MODE_CART,duration,3,-1,model);
        Check(safe && model.ElapsedTics==duration && travel.Result.Roof && travel.Result.WindSheltered,"coupled passenger journey advances its full protected duration");
        Check(Near(model.Thirst,travel.Result.Hydration) && Near(model.Hunger,travel.Result.ShiveringHunger)
            && model.Air>0.05*model.MaxAir && model.Anima>0,"travel couples sweat and shivering supplies with funded Air and Anima regeneration");
        Check(live.SweatKg==sweat && live.Exposure==exposure && User.CurrentThirst==100 && User.health==hp
            && travel.Result.DamageRemainder==damage,"journey projection changes no live reserves or real-time damage");
        CaelumThermalService.CommitForecast(User,travel.Result);
        Check(User.CurrentThirst==100 && live.RespirationJoules==travel.Result.RespirationJoules,"thermal commit retains respiratory energy without charging supplies twice");
    }
    void MicroCost()
    {
        // Small solver timing only: no actor-load or frame-throughput claim.
        for(int repetition=0;repetition<5;repetition++)
        {
            double cached=0,reference=0;int geometry=0,hits=0;
            for(int order=0;order<2;order++)
            {
                bool old=(order+repetition)%2==0;let s=Sample(11);s.Sweats=false;s.Exposure=2;
                for(int slot=0;slot<4;slot++)s.WorkWaterKg[slot]=0;
                double started=MSTimeF();
                for(int i=0;i<4000;i++)
                {
                    if(old)CA140ReferenceService.Integrate(s,1.0/35,1.0/700);
                    else CaelumThermalService.Integrate(s,1.0/35,1.0/700);
                }
                if(old)reference=MSTimeF()-started;
                else {cached=MSTimeF()-started;geometry=s.Coefficients.GeometryBuilds;hits=s.Coefficients.Hits;}
            }
            Console.Printf("CA140 MICRO repeat=%d steps=4000 referenceMs=%.6f cachedMs=%.6f geometry=%d hits=%d",repetition,reference,cached,geometry,hits);
        }
    }
    void Firearms()
    {
        Check(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_CARBINE)==2
            && CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_DAGGER)==2,"carbine and dagger share two base Air");
        Check(Near(CaelumThermalEffects.FirearmWatts(2,false),116.4)
            && Near(CaelumThermalEffects.FirearmWatts(2,true),174.6),"approved firing and reload MET subtract resting metabolism once");
        let s=Sample(0);s.Available=false;s.Exposure=0;s.ActivityWatts=0;s.Inertia=1000;
        CaelumThermalService.Integrate(s,3600,2,0,0,0,0,116.4);
        Check(Near(s.Exposure,0.2328) && Near(s.ActionJoules,232.8) && s.AbsorbedContinuousJoules==0
            && s.ActivityWatts==0,"firearm energy uses real action seconds without movement tail or magical energy");
        CaelumThermalService.Integrate(s,3600,0,0,0,0,0,116.4);
        Check(Near(s.ActionJoules,232.8) && Near(s.Exposure,0.2328),"calendar-only advancement invents no firearm work");
        let npc=CaelumPortDefender(Bodies[2]);let thermal=CaelumThermalBody.Get(npc,true);
        npc.Carbine=new("CaelumCityCarbine");npc.Carbine.Initialize(npc);npc.ForcedSleepTics=0;
        npc.CombatLucidityPhysicalStunRemaining=0;npc.SetState(npc.SpawnState);npc.Carbine.PreviousPosition=npc.Pos;
        thermal.PendingFirearmJoules=0;double power=CaelumThermalEffects.FirearmWatts(thermal.SurfaceArea,true);
        int flux=thermal.Coefficients.FluxUpdates;
        npc.Carbine.ReloadRemaining=0.001;npc.Carbine.Tick(npc);
        Check(Near(thermal.PendingFirearmJoules,power*0.001) && npc.Carbine.ReloadCount==1
            && thermal.Coefficients.FluxUpdates==flux,"NPC partial final reload tic queues exact work without forcing thermal solver");
        npc.Carbine.ReloadRemaining=1;npc.ForcedSleepTics=2;double pending=thermal.PendingFirearmJoules;
        npc.Carbine.Tick(npc);
        Check(thermal.PendingFirearmJoules==pending && npc.Carbine.ReloadRemaining==0,"interrupted NPC reload adds no future heat");
        npc.ForcedSleepTics=0;npc.Carbine.ReloadRemaining=0;npc.Carbine.NextShotTic=level.time+1;npc.Carbine.ShotCount=1;
        npc.Carbine.Tick(npc);
        Check(Near(thermal.PendingFirearmJoules-pending,CaelumThermalEffects.FirearmWatts(thermal.SurfaceArea,false)/TICRATE),"NPC firing cycle uses surface-scaled light effort");
        thermal.PendingFirearmJoules=0;
        s.Revision=4;s.PendingFirearmJoules=999;s.Initialize();s.PendingFirearmJoules=123;s.Initialize();
        Check(s.Revision==CaelumThermalData.REVISION && s.PendingFirearmJoules==123,"current migration initializes old queues once and preserves queued new work");
        let stock=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",User.Pos+(200,0,0)));
        int size=CaelumEquipmentRules.ResolveAcquisitionSize(User,CaelumEquipmentRules.CHARACTER_DEFAULT,CaelumConstants.EQUIPMENT_SIZE_M);
        stock.SeedEquipment(User,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_CARBINE,0,size,0);
        let item=CaelumEquipmentItem(stock.Inv);stock.RemoveInventory(item);item.AttachToOwner(User);item.AcquisitionResolved=true;
        User.EnsureEquipmentItemId(item);User.EquipmentSelectionItemId=item.ItemId;User.EquipmentSelectionKind=item.EquipmentKind;
        User.EquipmentSelectionWeaponType=item.ItemType;User.EquipmentSelectionTier=1;User.EquipmentSelectionSize=size;
        User.RefreshEquipmentSelectionPreview();User.EquipSelectedNativeEquipment();
        let ammo=CaelumCarbineAmmo(Actor.Spawn("CaelumCarbineAmmo",User.Pos));ammo.Amount=20;ammo.AttachToOwner(User);
        User.CarbineMagazine=10;User.OnNativeInventoryChanged();User.CreationWizardOpen=false;
        User.CurrentAir=User.DerivedStats.MaximumAir;User.EquippedWeaponCooldownRemaining=0;User.AttackAnimationDurationTics=0;
        let live=CaelumThermalBody.Get(User,true);live.Exposure=0;live.PendingFirearmJoules=0;
        double air=User.CurrentAir,heat=live.ActionJoules;
        User.PerformEquippedWeaponPrimaryAttack();
        Check(User.LastCarbineFired && User.CarbineMagazine==9 && ammo.Amount==19
            && Near(air-User.CurrentAir,2*User.DerivedStats.AirConsumptionMultiplier),"native player shot retains finite ammunition and dagger-scale Air debit");
        Check(live.ActionJoules==heat && live.PendingFirearmJoules==0,"player shot no longer inserts jump-reference heat impulse");
        CaelumThermalEffects.PlayerFirearmTic(User);
        Check(Near(live.PendingFirearmJoules,CaelumThermalEffects.FirearmWatts(live.SurfaceArea,false)/TICRATE),"native player firing clock supplies one real tic of light effort");
        User.AttackAnimationStartTic=level.time-11;User.AttackAnimationDurationTics=10.25;live.PendingFirearmJoules=0;
        CaelumThermalEffects.PlayerFirearmTic(User);
        Check(Near(live.PendingFirearmJoules,CaelumThermalEffects.FirearmWatts(live.SurfaceArea,false)*0.25/TICRATE),"fractional final firing tic uses the authoritative animation duration");
        User.AttackAnimationDurationTics=20;
        User.RequestRangedReload(CaelumConstants.WEAPON_TYPE_CARBINE);live.PendingFirearmJoules=0;
        CaelumThermalEffects.PlayerFirearmTic(User);
        Check(User.RangedReloadActive && Near(live.PendingFirearmJoules,CaelumThermalEffects.FirearmWatts(live.SurfaceArea,true)/TICRATE),"player reload overrides residual firing clock instead of doubling heat");
        User.WeaponModel.Equipped=false;live.PendingFirearmJoules=0;CaelumThermalEffects.PlayerFirearmTic(User);
        Check(live.PendingFirearmJoules==0,"unequipped player firearm adds no heat");
        User.WeaponModel.Equipped=true;User.CancelRangedReload();User.WorldCarbineShotUntil=0;
        User.CreationWizardOpen=true;
    }
    void Shivering()
    {
        Check(CaelumThermalRules.ShiveringExtraMet(1)==0 && CaelumThermalRules.ShiveringExtraMet(0)==0
            && CaelumThermalRules.ShiveringExtraMet(-2.5)==2 && CaelumThermalRules.ShiveringExtraMet(-5)==4
            && CaelumThermalRules.ShiveringExtraMet(-50)==4,"shivering ramps from one to five total MET and caps at minus five exposure");
        let s=Sample(0);s.Available=false;s.CanShiver=true;s.Inertia=1000;s.SurfaceArea=2;s.Exposure=-5;
        s.ShiveringHunger=100;s.ShiveringHungerPerMetSecond=0.001;
        CaelumThermalService.Integrate(s,1,0);
        Check(Near(s.ShiveringJoules,465.6) && Near(s.Exposure,-4.5344) && Near(s.ShiveringHunger,99.996)
            && s.ActionJoules==0 && s.ActivityWatts==0,"shivering supplies world-time heat and charges only extra proportional Hunger");
        s.Exposure=-5;s.ShiveringHunger=0;double before=s.ShiveringJoules;
        CaelumThermalService.Integrate(s,1,0);
        Check(s.ShiveringJoules==before && s.Exposure==-5,"empty player Hunger cannot fund additional metabolic heat");
        s.ShiveringHunger=0.001;CaelumThermalService.Integrate(s,1,0);
        Check(Near(s.ShiveringJoules-before,116.4) && s.ShiveringHunger==0,"last food fraction funds only its affordable heat");
        s.Exposure=-5;s.ShiveringHungerPerMetSecond=0;before=s.ShiveringJoules;
        CaelumThermalService.Integrate(s,1,0);
        Check(Near(s.ShiveringJoules-before,465.6),"NPC thermoregulation has no invented Hunger reserve");
        s.Exposure=1;before=s.ShiveringJoules;CaelumThermalService.Integrate(s,1,0);
        Check(s.ShiveringJoules==before,"warm actors stop shivering without a residual activity tail");
        int supported=0;
        for(int i=0;i<8;i++)
        {let thermal=CaelumThermalBody.Get(Bodies[i],true);CaelumThermalBody.Refresh(Bodies[i],thermal);supported+=int(thermal.CanShiver && thermal.ShiveringHungerPerMetSecond==0);}
        Check(supported==8,"all eight supported NPC profiles including bull and rat share approved shivering");
        let live=CaelumThermalBody.Get(User,true);User.CurrentHunger=73;CaelumThermalBody.Refresh(User,live);
        double expected=100.0/(CaelumConstants.HUNGER_EMPTY_GAME_HOURS*3600.0)*User.DerivedStats.BaseMassMultiplier
            *User.DerivedStats.GetHungerThirstConsumptionMultiplier(User.Attributes)/CaelumRestState.ResourceFactor(User);
        Check(live.ShiveringHunger==73 && Near(live.ShiveringHungerPerMetSecond,expected),"player shivering projection preserves authoritative Hunger, Constitution and rest");
        let copy=live.CopyForForecast();copy.Exposure=-5;double hunger=User.CurrentHunger,joules=live.ShiveringJoules;
        CaelumThermalService.Integrate(copy,2,0);
        Check(copy.ShiveringJoules>joules && copy.ShiveringHunger<hunger && User.CurrentHunger==hunger
            && live.ShiveringJoules==joules,"shivering forecast consumes only its independent food and energy projection");
    }
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.PersistCharacterState();User.CreationWizardOpen=true;
            String types[8]={"CaelumArgento","CaelumCaella","CaelumPortDefender","CaelumMandinga","CaelumZupayColossus","CaelumBull","CaelumGiantRat","CaelumRulo"};
            for(int i=0;i<8;i++)Bodies[i]=CaelumCombatActor(Actor.Spawn(types[i],(1000+i*700,6000,0),NO_REPLACE));
        }
        if(level.time==91)
        {
            Check(Near(Bodies[0].CurrentCombatAir-NPCAir,NPCGain),"normal NPC Tick doubles fatigued Air recovery");
            Check(Bodies[0].ThermalState.Hydration==NPCHydration,"NPC recovery adds no player nutrition charges");
            Console.Printf("CA140 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
        if(level.time!=90)return;
        Matrix();Dose();Resources();NativeBodies();Breathing();Gear();RestAndJourney();Firearms();Shivering();MicroCost();
        let body=Bodies[0];body.CurrentCombatAir=0.09*body.MaximumCombatAir;body.CombatAirRegenerationPerSecond=10;
        body.CombatAirSpending=false;let s=CaelumThermalBody.Get(body,true);s.Exposure=0;s.Hydration=43.25;
        s.RuntimeReady=true;s.RuntimeMap=level.MapName;s.LastRealTic=level.maptime;s.NextUpdateTic=2147480000;
        NPCAir=body.CurrentCombatAir;NPCHydration=s.Hydration;
        NPCGain=20.0*(body.IsCombatIdle() ? CaelumRestRules.CHAIR_RESOURCE_FACTOR : 1)/TICRATE;
    }
}
