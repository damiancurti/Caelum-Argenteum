// Marcadores invisibles consultados por el sistema USDF nativo. Los dos
// persistentes reflejan el registro del personaje; el de Elocuencia se
// recalcula antes de cada conversación.
class CaelumPalomoDialogueMarker : Inventory abstract
{
    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
        -INVENTORY.INVBAR
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

// Además de controlar el salto USDF, este comprobante viaja con Actor.Inv y
// permite reconstruir la propiedad si un cambio de mapa restaura primero una
// instantánea incompleta. La Caja nunca puede revocarse una vez recibida.
class CaelumMagicBoxOwnershipToken : CaelumPalomoDialogueMarker
{
    Default
    {
        +INVENTORY.UNTOSSABLE
    }
}
class CaelumPalomoDiscountGrantedToken : CaelumPalomoDialogueMarker {}
class CaelumPalomoEloquenceEligibleToken : CaelumPalomoDialogueMarker {}

// GiveItem de USDF activa estos objetos durante un único TryPickup. Al tener
// MaxAmount 0 nunca quedan como acciones repetibles en el inventario.
class CaelumPalomoDialogueAction : Inventory abstract
{
    Default
    {
        Inventory.MaxAmount 0;
        +INVENTORY.AUTOACTIVATE
        -INVENTORY.INVBAR
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumPalomoAcceptAdventureAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.GrantMagicBoxFromPalomo(false);
        return caelumPlayer.MagicBoxOwned;
    }
}

class CaelumPalomoTradeAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null || caelumPlayer.player == null)
        {
            return false;
        }
        Actor merchant = caelumPlayer.player.ConversationNPC;
        if (merchant == null) { return false; }
        caelumPlayer.OpenPalomoMerchant(merchant);
        return true;
    }
}

class CaelumPalomoDiscountAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.ResolvePalomoDiscountRequest();
        // La página siguiente determina éxito o fracaso comprobando el
        // marcador otorgado; ambos resultados consumen correctamente la acción.
        return true;
    }
}

// Conserva el flujo y los controles del ConversationMenu de GZDoom. Sólo
// sustituye el marcador del porcentaje en la confirmación y añade Q como
// cierre equivalente a Atrás para mantener la convención del proyecto.
class CaelumPalomoConversationMenu : ConversationMenu
{
    override void FormatSpeakerMessage()
    {
        if (!(mCurNode.UserData ~== "palomo_discount_confirm"))
        {
            Super.FormatSpeakerMessage();
            return;
        }

        String toSay = StringTable.Localize(mCurNode.Dialogue);
        CaelumPlayer caelumPlayer = mPlayer == null
            ? null : CaelumPlayer(mPlayer.mo);
        String chanceText = "0%";
        if (caelumPlayer != null)
        {
            chanceText = String.Format(
                "%d", caelumPlayer.PalomoDiscountChancePercent
            ) .. "%";
            if (caelumPlayer.PalomoDiscountAutomaticSuccess)
            {
                chanceText = chanceText .. " (" .. StringTable.Localize(
                    "CA_PALOMO_DIALOGUE_AUTOMATIC_SUCCESS", false
                ) .. ")";
            }
        }
        toSay.Replace("%CHANCE%", chanceText);
        if (toSay.Length() == 0) { toSay = "."; }
        mDialogueLines = displayFont.BreakLines(toSay, SpeechWidth);
    }

    override bool OnUIEvent(UIEvent ev)
    {
        if (ev.type == UIEvent.Type_Char
            && (ev.KeyChar == 113 || ev.KeyChar == 81))
        {
            return MenuEvent(MKEY_Back, false);
        }
        return Super.OnUIEvent(ev);
    }
}
