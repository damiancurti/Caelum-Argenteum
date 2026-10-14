// Hechos personales guardados por el Inventory viajero, nunca por el HUD.
class CaelumKnownPoi : Object play
{
    String MapId, PoiId, NameKey;
    int Category, ObservedAccess;
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
        // Revisiones 0/1: no inferir visitas ni estados de acceso. El nuevo
        // ObservedAccess vale cero (desconocido) y conserva todos los hechos.
        record.LocalKnowledgeRevision=CaelumPoiData.REVISION;
    }
    static bool RecordUse(CaelumPlayer user,Actor subject,int category)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0
            || user.player.playerstate!=PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || subject==null)return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.ProfileCommitted)return false;
        CaelumAuthoredCartography.BindSubject(subject,category);
        let it=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration entry;
        while((entry=CaelumPoiRegistration(it.Next()))!=null)
        {
            if(entry.Subject!=subject || entry.Category!=category)continue;
            Record(user,entry.PoiId,category,entry.NameKey,subject.Pos,
                CaelumAuthoredCartography.ObservedAccess(subject));
            return true;
        }
        return false;
    }
    // Sólo los sucesos de uso o entrada autorizados llaman a este registro.
    static bool Record(CaelumPlayer user,String id,int category,String nameKey,Vector3 position,int access=0)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0
            || user.player.playerstate!=PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || id.Length()==0 || nameKey.Length()==0
            || !CaelumPoiData.ValidCategory(category))return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.ProfileCommitted)return false;
        Ensure(record);
        let fact=Find(record,level.MapName,id);
        if(fact==null)
        {
            fact=new("CaelumKnownPoi");fact.MapId=level.MapName;fact.PoiId=id;
            record.KnownPois.Push(fact);
        }
        if(fact.NameKey!=nameKey || fact.Category!=category || fact.ObservedPosition!=position
            || fact.ObservedAccess!=access)
        {
            fact.NameKey=nameKey;fact.Category=category;fact.ObservedPosition=position;
            fact.ObservedAccess=access;record.LocalKnowledgeSerial++;
        }
        return true;
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
    transient CaelumPersistentCharacterState CachedRecord;
    transient CaelumKnownPoi CachedFact;
    transient int CachedSerial;
    override void Tick()
    {
        Super.Tick();bDormant=true;
        let user=CaelumPoiKnowledge.MarkerUser();if(user==null)return;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if(record==null)return;
        if(CachedRecord!=record || CachedFact==null || CachedSerial!=record.LocalKnowledgeSerial)
        {
            CachedRecord=record;CachedSerial=record.LocalKnowledgeSerial;
            CachedFact=CaelumPoiKnowledge.Find(record,level.MapName,PoiId);
        }
        let fact=CachedFact;if(fact==null)return;
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
