// Memoria escrita por el jugador, independiente de los hechos descubiertos.
class CaelumMapNote : Object play
{
    int Id,Category;
    String MapId,Text;
    Vector3 Position;
}

class CaelumMapNotes : Object play
{
    static clearscope CaelumMapNote Find(CaelumPersistentCharacterState record,String mapId,int id)
    {
        if(record==null || id<=0)return null;
        for(int i=0;i<record.ManualNotes.Size();i++)
        {
            let note=record.ManualNotes[i];
            if(note!=null && note.Id==id && note.MapId==mapId)return note;
        }
        return null;
    }
    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record==null || record.ManualNotesRevision>=CaelumMapNoteData.REVISION)return;
        // El guardado anterior no prueba ninguna nota; no importar marcas
        // numeradas nativas, visitas, categorías ni progreso de misiones.
        record.ManualNotesRevision=CaelumMapNoteData.REVISION;
        record.ManualNoteNextId=1;
    }
    static clearscope bool Available(CaelumPlayer user)
    {
        return CaelumPlayerAuthority.CanRead(user) && user.health>0
            && user.player.playerstate==PST_LIVE && user.CharacterCreationComplete
            && !user.CreationWizardOpen && !CaelumExhaustion.Active(user);
    }
    static bool Apply(CaelumPlayer user,int operation,int expected,String mapId,int id,
        int category,Vector3 position,String text)
    {
        if(!Available(user) || !CaelumPlayerAuthority.CanMutate(user) || mapId!=level.MapName)return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || !record.ProfileCommitted)return false;
        Ensure(record);
        // Identidad y revisión evitan dobles pulsaciones y ediciones tardías
        // dirigidas a una fila distinta después de borrar/cambiar de mapa.
        if(record.ManualNotesSerial!=expected)return false;
        if(operation==CaelumMapNoteData.REMOVE)
        {
            let note=Find(record,mapId,id);if(note==null)return false;
            for(int i=0;i<record.ManualNotes.Size();i++)if(record.ManualNotes[i]==note)
            {
                record.ManualNotes.Delete(i);record.ManualNotesSerial++;
                if(CaelumPoiKnowledge.MarkerUser()==user)
                {
                    let it=ThinkerIterator.Create("CaelumMapNoteMarker");CaelumMapNoteMarker marker;
                    while((marker=CaelumMapNoteMarker(it.Next()))!=null)if(marker.NoteId==id)marker.Destroy();
                }
                return true;
            }
            return false;
        }
        if(!CaelumMapNoteData.ValidCategory(category) || text.Length()==0
            || !CaelumMapNoteData.FitsRequest(mapId,text))return false;
        let note=Find(record,mapId,id);
        if(operation==CaelumMapNoteData.CREATE)
        {
            if(id!=0 || record.ManualNoteNextId<=0 || record.ManualNoteNextId==0x7fffffff)return false;
            // Rechaza NaN e infinitos, sin imponer límites de coordenadas.
            if(position.X-position.X!=0 || position.Y-position.Y!=0 || position.Z-position.Z!=0)return false;
            note=new("CaelumMapNote");note.Id=record.ManualNoteNextId++;
            note.MapId=mapId;note.Position=position;record.ManualNotes.Push(note);
        }
        else if(operation!=CaelumMapNoteData.EDIT || note==null)return false;
        note.Category=category;note.Text=text;record.ManualNotesSerial++;
        return true;
    }
    static void PrepareMarkers(CaelumPlayer user,CaelumPersistentCharacterState record)
    {
        Ensure(record);
        if(CaelumPoiKnowledge.MarkerUser()!=user)return;
        if(record.ManualMarkerMap==level.MapName && record.ManualMarkerSerial==record.ManualNotesSerial)return;
        record.ManualMarkerMap=level.MapName;record.ManualMarkerSerial=record.ManualNotesSerial;
        for(int i=0;i<record.ManualNotes.Size();i++)
        {
            let note=record.ManualNotes[i];if(note==null || note.MapId!=level.MapName)continue;
            bool found=false;let it=ThinkerIterator.Create("CaelumMapNoteMarker");CaelumMapNoteMarker marker;
            while((marker=CaelumMapNoteMarker(it.Next()))!=null)if(marker.NoteId==note.Id){found=true;break;}
            if(found)continue;
            marker=CaelumMapNoteMarker(Actor.Spawn("CaelumMapNoteMarker",note.Position,NO_REPLACE));
            if(marker!=null)marker.NoteId=note.Id;
        }
    }
}

// Papel escrito: distingue una nota manual de los iconos de servicios reales.
// Las categorías se leen en la lista; ninguna apariencia promete un servicio.
class CaelumMapNoteMarker : MapMarker
{
    int NoteId;
    transient CaelumPersistentCharacterState CachedRecord;
    transient CaelumMapNote CachedNote;
    transient int CachedSerial;
    override void Tick()
    {
        Super.Tick();bDormant=true;
        let user=CaelumPoiKnowledge.MarkerUser();if(user==null)return;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        if(record!=CachedRecord || (record!=null && record.ManualNotesSerial!=CachedSerial))
        {
            CachedRecord=record;CachedSerial=record==null?0:record.ManualNotesSerial;
            CachedNote=CaelumMapNotes.Find(record,level.MapName,NoteId);
        }
        // Otro personaje puede no tener este ID: ocultar, no retirar su marca.
        // La eliminación explícita retira sólo la proyección del dueño actual.
        let note=CachedNote;if(note==null)return;
        picnum=TexMan.CheckForTexture(CaelumMapNoteData.IconPath(),TexMan.Type_Any);
        Vector2 size=TexMan.GetScaledSize(picnum);if(size.X<=0 || size.Y<=0)return;
        Scale=(CaelumPoiData.ICON_SIZE/size.X,CaelumPoiData.ICON_SIZE/size.Y);
        if(Pos!=note.Position)SetOrigin(note.Position,false);
        bDormant=false;
    }
    Default {+DORMANT}
    States {Spawn: TNT1 A -1; Stop;}
}

class CaelumMapNoteEvents : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_map_notes" || gamestate!=GS_LEVEL || consoleplayer<0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(CaelumMapNotes.Available(user) && Menu.GetCurrentMenu()==null)
            Menu.SetMenu("CaelumMapNoteMenu");
    }
    override void UiTick()
    {
        let current=Menu.GetCurrentMenu();if(current==null)return;
        let notes=CaelumMapNoteMenu(current);
        if(notes==null && TextEnterMenu(current)!=null)notes=CaelumMapNoteMenu(current.mParentMenu);
        if(notes==null)return;
        if(notes.Subject==null)return;
        if(!notes.ValidOwner())
        {if(current!=notes)current.Close();notes.Close();return;}
        // El editor nativo hijo conserva la misma política viva que la lista.
        menuactive=Menu.OnNoPause;
    }
    override void NetworkCommandProcess(NetworkCommand command)
    {
        if(command.Command!='ca_note_apply' || command.Player<0 || command.Player>=MAXPLAYERS)return;
        int operation=command.ReadInt(),expected=command.ReadInt(),id=command.ReadInt(),category=command.ReadInt();
        String mapId=command.ReadString();Vector3 position=command.ReadVector3();String text=command.ReadString();
        if(!command.EndOfStream())return;
        let user=CaelumPlayer(players[command.Player].mo);
        if(user==null)return;
        bool accepted=CaelumMapNotes.Apply(user,operation,expected,mapId,id,category,position,text);
        let record=user.GetPersistentCharacterState(false);
        if(record!=null){record.ManualNoteReplySerial++;record.ManualNoteReplySuccess=accepted;}
    }
}
