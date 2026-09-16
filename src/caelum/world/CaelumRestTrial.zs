// Oferta opcional desde Mundo; utiliza el menú USDF ya aprobado, sin pausa.
// Las ayudas de reservas requieren una elección explícita del autor/jugador.
class CaelumRestTrial : Object play
{
    static bool Open(CaelumPlayer user, CaelumRestFurniture furniture = null, CaelumSleepingBag bag = null)
    {
        if (CaelumRestState.IsActive(user)) return false;
        if (bag != null && (furniture != null || !bag.AvailableTo(user))) return false;
        if (furniture != null && !furniture.CanReach(user)) return false;
        String reason = CaelumRestState.BlockReason(user,furniture!=null && CaelumWorldCatalogue.IsLimboMap(level.MapName));
        if (reason.Length() != 0 && reason != "CA_REST_NEEDS")
        {
            if (user != null) user.A_Print(StringTable.Localize(reason, false));
            return false;
        }
        let it = ThinkerIterator.Create("CaelumRestGuide");
        CaelumRestGuide old;
        while ((old = CaelumRestGuide(it.Next())) != null)
            if (old.Subject == user) return false;
        let guide = CaelumRestGuide(Actor.Spawn("CaelumRestGuide", user.Pos + (0,0,user.Height*0.5), NO_REPLACE));
        if (guide == null) return false;
        guide.Subject = user;
        guide.OriginMap = level.MapName;
        guide.Furniture = furniture;
        guide.UsesFurniture = furniture != null;
        guide.Bag = bag;
        guide.UsesBag = bag != null;
        int conversation = furniture == null ? 43510
            : furniture.RestMode() == CaelumRestRules.MODE_SLEEP ? 43512 : 43511;
        if (bag != null) conversation = 43513;
        if (furniture!=null && CaelumWorldCatalogue.IsLimboMap(level.MapName))
            conversation=furniture.RestMode()==CaelumRestRules.MODE_SLEEP?43516:43515;
        if (CaelumFactionCondition.OpenDialogue(user, guide, conversation, null, SF_IGNOREVISIBILITY)) return true;
        guide.Destroy();
        return false;
    }

    static void Prepare(CaelumPlayer user, int preset)
    {
        if (preset == 3) { CaelumSleepingBag.PrepareTrial(user); return; }
        if (preset != 1 && preset != 2) return;
        String reason = CaelumRestState.BlockReason(user);
        if (CaelumRestState.IsActive(user) || (reason.Length() != 0 && reason != "CA_REST_NEEDS")) return;
        user.CurrentHunger = CaelumConstants.SURVIVAL_MAXIMUM;
        user.CurrentThirst = CaelumConstants.SURVIVAL_MAXIMUM;
        user.CurrentSleep = preset == 2 ? 5.0 : 50.0;
        user.UpdateSurvivalStates();
        user.PersistCharacterState();
        user.A_Print(StringTable.Localize(preset == 2 ? "CA_REST_PREPARED_LOW" : "CA_REST_PREPARED", false));
    }

    static void DebugHit(CaelumPlayer user)
    {
        // Impacto nativo voluntario para probar interrupción en mapas vacíos.
        // No llama directamente a Finish: debe recorrer la ruta real de daño.
        if (user == null || user.health <= 1 || !CaelumRestState.IsActive(user)) return;
        int previousKind = user.LastImpactKind;
        user.LastImpactKind = CaelumConstants.IMPACT_KIND_FLOOR;
        user.DamageMobj(user, user, 1, 'CaelumImpact', DMG_NO_ARMOR, 0.0);
        user.LastImpactKind = previousKind;
    }
}

class CaelumRestGuide : Actor
{
    CaelumPlayer Subject;
    String OriginMap;
    int QueuedMode;
    int QueuedMinutes;
    int QueuedPreparation;
    CaelumRestFurniture Furniture;
    bool UsesFurniture;
    CaelumSleepingBag Bag;
    bool UsesBag;

    override void Tick()
    {
        Super.Tick();
        if (Subject == null || Subject.health <= 0 || OriginMap != level.MapName)
        { Destroy(); return; }
        if (bInConversation || Subject.HasActiveConversation()) return;
        int mode = QueuedMode;
        int minutes = QueuedMinutes;
        int preparation = QueuedPreparation;
        QueuedMode = 0;
        QueuedMinutes = 0;
        QueuedPreparation = 0;
        // La elección se resuelve después de cerrar USDF y valida otra vez.
        // Volver o cancelar deja los tres campos a cero.
        if (mode != 0)
        {
            if (UsesBag)
            {
                if (Bag == null || !Bag.AvailableTo(Subject))
                    Subject.A_Print(StringTable.Localize("CA_SLEEPING_BAG_UNAVAILABLE", false));
                else Bag.BeginRest(Subject, minutes);
            }
            else if (UsesFurniture && (Furniture == null || !Furniture.CanReach(Subject)))
                Subject.A_Print(StringTable.Localize("CA_REST_FURNITURE_UNAVAILABLE", false));
            else CaelumRestState.Begin(Subject, mode, minutes, Furniture);
        }
        else if (preparation != 0) CaelumRestTrial.Prepare(Subject, preparation);
        Destroy();
    }

    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +INVULNERABLE +NOTARGET RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumRestAction : CaelumPalomoDialogueAction abstract
{
    virtual int Mode() { return 0; }
    virtual int Minutes() { return 0; }
    virtual int Preparation() { return 0; }
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)) return false;
        let guide = CaelumRestGuide(user.player.ConversationNPC);
        if (guide == null || guide.Subject != user || !guide.bInConversation
            || user.player.ConversationPC != user || guide.OriginMap != level.MapName
            || guide.QueuedMode != 0 || guide.QueuedPreparation != 0) return false;
        int mode = Mode();
        int minutes = Minutes();
        int preparation = Preparation();
        if (preparation != 0)
        {
            if (guide.UsesFurniture || guide.UsesBag || mode != 0 || minutes != 0 || (preparation != 1 && preparation != 2 && preparation != 3)) return false;
            guide.QueuedPreparation = preparation;
        }
        else
        {
            if ((mode != CaelumRestRules.MODE_SLEEP && mode != CaelumRestRules.MODE_WAIT)
                || (CaelumRestRules.DurationTics(minutes) == 0
                    && !(minutes==0 && guide.Furniture!=null && CaelumWorldCatalogue.IsLimboMap(level.MapName)))) return false;
            if (guide.UsesFurniture && (guide.Furniture == null || guide.Furniture.RestMode() != mode)) return false;
            if (guide.UsesBag && (guide.Bag == null || mode != CaelumRestRules.MODE_SLEEP)) return false;
            guide.QueuedMode = mode;
            guide.QueuedMinutes = minutes;
        }
        return true;
    }
}

class CaelumRestSleepAction : CaelumRestAction abstract { override int Mode() { return CaelumRestRules.MODE_SLEEP; } }
class CaelumRestWaitAction : CaelumRestAction abstract { override int Mode() { return CaelumRestRules.MODE_WAIT; } }
class CaelumRestSleep5Action : CaelumRestSleepAction { override int Minutes() { return 5; } }
class CaelumRestSleep60Action : CaelumRestSleepAction { override int Minutes() { return 60; } }
class CaelumRestSleep240Action : CaelumRestSleepAction { override int Minutes() { return 240; } }
class CaelumRestSleep480Action : CaelumRestSleepAction { override int Minutes() { return 480; } }
class CaelumRestWait5Action : CaelumRestWaitAction { override int Minutes() { return 5; } }
class CaelumRestWait60Action : CaelumRestWaitAction { override int Minutes() { return 60; } }
class CaelumRestWait240Action : CaelumRestWaitAction { override int Minutes() { return 240; } }
class CaelumRestWait480Action : CaelumRestWaitAction { override int Minutes() { return 480; } }
class CaelumRestPrepareAction : CaelumRestAction { override int Preparation() { return 1; } }
class CaelumRestPrepareLowAction : CaelumRestAction { override int Preparation() { return 2; } }

class CaelumRestPrepareBagAction : CaelumRestAction { override int Preparation() { return 3; } }

class CaelumRestSitUntimedAction : CaelumRestWaitAction {}
class CaelumRestSleepUntimedAction : CaelumRestSleepAction {}
