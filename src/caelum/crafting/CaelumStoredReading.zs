// #410: el mueble existente conserva su cuerpo. Este componente invisible es
// el unico propietario nativo de los libros y de los demas objetos guardados.
class CaelumStoredReadingProgress : Object play
{
    CaelumLawfulIdentity Reader;
    CaelumRecipeBook Book;
    bool Rereading;
    int TaskSlot;
    double TotalSeconds, RemainingSeconds;
    Array<int> TaskSheets;
}

class CaelumBookcaseStorage : CaelumStashChest
{
    CaelumReadingShelf Shelf;
    Array<CaelumStoredReadingProgress> Readings;
    void SaveReading(CaelumPlayer user,CaelumRecipeSession session)
    {
        if(!session.Active || session.Book==null || session.Book.Owner!=self)return;
        let reader=CaelumLockRules.Character(user,true);
        for(int i=int(Readings.Size())-1;i>=0;i--)
            if(Readings[i].Book==null || Readings[i].Book.Owner!=self
                || (CaelumLockRules.SameTitle(Readings[i].Reader,reader) && Readings[i].Book==session.Book))Readings.Delete(i);
        let progress=new('CaelumStoredReadingProgress');progress.Reader=reader;progress.Book=session.Book;
        progress.Rereading=session.Rereading;progress.TaskSlot=session.TaskSlot;
        progress.TotalSeconds=session.TotalSeconds;progress.RemainingSeconds=session.RemainingSeconds;
        for(int i=0;i<session.TaskSheets.Size();i++)progress.TaskSheets.Push(session.TaskSheets[i]);
        Readings.Push(progress);
    }
    void ResumeReading(CaelumPlayer user,CaelumRecipeSession session)
    {
        let reader=CaelumLockRules.Character(user);
        for(int i=int(Readings.Size())-1;i>=0;i--)
        {
            let progress=Readings[i];
            if(progress.Book==null || progress.Book.Owner!=self){Readings.Delete(i);continue;}
            if(!CaelumLockRules.SameTitle(progress.Reader,reader) || progress.Book!=session.Book)continue;
            session.Rereading=progress.Rereading;session.TaskSlot=progress.TaskSlot;
            session.TotalSeconds=progress.TotalSeconds;session.RemainingSeconds=progress.RemainingSeconds;
            session.TaskSheets.Clear();
            for(int j=0;j<progress.TaskSheets.Size();j++)session.TaskSheets.Push(progress.TaskSheets[j]);
            session.Active=true;session.Anchor=session.StoredDesk;Readings.Delete(i);return;
        }
    }
    override bool CanCarryAsStorage(){return false;}
    override int StorageDisplayType(){return CaelumStoredReadingData.DISPLAY_TYPE;}
    override int StorageSlotLimit(){return CaelumStoredReadingData.SLOTS;}
    override double StorageWeightLimit(){return CaelumStoredReadingData.CAPACITY_KG;}
    override double EmptyStorageWeight(){return 0;}
    override void RefreshChestVisual(){}
    override bool CanReachStorage(CaelumPlayer user)
    {return Shelf!=null && !Shelf.bDestroyed && CaelumPlayerAuthority.CanMutate(user)
        && user.health>0 && !user.CreationWizardOpen && user.Distance3D(Shelf)<=user.UseRange+Shelf.Radius
        && user.CheckSight(Shelf);}
    bool Accessible(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Shelf==null || Shelf.bDestroyed || user.health<=0)return false;
        if(GetChestLockNumber()>0 && !ChestUnlocked && !user.CheckKeys(GetChestLockNumber(),false))return false;
        return InstalledPadlock==null || PadlockReleased || CaelumLockRules.HasAccess(user,InstalledPadlock);
    }
    override void Tick()
    {
        if(Shelf==null || Shelf.bDestroyed){Destroy();return;}
        EnsureStorage();SetOrigin(Shelf.Pos,false);
    }
    Default {Radius 0;Height 0;-SOLID +NOBLOCKMAP +NOGRAVITY +NOINTERACTION RenderStyle "None";}
}

// Reutiliza la mesa pequena propia como escritorio, sin comida, sillas ni
// bonificaciones nuevas. Los datos de colocacion no cambian la geometria.
class CaelumReadingDesk : Actor
{
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        return CaelumUseGeometry.AimedAt(user,self) && CaelumRecipeSession.OpenLibrary(user,self);
    }
    Default
    {
        Radius CaelumStoredReadingData.DESK_RADIUS;
        Height CaelumStoredReadingData.DESK_HEIGHT;
        +SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE +USESPECIAL
        Tag "$CA_READING_DESK";
    }
    States {Spawn:CAHC A -1;Stop;}
}

class CaelumStoredReading : Object play
{
    static bool Adjacent(Actor desk,CaelumReadingShelf shelf)
    {
        return desk!=null && shelf!=null && !desk.bDestroyed && !shelf.bDestroyed
            && (desk is 'CaelumReadingDesk' || desk is 'CaelumDiningTable')
            && desk.Distance3D(shelf)<=CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE
            && desk.CheckSight(shelf,SF_IGNOREVISIBILITY);
    }
    static bool Access(CaelumPlayer user,Actor desk,CaelumBookcaseStorage source)
    {
        return source!=null && !source.bDestroyed && source.Accessible(user)
            && CaelumPropertyRules.ResidenceAllowed(user)
            && CaelumRecipeSession.CanReach(user,desk) && Adjacent(desk,source.Shelf);
    }
    static bool Prepare()
    {
        if(level.MapName!='MAP01')return true;
        // Una consulta tipada durante la instalacion, nunca durante cada lectura.
        if(ThinkerIterator.Create('CaelumReadingDesk').Next()!=null)return true;
        let desk=Actor.Spawn('CaelumReadingDesk',CaelumStoredReadingData.DeskPosition(),NO_REPLACE);
        if(desk==null)return false;
        desk.A_SetSize(CaelumStoredReadingData.DESK_RADIUS,CaelumStoredReadingData.DESK_HEIGHT,false);
        desk.Angle=CaelumReadingFurnitureData.Facing();
        if(!desk.TestMobjLocation() || Abs(desk.FloorZ-desk.Pos.Z)>1 || desk.WaterLevel!=0)
        {desk.Destroy();return false;}
        return true;
    }
}
