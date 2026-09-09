// Marcadores invisibles consultados por el sistema USDF nativo. Reflejan el
// registro del personaje y sólo existen como puente con las condiciones del
// diálogo; nunca son la fuente autoritativa del progreso.
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

class CaelumMagicBoxOwnershipToken : CaelumPalomoDialogueMarker {}
class CaelumPalomoDiscountGrantedToken : CaelumPalomoDialogueMarker {}
class CaelumPalomoEloquenceEligibleToken : CaelumPalomoDialogueMarker {}
class CaelumMainM00PalomoMetToken : CaelumPalomoDialogueMarker {}
class CaelumMainM00AskedPalomoWhereToken : CaelumPalomoDialogueMarker {}
class CaelumMainM00AskedPalomoWhatHappenedToken : CaelumPalomoDialogueMarker {}
class CaelumMainM00NoticedMemoryGapToken : CaelumPalomoDialogueMarker {}
class CaelumMainM00ToldPalomoAboutVoiceToken : CaelumPalomoDialogueMarker {}

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

// Compatibilidad de infraestructura: estas tres acciones conservan el comercio
// aislado para mapas de depuración, pero CAPALOMO ya no las ofrece en la historia.
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

class CaelumMainM00AskPalomoWhereAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.RecordMainM00PalomoDialogueFlag(
            CaelumConstants.MAIN_M00_FLAG_ASKED_PALOMO_WHERE
        );
        return true;
    }
}

class CaelumMainM00AskPalomoWhatHappenedAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.RecordMainM00PalomoDialogueFlag(
            CaelumConstants.MAIN_M00_FLAG_ASKED_PALOMO_WHAT_HAPPENED
        );
        return true;
    }
}

class CaelumMainM00TellPalomoMemoryGapAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.RecordMainM00PalomoDialogueFlag(
            CaelumConstants.MAIN_M00_FLAG_NOTICED_MEMORY_GAP
        );
        return true;
    }
}

class CaelumMainM00TellPalomoAboutVoiceAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.RecordMainM00PalomoDialogueFlag(
            CaelumConstants.MAIN_M00_FLAG_TOLD_PALOMO_ABOUT_VOICE
        );
        return true;
    }
}

class CaelumMainM00FinishPalomoFoyerAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.RecordMainM00PalomoMet();
        return true;
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

// Hablante técnico sin representación visual. Permite que la apertura utilice
// el ConversationMenu nativo sin convertir la Voz en un actor físico del mapa.
class CaelumUnknownVoiceSpeaker : Actor
{
    bool ConversationOpened;
    int CleanupGraceTics;

    void MarkConversationOpened()
    {
        ConversationOpened = true;
        CleanupGraceTics = 2;
    }

    override void Tick()
    {
        Super.Tick();
        if (!ConversationOpened) { return; }
        if (CleanupGraceTics > 0)
        {
            CleanupGraceTics--;
            return;
        }
        if (bInConversation) { return; }
        if (HasConversation())
        {
            Level.ExecuteSpecial(
                CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                self, null, false, 0, 0
            );
        }
        Destroy();
    }

    Default
    {
        Radius 1;
        Height 1;
        RenderStyle "None";
        +NOBLOCKMAP
        +NOGRAVITY
        +INVULNERABLE
        +NOTARGET
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

// Conserva el flujo y los controles del ConversationMenu de GZDoom. La rama de
// formato comercial queda disponible para pruebas aisladas; Q funciona como
// cierre equivalente a Atrás en todos los diálogos narrativos del archivo.
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
