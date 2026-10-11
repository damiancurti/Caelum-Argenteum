// #147: el registro viajero posee el perfil y la asignación. Los campos del
// cuerpo son referencias al mismo objeto, no otra identidad independiente.
class CaelumCharacterIdentity : Object play
{
    const REVISION = 1;

    static clearscope CaelumCharacterProfile Profile(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanRead(user)) return null;
        let record = CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if (record != null && record.IdentityProfile != null) return record.IdentityProfile;
        return user.CharacterProfile;
    }

    static clearscope int VoiceSex(CaelumPlayer user)
    {
        let profile = Profile(user);
        return profile != null ? profile.Sex : CaelumConstants.SEX_MALE;
    }

    static void Bind(CaelumPlayer user, CaelumPersistentCharacterState record, bool liveProfile)
    {
        if (!CaelumPlayerAuthority.OwnsRecord(user, record)) return;
        if (record.IdentityRevision < REVISION)
        {
            if (liveProfile && user.CharacterProfile != null && user.CharacterAllocation != null)
            {
                // Un save nativo conserva el último perfil del cuerpo incluso
                // si no hubo un viaje que actualizara los campos planos antiguos.
                record.IdentityProfile = user.CharacterProfile;
                record.IdentityAllocation = user.CharacterAllocation;
            }
            else
            {
                record.IdentityProfile = new("CaelumCharacterProfile");
                record.IdentityAllocation = new("CaelumCharacterAllocation");
                record.IdentityProfile.Race = record.Race;
                record.IdentityProfile.FirstClass = record.FirstClass;
                record.IdentityProfile.SecondClass = record.SecondClass;
                record.IdentityProfile.Sex = record.Sex;
                record.IdentityProfile.HeightChoice = record.HeightChoice;
                for (int i = 0; i < CaelumConstants.ATTRIBUTE_LAYER_COUNT; i++)
                    record.IdentityAllocation.LayerBonus[i] = record.LayerBonus[i];
                for (int i = 0; i < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; i++)
                    record.IdentityAllocation.AttributeBonus[i] = record.AttributeBonus[i];
            }
            record.IdentityRevision = REVISION;
        }
        user.CharacterProfile = record.IdentityProfile;
        user.CharacterAllocation = record.IdentityAllocation;
        // La apariencia mundial existente es propia; una skin global de Doom
        // no sustituye el cuerpo ni su banco sonoro. #148 ampliará los recursos.
        user.bNoSkin = true;
    }

    static void Ensure(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete) return;
        let record = user.GetPersistentCharacterState(false);
        if (record != null && record.ProfileCommitted) Bind(user, record, true);
    }
}
