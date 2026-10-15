// La colección conserva la autoridad de propiedad. El cursor de ilustraciones
// del Diario sólo solicita una selección; nunca concede esencias ni poderes.
class CaelumTarotPowers : Object play
{
    const REVISION = CaelumTarotService.REVISION;

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

// #251: PowerFlight comparte flags, pero su EndEffect no cuenta otras fuentes.
// Restaurar sólo flags previos evita repetir el impulso de InitEffect o pagar
// de nuevo. Cada fuente conserva su propio reloj y su política de viaje.
class CaelumFlightOwnership : Object play
{
    static void AfterEnd(Actor owner,Inventory ending,bool wasFlying,bool hadNoGravity,bool wasCentering)
    {
        if(owner==null || owner.health<=0 || owner.player==null)return;
        for(Inventory item=owner.Inv;item!=null;item=item.Inv)
        {
            let flight=PowerFlight(item);
            if(item==ending || flight==null || flight.EffectTics<=0)continue;
            owner.bFly=wasFlying;
            owner.bNoGravity=hadNoGravity;
            owner.player.centering=wasCentering;
            return;
        }
    }
}

// El motor proporciona los controles y flags nativos de vuelo. El registro
// personal fija la caducidad incluso en mapas con infinite_flight.
class CaelumTarotFlight : PowerFlight
{
    override void EndEffect()
    {
        Actor owner=Owner;
        bool wasFlying=owner!=null && owner.bFly;
        bool hadNoGravity=owner!=null && owner.bNoGravity;
        bool wasCentering=owner!=null && owner.player!=null && owner.player.centering;
        Super.EndEffect();
        CaelumFlightOwnership.AfterEnd(owner,self,wasFlying,hadNoGravity,wasCentering);
    }

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
