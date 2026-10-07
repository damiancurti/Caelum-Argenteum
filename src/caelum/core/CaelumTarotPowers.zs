// La colección conserva la autoridad de propiedad. El cursor de ilustraciones
// del Diario sólo solicita una selección; nunca concede esencias ni poderes.
class CaelumTarotPowers : Object play
{
    const REVISION = 1;

    static void EnsureRevision(CaelumPersistentCharacterState record)
    { CaelumTarotService.EnsureRevision(record); }

    static bool ValidUser(CaelumPlayer user)
    { return CaelumTarotService.ValidUser(user); }

    static void Feedback(CaelumPlayer user, String key)
    { CaelumTarotService.Feedback(user, key); }

    static clearscope bool Implemented(int card)
    { return CaelumTarotService.Implemented(card); }

    static int SelectedCount(CaelumPersistentCharacterState record)
    { return CaelumTarotService.SelectedCount(record); }

    static bool Select(CaelumPlayer user, int card)
    { return CaelumTarotService.Select(user, card); }

    static bool Activate(CaelumPlayer user)
    { return CaelumTarotService.Activate(user); }

    // El tiempo personal también gobierna recargas/clases y los saltos de
    // descanso. Cargar o cambiar de mapa nunca reinicia estos contadores.
    static void Advance(CaelumPlayer user, int elapsedTics = 1)
    { CaelumTarotService.Advance(user, elapsedTics); }
}

// El motor proporciona los controles y flags nativos de vuelo. El registro
// personal fija la caducidad incluso en mapas con infinite_flight.
class CaelumTarotFlight : PowerFlight
{
    override void Tick()
    {
        let user = CaelumPlayer(Owner);
        let record = user == null ? null : user.GetPersistentCharacterState(false);
        if (!CaelumTarotService.IsActive(record, CaelumConstants.TAROT_THE_FOOL))
        { Destroy(); return; }
        EffectTics = CaelumTarotService.EffectTics(record) + 1;
        Super.Tick();
    }

    override TextureID GetPowerupIcon()
    { return TexMan.CheckForTexture(CaelumTarotArt.FrontPath(CaelumConstants.TAROT_THE_FOOL)); }
}
