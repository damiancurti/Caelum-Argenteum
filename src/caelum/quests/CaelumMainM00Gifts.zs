// Regalos únicos de #164. Los identificadores persisten aunque la pieza se venda,
// se gaste o se pierda; migrar nunca reconstruye una instancia ya entregada.
class CaelumMainM00Gifts : Object play
{
    const REVISION = 1;

    static bool EnsureTool(CaelumPlayer user, bool bolas)
    {
        if (user == null || !user.CharacterCreationComplete || user.health <= 0
            || user.WeaponModel == null) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(bolas ? CaelumConstants.MAIN_M00_FLAG_RULO_STARTED
            : CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED)) return false;
        if ((bolas ? r.MainM00BolasId : r.MainM00UtilityStaffId) > 0) return true;
        int type = bolas ? CaelumConstants.WEAPON_TYPE_BOLAS : CaelumConstants.WEAPON_TYPE_UTILITY_STAFF;
        int size = CaelumEquipmentRules.ResolveAcquisitionSize(user,
            CaelumEquipmentRules.CHARACTER_DEFAULT, user.WeaponModel.Size);
        double weight = user.WeaponModel.GetWeightFor(type, 1, size);
        bool box = !user.CanAddWeightToPersonalInventory(weight);
        if (box && (!user.HasNativeMagicBoxSlotAvailable() || !user.CanAddRawWeightToMagicBox(weight)))
            return false;
        let item = CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup", user.Pos, NO_REPLACE));
        if (item == null) return false;
        item.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        item.ItemType = type; item.Tier = 1; item.ArmorSlot = -1;
        item.EquipmentSize = size; item.SizePolicy = CaelumEquipmentRules.CHARACTER_DEFAULT;
        item.EssenceType = CaelumConstants.ESSENCE_FIRE;
        item.UnitWeight = weight;
        item.Durability = user.WeaponModel.GetMaximumDurabilityFor(type, 1, size);
        item.WeaponDurabilityRevision = CaelumAttackRules.DURABILITY_REVISION;
        item.PickupDataInitialized = true; item.AcquisitionResolved = true;
        item.InMagicBox = box; item.AttachToOwner(user); user.EnsureEquipmentItemId(item);
        if (bolas) r.MainM00BolasId = item.ItemId;
        else r.MainM00UtilityStaffId = item.ItemId;
        CaelumNotifications.Acquired(user, item, 1);
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
        return true;
    }

    static void Update(CaelumPlayer user)
    {
        if (user == null || !user.CharacterCreationComplete || user.health <= 0) return;
        let r = user.GetPersistentCharacterState(false);
        if (r == null) return;
        if (r.MainM00GiftsRevision < REVISION)
        {
            CaelumMainM00Loadout.EnsureMigration(user);
            r.RefreshMainM00MagicObjective();
            r.MainM00GiftsRevision = REVISION;
        }
        // Reintenta sólo regalos aún no entregados si faltaba capacidad. No
        // retrocede la misión ni exige repetir conversaciones ya terminadas.
        if (level.time % TICRATE != 0) return;
        if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED))
            CaelumTarotDeckRules.Grant(user, false);
        EnsureTool(user, false); EnsureTool(user, true);
    }
}
