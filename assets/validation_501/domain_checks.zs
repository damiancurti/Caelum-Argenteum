// Datos artificiales sólo para pruebas nativas; nunca se incluyen en src.
class CA117Marker : Inventory
{
    int FirstItem, SecondItem, NextItem, Race, FirstClass, SecondClass, Visits;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}

class CA117Checks : StaticEventHandler
{
    int Checks, Failures;
    void Check(bool ok, String label)
    {
        Checks++;
        if (!ok) { Failures++; Console.Printf("CA117 FAIL %s", label); }
    }
    void Dump(CaelumPlayer u, String label)
    {
        Console.Printf("CA117 VALUE %s hp=%d anima=%.9f air=%.9f adrenaline=%.9f lucidity=%.9f hunger=%.9f thirst=%.9f sleep=%.9f debt=%.9f debtTics=%d combat=%.9f stun=%.9f healthState=%d survival=%.9f move=%.9f maxhp=%.9f maxair=%.9f maxanima=%.9f",
            label,u.health,u.CurrentAnima,u.CurrentAir,u.CurrentAdrenaline,u.CurrentLucidity,
            u.CurrentHunger,u.CurrentThirst,u.CurrentSleep,u.UnderwaterAirRecoveryDebt,
            u.UnderwaterAirRecoveryTicsRemaining,u.CombatTimeRemaining,u.LucidityPhysicalStunRemaining,
            u.HealthState,u.SurvivalPerformanceMultiplier,u.EffectiveMovementPercent,
            u.DerivedStats.MaximumHealth,u.DerivedStats.MaximumAir,u.DerivedStats.MaximumAnima);
    }
    void ResetResources(CaelumPlayer u)
    {
        u.health=u.CaelumMaximumHealth; u.player.health=u.health;
        u.CurrentAnima=u.DerivedStats.MaximumAnima;
        u.RefillAir(); u.RefillSurvivalResources(); u.RefillLucidity();
        u.CurrentAdrenaline=0; u.CombatTimeRemaining=0;
        u.SurvivalDamageAccumulator=0; u.NaturalHealthRegenerationAccumulator=0;
        u.LucidityPhysicalStunRemaining=0; u.PainImmobilizationRemaining=0;
        u.ForcedSleepTics=0; u.UpdateHealthStateEffects();
    }
    void Draft(CaelumPlayer u, Name key, int value)
    { CVar.GetCVar(key,u.player).SetInt(value); }
    void ProfileChecks(CaelumPlayer u)
    {
        // Las combinaciones recorren los perfiles legales; los presupuestos
        // proceden del asignador real, no de otra fórmula de creación.
        for(int race=CaelumConstants.RACE_BEAST_MAN;race<=CaelumConstants.RACE_GOBLIN;race++)
        for(int first=CaelumConstants.CLASS_WARRIOR;first<=CaelumConstants.CLASS_MAGE;first++)
        for(int second=CaelumConstants.CLASS_WARRIOR;second<=CaelumConstants.CLASS_MAGE;second++)
        {
            u.CharacterProfile.Race=race; u.CharacterProfile.FirstClass=first; u.CharacterProfile.SecondClass=second;
            u.CharacterAllocation.ResetAllocations();
            for(int pass=0;pass<10;pass++)
            for(int i=0;i<4;i++)
            { u.CharacterAllocation.SelectedLayer=i; u.CharacterAllocation.TryAddSelectedLayerPoint(u.CharacterProfile); }
            for(int pass=0;pass<10;pass++)
            for(int i=0;i<12;i++)
            { u.CharacterAllocation.SelectedAttribute=i; u.CharacterAllocation.TryAddSelectedAttributePoint(u.CharacterProfile); }
            Check(u.ValidateLoadedNewCharacterDraft(),"valid allocated race/class profile");
            u.ApplyCharacterProfile();
            int hp=u.health; double anima=u.CurrentAnima, air=u.CurrentAir;
            u.ApplyCharacterProfile(); u.EnsureCurrentAttributeBalance();
            Check(u.health==hp && u.CurrentAnima==anima && u.CurrentAir==air,"profile recalculation does not refill");
            Dump(u,String.Format("profile-%d-%d-%d",race,first,second));
        }
        u.InitializeDirectMapCharacter(); ResetResources(u);
        Check(u.ValidateLoadedNewCharacterDraft(),"direct-map profile valid");
        u.CharacterAllocation.AttributeBonus[0]=-1;
        Check(!u.ValidateLoadedNewCharacterDraft(),"negative allocation rejected");
        u.InitializeDirectMapCharacter();
        Draft(u,"ca_newchar_ready",1); Draft(u,"ca_newchar_race",-1);
        Check(!u.ConsumeNewCharacterDraft() && !u.NewCharacterDraftIsReady(),"invalid draft consumed safely");
        u.InitializeDirectMapCharacter();
        Draft(u,"ca_newchar_race",u.CharacterProfile.Race);
        Draft(u,"ca_newchar_first_class",u.CharacterProfile.FirstClass);
        Draft(u,"ca_newchar_second_class",u.CharacterProfile.SecondClass);
        Draft(u,"ca_newchar_sex",u.CharacterProfile.Sex); Draft(u,"ca_newchar_height",u.CharacterProfile.HeightChoice);
        for(int i=0;i<4;i++) Draft(u,Name(String.Format("ca_newchar_layer%d",i)),u.CharacterAllocation.LayerBonus[i]);
        for(int i=0;i<12;i++) Draft(u,Name(String.Format("ca_newchar_attribute%d",i)),u.CharacterAllocation.AttributeBonus[i]);
        Draft(u,"ca_newchar_ready",1);
        Check(u.ConsumeNewCharacterDraft(),"valid native CVar draft accepted");
        Check(!u.NewCharacterDraftIsReady() && !u.ConsumeNewCharacterDraft(),"draft is consumed once");
        Check(u.CharacterCreationComplete && !u.CreationWizardOpen,"creation completion flags");
        ResetResources(u);
    }
    void ResourceChecks(CaelumPlayer u)
    {
        for(int i=0;i<=10;i++)
        {
            ResetResources(u);
            u.health=Max(1,int(u.CaelumMaximumHealth*i/10.0)); u.player.health=u.health;
            u.CurrentHunger=i*10; u.CurrentThirst=100-i*10; u.CurrentSleep=i*10;
            u.CurrentAdrenaline=u.DerivedStats.MaximumAdrenaline*i/10.0;
            u.CurrentLucidity=i*10; u.CurrentAir=u.DerivedStats.MaximumAir*i/10.0;
            u.UpdateHealthStateEffects(); u.UpdateSurvivalStates(); u.UpdateLucidityState(); u.UpdateAirStateEffects();
            Check(u.SurvivalPerformanceMultiplier>=0 && u.SurvivalPerformanceMultiplier<=1,"bounded survival penalty");
            double stun=u.LucidityPhysicalStunRemaining;
            u.UpdateLucidityState(); Check(u.LucidityPhysicalStunRemaining==stun,"stun crossing is not retriggered");
            u.UpdateLucidityPhysicalStun(); u.PainImmobilizationRemaining=0.01; u.UpdatePainImmobilization();
            Check(u.PainImmobilizationRemaining==0,"pain timer clamps at zero");
            u.ApplyNaturalHealthRegeneration(); u.ApplyCriticalSurvivalDamage();
            u.UpdateSurvivalResources(); u.ApplyAirRegeneration();
            Dump(u,String.Format("resources-%d",i));
        }
        ResetResources(u);
        u.CurrentAdrenaline=u.DerivedStats.MaximumAdrenaline/2; u.MarkCombatActivity();
        double adrenaline=u.CurrentAdrenaline;
        u.UpdateAdrenalineDecay(); Check(u.CurrentAdrenaline==adrenaline,"combat holds adrenaline");
        u.CombatTimeRemaining=0; u.UpdateAdrenalineDecay();
        Check(u.CurrentAdrenaline<adrenaline,"adrenaline decays after combat");
        u.AddAdrenaline(-1); u.AddCombatAdrenaline(1);
        Dump(u,"adrenaline");
        ResetResources(u);
        double air=u.CurrentAir;
        for(int tic=0;tic<70;tic++) u.UpdateUnderwaterAirForState(true);
        Check(u.CurrentAir<air && u.UnderwaterAirRecoveryDebt>0,"submersion spends air and records debt");
        Dump(u,"underwater");
        for(int tic=0;tic<CaelumConstants.UNDERWATER_AIR_RECOVERY_SECONDS*TICRATE;tic++) u.UpdateUnderwaterAirForState(false);
        Check(abs(u.CurrentAir-air)<0.000001 && u.UnderwaterAirRecoveryDebt==0,"air debt recovered exactly");
        Dump(u,"surfaced");
        u.ConsumeJumpAir(); Check(u.CurrentAir<air,"jump spends air");
        for(int type=0;type<=CaelumConstants.CONSUMABLE_WATER_RATION;type++)
        {
            u.CurrentHunger=40; u.CurrentThirst=40; u.CurrentSleep=40;
            u.CurrentAnima=u.DerivedStats.MaximumAnima/2; u.CurrentAir=u.DerivedStats.MaximumAir/2;
            u.ApplyConsumableRegenerationPulse(type); Dump(u,String.Format("consumable-%d",type));
        }
        ResetResources(u);
        u.ApplyLocalizedLucidityLoss(CaelumConstants.VULNERABILITY_CRITICAL_POINT,CaelumConstants.VULNERABILITY_CRITICAL_POINT,false,0);
        Check(u.CurrentLucidity<CaelumConstants.MAXIMUM_LUCIDITY,"localized hit loses lucidity"); Dump(u,"localized");
        ResetResources(u);
        u.CurrentAnima=u.DerivedStats.MaximumAnima/2;
        u.CurrentAir=u.DerivedStats.MaximumAir/2;
        for(int i=0;i<35;i++) u.AdvancePersonalTimeTic();
        Dump(u,"personal-time-35");
        Check(u.CurrentAnima>u.DerivedStats.MaximumAnima/2,"personal time regenerates anima");
        ResetResources(u);
    }
    CaelumEquipmentItem Item(CaelumPlayer u)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem",u.Pos));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType=CaelumConstants.WEAPON_TYPE_STANDARD_BOW; item.Tier=1;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        item.Durability=10; item.Equipped=true; item.PickupDataInitialized=true;
        item.WeaponDurabilityRevision=1;
        item.AttachToOwner(u); u.EnsureEquipmentItemId(item); return item;
    }
    void Seed(CaelumPlayer u)
    {
        let first=Item(u); let second=Item(u); second.Durability=7;
        Check(first.ItemId!=second.ItemId,"identical equipment keeps exact identities");
        Check(u.ActivateExactEquippedWeapon(first),"native first selector");
        Check(u.ActivateExactEquippedWeapon(second) && u.ActiveWeaponItemId==second.ItemId,"native second selector");
        // El arma testigo queda fuera del selector pendiente antes de guardar;
        // la animación nativa todavía puede reconciliar el arma preparada.
        second.Equipped=false; u.ActivateExactEquippedWeapon(first);
        let marker=CA117Marker(Actor.Spawn("CA117Marker",u.Pos)); marker.AttachToOwner(u);
        marker.FirstItem=first.ItemId; marker.SecondItem=second.ItemId;
        marker.Race=u.CharacterProfile.Race; marker.FirstClass=u.CharacterProfile.FirstClass; marker.SecondClass=u.CharacterProfile.SecondClass;
        let record=u.GetPersistentCharacterState(true);
        marker.NextItem=record.NextEquipmentItemId;
        record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
        record.FactionReputation[0]=17;
        u.health=Max(1,u.CaelumMaximumHealth/2); u.player.health=u.health;
        u.CurrentAnima=u.DerivedStats.MaximumAnima/3; u.CurrentAir=u.DerivedStats.MaximumAir/2;
        u.CurrentHunger=72; u.CurrentThirst=63; u.CurrentSleep=54; u.CurrentLucidity=43;
        u.CurrentAdrenaline=u.DerivedStats.MaximumAdrenaline/3; u.MarkCombatActivity();
        u.UpdateSurvivalStates(); u.UpdateLucidityState(); u.UpdateHealthStateEffects(); u.UpdateAirStateEffects();
        u.PersistCharacterState();
    }
    void Persistence(CaelumPlayer u, String label)
    {
        let marker=CA117Marker(u.FindInventory("CA117Marker")); if(marker==null)return;
        let record=u.GetPersistentCharacterState(false);
        Check(record!=null,"record retained");
        Check(u.CharacterProfile.Race==marker.Race && u.CharacterProfile.FirstClass==marker.FirstClass && u.CharacterProfile.SecondClass==marker.SecondClass,"profile retained");
        Check(u.ValidateLoadedNewCharacterDraft(),"allocation retained");
        Check(u.HealthResourceInitialized && u.AnimaResourceInitialized && u.AirResourceInitialized && u.SurvivalResourcesInitialized,"initialization retained");
        Check(u.CurrentAnima<u.DerivedStats.MaximumAnima && u.CurrentHunger<100 && u.CurrentThirst<100 && u.CurrentSleep<100,"resources not reset");
        Check(record.TarotOwned[CaelumConstants.TAROT_THE_FOOL] && record.FactionReputation[0]==17,"progress retained");
        Check(record.NextEquipmentItemId==marker.NextItem,"no item ID allocation on reload/travel");
        let first=u.FindNativeEquipmentItemById(marker.FirstItem); let second=u.FindNativeEquipmentItemById(marker.SecondItem);
        Check(first!=null && second!=null && first!=second && second.Durability==7,"exact equipment and wear retained");
        int count=0; for(Inventory c=u.Inv;c!=null;c=c.Inv) if(CaelumEquipmentItem(c)!=null)count++;
        Check(count==2,"no duplicate equipment");
        Dump(u,label);
        Console.Printf("CA117 PERSIST %s map=%s checks=%d failures=%d",label,level.MapName,Checks,Failures);
    }
    override void WorldLoaded(WorldEvent e)
    {
        let u=CaelumPlayer(players[0].mo); if(u==null)return;
        Persistence(u,e.IsSaveGame?"save-load":e.IsReopen?"hub-return":"travel-arrival");
    }
    override void WorldUnloaded(WorldEvent e)
    {
        let u=CaelumPlayer(players[0].mo); if(u!=null) Persistence(u,"travel-departure");
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo); if(u==null || level.time<2 || u.FindInventory("CA117Marker")!=null)return;
        ProfileChecks(u); ResourceChecks(u); Seed(u);
        Console.Printf("CA117 DONE checks=%d failures=%d",Checks,Failures);
    }
}
