// Hechos personales guardados por el Inventory viajero, nunca por el HUD.
class CaelumKnownPoi : Object play
{
    String MapId, PoiId, NameKey;
    int Category;
    Vector3 ObservedPosition;
}

// Enlace explícito de datos del mapa a un objeto existente. Registrar no revela.
// #234 aporta los enlaces de los mapas reales; no se deducen por proximidad.
class CaelumPoiRegistration : Thinker
{
    String PoiId, NameKey;
    int Category;
    Actor Subject;

    static CaelumPoiRegistration Bind(Actor subject,String id,int category,String nameKey)
    {
        if(subject==null || id.Length()==0 || nameKey.Length()==0 || !CaelumPoiData.ValidCategory(category))return null;
        let it=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration entry;
        while((entry=CaelumPoiRegistration(it.Next()))!=null)
        {
            if(entry.PoiId==id)
            {
                // Un ID conflictivo falla cerrado; recrear el mismo objeto
                // ausente conserva su ID, sin dar conocimiento al personaje.
                if(entry.Category!=category || entry.NameKey!=nameKey
                    || (entry.Subject!=null && entry.Subject!=subject))return null;
                entry.Subject=subject;return entry;
            }
            if(entry.Subject==subject)return null;
        }
        entry=new("CaelumPoiRegistration");entry.PoiId=id;entry.Category=category;
        entry.NameKey=nameKey;entry.Subject=subject;return entry;
    }
}

class CaelumPoiKnowledge : Object play
{
    static clearscope CaelumKnownPoi Find(CaelumPersistentCharacterState record,String mapId,String id)
    {
        if(record==null || mapId.Length()==0 || id.Length()==0)return null;
        for(int i=0;i<record.KnownPois.Size();i++)
        {
            let fact=record.KnownPois[i];
            if(fact!=null && fact.MapId==mapId && fact.PoiId==id)return fact;
        }
        return null;
    }
    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record==null || record.LocalKnowledgeRevision>=CaelumPoiData.REVISION)return;
        // Revisión cero: ausencia de prueba significa desconocido. No inferir
        // objetos a partir de mapas visitados, rutas ni etapas de misión.
        record.LocalKnowledgeRevision=CaelumPoiData.REVISION;
    }
    static bool RecordUse(CaelumPlayer user,Actor subject,int category)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0
            || user.player.playerstate!=PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || subject==null)return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.ProfileCommitted)return false;
        let it=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration entry;
        while((entry=CaelumPoiRegistration(it.Next()))!=null)
        {
            if(entry.Subject!=subject || entry.Category!=category)continue;
            Ensure(record);
            let fact=Find(record,level.MapName,entry.PoiId);
            if(fact==null)
            {
                fact=new("CaelumKnownPoi");fact.MapId=level.MapName;fact.PoiId=entry.PoiId;
                record.KnownPois.Push(fact);
            }
            if(fact.NameKey!=entry.NameKey || fact.Category!=category || fact.ObservedPosition!=subject.Pos)
            {
                fact.NameKey=entry.NameKey;fact.Category=category;fact.ObservedPosition=subject.Pos;
                record.LocalKnowledgeSerial++;
            }
            return true;
        }
        return false;
    }
    // Los MapMarker nativos ignoran dueño y filtros de jugador. Nunca se
    // muestran en multijugador; los hechos personales sí permanecen separados.
    static clearscope CaelumPlayer MarkerUser()
    {
        if(multiplayer)return null;
        CaelumPlayer user;int count=0;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i]){count++;user=CaelumPlayer(players[i].mo);}
        return count==1 && CaelumPlayerAuthority.CanRead(user)?user:null;
    }
    static void PrepareMarkers(CaelumPlayer user,CaelumPersistentCharacterState record)
    {
        if(MarkerUser()!=user)return;
        if(record.LocalMarkerMap==level.MapName && record.LocalMarkerSerial==record.LocalKnowledgeSerial)return;
        record.LocalMarkerMap=level.MapName;record.LocalMarkerSerial=record.LocalKnowledgeSerial;
        for(int i=0;i<record.KnownPois.Size();i++)
        {
            let fact=record.KnownPois[i];
            if(fact==null || fact.MapId!=level.MapName)continue;
            bool found=false;let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker marker;
            while((marker=CaelumKnownPoiMarker(it.Next()))!=null)
                if(marker.PoiId==fact.PoiId){found=true;break;}
            if(found)continue;
            marker=CaelumKnownPoiMarker(Actor.Spawn("CaelumKnownPoiMarker",fact.ObservedPosition,NO_REPLACE));
            if(marker!=null)marker.PoiId=fact.PoiId;
        }
    }
}

// Sólo una proyección desechable: jamás consulta objetos ocultos ni registra
// hechos. Si cambia el personaje, consulta de nuevo su propio Inventory.
class CaelumKnownPoiMarker : MapMarker
{
    String PoiId;
    override void Tick()
    {
        Super.Tick();bDormant=true;
        let user=CaelumPoiKnowledge.MarkerUser();if(user==null)return;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let fact=CaelumPoiKnowledge.Find(record,level.MapName,PoiId);if(fact==null)return;
        picnum=TexMan.CheckForTexture(CaelumPoiData.IconPath(fact.Category),TexMan.Type_Any);
        Vector2 size=TexMan.GetScaledSize(picnum);
        if(size.X<=0 || size.Y<=0)return;
        Scale=(CaelumPoiData.ICON_SIZE/size.X,CaelumPoiData.ICON_SIZE/size.Y);
        if(Pos!=fact.ObservedPosition)SetOrigin(fact.ObservedPosition,false);
        bDormant=false;
    }
    Default { +DORMANT }
    States { Spawn: TNT1 A -1; Stop; }
}
