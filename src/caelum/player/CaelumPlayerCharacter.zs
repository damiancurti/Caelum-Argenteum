// #117: operaciones sin estado propio; el jugador conserva los datos serializados.
// El coordinador mantiene el orden de llamadas y la inicialización explícita.
class CaelumPlayerCharacter : Object play
{
    static int ReadNewCharacterDraft(CaelumPlayer user, Name setting, int fallback)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return fallback;
        if (user.player == null) { return fallback; }
        CVar value = CVar.GetCVar(setting, user.player);
        return value == null ? fallback : value.GetInt();
    }

    static int ReadNewCharacterLayer(CaelumPlayer user, int layer)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        switch (layer)
        {
            case 0: return user.ReadNewCharacterDraft("ca_newchar_layer0", 0);
            case 1: return user.ReadNewCharacterDraft("ca_newchar_layer1", 0);
            case 2: return user.ReadNewCharacterDraft("ca_newchar_layer2", 0);
            default: return user.ReadNewCharacterDraft("ca_newchar_layer3", 0);
        }
    }

    static int ReadNewCharacterAttribute(CaelumPlayer user, int attribute)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return 0;
        switch (attribute)
        {
            case 0: return user.ReadNewCharacterDraft("ca_newchar_attribute0", 0);
            case 1: return user.ReadNewCharacterDraft("ca_newchar_attribute1", 0);
            case 2: return user.ReadNewCharacterDraft("ca_newchar_attribute2", 0);
            case 3: return user.ReadNewCharacterDraft("ca_newchar_attribute3", 0);
            case 4: return user.ReadNewCharacterDraft("ca_newchar_attribute4", 0);
            case 5: return user.ReadNewCharacterDraft("ca_newchar_attribute5", 0);
            case 6: return user.ReadNewCharacterDraft("ca_newchar_attribute6", 0);
            case 7: return user.ReadNewCharacterDraft("ca_newchar_attribute7", 0);
            case 8: return user.ReadNewCharacterDraft("ca_newchar_attribute8", 0);
            case 9: return user.ReadNewCharacterDraft("ca_newchar_attribute9", 0);
            case 10: return user.ReadNewCharacterDraft("ca_newchar_attribute10", 0);
            default: return user.ReadNewCharacterDraft("ca_newchar_attribute11", 0);
        }
    }

    static bool NewCharacterDraftIsReady(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (user.player == null) { return false; }
        CVar ready = CVar.GetCVar("ca_newchar_ready", user.player);
        return ready != null && ready.GetBool();
    }

    static void ClearNewCharacterDraftReady(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.player == null) { return; }
        CVar ready = CVar.GetCVar("ca_newchar_ready", user.player);
        if (ready != null) { ready.SetBool(false); }
    }

    static bool ValidateLoadedNewCharacterDraft(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return false;
        if (user.CharacterProfile == null || user.CharacterAllocation == null) return false;
        if (user.CharacterProfile.Race < CaelumConstants.RACE_BEAST_MAN
            || user.CharacterProfile.Race > CaelumConstants.RACE_GOBLIN
            || user.CharacterProfile.FirstClass < CaelumConstants.CLASS_WARRIOR
            || user.CharacterProfile.FirstClass > CaelumConstants.CLASS_MAGE
            || user.CharacterProfile.SecondClass < CaelumConstants.CLASS_WARRIOR
            || user.CharacterProfile.SecondClass > CaelumConstants.CLASS_MAGE
            || user.CharacterProfile.Sex < CaelumConstants.SEX_MALE
            || user.CharacterProfile.Sex > CaelumConstants.SEX_FEMALE
            || user.CharacterProfile.HeightChoice < CaelumConstants.HEIGHT_SHORT
            || user.CharacterProfile.HeightChoice > CaelumConstants.HEIGHT_TALL)
        {
            return false;
        }

        int spentLayers = 0;
        for (int layer = 0; layer < CaelumConstants.ATTRIBUTE_LAYER_COUNT; layer++)
        {
            int bonus = user.CharacterAllocation.LayerBonus[layer];
            spentLayers += bonus;
            if (bonus < 0
                || user.CharacterProfile.GetCombinedLayerValue(layer) + bonus
                    > CaelumConstants.MAX_LAYER_BASE)
            {
                return false;
            }
        }
        if (spentLayers != CaelumConstants.FREE_LAYER_POINTS) { return false; }

        int spentAttributes = 0;
        for (int attribute = 0;
            attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
        {
            int bonus = user.CharacterAllocation.AttributeBonus[attribute];
            spentAttributes += bonus;
            if (bonus < 0 || bonus > user.CharacterAllocation.GetMaximumIndividualBonus(
                user.CharacterProfile, attribute
            ))
            {
                return false;
            }
        }
        return spentAttributes == CaelumConstants.INDIVIDUAL_ATTRIBUTE_POINTS;
    }

    static bool ConsumeNewCharacterDraft(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return false;
        if (!user.NewCharacterDraftIsReady()) { return false; }

        user.CharacterProfile.Race = user.ReadNewCharacterDraft(
            "ca_newchar_race", CaelumConstants.RACE_HUMAN
        );
        user.CharacterProfile.FirstClass = user.ReadNewCharacterDraft(
            "ca_newchar_first_class", CaelumConstants.CLASS_WARRIOR
        );
        user.CharacterProfile.SecondClass = user.ReadNewCharacterDraft(
            "ca_newchar_second_class", CaelumConstants.CLASS_MAGE
        );
        user.CharacterProfile.Sex = user.ReadNewCharacterDraft(
            "ca_newchar_sex", CaelumConstants.SEX_MALE
        );
        user.CharacterProfile.HeightChoice = user.ReadNewCharacterDraft(
            "ca_newchar_height", CaelumConstants.HEIGHT_NORMAL
        );
        for (int layer = 0; layer < CaelumConstants.ATTRIBUTE_LAYER_COUNT; layer++)
        {
            user.CharacterAllocation.LayerBonus[layer] = user.ReadNewCharacterLayer(layer);
        }
        for (int attribute = 0;
            attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
        {
            user.CharacterAllocation.AttributeBonus[attribute] =
                user.ReadNewCharacterAttribute(attribute);
        }

        if (!user.ValidateLoadedNewCharacterDraft())
        {
            user.ClearNewCharacterDraftReady();
            Console.Printf(
                "[Caelum] Borrador inválido rechazado; se aplicará el perfil "
                "seguro de ejecución directa."
            );
            return false;
        }

        user.CharacterCreationComplete = true;
        user.CreationWizardOpen = false;
        user.CreationProfileBackup = null;
        user.CreationAllocationBackup = null;
        user.ApplyCharacterProfile();
        user.GrantStartingDevelopmentEquipment();
        user.ClearNewCharacterDraftReady();
        return true;
    }

    static void InitializeDirectMapCharacter(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.CharacterProfile.InitializeDefaultTestProfile();
        user.CharacterAllocation.ResetAllocations();
        for (int layer = 0; layer < CaelumConstants.ATTRIBUTE_LAYER_COUNT; layer++)
        {
            user.CharacterAllocation.LayerBonus[layer] = 1;
        }
        user.CharacterAllocation.AttributeBonus[0] = 3;
        user.CharacterAllocation.AttributeBonus[1] = 3;
        user.CharacterAllocation.AttributeBonus[2] = 2;
        user.CharacterAllocation.AttributeBonus[3] = 3;
        user.CharacterAllocation.AttributeBonus[4] = 3;
        user.CharacterAllocation.AttributeBonus[5] = 2;
        user.CharacterAllocation.AttributeBonus[6] = 3;
        user.CharacterAllocation.AttributeBonus[7] = 2;
        user.CharacterAllocation.AttributeBonus[8] = 2;
        user.CharacterAllocation.AttributeBonus[9] = 3;
        user.CharacterAllocation.AttributeBonus[10] = 2;
        user.CharacterAllocation.AttributeBonus[11] = 2;
        user.CharacterCreationComplete = true;
        user.CreationWizardOpen = false;
        user.ApplyCharacterProfile();
        user.GrantStartingDevelopmentEquipment();
        Console.Printf(
            "[Caelum] Inicio por comando directo: perfil de prueba seguro aplicado."
        );
    }

    static void EnsureCurrentAttributeBalance(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.AttributeBalanceVersion >= 3 || !user.CharacterCreationComplete
            || user.Attributes == null || user.DerivedStats == null) return;
        user.ApplyCharacterProfile();

    }

    static void ApplyCharacterProfile(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if (user.Attributes != null
            && user.CharacterProfile != null
            && user.CharacterAllocation != null
            && user.DerivedStats != null)
        {
            // La revisión 3 actualiza el coste guardado y el lanzamiento en curso
            // antes de pagarlo; conserva el tiempo, los recursos y el progreso.
            bool migrateBalance = user.AttributeBalanceVersion < 3;
            user.Attributes.InitializeFromCreation(user.CharacterProfile, user.CharacterAllocation);
            if (user.ArmorModel != null)
            {
                user.ArmorModel.ApplyAttributeBonuses(user.Attributes);
            }
            user.ApplyJewelryAttributeBonuses(user.Attributes);
            if (user.CharacterProfile.Race == CaelumConstants.RACE_DEBUG)
            {
                // La base del perfil rápido usa DEBUG_CREATION_ATTRIBUTE_LEVEL incluso con equipo.
                // La colección de Tarot se aplica después, como en las demás razas.
                user.Attributes.SetAllForDebug(
                    CaelumConstants.DEBUG_CREATION_ATTRIBUTE_LEVEL
                );
            }
            else if (user.DebugAttributesAt100)
            {
                user.Attributes.SetAllForDebug(CaelumConstants.DEBUG_ALL_ATTRIBUTES_LEVEL_100);
            }
            else if (user.DebugAttributesAt75)
            {
                // La base de prueba sustituye las bonificaciones del equipo;
                // el porcentaje del Tarot se calcula después.
                user.Attributes.SetAllForDebug(CaelumConstants.DEBUG_ALL_ATTRIBUTES_LEVEL_75);
            }
            let tarotRecord = user.GetPersistentCharacterState(false);
            user.Attributes.ApplyTarotMinorBonuses(tarotRecord);
            user.Attributes.ApplyTarotBonus(tarotRecord == null ? 0 : tarotRecord.GetTarotAttributeBonusPercent());
            user.RefreshCarriedInventorySummary();
            user.DerivedStats.Recalculate(user.Attributes, user.CharacterProfile);
            // La capacidad de la caja depende de Inteligencia. Una segunda
            // lectura aplica inmediatamente el nuevo divisor a su contenido;
            // el recálculo final actualiza masa, movimiento y aire con esa
            // carga corregida en el mismo tic.
            user.RefreshCarriedInventorySummary();
            user.DerivedStats.Recalculate(user.Attributes, user.CharacterProfile);
            if (migrateBalance)
            {
                if (user.StaffCastPending && user.WeaponModel != null)
                {
                    double tierFactor = user.PendingStaffWeaponTier >= 3 ? 2.5
                        : user.PendingStaffWeaponTier == 2 ? 1.6 : 1.0;
                    user.PendingStaffAnimaCost = user.WeaponModel.GetAnimaCostFor(user.PendingStaffWeaponType)
                        * tierFactor * user.DerivedStats.StaffAnimaCost / CaelumConstants.DEBUG_STAFF_ANIMA_COST
                        * (user.PendingStaffChargedAttack ? CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER : 1.0);
                }
            }
            user.AttributeBalanceVersion = 3;
            user.SyncHUDLoadState();
            // La masa nativa representa la masa total para que el motor y los
            // ataques externos respeten tambien el peso equipado del jugador.
            user.Mass = Max(1, int(user.DerivedStats.TotalMass + 0.5));
            // Radius es readonly en ZScript; A_SetSize actualiza ambas medidas
            // y vuelve a enlazar correctamente al jugador en el mundo.
            user.A_SetSize(
                user.DerivedStats.ActorRadius,
                user.DerivedStats.ActorHeight,
                false
            );
            user.UpdateLucidityAccuracyEffects();

            // Recalculation never grants free healing. Increasing the maximum
            // leaves current health unchanged; decreasing it only clamps an
            // amount that no longer fits under the new maximum.
            if (user.HealthResourceInitialized)
            {
                user.CaelumMaximumHealth = Max(1, int(user.DerivedStats.MaximumHealth));
                user.health = Min(user.health, user.CaelumMaximumHealth);

                if (user.player != null)
                {
                    user.player.health = user.health;
                }
            }

            // Profile changes never refill Anima for free; they only enforce a
            // newly reduced capacity, matching the health and air behavior.
            if (user.AnimaResourceInitialized)
            {
                user.CurrentAnima = Min(user.CurrentAnima, user.DerivedStats.MaximumAnima);
            }

            if (user.AdrenalineResourceInitialized)
            {
                user.CurrentAdrenaline = Min(
                    user.CurrentAdrenaline,
                    user.DerivedStats.MaximumAdrenaline
                );
            }

            // A profile change may lower maximum air. Never leave the current
            // resource above its newly calculated maximum.
            if (user.AirResourceInitialized)
            {
                user.CurrentAir = Min(user.CurrentAir, user.DerivedStats.MaximumAir);
            }
        }
    }

}
