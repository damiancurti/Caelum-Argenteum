// Servicio opcional de diagnóstico. La oferta deriva de las conexiones
// existentes; no introduce horarios, precios ni vehículos de campaña.
class CaelumCaravanTrial : Object play
{
    static int FirstRoute()
    {
        int location = CaelumWorldCatalogue.LocationForMap(level.MapName);
        int first = 0;
        for (int id = 2; id < CaelumWorldCatalogue.CONNECTION_DEFINED_COUNT; id++)
            if (CaelumWorldCatalogue.IsSewerConnection(id)
                && CaelumWorldCatalogue.ConnectionOrigin(id) == location) { first = id; break; }
        return first;
    }

    static bool Open(CaelumPlayer user)
    {
        int location = CaelumWorldCatalogue.LocationForMap(level.MapName);
        int first = FirstRoute();
        if (first == 0 || !CaelumTravelService.CanDepart(user, first)) return false;
        let it = ThinkerIterator.Create("CaelumCaravanGuide");
        CaelumCaravanGuide old;
        while ((old = CaelumCaravanGuide(it.Next())) != null)
            if (old.Subject == user) return false;
        let guide = CaelumCaravanGuide(Actor.Spawn("CaelumCaravanGuide", user.Pos + (0,0,user.Height*0.5), NO_REPLACE));
        if (guide == null) return false;
        guide.Subject = user; guide.OriginMap = level.MapName;
        if (CaelumFactionCondition.OpenDialogue(user, guide, 43408 + location, null, SF_IGNOREVISIBILITY)) return true;
        guide.Destroy();
        return false;
    }
}

class CaelumCaravanGuide : Actor
{
    CaelumPlayer Subject;
    String OriginMap;
    int QueuedConnection;
    int QueuedPreparation;

    override void Tick()
    {
        Super.Tick();
        if (Subject == null || Subject.health <= 0 || OriginMap != level.MapName)
        { Destroy(); return; }
        if (bInConversation || Subject.HasActiveConversation()) return;
        // USDF termina antes de ChangeLevel, evitando arrastrar una sesión
        // activa al destino. Cancelar no pone una conexión en la cola.
        int requested = QueuedConnection; QueuedConnection = 0;
        int preparation = QueuedPreparation; QueuedPreparation = 0;
        if (requested != 0) CaelumTravelService.Begin(Subject, requested, CaelumJourneyState.MODE_CARAVAN);
        else if (preparation != 0) CaelumSewerTrialSupport.Prepare(Subject, preparation);
        Destroy();
    }
    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +INVULNERABLE +NOTARGET RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumCaravanAction : CaelumPalomoDialogueAction abstract
{
    virtual int Route() { return 0; }
    virtual int Preparation() { return 0; }
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING)) return false;
        let guide = CaelumCaravanGuide(user.player.ConversationNPC);
        int id = Route();
        int preparation = Preparation();
        if (guide == null || guide.Subject != user || !guide.bInConversation
            || user.player.ConversationPC != user || guide.OriginMap != level.MapName
            || guide.QueuedConnection != 0 || guide.QueuedPreparation != 0) return false;
        if (preparation != 0)
        {
            if (id != 0 || !CaelumSewerTrialSupport.IsTrialMap()
                || (preparation != CaelumSewerTrialSupport.PREPARE_SEAL
                    && preparation != CaelumSewerTrialSupport.PREPARE_CRAFT)) return false;
            guide.QueuedPreparation = preparation;
        }
        else
        {
            if (!CaelumWorldCatalogue.IsSewerConnection(id)
                || CaelumWorldCatalogue.ConnectionOrigin(id) != CaelumWorldCatalogue.LocationForMap(level.MapName)) return false;
            guide.QueuedConnection = id;
        }
        return true;
    }
}
class CaelumCaravanRoute2Action : CaelumCaravanAction { override int Route() { return 2; } }
class CaelumCaravanRoute3Action : CaelumCaravanAction { override int Route() { return 3; } }
class CaelumCaravanRoute4Action : CaelumCaravanAction { override int Route() { return 4; } }
class CaelumCaravanRoute5Action : CaelumCaravanAction { override int Route() { return 5; } }
class CaelumCaravanRoute6Action : CaelumCaravanAction { override int Route() { return 6; } }
class CaelumCaravanRoute7Action : CaelumCaravanAction { override int Route() { return 7; } }
class CaelumSewerPrepareSealAction : CaelumCaravanAction
{
    override int Preparation() { return CaelumSewerTrialSupport.PREPARE_SEAL; }
}
class CaelumSewerPrepareCraftAction : CaelumCaravanAction
{
    override int Preparation() { return CaelumSewerTrialSupport.PREPARE_CRAFT; }
}
